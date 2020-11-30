/client
	// * Black magic things *
	parent_type = /datum

	// * Admin things *
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/adminobs = null
	var/adminhelped = 0
	var/watchlist_warn = null

	// * Other things *
	var/static/obj/screen/click_catcher/void
	var/datum/click_handler/click_handler

	var/datum/preferences/prefs = null
	var/move_delay = 1
	var/moving = null
	var/species_ingame_whitelisted = FALSE

	var/datum/donator_info/donator_info = new

 	///world.time they connected
	var/connection_time
 	///world.realtime they connected
	var/connection_realtime
 	///world.timeofday they connected
	var/connection_timeofday

	///onyxchat chatoutput of the client
	var/datum/chatOutput/chatOutput

	// set to:
	// 0 to allow using external resources or on-demand behaviour;
	// 1 to use the default behaviour
	// 2 for preloading absolutely everything;
	preload_rsc = 2

	// List of all asset filenames sent to this client by the asset cache, along with their assoicated md5s
	var/list/sent_assets = list()
	/// List of all completed blocking send jobs awaiting acknowledgement by send_asset
	var/list/completed_asset_jobs = list()
	/// Last asset send job id.
	var/last_asset_job = 0
	var/last_completed_asset_job = 0

	// * Sound stuff *
	var/ambience_playing = null
	var/played = 0

	// * Security things *
	var/received_irc_pm = -99999

	//IRC admin that spoke with them last.
	var/irc_admin
	var/mute_irc = 0

	// Prevents people from being spammed about multikeying every time their mob changes.
	var/warned_about_multikeying = 0

	var/datum/eams_info/eams_info = new
	var/list/topiclimiter

	// comment out the line below when debugging locally to enable the options & messages menu
	//control_freak = 1

	// * Database related things *

	//So admins know why it isn't working - Used to determine how old the account is - in days.
	var/player_age = "Requires database"

	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"

	//So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"

	//used for initial centering of saywindow
	var/first_say = TRUE
