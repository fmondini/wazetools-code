////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Category.java
//
// CODE Categories List
//
// First Release: Mar/2015 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Jan/2024 Moved to V3
//       Revised: Feb/2024 Changed to ReqObject CRUD operations
//       Revised: Mar/2025 Ported to Waze dslib.jar
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.code;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Vector;

import net.danisoft.dslib.FmtTool;
import net.danisoft.wtlib.code.CodeRole;

/**
 * CODE Categories List
 */
public class Category {

	private final static String TBL_NAME = "CODE_categories";

	public static String getTblName() { return TBL_NAME; }

	private Connection cn;

	/**
	 * Constructor
	 */
	public Category(Connection conn) {
		this.cn = conn;
	}

	/**
	 * Category Data
	 */
	public class Data {
		
		// Fields
		private int		_ID;		// `CAT_ID` int NOT NULL DEFAULT '0'
		private int		_Role;		// `CAT_Role` int unsigned NOT NULL DEFAULT '0'
		private String	_Descr;		// `CAT_Descr` varchar(255) NOT NULL DEFAULT 'Insert Category Name'
		private int		_Level;		// `CAT_Level` int NOT NULL DEFAULT '0' COMMENT 'View level required to access'
		private int		_ScrCount;	// (SELECT COUNT(*) FROM CODE_scripts WHERE CAT_ID = SCR_Category) AS ScrCount

		// Getters
		public int		getID()			{ return this._ID;			}
		public int		getRole()		{ return this._Role;		}
		public String	getDescr()		{ return this._Descr;		}
		public int		getLevel()		{ return this._Level;		}
		public int		getScrCount()	{ return this._ScrCount;	}

		// Setters
		public void setID(int id)				{ this._ID = id;				}
		public void setRole(int role)			{ this._Role = role;			}
		public void setDescr(String descr)		{ this._Descr = descr;			}
		public void setLevel(int level)			{ this._Level = level;			}
		public void setScrCount(int scrCount)	{ this._ScrCount = scrCount;	}

		/**
		 * Constructor
		 */
		public Data() {
			super();

			this._ID		= 0;
			this._Role		= 0;
			this._Descr		= "";
			this._Level		= 0;
			this._ScrCount	= 0;
		}

	}

	/**
	 * Read
	 */
	public Data Read(int CatID) {
		return(_read_cat_by_id(CatID));
	}

	/**
	 * Update
	 * @throws Exception
	 */
	public void Update(int CatID, Data catData) throws Exception {

		Statement st = this.cn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
		ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE CAT_ID = " + CatID);

		if (rs.next()) {

			rs.updateInt("CAT_ID", catData.getID());
			rs.updateInt("CAT_Role", catData.getRole());
			rs.updateString("CAT_Descr", catData.getDescr());

			rs.updateRow();

		} else
			throw new Exception("Category.Update(): CAT_ID '" + CatID + "' NOT found");

		rs.close();
		st.close();
	}

	/**
	 * Get All Categories
	 */
	public Vector<Data> getAll() {

		return(_fill_cat_vector("SELECT * FROM " + TBL_NAME + " ORDER BY CAT_ID;"));
	}

	/**
	 * Get All Categories for a given UserRole
	 */
	public Vector<Data> getAll(int UserRoleValue) {

		if (UserRoleValue == 0)
			UserRoleValue = CodeRole.EUSER.getValue(); // Force "End User" role for unlogged users

		Vector<Data> vecCatRslt = new Vector<Data>();

		Vector<Data> vecCatData = _fill_cat_vector(
			"SELECT " +
				"CAT_ID, CAT_Role, CAT_Descr, CAT_Level, " +
				"(SELECT COUNT(*) FROM " + Script.getTblName() + " WHERE CAT_ID = SCR_Category) AS ScrCount " +
			"FROM " + TBL_NAME + " " +
			"ORDER BY CAT_ID;"
		);

		for (Data catData : vecCatData)
			if ((catData.getRole() & UserRoleValue) == catData.getRole())
				vecCatRslt.add(catData);

		return(vecCatRslt);
	}

	/**
	 * Get Categories Combo
	 */
	public String getCombo(int selected) {

		String Results = "";

		try {

			Vector<Data> vecCatData = _fill_cat_vector("SELECT * FROM " + TBL_NAME + " ORDER BY CAT_ID;");

			for (Data catData : vecCatData) {
				Results +=
					"<option value=\"" + catData.getID() + "\" " + (catData.getID() == selected ? "selected" : "") + ">" +
						FmtTool.fmtZeroPad(catData.getID(), 3) + " - " + catData.getDescr() +
					"</option>";			
			}

		} catch (Exception e) {
			Results = "<option selected>" + e.toString() + "</option>";
		}

		return(Results);
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// +++ PRIVATE +++
	//
	////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Read CAT Record by CatID
	 * @return <Category.Data> 
	 */
	private Data _read_cat_by_id(int CatID) {

		Data data = new Data();

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE CAT_ID = " + CatID + ";");

			if (rs.next()) {

				data.setID(rs.getInt("CAT_ID"));
				data.setRole(rs.getInt("CAT_Role"));
				data.setDescr(rs.getString("CAT_Descr"));
				data.setLevel(rs.getInt("CAT_Level"));
			}

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(data);
	}

	/**
	 * Read CAT Records based on given query
	 * @return Vector<Category.Data> of results 
	 */
	private Vector<Data> _fill_cat_vector(String query) {

		Vector<Data> vecData = new Vector<Data>();

		try {
			
			Data data;
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery(query);

			while (rs.next()) {

				data = new Data();

				data.setID(rs.getInt("CAT_ID"));
				data.setRole(rs.getInt("CAT_Role"));
				data.setDescr(rs.getString("CAT_Descr"));
				data.setLevel(rs.getInt("CAT_Level"));

				try {
					data.setScrCount(rs.getInt("ScrCount")); // Only if exists
				} catch (Exception e) { }

				vecData.add(data);
			}

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(vecData);
	}

}
