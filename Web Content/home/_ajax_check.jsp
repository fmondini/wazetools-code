<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.sql.*"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.code.*"
	import="net.danisoft.wazetools.*"
%><%!
	private static final String WEBLOG_logAcc = "logAcc";
	private static final String CODE_chkTempTable = "CODE_tmpCheck";

	private static final String weblogSchema = "WebLogs";
	private static final String weblogUser = "user=" + AppCfg.getWeblogsUser();
	private static final String weblogPass = "password=" + AppCfg.getWeblogsPass();

	/**
	 * Open WEBLOGS connection
	 */
	private static Connection weblogsConnOpen() throws Exception {

		Connection weblogConn = null;

		try {

			SiteCfg SCFG = new SiteCfg();

			if (!SCFG.getMySQL().isEnabled())
				throw new Exception("MySQL disabled in SiteCfg.json");

			String weblogConnClass = SCFG.getMySQL().getConnClass();
			String weblogHost = SysTool.isWindog() ? SCFG.getMySQL().getDevlHost() : SCFG.getMySQL().getProdHost();
			int weblogPort = SysTool.isWindog() ? SCFG.getMySQL().getDevlPort() : SCFG.getMySQL().getProdPort();
			String connParams = "";

			for (String Param : SCFG.getMySQL().getParams())
				connParams += ("&" + Param);

			Class.forName(weblogConnClass).newInstance();

			weblogConn = DriverManager.getConnection(
				"jdbc:mysql://" + weblogHost + ":" + weblogPort + "/" + weblogSchema + "?" + weblogUser + "&" + weblogPass + connParams
			);

		} catch (Exception e) {

			weblogsConnClose(weblogConn);
			throw new Exception("[_ajax_check.jsp] cnIntranetOpen(): " + e.toString());
		}

		return(weblogConn);
	}

	/**
	 * Close WEBLOGS connection
	 */
	private static void weblogsConnClose(Connection weblogConn) {

		try {
			if (weblogConn != null)
				weblogConn.close();
		} catch (Exception e) {
			System.err.println("[_ajax_check.jsp] cnWeblogsClose(): " + e.toString());
		}
	}
%>
<%
	Database DB = null;
	Connection weblogConn = null;
	MsgTool MSG = new MsgTool(session);

	try {

		if (!CodeRole.userHasRole(session, CodeRole.SITEM))
			throw new Exception("You don't have enough privileges to access this page");

		DB = new Database();
		weblogConn = weblogsConnOpen();

		Statement stChk = DB.getConnection().createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
		Statement stLog = weblogConn.createStatement();

		ResultSet rsLog = null;
		ResultSet rsChk = null;
		
		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// GENERATE TEMP TABLE
		//

		//
		// Create TMP tables
		//

		stChk.executeUpdate("DROP TABLE IF EXISTS " + CODE_chkTempTable);

		stChk.executeUpdate(
			"CREATE TABLE " + CODE_chkTempTable + " (" +
				"SCR_ID varchar(255) NOT NULL DEFAULT '', " +
				"SCR_Count int NOT NULL DEFAULT '0', " +
				"PRIMARY KEY (SCR_ID), " +
				"KEY IX_Count (SCR_Count)" +
			") ENGINE=InnoDB;"
		);

		//
		// Get Log Lines
		//

		String ScriptID;
		String startDate = FmtTool.fmtDateSqlStyle(FmtTool.addDays(new java.util.Date(), -7)).concat(" 00:00:00");

		rsLog = stLog.executeQuery(
			"SELECT DISTINCT ACC_Parameters " +
			"FROM " + WEBLOG_logAcc + " " +
			"WHERE (" +
				"ACC_Site = 'code.waze.tools' AND " +
				"ACC_RequestDate >= '" + startDate + "' AND " +
				"ACC_RetCode = 404 AND " +
				"ACC_Parameters LIKE '/repository/%.user.js %'" +
			");"
		);

		while (rsLog.next()) {

			ScriptID = rsLog.getString("ACC_Parameters")
				.replace("/repository/", "")
				.split(" ")[0]
				.replace(".user.js", "")
			;

			stChk.executeUpdate("INSERT INTO " + CODE_chkTempTable + " (SCR_ID) VALUES ('" + ScriptID + "');");
		}

		rsLog.close();

		//
		// Get Last Update
		//

		String LastUpdate = "ERROR";

		rsLog = stLog.executeQuery(
			"SELECT MAX(ACC_RequestDate) AS LastUpd " +
			"FROM " + WEBLOG_logAcc + " " +
			"WHERE (" +
				"ACC_Site = 'code.waze.tools' AND " +
				"ACC_RequestDate >= '" + startDate + "' AND " +
				"ACC_RetCode = 404 AND " +
				"ACC_Parameters LIKE '/repository/%.user.js %'" +
			");"
		);

		if (rsLog.next())
			LastUpdate = FmtTool.fmtDate(rsLog.getDate("LastUpd")) + " " + FmtTool.fmtTime(rsLog.getTime("LastUpd"));

		rsLog.close();

		//
		// Fill Temp Vector
		//

		Vector<String> vecScripts = new Vector<>();

		rsChk = stChk.executeQuery("SELECT * FROM " + CODE_chkTempTable + " ORDER BY SCR_ID;");

		while (rsChk.next())
			vecScripts.add(rsChk.getString("SCR_ID"));

		rsChk.close();

		//
		// Count rows occurrences
		//
		
		Vector<String> vecCount = new Vector<>();

		for (int i=0; i<vecScripts.size(); i++) {

			rsLog = stLog.executeQuery(
				"SELECT COUNT(*) AS RecNo " +
				"FROM " + WEBLOG_logAcc + " " +
				"WHERE (" +
					"ACC_Site = 'code.waze.tools' AND " +
					"ACC_RequestDate >= '" + startDate + "' AND " +
					"ACC_RetCode = 404 AND " +
					"ACC_Parameters LIKE '%" + vecScripts.get(i) + ".user.js%'" +
				");"
			);

			rsLog.next();
			vecCount.add(vecScripts.get(i) + SysTool.getDelimiter() + rsLog.getString("RecNo"));

			rsLog.close();
		}

		stLog.close();

		weblogsConnClose(weblogConn);

		//
		// Update counter
		//

		int ScrNo;
		String ScrID;

		for (int i=0; i<vecCount.size(); i++) {

			ScrID = vecCount.get(i).split(SysTool.getDelimiter())[0];
			ScrNo = Integer.parseInt(vecCount.get(i).split(SysTool.getDelimiter())[1]);

			stChk.executeUpdate(
				"UPDATE " + CODE_chkTempTable + " " +
				"SET SCR_Count = " + ScrNo + " " +
				"WHERE SCR_ID = '" + ScrID + "';"
			);
		}

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// SHOW RESULTS
		//
		
		SiteCfg SCFG = new SiteCfg();

		String weblogHost = SysTool.isWindog() ? SCFG.getMySQL().getDevlHost() : SCFG.getMySQL().getProdHost();
		int weblogPort = SysTool.isWindog() ? SCFG.getMySQL().getDevlPort() : SCFG.getMySQL().getProdPort();
%>
		<table class="TableSpacing_0px">

		<tr class="DS-back-gray DS-border-full">
			<td class="DS-padding-4px" ColSpan="2">
				<div class="DS-text-extra-large" align="center">Check Results - Errors since <%= FmtTool.fmtDate(FmtTool.scnDateSqlStyle(startDate)) %></div>
				<div class="DS-text-compact DS-text-italic" align="center">Real-time data taken from <%= weblogHost %>:<%= weblogPort %> table <%= weblogSchema %>.<%= WEBLOG_logAcc %></div>
			</td>
		</tr>
		<tr class="DS-back-lightgray DS-text-large DS-text-bold DS-text-italic DS-border-full">
			<td class="DS-padding-4px">Script ID</td>
			<td class="DS-padding-4px" align="right">Errors 404 count</td>
		</tr>
<%
		rsChk = stChk.executeQuery("SELECT * FROM " + CODE_chkTempTable + " ORDER BY SCR_ID;");

		while (rsChk.next()) {

			ScrID = rsChk.getString("SCR_ID");
			ScrNo = rsChk.getInt("SCR_Count");
%>
			<tr class="DS-border-full DS-text-fixed-compact">
				<td class="DS-padding-4px"><%= ScrID %></td>
				<td class="DS-padding-4px" align="right"><%= ScrNo %> times</td>
			</tr>
<%
		}
		
		rsChk.close();
%>
		<tr class="DS-back-lightgray DS-text-large DS-text-italic DS-border-full">
			<td class="DS-padding-4px" ColSpan="2" align="center">Last Update: <%= LastUpdate %></td>
		</tr>
		</table>
<%
		stChk.executeUpdate("DROP TABLE IF EXISTS " + CODE_chkTempTable);

		stChk.close();

	} catch (Exception e) {

		System.err.println(e.toString());
		MSG.setSlideText("Servlet Error", e.toString());
%>
		<script>
			window.location.href='../home/';
		</script>
<%
	}

	if (DB != null)
		DB.destroy();
%>
