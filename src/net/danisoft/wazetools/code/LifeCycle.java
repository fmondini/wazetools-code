////////////////////////////////////////////////////////////////////////////////////////////////////
//
// LifeCycle.java
//
// CODE LifeCycle
//
// First Release: ???/???? by Fulvio Mondini (https://danisoft.software/)
//       Revised: Mar/2025 Ported to Waze dslib.jar
//
////////////////////////////////////////////////////////////////////////////////////////////////////

package net.danisoft.wazetools.code;

/**
 * CODE LifeCycle
 */
public enum LifeCycle {

	//			-----	---------------	---------------------------	---------------	---------------	---------
	//			Value	Cycle			Description					Icon			Google Icon		Color
	//			-----	---------------	---------------------------	---------------	---------------	---------
	UNKNOWN		(0,		"[?]",			"LifeCycle: Unknown",		"unknown.png",	"help",			"#cc0000"),
	EOL			(1,		"eol",			"End Of Life (obsolete)",	"eol.png",		"elderly",		"#b30059"),
	EOS			(2,		"eos",			"End Of Support (retired)",	"eos.png",		"elderly",		"#b30059"),
	PREALPHA	(3,		"pre-alpha",	"Pre-Alpha Release",		"prealpha.png",	"bug_report",	"#cc00cc"),
	ALPHA		(4,		"alpha",		"Alpha Release",			"alpha.png",	"bug_report",	"#cc00cc"),
	BETA		(5,		"beta",			"Beta Release",				"beta.png",		"bug_report",	"#8c1aff"),
	RC			(6,		"rc",			"Release Candidate",		"rc.png",		"new_releases",	"#999900"),
	RTM			(7,		"rtm",			"Release to Marketing",		"rtm.png",		"new_releases",	"#999900"),
	GA			(8,		"ga",			"General Availability",		"ga.png",		"verified",		"#009933"),
	GOLD		(9,		"gold",			"Production Release",		"gold.png",		"verified",		"#009933");

	private final int		_Value;
	private final String	_Cycle;
	private final String	_Descr;
	private final String	_Icon;
	private final String	_GIcon;
	private final String	_Color;

	LifeCycle(int value, String cycle, String descr, String icon, String gIcon, String color) {
		this._Value = value;
		this._Cycle = cycle;
		this._Descr = descr;
		this._Icon = "../images/016x016/" + icon;
		this._GIcon = gIcon;
		this._Color = color;
    }

	public int    getValue()	{ return(this._Value);	}
	public String getDescr()	{ return(this._Descr);	}
	public String getCycle()	{ return(this._Cycle);	}
	public String getIcon()		{ return(this._Icon);	}
	public String getGIcon()	{ return(this._GIcon);	}
	public String getColor()	{ return(this._Color);	}

	/**
	 * Get LifeCycle Combo
	 */
	public static String getCombo(int defaultValue) {

		// Change obsolete values

		if (defaultValue == EOS.getValue())			{ defaultValue = EOL.getValue();	} else
		if (defaultValue == PREALPHA.getValue())	{ defaultValue = ALPHA.getValue();	} else
		if (defaultValue == RTM.getValue())			{ defaultValue = RC.getValue();		} else
		if (defaultValue == GOLD.getValue())		{ defaultValue = GA.getValue();		} else
		{
			// ELSE: Do nothing, keep current value
		}

		String Results = (defaultValue == UNKNOWN.getValue()
			? "<option value=\"" + UNKNOWN.getValue() + "\" selected>--=[ Please select an item ]=--</option>"
			: ""
		);

		for (LifeCycle X : LifeCycle.values()) {
			if (
				X.getValue() != UNKNOWN.getValue()	&&
				X.getValue() != EOS.getValue()		&&
				X.getValue() != PREALPHA.getValue()	&&
				X.getValue() != RTM.getValue()		&&
				X.getValue() != GOLD.getValue()
			) {
				Results +=
					"<option value=\"" + X.getValue() + "\" " + (X.getValue() == defaultValue ? "selected" : "") + ">" +
						"[" + X.getCycle().toUpperCase() + "] - " + X.getDescr() +
					"</option>"
				;
			}
		}

		return(Results);
	}

	/**
	 * Get Google Icon SPAN for current enum
	 */
	public String getIconSpan() {

		return(
			"<span " +
				"class=\"material-icons\" " +
				"title=\"[" + this.getCycle().toUpperCase() + "] " + this.getDescr() + "\" " +
				"style=\"font-size:20px; color:" + this.getColor() + ";\"" +
			">" +
				this.getGIcon() +
			"</span>"
		);
	}

	/**
	 * Get Enum by Value
	 */
	public static LifeCycle getEnum(int Value) {
		
		LifeCycle rc = UNKNOWN;

		for (LifeCycle X : LifeCycle.values())
			if (X.getValue() == Value)
				rc = X;

		return(rc);
	}

	/**
	 * Get Enum by Cycle
	 */
	public static LifeCycle getEnum(String cycle) {
		
		LifeCycle rc = UNKNOWN;

		for (LifeCycle X : LifeCycle.values())
			if (X.getCycle().toLowerCase().trim().equals(cycle))
				rc = X;

		return(rc);
	}

}
