////////////////////////////////////////////////////////////////////////////////////////////////////
//
// SetScriptField.java
//
// Set a script field
//
// First Release: ???/???? by Fulvio Mondini (https://danisoft.software/)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//                         Changed to @WebServlet style
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.servlets;

import java.io.IOException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.danisoft.dslib.Database;
import net.danisoft.dslib.EnvTool;
import net.danisoft.dslib.FmtTool;
import net.danisoft.wazetools.code.Script;

@WebServlet(description = "Set a script field", urlPatterns = { "/servlet/SetScriptField" })

public class SetScriptField extends HttpServlet {

	private static final long serialVersionUID = FmtTool.getSerialVersionUID();

	public SetScriptField() {
		super();
	}

	@Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

		Database DB = null;

		try {

			DB = new Database();

			String ScrID = EnvTool.getStr(request, "ScrID", "");
			String ScrName = EnvTool.getStr(request, "ScrName", "");
			String ScrValue = EnvTool.getStr(request, "ScrValue", "");

			if (ScrID.equals(""))
				throw new Exception("Invalid Script ID: '" + ScrID + "'");

			if (ScrName.equals(""))
				throw new Exception("Invalid Field Name: '" + ScrName + "'");

			Statement st = DB.getConnection().createStatement();
			st.executeUpdate("UPDATE " + Script.getTblName() + " SET " + ScrName + " = '" + ScrValue + "' WHERE SCR_ID = '" + ScrID + "'");
			st.close();

			ServletOutputStream out = response.getOutputStream();
			out.println("SetScriptField(); OK");

		} catch (Exception e) {

			response.setStatus(HttpServletResponse.SC_NOT_ACCEPTABLE);
            response.getWriter().write("SetScriptField(): " + e.getMessage());
		}

		if (DB != null)
			DB.destroy();
	}

}
