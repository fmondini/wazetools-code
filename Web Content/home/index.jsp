<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.code.*"
	import="net.danisoft.wazetools.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName() + " Home";
	private static final String PAGE_Keywords = "Waze.Tools Code, Waze, Tools, Code, Script, Repository";
	private static final String PAGE_Description = AppCfg.getAppAbstract();
%>
<!DOCTYPE html>
<html>

<head>
	<jsp:include page="../_common/head.jsp">
		<jsp:param name="PAGE_Title" value="<%= PAGE_Title %>"/>
		<jsp:param name="PAGE_Keywords" value="<%= PAGE_Keywords %>"/>
		<jsp:param name="PAGE_Description" value="<%= PAGE_Description %>"/>
	</jsp:include>
</head>

<body>

	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">
	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">

		<div class="DS-card-head">
			<div class="mdc-layout-grid__inner">
				<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %> DS-padding-bottom-16px DS-border-rg">
					<%= MdcTool.Layout.IconCard(
						true,	// isEnabled
						"",		// Div Class		
						"browse",
						"../home/browse.jsp",
						"Browse",
						"Browse the repository",
						"Browse the repository and download<br>all the scripts you need",
						true,
						true
					) %>
				</div>
				<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %> DS-padding-bottom-16px DS-border-rg">
					<%= MdcTool.Layout.IconCard(
						!SysTool.isUserLoggedIn(request),	// isEnabled
						"",									// Div Class		
						"passkey",
						"../home/login.jsp",
						"LogIn",
						"Authentication",
						"Authenticate yourself to gain<br>access to management functions",
						true,
						true
					) %>
				</div>
				<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %> DS-padding-bottom-16px DS-border-rg">
					<%= MdcTool.Layout.IconCard(
						CodeRole.userHasRole(session, CodeRole.SITEM),	// isEnabled
						"",											// Div Class		
						"data_check",
						"../home/checklist.jsp",
						"Check List",
						"Scripts Check List",
						"Check Scripts Sepository<br>(additional privileges required)",
						true,
						true
					) %>
				</div>
				<div class="<%= MdcTool.Layout.Cell(3, 2, 4) %> DS-padding-bottom-16px">
					<%= MdcTool.Layout.IconCard(
						CodeRole.userHasRole(session, CodeRole.SYSOP),	// isEnabled
						"",											// Div Class		
						"category",
						"../home/categories.jsp",
						"Categories",
						"Manage Categories",
						"Script categories management<br>(additional privileges required)",
						true,
						true
					) %>
				</div>
			</div>		
		</div>

		<div class="DS-card-foot">
			<%= MdcTool.Button.BackTextIcon("Exit", AppCfg.getAppExitLink()) %>
		</div>
<%
	//
	// Check for Error Messages (if any)
	//

	String RedirectTo = "", msg = EnvTool.getStr(request, "msg", "");

	if (!msg.equals("")) {
		new MsgTool(session).setAlertText("Internal Error", msg);
		RedirectTo = "../home/";
	}
%>
	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>

</body>
</html>
