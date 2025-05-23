<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.*"
%>
<%!
	private static final String PAGE_Title = AppCfg.getAppName() + " Check List";
	private static final String PAGE_Keywords = AppCfg.getAppName() + " Check List";
	private static final String PAGE_Description = "Check " + AppCfg.getAppName() + " Scripts Integrity";
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

		function RunCheck(divResults) {

			$.ajax({

				async: true,
				cache: false,
				type: 'GET',
				dataType: 'text',
				url: '_ajax_check.jsp',

				beforeSend: function(jqXHR, settings) {
					$('#divBackButton').addClass('DS-hidden');
				},

				success: function(data) {
					$('#' + divResults).html(data);
				},

				error: function(jqXHR, textStatus, errorThrown) {
					$('#' + divResults).html(jqXHR.responseText);
				},
				
				complete: function(jqXHR, textStatus) {
					$('#divBackButton').removeClass('DS-hidden');
				}
			});
		}

		$(window).on('load', function() {
			RunCheck('DIV_ChkResult');
		});

	</script>

</head>

<body>

	<jsp:include page="../_common/header.jsp" />

	<div class="mdc-layout-grid DS-layout-body">
	<div class="mdc-layout-grid__inner">

	<div class="<%= MdcTool.Layout.Cell(12, 8, 4) %>">

		<div class="DS-card-body">
			<div class="DS-text-title-shadow"><%= PAGE_Title %></div>
		</div>

		<div class="DS-card-full" align="center">
			<div class="DS-card-full" align="center">
				<div id="DIV_ChkResult">
					<img src="../images/mdctool-pleasewait.gif">
					<div class="DS-text-extra-large">Retrieving data, this can take some time...</div>
				</div>
			</div>
		</div>
<%
		//
		// BACK
		//
%>
		<div id="divBackButton" class="DS-card-foot">
			<%= MdcTool.Button.BackTextIcon("Back", "../home/") %>
		</div>

	</div>

	</div>
	</div>

	<jsp:include page="../_common/footer.jsp">
		<jsp:param name="RedirectTo" value=""/>
	</jsp:include>

</body>
</html>
