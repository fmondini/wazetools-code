<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.code.*"
%>
<!DOCTYPE html>
<html>
<head>

	<script>

	/**
	 * Set Script Field
	 */
	 function setField(id, name, value) {

		$.ajax({

			type: 'POST',
			url: '../servlet/SetScriptField',
			data: { ScrID: id, ScrName: name, ScrValue: value },

			error: function(jqXHR, textStatus, errorThrown) {

				$('#ERROR_DIV').html('<b>Error updating database field.</b><br>' + jqXHR.responseText);
				$('#ERROR_DIV').slideDown('fast').delay(3000).slideUp('fast');
			},
		});
	}

	</script>

</head>
<body>
<%
	Database DB = new Database();
	Script SCR = new Script(DB.getConnection());
	Category CAT = new Category(DB.getConnection());

	String ScrID = EnvTool.getStr(request, "scr", "");

	try {

		Script.Data scrData;

		try {

			scrData = SCR.Read(ScrID);

		} catch (Exception e) {

			String newUuid = SCR.CreateEmpty(SysTool.getCurrentUser(request));
			scrData = SCR.Read(newUuid);
		}
%>
		<div class="DS-padding-8px DS-back-darkgray DS-border-dn">
			<div class="DS-text-huge DS-text-bold">Update Script</div>
		</div>

		<div class="DS-padding-8px">

			<table class="TableSpacing_0px DS-full-width">

				<tr>
					<td class="CellPadding_5px DS-border-updn DS-border-rg DS-back-gray" valign="top">Script ID</td>
					<td class="CellPadding_5px DS-border-updn" valign="top">
						<div class="DS-text-fixed DS-text-gray DS-text-bold"><%= scrData.getID() %></div>
					</td>
				</tr>

				<tr>
					<td class="CellPadding_5px DS-border-updn DS-border-rg DS-back-gray" valign="top">Title</td>
					<td class="CellPadding_5px DS-border-updn" valign="top">
						<input type="text" class="DS-input-textbox DS-full-width" name="reqTitle" maxlength="255" value="<%= scrData.getTitle() %>" onBlur="setField('<%= scrData.getID() %>', 'SCR_Title', this.value);">
					</td>
				</tr>

				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Category</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<select class="DS-input-textbox DS-full-width" name="reqCategory" onBlur="setField('<%= scrData.getID() %>', 'SCR_Category', this.value);"><%= CAT.getCombo(scrData.getCategory()) %></select>
					</td>
				</tr>

				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Version</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<table class="TableSpacing_0px DS-full-width">
							<tr>
								<td class="DS-text-small DS-text-italic DS-text-gray" style="padding-right: 5px" align="center">Major</td>
								<td class="DS-text-small DS-text-italic DS-text-gray" style="padding-right: 5px" align="center">Minor</td>
								<td class="DS-text-small DS-text-italic DS-text-gray" style="padding-right: 5px" align="center">Build</td>
								<td class="DS-text-small DS-text-italic DS-text-gray" style="padding-right: 5px">Release</td>
								<td class="DS-text-small DS-text-italic DS-text-gray" style="padding-right: 5px" align="right"></td>
							</tr>
							<tr>
								<td style="padding-right: 5px"><input type="text" class="DS-input-textbox" name="reqMajor" size="2" maxlength="2" value="<%= scrData.getMajor() %>" style="text-align: center" onBlur="setField('<%= scrData.getID() %>', 'SCR_Major', this.value);"></td>
								<td style="padding-right: 5px"><input type="text" class="DS-input-textbox" name="reqMinor" size="2" maxlength="2" value="<%= scrData.getMinor() %>" style="text-align: center" onBlur="setField('<%= scrData.getID() %>', 'SCR_Minor', this.value);"></td>
								<td style="padding-right: 5px"><input type="text" class="DS-input-textbox" name="reqBuild" size="4" maxlength="4" value="<%= scrData.getBuild() %>" style="text-align: center" onBlur="setField('<%= scrData.getID() %>', 'SCR_Build', this.value);"></td>
								<td style="" colspan="2"><select class="DS-input-textbox DS-full-width" name="reqCycle" onBlur="setField('<%= scrData.getID() %>', 'SCR_LifeCycle', this.value);"><%= LifeCycle.getCombo(scrData.getLifeCycle().getValue()) %></select></td>
							</tr>
						</table>
					</td>
				</tr>
			
				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Author(s)</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<input class="DS-input-textbox" type="text" name="reqAuth" style="width: 100%" maxlength="255" value="<%= scrData.getAuthor() %>" onBlur="setField('<%= scrData.getID() %>', 'SCR_Author', this.value);">
					</td>
				</tr>

				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Description</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<textarea class="DS-input-textbox" rows="5" name="reqDescr" style="width: 100%" onBlur="setField('<%= scrData.getID() %>', 'SCR_Descr', this.value);"><%= scrData.getDescr() %></textarea>
					</td>
				</tr>

				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Home Page URL</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<input class="DS-input-textbox" type="text" name="reqHome" style="width: 100%; font-size: 85%;" maxlength="255" value="<%= scrData.getHomePage() %>" onBlur="setField('<%= scrData.getID() %>', 'SCR_HomePage', this.value);">
					</td>
				</tr>	

				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" valign="top">Help / Docs URL</td>
					<td class="CellPadding_5px DS-border-dn" valign="top">
						<input class="DS-input-textbox" type="text" name="reqHelp" style="width: 100%; font-size: 85%;" maxlength="255" value="<%= scrData.getHelpPage() %>" onBlur="setField('<%= scrData.getID() %>', 'SCR_HelpPage', this.value);">
					</td>
				</tr>	
	
				<tr>
					<td class="CellPadding_5px DS-border-dn DS-border-rg DS-back-gray" nowrap>Javascript File</td>
					<td class="CellPadding_5px DS-border-dn" nowrap>
						<form method="post" action="../servlet/FileUploader" enctype="multipart/form-data" accept-charset="UTF-8" style="margin: 0px">
						<input type="hidden" name="scrUid" value="<%= scrData.getID() %>">
						<table class="TableSpacing_0px"><tr>
							<% if (SCR.fileExists(scrData.getID())) { %>
								<td class="CellPadding_0px DS-full-width"><a href="<%= Script.getScriptBaseUrl() %>/<%= scrData.getID() %><%= Script.getScriptExtn() %>"><%= scrData.getID() %><%= Script.getScriptExtn() %></a></td>
								<td class="CellPadding_0px" style="padding-left: 10px">
									<button type="button"
										class="mdc-button mdc-button--outlined DS-back-pastel-green"
										title="Clean this script and upload a new version"
										onClick="actionClean('<%= scrData.getID() %>');">
										<div class="mdc-button__ripple"></div>
										<i class="material-icons DS-text-green">cached</i>
										<span class="mdc-button__label">&nbsp;Update</span>
									</button>
								</td>
							<% } else { %>
								<td class="CellPadding_0px DS-full-width"><input class="DS-input-textbox DS-full-width"
									style="font-size: 80%" type="file" name="reqFileName" value=""
									accept=".js"></td>
								<td class="CellPadding_0px" style="padding-left: 10px">
									<button type="submit"
										class="mdc-button mdc-button--outlined DS-back-pastel-green">
										<div class="mdc-button__ripple"></div>
										<i class="material-icons DS-text-green">cloud_upload</i>
										<span class="mdc-button__label">&nbsp;Upload</span>
									</button>
								</td>
							<% } %>
						</tr></table>
						</form>
					</td>
				</tr>
	
			</table>

			<div id="ERROR_DIV" class="DS-padding-8px DS-text-exception DS-back-pastel-red DS-border-full" style="display:none" align="center"></div>

		</div>
<%
		//
		// Footer buttons
		//
%>
		<div class="DS-padding-8px DS-back-gray DS-border-up">
			<table class="TableSpacing_0px" style="width:100%">
				<tr>
					<td class="CellPadding_0px" align="left"><button type="button"
						class="mdc-button mdc-dialog__footer__button mdc-dialog__footer__button--cancel mdc-button--raised"
						onClick="window.location.href='?ShowSID=<%= scrData.getID() %>'">
						<div class="mdc-button__ripple"></div>
						<i class="material-icons">arrow_back_ios</i>
						<span class="mdc-button__label">Back</span>
					</button></td>
					<td class="CellPadding_0px DS-text-italic DS-text-gray" align="right">
						Last Update: <%= FmtTool.fmtDateTime(scrData.getLastUpd()) %> by <%= scrData.getLastUpdBy() %>
					</td>
				</tr>
			</table>
		</div>
<%
	} catch (Exception e) {

		System.err.println(e.toString());
		new MsgTool(session).setSlideText("Internal Error", e.toString());
%>
		<script>
			window.location.href = '?ExpSID=<%= ScrID %>';
		</script>
<%
	}

	DB.destroy();
%>
</body>
</html>
