////////////////////////////////////////////////////////////////////////////////////////////////////
//
// FileUploader.java
//
// Upload files 
//
// First Release: ???/???? by Fulvio Mondini (https://danisoft.software/)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//                         Changed to @WebServlet style
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.servlets;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.util.Iterator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import net.danisoft.dslib.CmdQueue;
import net.danisoft.dslib.Database;
import net.danisoft.dslib.FilTool;
import net.danisoft.dslib.FmtTool;
import net.danisoft.dslib.MsgTool;
import net.danisoft.wazetools.code.LifeCycle;
import net.danisoft.wazetools.code.Script;

@WebServlet(description = "Upload files", urlPatterns = { "/servlet/FileUploader" })

public class FileUploader extends HttpServlet {

	private static final long serialVersionUID = FmtTool.getSerialVersionUID();

	private final static String SCR_OWNER_PERM	= "644";
	private final static String SCR_OWNER_USER	= "code_waze_tools";
	private final static String SCR_OWNER_GROUP	= "code_waze_tools";

	public FileUploader() {
		super();
	}

	@SuppressWarnings("unchecked")
	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		request.setCharacterEncoding("UTF-8");

		String InfoMsg = "", ErrorMsg = "";
		String RedirectURL = "../home/"; // In case something goes wrong

		Database DB = null;
		MsgTool MSG = new MsgTool(request.getSession());

		try {

			DB = new Database();

			String scrUid = null;
    		String SavedFileName = null;
    		String TempFileName = null;
    		String ReadyFileName = null;

    		// Get POST Parameters

			FileItemFactory factory = new DiskFileItemFactory();
	    	ServletFileUpload upload = new ServletFileUpload(factory);
	    	upload.setSizeMax(5L * 1024L * 1024L);
			List<ServletFileUpload> items = upload.parseRequest(request);
    		Iterator<ServletFileUpload> itr = items.iterator();

    		while (itr.hasNext()) {

    			FileItem item = (FileItem) itr.next();

				if (item.isFormField()) {

					if (item.getFieldName().equals("scrUid"))
						scrUid = item.getString();

				} else {

					String FileToUpload = item.getName();

					if (!FileToUpload.equals("")) {
						SavedFileName = Script.getScriptTempPath() + "/" + scrUid;
						item.write(new File(SavedFileName));
					}
				}
    		}

    		RedirectURL = "../home/browse.jsp?ForceSID=" + scrUid; // we have the ScriptID only here

			if (SavedFileName == null)
				throw new Exception("Please select a file to upload");

			TempFileName = SavedFileName + ".tmp";
			ReadyFileName = SavedFileName + ".ready";

			// Modify some fields

			BufferedReader iBr;
			BufferedWriter oBw;
			String inLine = "", orgVersions[] = null;
			boolean updateUrlFound = false, versionFound = false;
			int newVersions[] = {0, 0, 0, LifeCycle.ALPHA.getValue() };

			//
			// Scan Original Script
			//

			iBr = new BufferedReader(new InputStreamReader(new FileInputStream(SavedFileName),"UTF-8"));
			oBw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(TempFileName), "UTF-8"));

			while ((inLine = iBr.readLine()) != null) {

				if (inLine.toLowerCase().contains("@updateurl")) {

					inLine = "// @updateURL\t" + Script.getScriptBaseUrl() + "/" + scrUid + Script.getScriptExtn();
					InfoMsg += "<li>Script @updateURL changed to " + Script.getScriptBaseUrl() + "/" + scrUid + Script.getScriptExtn() + "</li>";
					updateUrlFound = true;

				} else if (!versionFound && inLine.toLowerCase().contains("@version")) {

					try {

						orgVersions = inLine.substring(inLine.toLowerCase().indexOf("@version") + "@version".length()).trim().split("\\.");

						newVersions[0] = 0; try { if (orgVersions.length > 0) newVersions[0] = Integer.parseInt(orgVersions[0]); } catch (Exception ef) { }
						newVersions[1] = 0; try { if (orgVersions.length > 1) newVersions[1] = Integer.parseInt(orgVersions[1]); } catch (Exception ef) { }
						newVersions[2] = 0; try { if (orgVersions.length > 2) newVersions[2] = Integer.parseInt(orgVersions[2]); } catch (Exception ef) { }

						newVersions[3] = LifeCycle.UNKNOWN.getValue();
						try {
							if (orgVersions.length > 3)
								newVersions[3] = LifeCycle.getEnum(orgVersions[3]).getValue();
						} catch (Exception ef) { }

						Script SCR = new Script(DB.getConnection());
						Script.Data scrData = SCR.Read(scrUid);

						scrData.setMajor(newVersions[0]);
						scrData.setMinor(newVersions[1]);
						scrData.setBuild(newVersions[2]);
						scrData.setLifeCycle(LifeCycle.getEnum(newVersions[3]));

						SCR.Update(scrUid, scrData);

						InfoMsg += "<li>" +
							"Script version changed to " +
								scrData.getMajor() + "." +
								scrData.getMinor() + "." +
								scrData.getBuild() + "." +
								scrData.getLifeCycle().getCycle() +
						"</li>";

					} catch (Exception ee) {
						ErrorMsg += "<li>" +
							"Unable to parse the '@version' string data in script, please check your source<br>" +
							"Expected format: maj[.min[.build[.cycle]]]<br>" +
							"Example: 1 - 0.15 - 1.1.10 - 1.2.0.GA" +
						"</li>";
					}

					versionFound = true;
				}

				oBw.write(inLine + System.getProperty("line.separator"));
			}

			oBw.close();
			iBr.close();

			FilTool.DeleteFile(SavedFileName);

			//
			// Version / UpdateURL Check
			//

			iBr =  new BufferedReader(new InputStreamReader(new FileInputStream(TempFileName),"UTF-8"));
			oBw = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(ReadyFileName), "UTF-8"));

			// Copy 1st line
			inLine = iBr.readLine();
			oBw.write(inLine + System.getProperty("line.separator"));

			if (!versionFound) {
				// Insert version line
				oBw.write("// @version\t\t0.0.0" + System.getProperty("line.separator"));
				ErrorMsg += "<li>Keyword '@version' not found, forced a new one</li>";
			}

			if (!updateUrlFound) {
				// Insert UpdateUrl line
				oBw.write("// @updateURL\t" + Script.getScriptBaseUrl() + "/" + scrUid + Script.getScriptExtn() + System.getProperty("line.separator"));
				ErrorMsg += "<li>Keyword '@updateURL' not found, forced a new one</li>";
			}

			// Copy all the rest
			while ((inLine = iBr.readLine()) != null)
				oBw.write(inLine + System.getProperty("line.separator"));

			// Done
			oBw.close();
			iBr.close();

			FilTool.DeleteFile(TempFileName);

			//
    		// Store Edited Script
			//

			File NewFile = new File(Script.getScriptBasePath() + "/" + scrUid + Script.getScriptExtn());

			NewFile.delete();

			if (!new File(ReadyFileName).renameTo(NewFile))
				throw new Exception("Cannot rename " + ReadyFileName + " to " + NewFile.getCanonicalPath());

			// Change Script Owner

			CmdQueue CMDQ = new CmdQueue();

			CMDQ.Append("#");
			CMDQ.Append("## Change Ownership");
			CMDQ.Append("#");
			CMDQ.Append("");
			CMDQ.Append("chown " + SCR_OWNER_USER + ":" + SCR_OWNER_GROUP + " \"" + NewFile.getCanonicalPath() + "\"");
			CMDQ.Append("chmod " + SCR_OWNER_PERM + " \"" + NewFile.getCanonicalPath() + "\"");

			String QueueResult = CMDQ.Run();

			if (!QueueResult.equals(""))
				throw new Exception(QueueResult);

			// RedirectURL = "../home/browse.jsp?ExpSID=" + scrUid;

		} catch (Exception e) {
			ErrorMsg += "<li>" + (e.getMessage() == null ? e.toString() : e.getMessage()) + "</li>";
		}

		if (DB != null)
			DB.destroy();

		if (!ErrorMsg.equals(""))
			MSG.setSlideText("Error(s) in Script Upload Process", "<b>One or more errors / warnings found:</b><br><ul>" + ErrorMsg + "</ul>");
		else if (!InfoMsg.equals(""))
			MSG.setSlideText("Script Uploaded <span class='DS-text-small DS-text-italic'>(with some warnings)</span>", "<b>Some automatic changes applied:</b><br><ul>" + InfoMsg + "</ul>");

		response.sendRedirect(RedirectURL);
	}

}
