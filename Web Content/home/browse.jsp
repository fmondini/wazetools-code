<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="org.json.*"
	import="java.io.*"
	import="java.util.*"
	import="java.nio.file.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.code.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.code.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName() + " Browser";
	private static final String PAGE_Keywords = "Waze.Tools Code, Waze, Tools, Code, Script, Repository";
	private static final String PAGE_Description = AppCfg.getAppAbstract();

	private static final String LAST_CHECKED_DATE_FILE = AppCfg.getServerRootPath() + "/LastCheckedFile.json";

	private static String getLastCheckUser() {

		String Result = "<span class=\"DS-text-disabled\">[No Last Check User Set]</span>";

		try {
			Result = "Last Checked by " + new JSONObject(
				new String(
					Files.readAllBytes(
						Paths.get(LAST_CHECKED_DATE_FILE)
					)
				)
			).getString("user");
		} catch (Exception e) { }

		return(Result);
	}

	private static String getLastCheckDate() {

		String Result = "No Date/Time Set";

		try {
			Result = new JSONObject(
				new String(
					Files.readAllBytes(
						Paths.get(LAST_CHECKED_DATE_FILE)
					)
				)
			).getString("date");
		} catch (Exception e) { }

		return(Result);
	}
%>
<!DOCTYPE html>
<html>
<head>

	<jsp:include page="../_common/head.jsp">
		<jsp:param name="PAGE_Title" value="<%= PAGE_Title %>"/>
		<jsp:param name="PAGE_Keywords" value="<%= PAGE_Keywords %>"/>
		<jsp:param name="PAGE_Description" value="<%= PAGE_Description %>"/>
	</jsp:include>

	<script>

		/**
		 * Details PopUp
		 */
		function DLG_ShowDetails(ScrID) {

			$.ajax({

				type: 'GET',
				dataType: 'text',
				url: '_dlg_showdetails.jsp',
				data: { scr: ScrID },

				beforeSend: function() {
					// _Show_PopUp_Wait();
				},

				success: function(data) {
					ShowDialog_AJAX(data);
				},

				error: function(jqXHR, textStatus, errorThrown) {
					console.log('Error ' + jqXHR.status + ' - %o', jqXHR);
					ShowDialog_AJAX(jqXHR.responseText);
				}
			});
		}

		/**
		 * Update script data
		 */
		function DLG_UpdateDetails(ScrID) {

			$.ajax({

				type: 'GET',
				dataType: 'text',
				url: '_dlg_scr_update.jsp',
				data: { scr: ScrID },

				beforeSend: function() {
					// _Show_PopUp_Wait();
				},

				success: function(data) {
					ShowDialog_AJAX(data);
				},

				error: function(jqXHR, textStatus, errorThrown) {
					console.log('Error ' + jqXHR.status + ' - %o', jqXHR);
					ShowDialog_AJAX(jqXHR.responseText);
				}
			});
		}

		/**
		 * Download script
		 */
		function actionDownload(ScrID) {

			$.ajax({

				type: 'GET',
				url: '?Action=increment&scr=' + ScrID,
				data: { scr: ScrID },

				success: function(data, textStatus, jqXHR) {
					window.location.href='<%= Script.getScriptBaseUrl() %>/' + ScrID + '<%= Script.getScriptExtn() %>';
				}
			});
		}

		/**
		 * Delete script record from DB
		 */
		function actionDelete(ScrID) {

			ShowDialog_YesNo(
				'Delete This Script',
				'This action will <b class="DS-text-exception">delete</b> this script data and repository files from the database. Are you sure?',
				'Yes, delete it', '?Action=delete&scr=' + ScrID,
				'No, keep it', ''
			);
		}

		/**
		 * Clean script file
		 */
		function actionClean(ScrID) {

			ShowDialog_YesNo(
				'Clean the Attached File',
				'This action will <b>clean up</b> the attachment by <b class="DS-text-exception">deleting</b> the current script file and preparing the repository for a <b class="DS-text-green">new upload</b> (if necessary). Are you sure?',
				'Yes, update it', '?Action=remove&scr=' + ScrID,
				'No, keep it', ''
			);
		}

	</script>

	<script>
	</script>

	<style type="text/css">
		.ui-state-default { color: black !important; font-size: 125% !important; font-weight: bold !important; background-color: #e0e0e0; background-image: none; }
		.ui-accordion-header-collapsed { color: black !important; font-size: 125% !important; font-weight: normal !important; background-color: #f7f7f7; }
	</style>

</head>

<body>

	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">
	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">

	<div class="DS-card-body">
		<div class="mdc-layout-grid__inner">
			<div class="<%= MdcTool.Layout.Cell(8, 6, 3) %> DS-grid-middle-left">
				<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
			</div>
			<div class="<%= MdcTool.Layout.Cell(4, 2, 1) %> DS-grid-middle-right">
				<div class="DS-text-compact DS-text-italic" align="center">
					<div><%= getLastCheckUser() %></div>
					<div class="DS-text-bold"><%= getLastCheckDate() %></div>
					<% if (CodeRole.userHasRole(session, CodeRole.SITEM)) { %>
					<div><a href="?Action=UpdChkDate">Update Last Checked Date to NOW</a></div>
					<% } %>
				</div>
			</div>
		</div>
	</div>

	<div class="DS-card-body">
	<div id="acc-list" style="display:none">
<%
	String RedirectTo = "";

	Database DB = new Database();
	Category CAT = new Category(DB.getConnection());
	Script SCR = new Script(DB.getConnection());
	LogTool LOG = new LogTool(DB.getConnection());
	MsgTool MSG = new MsgTool(session);

	String Action = EnvTool.getStr(request, "Action", "");
	String ExpSID = EnvTool.getStr(request, "ExpSID", "");
	String ShowSID = EnvTool.getStr(request, "ShowSID", "");
	String ForceSID = EnvTool.getStr(request, "ForceSID", ""); // Force editing of this ScriptID

	if (!ShowSID.equals(""))
		ExpSID = ShowSID; // Force category open

	if (Action.equals("")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// BROWSE
		//

		int ExpCAT = 0;
		boolean NoScriptsFound = true;

		try {

			Vector<Category.Data> vecCatData = CAT.getAll(CodeRole.getUserRoleValue(session));

			for (Category.Data catData : vecCatData) {

				if (catData.getScrCount() > 0) {
%>
					<div id="CAT_<%= catData.getID() %>" class="accSection">
						<table class="TableSpacing_0px DS-full-width">
							<tr>
								<td class="DS-padding-0px">
									<span class="DS-text-italic"><%= catData.getDescr() %></span>
									<span class="DS-text-small DS-text-italic DS-text-gray">(<%= catData.getScrCount() %>)</span>
								</td>
								<td class="DS-padding-0px DS-text-italic DS-text-gray" align="right">
									<div class="DS-text-small DS-text-italic DS-text-gray" title="Category ID"><%= FmtTool.fmtZeroPad(catData.getID(), 3) %></div>
								</td>
							</tr>
						</table>
					</div>

					<div>

					<table class="TableSpacing_0px DS-full-width">
					<tr class="DS-back-gray DS-border-full">
						<td class="DS-padding-lfrg-4px DS-border-updn DS-border-rg" ColSpan="2" align="left" nowrap>LifeCycle / Title / Author</td>
						<td class="DS-padding-lfrg-4px DS-border-updn DS-border-rg" ColSpan="3" align="center" nowrap>Version</td>
						<td class="DS-padding-lfrg-4px DS-border-updn DS-border-rg" align="center" nowrap>Last Update</td>
						<td class="DS-padding-lfrg-4px DS-border-updn DS-border-rg" align="center" nowrap>Script Age</td>
						<td class="DS-padding-lfrg-4px DS-border-updn" align="center" colspan="2" nowrap>Downloads</td>
					</tr>
<%
					String ScriptAuthors = "";
					Vector<Script.Data> vecScrData = SCR.getAll(catData.getID());

					for (Script.Data scrData : vecScrData) {

						Date LastUpdate = FilTool.getLastModified(Script.getScriptBasePath() + "/" + scrData.getID() + Script.getScriptExtn());

						ScriptAuthors = scrData.getAuthor().equals("") ? "" : "by " + scrData.getAuthor();

						if (ScriptAuthors.length() > 45)
							ScriptAuthors = ScriptAuthors.substring(0, 45).concat(" ... [&amp; others]");
%>
						<tr class="DS-border-full">
							<td class="DS-padding-lfrg-4px DS-padding-top-4px" width="16">
								<%= scrData.getLifeCycle().getIconSpan() %>
							</td>
							<td class="DS-padding-lfrg-4px DS-border-rg">
								<div onClick="DLG_ShowDetails('<%= scrData.getID() %>');" style="cursor: pointer">
									<table class="TableSpacing_0px" style="width:100%">
										<tr>
											<td align="left"><%= scrData.getTitle() %></td>
											<td align="right" class="DS-text-small DS-text-italic DS-text-gray"><%= ScriptAuthors %></td>
										</tr>
									</table>
								</div>
							</td>
							<td class="DS-padding-lfrg-4px DS-padding-top-5px" align="left">
								<% if (scrData.CanManageScript(request, SysTool.getCurrentUser(request))) { %>
									<i class="material-icons DS-text-green" style="font-size:18px;" title="Script Management Active">edit_note</i>
								<% } %>
							</td>
							<td class="DS-padding-lfrg-4px" style="padding-right:0px" align="right"><%= scrData.getMajor() %>.<%= scrData.getMinor() %>.<%= scrData.getBuild() %></td>
							<td class="DS-padding-lfrg-4px DS-text-gray DS-border-rg" style="padding-left:0px" align="left"><%= "." + scrData.getLifeCycle().getCycle() %></td>

							<td class="DS-padding-lfrg-4px DS-border-rg DS-text-fixed-compact" align="center" nowrap><%= LastUpdate.equals(FmtTool.DATEZERO)
								? "<span class=\"DS-text-disabled\">" + FmtTool.fmtDateTime(scrData.getLastUpd()) + "</span>"
								: FmtTool.fmtDateTime(LastUpdate)
							%></td>

							<td class="DS-padding-lfrg-4px DS-text-fixed-compact DS-border-rg" align="center" nowrap><%= LastUpdate.equals(FmtTool.DATEZERO) ? "<span class=\"DS-text-disabled\">N/A</span>" : FmtTool.DaysBetween(LastUpdate, new Date(), " days") %></td>
							<td class="DS-padding-lfrg-4px DS-text-fixed-compact" align="right" nowrap><%= SCR.fileExists(scrData.getID()) ? FmtTool.fmtNumber0dIT(scrData.getDownloads()) : "<span class=\"DS-text-disabled\">N/A</span>" %></td>
							<td class="DS-padding-lfrg-4px DS-padding-top-5px" align="left"><i
								class="material-icons DS-text-<%= SCR.fileExists(scrData.getID()) ? "green" : "exception" %>"
								style="font-size:16px;"
								title="<%= SCR.fileExists(scrData.getID()) ? "Attached file: " + scrData.getID() + Script.getScriptExtn() : "This entry has no attached script" %>"
							><%= SCR.fileExists(scrData.getID()) ? "event_available" : "block" %></i></td>
						</tr>
<%
						if (scrData.getID().equals(ExpSID))
							ExpCAT = scrData.getCategory();

						NoScriptsFound = false;
					}
%>
					</table>
					</div>
<%
				} // if (catObject.getScrCount() > 0)

			} // for (CatObject catObject : vecCatObj)

			if (NoScriptsFound)
				throw new Exception("No valid categories found.<br>Please ask an administrator to update your privileges in your " + AppCfg.getAppName() + " profile");

			//
			// SYSOP AND SITE MANAGER ONLY, Check orphan scripts (js in repository but NO entry in script table)
			//

			if ((SysTool.isUserLoggedIn(request) && (CodeRole.userHasRole(session, CodeRole.SYSOP) || CodeRole.userHasRole(session, CodeRole.SITEM)))) {
%>
				<div class="DS-margin-up-16px DS-back-pastel-red DS-padding-16px DS-border-full" align="center">
					<div class="DS-text-title">Orphan Scripts Check</div>
					<div class="DS-text-stdsize DS-text-italic DS-text-exception">(for SysOp and Site Manager Only)</div>
				</div>
<%
				//
				// Script without DB entry
				//

				int scriptsCount = 0;
				File folder = new File(Script.getScriptBasePath());
				List<String> scriptArray = new ArrayList<>();

				for (File f : folder.listFiles()) {
		            if (f.isFile()) {
		                if (f.getName().matches(".*\\.js")) {
		                	if (!SCR.Exists(f.getName().replace(Script.getScriptExtn(), "")))
		                		scriptArray.add(f.getName());
		                	scriptsCount++;
		                }
		            }
				}
%>
				<div class="DS-card-head DS-back-white">
					<div class="DS-text-subtitle">Script files without database entry</div>
				</div>

				<div class="DS-card-foot DS-border-dn">
					<div>
						<% if (scriptArray.size() > 0) { %>
							<% for (String scriptEntry : scriptArray) { %>
								<div class="DS-text-fixed-compact">
									Javascript file found but no DB script entry:
									<a href="<%= Script.getScriptBaseUrl() + "/" + scriptEntry %>"><b><%= scriptEntry %></b></a>
								</div>
							<% } %>
						<% } else { %>
							<div class="DS-text-green"><b>[ALL OK]</b> All <%= scriptsCount %> script(s) on this server have its own database entry</div><br>
						<% } %>
					</div>
				</div>
<%
				//
				// DB entry without script
				//

				boolean scrFound;
				List<String> scrAllFiles = new ArrayList<>();
				Vector<Script.Data> vecScrData = SCR.getAll();
				Vector<Script.Data> vecScrDataOrphans = new Vector<Script.Data>();

				for (File f : folder.listFiles()) {
		            if (f.isFile()) {
		                if (f.getName().matches(".*\\.js")) {
		                	scrAllFiles.add(f.getName());
		                }
		            }
				}

				for (Script.Data scrData : vecScrData) {

					scrFound = false;

					for (String scrName : scrAllFiles) {
						if (scrData.getID().equals(scrName.split("\\.")[0])) {
							scrFound = true;
							break;
						}
					}

					if (!scrFound) {
						if (!scrData.getTitle().startsWith("Example Script"))
							vecScrDataOrphans.add(scrData);
					}
				}
%>
				<div class="DS-card-head DS-back-white">
					<div class="DS-text-subtitle">Database entries without script file</div>
				</div>

				<div class="DS-card-body DS-border-dn">
					<div>
						<% if (vecScrDataOrphans.size() > 0) { %>
							<% for (Script.Data scrDataOrphan : vecScrDataOrphans) { %>
								<div class="DS-text-fixed-compact">
									DB script entry found but no javascript file:
									<a href="<%= "?ShowSID=" + scrDataOrphan.getID() %>"><b><%= scrDataOrphan.getTitle() %></b></a>
								</div>
							<% } %>
						<% } else { %>
							<div class="DS-text-green"><b>[ALL OK]</b> All <%= vecScrData.size() %> database entries have its own script file</div><br>
						<% } %>
					</div>
				</div>
<%
			}

		} catch (Exception e) {

			MSG.setAlertText("Read Error", "<b>Error reading script list</b><br>" + e.toString());
			RedirectTo = "../home/";
		}
%>
	<script>

		/**
		 * Create Script List
		 */
		$(function() {
			$('#acc-list').accordion({
				icons: false,
				header: '.accSection',
				heightStyle: 'content'
			});
		});

		/**
		 * Show Script List and open selected
		 */
		$(document).ready(
			function() {
				$('#acc-list').show();
				$('#CAT_<%= ExpCAT %>').click(); 
				<% if (!ForceSID.equals("")) { %>
					DLG_UpdateDetails('<%= ForceSID %>');
				<% } %>
			}
		);

		<% if (!ShowSID.equals("")) { %>
			/**
			 * Open selected details
			 */
			$(window).on('load', function() {
				DLG_ShowDetails('<%= ShowSID %>');
			});
		<% } %>

	</script>
<%
	} else if (Action.equals("increment")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// INCREMENT DOWNLOAD COUNTER
		//

		String ScrID = EnvTool.getStr(request, "scr", "");

		try {

			SCR.incCounter(ScrID);

			LOG.Info(request, LogTool.Category.DWNL, "Script downloaded: " + ScrID);

		} catch (Exception e) {

			LOG.Error(request, LogTool.Category.DWNL, e.toString() + " - ScrID: " + ScrID);
		}

		RedirectTo = "?ExpSID=" + ScrID;

	} else if (Action.equals("create")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// CREATE SCRIPT
		//

		try {

			String newUuid = SCR.CreateEmpty(SysTool.getCurrentUser(request));
			RedirectTo = "?ForceSID=" + newUuid;

		} catch (Exception e) {

			MSG.setAlertText("Create Error", "<b>Error creating script</b><br>" + e.toString());
			LOG.Error(request, LogTool.Category.SCRM, e.toString());
			RedirectTo = "?";
		}

	} else if (Action.equals("remove")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// REMOVE SCRIPT
		//

		String ScrID = EnvTool.getStr(request, "scr", "");

		try {

			if (!new File(Script.getScriptBasePath() + "/" + ScrID + Script.getScriptExtn()).delete())
				MSG.setAlertText("Remove Error", "<b>Error removing script " + ScrID + "</b> - File not found");
			else
				MSG.setSnackText("Script removed");

			RedirectTo = "?ForceSID=" + ScrID;

		} catch (Exception e) {

			MSG.setAlertText("Remove Error", "<b>Error removing script</b><br>" + e.toString());
			RedirectTo = "?";
		}

	} else if (Action.equals("delete")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// DELETE SCRIPT
		//

		String ScrID = EnvTool.getStr(request, "scr", "");

		try {

			new File(Script.getScriptBasePath() + "/" + ScrID + Script.getScriptExtn()).delete();

			SCR.Delete(ScrID);

			MSG.setSnackText("Script deleted from database");

		} catch (Exception e) {

			MSG.setAlertText("Delete Error", "<b>Error deleting script</b><br>" + e.toString());
		}

		RedirectTo = "?";

	} else if (Action.equals("UpdChkDate")) {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// UPDATE LAST CHECK DATE/TIME
		//

		JSONObject jLastChk = new JSONObject();
		String LastChkUser = SysTool.getCurrentUser(request);
		String LastChkDate = FmtTool.fmtDateDayName().concat(", ").concat(FmtTool.fmtDateTime());

		jLastChk.put("user", LastChkUser);
		jLastChk.put("date", LastChkDate);

		PrintWriter jsonFile = new PrintWriter(new FileWriter(LAST_CHECKED_DATE_FILE, false));
		jsonFile.println(jLastChk.toString());
		jsonFile.flush();
		jsonFile.close();
		
		MSG.setSnackText("Last Check Date set to " + LastChkDate);
		RedirectTo = "?";

	} else {

		////////////////////////////////////////////////////////////////////////////////////////////////////
		//
		// UNKNOWN
		//

		MSG.setAlertText("Internal Error", "Unknown Action: '" + Action + "'");
		RedirectTo = "../home/";
	}

	DB.destroy();
%>
	</div> <!-- /acc-list -->
	</div> <!-- /DS-card-body -->

	<div class="DS-card-foot">
		<table class="TableSpacing_0px" style="width:100%">
			<tr>
				<td class="CellPadding_0px" align="left"><%= MdcTool.Button.BackTextIcon("Back", "../home/") %></td>
				<% if (SysTool.isUserLoggedIn(request)) { %>
				<td class="CellPadding_0px" align="right">
					<%= MdcTool.Button.TextIconClass(
						"add_circle",
						"&nbsp;Add Script",
						null,
						"DS-text-lime",
						null,
						"onClick=\"window.location.href='?Action=create'\"",
						"Add a new script"
					) %>
				</td>
				<% } %>
			</tr>
		</table>
	</div>

	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>

</body>
</html>
