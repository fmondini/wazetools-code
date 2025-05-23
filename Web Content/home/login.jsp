<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.net.*"
	import="java.sql.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.auth.*"
	import="net.danisoft.wtlib.code.*"
%>
<%
	request.setCharacterEncoding("UTF-8");

	response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
	response.setHeader("Pragma", "no-cache"); // HTTP 1.0
	response.setDateHeader("Expires", 0); // Proxies

	Database DB = null;
	MsgTool MSG = new MsgTool(session);
	String RedirectTo = "../home/browse.jsp";

	try {

		DB = new Database();
		User USR = new User(DB.getConnection());

		User.Data usrData = USR.Read(SysTool.getCurrentUser(request));

		CodeRole.setUserRoleValue(session, usrData.getWazerConfig().getCode().getRole());
		MSG.setSnackText("You have successfully logged in as " + SysTool.getCurrentUser(request));
		RedirectTo = "../home/browse.jsp";

	} catch (Exception e) {
		
		CodeRole.setUserRoleValue(session, 0);
		MSG.setSnackText(e.getMessage());
		RedirectTo = "../_common/auth_logout.jsp?msg=" + URLEncoder.encode(e.getMessage(), "UTF-8");
	}

	if (DB != null)
		DB.destroy();

	response.sendRedirect(RedirectTo);
%>
