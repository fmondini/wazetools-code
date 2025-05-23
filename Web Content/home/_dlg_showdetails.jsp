<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="java.util.*"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.code.*"
%>
<!DOCTYPE html>
<html>
<body>
<%
	Database DB = new Database();
	Script SCR = new Script(DB.getConnection());

	String ScrID = EnvTool.getStr(request, "scr", "");

	try {

		Script.Data scrData = SCR.Read(ScrID);
//		SCR.Read(ScrID);
%>
		<div class="DS-padding-8px DS-back-darkgray DS-border-dn">
			<div class="DS-text-huge DS-text-bold"><%= scrData.getTitle() %></div>
		</div>
<%
		//
		// Description
		//
%>
		<div class="DS-padding-8px DS-border-dn">
			<div class="DS-text-italic DS-text-compact DS-text-gray">Description</div>
			<div class="DS-text-black">
			<% if (scrData.getDescr().trim().equals("")) { %>
				<div class="DS-text-italic">Sorry, no description found.</div>
			<% } else { %>
				<div class="DS-text-black"><%= scrData.getDescr().replaceAll("\n", "<br>") %></div>
			<% } %>
			</div>
		</div>
<%
		//
		// Home page
		//
%>
		<div class="DS-padding-8px DS-border-dn" align="left">
			<div class="DS-text-italic DS-text-compact DS-text-gray">Home Page</div>
			<% if (scrData.getHomePage().trim().equals("")) { %>
				<div class="DS-text-italic">Sorry, no homepage found.</div>
			<% } else if (scrData.getHomePage().startsWith("http://") | scrData.getHomePage().startsWith("https://")) { %>
				<div class="" style="word-break: break-word;"><a href="<%= scrData.getHomePage() %>" target="_blank"><%= scrData.getHomePage() %></a></div>
			<% } else { %>
				<div class="" style="word-break: break-word;"><%= scrData.getHomePage() %></div>
			<% } %>
		</div>
<%
		//
		// Help / Docs
		//
%>
		<div class="DS-padding-8px DS-border-dn" align="left">
			<div class="DS-text-italic DS-text-compact DS-text-gray">Help / Documentation</div>
			<% if (scrData.getHelpPage().trim().equals("")) { %>
				<div class="DS-text-exception DS-text-italic">Sorry, no help or documentation page found.</div>
			<% } else if (scrData.getHelpPage().startsWith("http://") | scrData.getHelpPage().startsWith("https://")) { %>
				<div class="" style="word-break: break-word;"><a href="<%= scrData.getHelpPage() %>" target="_blank"><%= scrData.getHelpPage() %></a></div>
			<% } else { %>
				<div class="" style="word-break: break-word;"><%= scrData.getHelpPage() %></div>
			<% } %>
		</div>
<%
		//
		// Script Warning
		//

		Vector<String> vecErr = new Vector<>();

		if (!SCR.fileExists(scrData.getID()))
			vecErr.add("Installation is unavailable, no attached scripts found");

		if (scrData.getLifeCycle().getValue() < LifeCycle.RTM.getValue())
			vecErr.add("Script in " + scrData.getLifeCycle().getDescr() + ", install at your own risk");

		if (scrData.getLifeCycle().getValue() < LifeCycle.PREALPHA.getValue())
			vecErr.add("This script is unsupported - Reason: " + scrData.getLifeCycle().getDescr());

		if (vecErr.size() > 0) {
%>
			<div class="DS-padding-8px DS-back-pastel-red">
				<div class="DS-text-italic DS-text-compact DS-text-gray">Additional Warning List:</div>
				<ul class="DS-ul-padding"><% for (String vecErrMsg : vecErr) { %>
					<li class="DS-li-padding DS-text-exception DS-text-italic"><%= vecErrMsg %></li>
				<% } %></ul>
			</div>
<%
		}

		//
		// Footer buttons
		//
%>
		<div class="DS-padding-8px DS-back-gray DS-border-up">
			<table class="TableSpacing_0px" style="width:100%">
				<tr>
					<td class="CellPadding_0px" align="left" style="width:25%">
						<%= MdcTool.Dialog.BtnDismiss(
							"btnDismiss",
							"Back",
							true,
							"",
							"",
							"arrow_back_ios",
							MdcTool.Button.Look.RAISED
						) %>
					</td>
					<td class="CellPadding_0px" align="center" style="width:25%">
						<% if (scrData.CanManageScript(request, SysTool.getCurrentUser(request))) { %>
							<%= MdcTool.Button.TextIconOutlinedClass(
								"edit", // btnIconLeft
								"&nbsp;Edit", // btnLabel
								null, // btnIconRight
								null, // IconClass
								null, // TextClass
								"onClick=\"DLG_UpdateDetails('" + scrData.getID() + "');\"",
								null
							) %>
						<% } %>
					</td>
					<td class="CellPadding_0px" align="center" style="width:25%">
						<% if (scrData.CanManageScript(request, SysTool.getCurrentUser(request))) { %>
							<%= MdcTool.Button.TextIconOutlinedClass(
								"delete", // btnIconLeft
								"&nbsp;Delete", // btnLabel
								null, // btnIconRight
								"DS-text-exception", // IconClass
								"DS-text-exception", // TextClass
								"onClick=\"actionDelete('" + scrData.getID() + "');\"",
								null
							) %>
						<% } %>
					</td>
					<td class="CellPadding_0px" align="right" style="width:25%">
						<% if (SCR.fileExists(scrData.getID())) { %>
							<%= MdcTool.Button.TextIconClass(
								"get_app",
								"&nbsp;Install",
								null,
								"DS-text-lime", // IconClass
								null, // TextClass
								"onClick=\"actionDownload('" + scrData.getID() + "');\"",
								null
							) %>
						<% } else { %>
							<div title="No script found">
								<button type="button" class="mdc-button mdc-button--raised" disabled><i class="material-icons">get_app</i>&nbsp;Install</button>
							</div>
						<% } %>
					</td>
				</tr>
			</table>
		</div>
<%
	} catch (Exception e) {
%>
		<div class="DS-padding-8px DS-back-pastel-red DS-border-up">
			<div class="DS-text-subtitle DS-text-exception">Internal Error</div>
		</div>
		<div class="DS-padding-8px DS-back-pastel-red DS-border-dn">
			<div class="DS-text-exception"><%= e.toString() %></div>
		</div>
<%
	}

	DB.destroy();
%>
</body>
</html>
