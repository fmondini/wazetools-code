////////////////////////////////////////////////////////////////////////////////////////////////////
//
// Script.java
//
// CODE Scripts Inventory
//
// First Release: Mar/2015 by Fulvio Mondini (fmondini[at]danisoft.net)
//       Revised: Jan/2024 Moved to V3
//       Revised: Feb/2024 Changed to ReqObject CRUD operations
//       Revised: Mar/2025 Ported to Waze dslib.jar
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.code;

import java.io.File;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.UUID;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;

import net.danisoft.dslib.FmtTool;
import net.danisoft.dslib.SysTool;
import net.danisoft.wtlib.code.CodeRole;
import net.danisoft.wazetools.AppCfg;

/**
 * CODE Scripts Inventory
 */
public class Script {

	private final static String TBL_NAME = "CODE_scripts";

	// Fields
	private final static String SCRIPT_BASEURL	= AppCfg.getServerHomeUrl() + "/repository";
	private final static String SCRIPT_BASEPATH	= AppCfg.getServerRootPath() + "/repository";
	private final static String SCRIPT_TEMPPATH	= (SysTool.isWindog() ? "C:/Temp" : "/tmp");
	private final static String SCRIPT_EXTENS	= ".user.js";

	// Getters
	public static String getTblName()			{ return TBL_NAME; 			}
	public static String getScriptBaseUrl()		{ return SCRIPT_BASEURL;	}
	public static String getScriptBasePath()	{ return SCRIPT_BASEPATH;	}
	public static String getScriptTempPath()	{ return SCRIPT_TEMPPATH;	}
	public static String getScriptExtn()		{ return SCRIPT_EXTENS;		}

	private Connection cn;

	/**
	 * Constructor
	 */
	public Script(Connection conn) {
		this.cn = conn;
	}

	/**
	 * Script Data
	 */
	public class Data {

		// Fields
		private String		_ID;		// `SCR_ID` varchar(36) NOT NULL DEFAULT '00000000-0000-0000-0000-000000000000'
		private int			_Category;	// `SCR_Category` int NOT NULL DEFAULT '0'
		private String		_Title;		// `SCR_Title` varchar(255) NOT NULL DEFAULT 'Please Insert Script Title'
		private String		_Descr;		// `SCR_Descr` mediumtext NOT NULL
		private int			_Major;		// `SCR_Major` int NOT NULL DEFAULT '0' COMMENT 'Script Version: Major'
		private int			_Minor;		// `SCR_Minor` int NOT NULL DEFAULT '0' COMMENT 'Script Version: Minor'
		private int			_Build;		// `SCR_Build` int NOT NULL DEFAULT '0' COMMENT 'Script Version: Build'
		private LifeCycle	_LifeCycle;	// `SCR_LifeCycle` int NOT NULL DEFAULT '0' COMMENT 'Script Version: LifeCycle - Hardcoded with ENUM in the Script.java Class'
		private String		_Author;	// `SCR_Author` varchar(255) NOT NULL DEFAULT ''
		private Timestamp	_LastUpd;	// `SCR_LastUpd` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
		private String		_LastUpdBy;	// `SCR_LastUpdBy` varchar(32) NOT NULL DEFAULT ''
		private String		_HomePage;	// `SCR_HomePage` varchar(255) NOT NULL DEFAULT ''
		private String		_HelpPage;	// `SCR_HelpPage` varchar(255) NOT NULL DEFAULT ''
		private int			_Downloads;	// `SCR_Downloads` int NOT NULL DEFAULT '0'

		// Getters
		public String		getID()			{ return this._ID;			}
		public int			getCategory()	{ return this._Category;	}
		public String		getTitle()		{ return this._Title;		}
		public String		getDescr()		{ return this._Descr;		}
		public int			getMajor()		{ return this._Major;		}
		public int			getMinor()		{ return this._Minor;		}
		public int			getBuild()		{ return this._Build;		}
		public LifeCycle	getLifeCycle()	{ return this._LifeCycle;	}
		public String		getAuthor()		{ return this._Author;		}
		public Timestamp	getLastUpd()	{ return this._LastUpd;		}
		public String		getLastUpdBy()	{ return this._LastUpdBy;	}
		public String		getHomePage()	{ return this._HomePage;	}
		public String		getHelpPage()	{ return this._HelpPage;	}
		public int			getDownloads()	{ return this._Downloads;	}

		// Setters
		public void setID(String id)					{ this._ID = id;				}
		public void setCategory(int category)			{ this._Category = category;	}
		public void setTitle(String title)				{ this._Title = title;			}
		public void setDescr(String descr)				{ this._Descr = descr;			}
		public void setMajor(int major)					{ this._Major = major;			}
		public void setMinor(int minor)					{ this._Minor = minor;			}
		public void setBuild(int build)					{ this._Build = build;			}
		public void setLifeCycle(LifeCycle lifeCycle)	{ this._LifeCycle = lifeCycle;	}
		public void setAuthor(String author)			{ this._Author = author;		}
		public void setLastUpd(Timestamp lastUpd)		{ this._LastUpd = lastUpd;		}
		public void setLastUpdBy(String lastUpdBy)		{ this._LastUpdBy = lastUpdBy;	}
		public void setHomePage(String homePage)		{ this._HomePage = homePage;	}
		public void setHelpPage(String helpPage)		{ this._HelpPage = helpPage;	}
		public void setDownloads(int downloads)			{ this._Downloads = downloads;	}

		/**
		 * Constructor
		 */
		public Data() {
			super();

			this._ID		= "";
			this._Category	= 0;
			this._Title		= "";
			this._Descr		= "";
			this._Major		= 0;
			this._Minor		= 0;
			this._Build		= 0;
			this._LifeCycle	= LifeCycle.UNKNOWN;
			this._Author	= "";
			this._LastUpd	= FmtTool.DATEZERO;
			this._LastUpdBy	= "";
			this._HomePage	= "";
			this._HelpPage	= "";
			this._Downloads	= 0;
		}

		/**
		 * Check if the given user can edit this script
		 */
		public boolean CanManageScript(HttpServletRequest request, String userName) {

			return(
				CodeRole.userHasRole(request.getSession(), CodeRole.SYSOP)	||
				CodeRole.userHasRole(request.getSession(), CodeRole.SITEM)	||
				this.getAuthor().equals(userName)
			);
		}
	}

	/**
	 * Read a Script
	 */
	public Data Read(String ScrID) {
		return(
			_read_obj_by_id(ScrID)
		);
	}

	/**
	 * Create a new Script
	 */
	public String CreateEmpty(String currentUser) {

		String newUuid = getNewUUID();

		Data data = new Data();

		data.setID(newUuid);
		data.setTitle("+++ [Insert Script Title Here]");
		data.setDescr("+++ [Insert Script Description Here]");
		data.setLifeCycle(LifeCycle.UNKNOWN);
		data.setAuthor(currentUser);
		data.setLastUpdBy(currentUser);

		Insert(data);

		return(newUuid);
	}

	/**
	 * Insert a new Script
	 */
	public void Insert(Data data) {

		try {

			Statement st = this.cn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
			ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " LIMIT 1");

			rs.moveToInsertRow();
			_update_rs_from_obj(rs, data);
			rs.insertRow();

			rs.close();
			st.close();

		} catch (Exception e) { }
	}

	/**
	 * Update
	 * @throws Exception
	 */
	public void Update(String ScrID, Data data) throws Exception {

		Statement st = this.cn.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
		ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE SCR_ID = '" + ScrID + "'");

		if (rs.next()) {

			_update_rs_from_obj(rs, data);
			rs.updateRow();

		} else
			throw new Exception("Script.Update(): SCR_ID '" + ScrID + "' NOT found");

		rs.close();
		st.close();
	}

	/**
	 * Delete from DB and from disk
	 * @throws Exception
	 */
	public void Delete(String ScrID) throws Exception {

		Statement st = this.cn.createStatement();
		st.executeUpdate("DELETE FROM " + TBL_NAME + " WHERE SCR_ID = '" + ScrID + "'");
		st.close();

		new File(SCRIPT_BASEPATH + "/" + ScrID + SCRIPT_EXTENS).delete();
	}

	/**
	 * Check if a ScrID has an entry in Scripts Table
	 */
	public boolean Exists(String ScrID) {

		boolean rc = false;

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE SCR_ID = '" + ScrID + "'");

			if (rs.next())
				rc = true;

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(rc);
	}

	/**
	 * Count Scripts for a specified Category
	 */
	public int Count(int CatID) {

		int rc = 0;

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery("SELECT COUNT(*) AS RecNo FROM " + TBL_NAME + " WHERE SCR_Category = " + CatID);

			if (rs.next())
				rc = rs.getInt("RecNo");

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(rc);
	}

	/**
	 * Increment Download Counter
	 */
	public void incCounter(String ScrID) {

		try {

			Statement st = this.cn.createStatement();
			st.executeUpdate("UPDATE " + TBL_NAME + " SET SCR_Downloads = SCR_Downloads + 1 WHERE SCR_ID = '" + ScrID + "'");
			st.close();

		} catch (Exception e) { }
	}

	/**
	 * Get All Scripts - Order: SCR_LifeCycle DESC, SCR_Title
	 */
	public Vector<Data> getAll() {

		return(
			_fill_scr_vector(
				"SELECT * " +
				"FROM " + TBL_NAME + " " +
				"ORDER BY SCR_LifeCycle DESC, SCR_Title;"
			)
		);
	}

	/**
	 * Get All Scripts in a given Category - Order: SCR_LifeCycle DESC, SCR_Title
	 */
	public Vector<Data> getAll(int CatID) {

		return(
			_fill_scr_vector(
				"SELECT * " +
				"FROM " + TBL_NAME + " " +
				"WHERE SCR_Category = " + CatID + " " +
				"ORDER BY SCR_LifeCycle DESC, SCR_Title;"
			)
		);
	}

	/**
	 * Check if a script file exists
	 */
	public boolean fileExists(String ScrID) {

		return(new File(SCRIPT_BASEPATH + "/" + ScrID + SCRIPT_EXTENS).exists());
	}

	/**
	 * Generate a new random UUID
	 */
	public static String getNewUUID() {

		return(UUID.randomUUID().toString());
	}

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// +++ PRIVATE +++
	//
	////////////////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Read SCR Record based on given UUID
	 * @return <Script.Data> result 
	 */
	private Data _read_obj_by_id(String ScrID) {

		Data data = new Data();

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery("SELECT * FROM " + TBL_NAME + " WHERE SCR_ID = '" + ScrID + "';");

			if (rs.next())
				data = _parse_obj_from_rs(rs);

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(data);
	}

	/**
	 * Read SCR Records based on given query
	 * @return Vector<Script.Data> of results 
	 */
	private Vector<Data> _fill_scr_vector(String query) {

		Vector<Data> vecData = new Vector<Data>();

		try {
			
			Statement st = this.cn.createStatement();
			ResultSet rs = st.executeQuery(query);

			while (rs.next())
				vecData.add(_parse_obj_from_rs(rs));

			rs.close();
			st.close();

		} catch (Exception e) { }

		return(vecData);
	}

	/**
	 * Parse a given ResultSet into a ScrObject object
	 * @return <Script.Data> result 
	 */
	private Data _parse_obj_from_rs(ResultSet rs) {

		Data data = new Data();

		try {
			
			data.setID(rs.getString("SCR_ID"));
			data.setCategory(rs.getInt("SCR_Category"));
			data.setTitle(rs.getString("SCR_Title"));
			data.setDescr(rs.getString("SCR_Descr"));
			data.setMajor(rs.getInt("SCR_Major"));
			data.setMinor(rs.getInt("SCR_Minor"));
			data.setBuild(rs.getInt("SCR_Build"));
			data.setLifeCycle(LifeCycle.getEnum(rs.getInt("SCR_LifeCycle")));
			data.setAuthor(rs.getString("SCR_Author"));
			data.setLastUpd(rs.getTimestamp("SCR_LastUpd"));
			data.setLastUpdBy(rs.getString("SCR_LastUpdBy"));
			data.setHomePage(rs.getString("SCR_HomePage"));
			data.setHelpPage(rs.getString("SCR_HelpPage"));
			data.setDownloads(rs.getInt("SCR_Downloads"));

			// Special handling for dates
			try { data.setLastUpd(rs.getTimestamp("SCR_LastUpd")); } catch (Exception e) { data.setLastUpd(FmtTool.DATEZERO); }

		} catch (Exception e) { }

		return(data);
	}

	/**
	 * Update a given ResultSet from a given Script.Data
	 */
	private static void _update_rs_from_obj(ResultSet rs, Data data) {

		try {
			
			rs.updateString("SCR_ID", data.getID());
			rs.updateInt("SCR_Category", data.getCategory());
			rs.updateString("SCR_Title", data.getTitle());
			rs.updateString("SCR_Descr", data.getDescr());
			rs.updateInt("SCR_Major", data.getMajor());
			rs.updateInt("SCR_Minor", data.getMinor());
			rs.updateInt("SCR_Build", data.getBuild());
			rs.updateString("SCR_Author", data.getAuthor());
			rs.updateInt("SCR_LifeCycle", data.getLifeCycle().getValue());
			rs.updateTimestamp("SCR_LastUpd", new Timestamp(new java.util.Date().getTime()));
			rs.updateString("SCR_LastUpdBy", data.getLastUpdBy());
			rs.updateString("SCR_HomePage", data.getHomePage());
			rs.updateString("SCR_HelpPage", data.getHelpPage());
			rs.updateInt("SCR_Downloads", data.getDownloads());

		} catch (Exception e) { }
	}

}
