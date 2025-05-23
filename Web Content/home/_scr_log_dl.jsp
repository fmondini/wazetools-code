<%@ page
	language="java"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	import="net.danisoft.dslib.*"
	import="net.danisoft.wazetools.code.*"
%>
<%
	Database DB = new Database();
	LogTool LOG = new LogTool(DB.getConnection());
	Script SCR = new Script(DB.getConnection());

	String ScrID = EnvTool.getStr(request, "scr", "");

	try {

		SCR.incCounter(ScrID);

		LOG.Info(request, LogTool.Category.DWNL, "Script downloaded: " + ScrID);

	} catch (Exception e) {

		LOG.Error(request, LogTool.Category.DWNL, e.toString() + " - ScrID: " + ScrID);
	}

	DB.destroy();
%>
