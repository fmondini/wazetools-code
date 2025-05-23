<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wtlib.code.*"
	import="net.danisoft.wazetools.*"
	import="net.danisoft.wazetools.code.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName() + " Categories Management";
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

	<div class="DS-card-body">
		<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
	</div>
<%
	Database DB = new Database();
	Category CAT = new Category(DB.getConnection());
	LogTool LOG = new LogTool(DB.getConnection());
	MsgTool MSG = new MsgTool(session);

	String RedirectTo = "";
	String Action = EnvTool.getStr(request, "Action", "");

	try {

		if (!(SysTool.isUserLoggedIn(request) && CodeRole.userHasRole(session, CodeRole.SYSOP)))
			throw new Exception("You don't have enough privileges to access this page");

		if (Action.equals("")) {

			////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			// CATEGORIES LIST
			//
%>
			<div class="DS-card-body">

			<table class="TableSpacing_0px DS-full-width">

			<tr class="DS-back-gray">
				<td class="CellPadding_3px DS-border-updn DS-border-rg" align="center">ID</td>
				<td class="CellPadding_3px DS-border-updn DS-border-rg">Description</td>
				<td class="CellPadding_3px DS-border-updn">Required UserRole</td>
			</tr>
<%
			Vector<Category.Data> vecCatData = CAT.getAll();

			try {

				for (Category.Data catData : vecCatData) {
%>
					<tr>
						<td class="CellPadding_3px DS-border-dn DS-border-rg" align="center"><%= FmtTool.fmtZeroPad(catData.getID(), 3) %></td>
						<td class="CellPadding_3px DS-border-dn DS-border-rg"><a href="?Action=edt&cat=<%= catData.getID() %>"><%= catData.getDescr() %></a></td>
						<td class="CellPadding_3px DS-border-dn"><%= CodeRole.getDescr(catData.getRole(), true) %></td>
					</tr>
<%
				}

			} catch (Exception e) {
%>
				<tr>
					<td class="TableCell DS-text-exception" colspan="3"><%= e.toString() %></td>
				</tr>
<%
			}
%>
			</table>
			</div>

			<div class="DS-card-foot">
				<%= MdcTool.Button.BackTextIcon("Back", "../home/") %>
			</div>
<%
		} else if (Action.equals("edt")) {
		
			////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			// EDIT CATEGORY
			//

			Category.Data catData = CAT.Read(EnvTool.getInt(request, "cat", 0));
%>
			<form style="margin: 0px">
			<input type="hidden" name="Action" value="upd">
			<input type="hidden" name="cat" value="<%= catData.getID() %>">

			<div class="DS-card-body">
				<div class="DS-text-subtitle">Editing Category "<%= catData.getID() %>" - <%= catData.getDescr() %></div>
			</div>

			<div class="DS-card-body">
				<table class="TableSpacing_0px DS-full-width">
					<tr>
						<td class="CellPadding_3px DS-border-updn DS-border-rg DS-back-gray" width="150">Category ID</td>
						<td class="CellPadding_3px DS-border-updn"><input class="DS-input-textbox" type="text" name="newId" size="7" maxlength="7" value="<%= catData.getID() %>"></td>
					</tr>
					<tr>
						<td class="CellPadding_3px DS-border-dn DS-border-rg DS-back-gray">Description</td>
						<td class="CellPadding_3px DS-border-dn"><input class="DS-input-textbox" type="text" name="txtDesc" value="<%= catData.getDescr() %>" style="width: 100%"></td>
					</tr>
					<tr>
						<td class="CellPadding_3px DS-border-dn DS-border-rg DS-back-gray" valign="top">Required UserRole</td>
						<td class="CellPadding_3px DS-border-dn DS-border-rg">
							<% for (CodeRole X : CodeRole.values()) { %>
								<input id="opt_<%= X.toString() %>" name="optUR" value="<%= X.getValue() %>" <%= (catData.getRole() & X.getValue()) == X.getValue() ? "checked" : "" %> type="radio">
								<label for="opt_<%= X.toString() %>"><%= X.getDescr() %></label><br>
							<% } %>
						</td>
					</tr>
				</table>
			</div>

			<div class="DS-card-foot">
				<table class="TableSpacing_0px" style="width:100%">
					<tr>
						<td>
							<%= MdcTool.Button.BackTextIcon("Back", "?") %>
						</td>
						<td align="right">
							<%= MdcTool.Button.SubmitTextIconClass(
								"save",
								"&nbsp;Save",
								null,
								"DS-text-lime",
								null,
								null
							) %>
						</td>
					</tr>
				</table>
			</div>

			</form>
<%
		} else if (Action.equals("upd")) {
		
			////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			// UPDATE CATEGORY
			//

			int CatID = EnvTool.getInt(request, "cat", 0);
			int optUR = EnvTool.getInt(request, "optUR", 0);
			int newId = EnvTool.getInt(request, "newId", 0);
			String txtDesc = EnvTool.getStr(request, "txtDesc", "");

			try {

				if (txtDesc.equals(""))
					throw new Exception("Update denied: Description field needed.");

				// Update

				Category.Data catData = CAT.Read(CatID);

				catData.setID(newId);
				catData.setRole(optUR);
				catData.setDescr(txtDesc);

				CAT.Update(CatID, catData);

				MSG.setSnackText("Category data updated");

				RedirectTo = "?";

			} catch (java.sql.SQLIntegrityConstraintViolationException e) {

				MSG.setAlertText("Error Updating Category", "Sorry, this category has some scripts associated with it and therefore, to prevent link breaks, the ID cannot be modified.<br>In order to modify the ID of this category remove all associated scripts and retry.");
				RedirectTo = "?Action=edt&cat=" + CatID;

			} catch (Exception e) {

				MSG.setAlertText("Error Updating Category", e.toString());
				RedirectTo = "?Action=edt&cat=" + CatID;
			}

		} else {

			////////////////////////////////////////////////////////////////////////////////////////////////////
			//
			// BAD ACTION
			//

			throw new Exception("Bad Action: '" + Action + "'");
		}

	} catch (Exception e) {

		LOG.Error(request, LogTool.Category.SCRM, e.toString());
		MSG.setAlertText("Internal Error", e.getMessage());
		RedirectTo = "../home/";
	}

	DB.destroy();
%>
	</div>
	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value="<%= RedirectTo %>" />
	</jsp:include>

</body>
</html>
