////////////////////////////////////////////////////////////////////////////////////////////////////
//
// AppCfg.java
//
// main application configuration file
//
// First Release: Mar/2025 by Fulvio Mondini (https://danisoft.software/)
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools;

import net.danisoft.dslib.AppList;
import net.danisoft.dslib.FmtTool;
import net.danisoft.dslib.SiteCfg;
import net.danisoft.dslib.SysTool;

public class AppCfg {

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Editable parameters
	//

	private static final int	APP_VERS_MAJ = 5;
	private static final int	APP_VERS_MIN = 0;
	private static final String	APP_VERS_REL = "GA";
	private static final String	APP_DATE_REL = "May 23, 2025";

	private static final String	APP_NAME_TAG = AppList.CODE.getName();
	private static final String	APP_NAME_TXT = "Waze.Tools " + APP_NAME_TAG;
	private static final String	APP_ABSTRACT = "Find all the waze scripts you need";
	private static final String	APP_EXITLINK = "https://waze.tools/";

	private static final String	SERVER_ROOTPATH_DEVL = "C:/WorkSpace/Eclipse/Waze.Tools/wazetools-code/Web Content";
	private static final String	SERVER_ROOTPATH_PROD = "/var/www/html/code.waze.tools/Web Content";

	private static final String	SERVER_HOME_URL_DEVL = "http://localhost:8080/code.waze.tools";
	private static final String	SERVER_HOME_URL_PROD = "https://code.waze.tools";

	// Login stuff
	private static final String	ONLOGOUT_URL = "../home/";

	////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Getters
	//

	public static final String getAppTag()				{ return(APP_NAME_TAG);	}
	public static final String getAppName()				{ return(APP_NAME_TXT);	}
	public static final String getAppAbstract()			{ return(APP_ABSTRACT);	}
	public static final String getAppVersion()			{ return(APP_VERS_MAJ + "." + FmtTool.fmtZeroPad(APP_VERS_MIN, 2) + "." + APP_VERS_REL); }
	public static final String getAppRelDate()			{ return(APP_DATE_REL);	}
	public static final String getAppExitLink()			{ return(APP_EXITLINK);	}
	public static final String getServerRootPath()		{ return(SysTool.isWindog() ? SERVER_ROOTPATH_DEVL : SERVER_ROOTPATH_PROD); }
	public static final String getServerHomeUrl()		{ return(SysTool.isWindog() ? SERVER_HOME_URL_DEVL : SERVER_HOME_URL_PROD); }
	// Login stuff
	public static final String getAuthDefaultUser()		{ return(SysTool.isWindog() ? new SiteCfg().getPrivateParams().getDebugUser() : ""); }
	public static final String getAuthDefaultPass()		{ return(SysTool.isWindog() ? new SiteCfg().getPrivateParams().getDebugPass() : ""); }
	public static final String getAuthOnLogoutUrl()		{ return(ONLOGOUT_URL); }
	// WebLogs stuff
	public static final String getWeblogsUser()			{ return(new SiteCfg().getPrivateParams().getWeblogsUser()); }
	public static final String getWeblogsPass()			{ return(new SiteCfg().getPrivateParams().getWeblogsPass()); }
}
