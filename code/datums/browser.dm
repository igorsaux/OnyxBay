/datum/browser
	var/mob/user
	var/title
	var/window_id // window_id is used as the window name for browse and onclose
	var/width = 0
	var/height = 0
	var/atom/ref = null
	var/window_options = "focus=0;can_close=1;can_minimize=1;can_maximize=0;can_resize=1;titlebar=1;" // window option is set using window_id
	var/stylesheets[0]
	var/scripts[0]
	var/title_image
	var/head_elements
	var/body_elements
	var/head_content = ""
	var/content = ""
	var/title_buttons = ""


/datum/browser/New(nuser, nwindow_id, ntitle = 0, nwidth = 0, nheight = 0, var/atom/nref = null)

	user = nuser
	window_id = nwindow_id
	if (ntitle)
		title = format_text(ntitle)
	if (nwidth)
		width = nwidth
	if (nheight)
		height = nheight
	if (nref)
		ref = nref
	// If a client exists, but they have disabled fancy windowing, disable it!
	if(user && user.client && user.client.get_preference_value(/datum/client_preference/browser_style) == GLOB.PREF_PLAIN)
		return

	add_stylesheet("common", 'html/chui/chui.css') // this CSS sheet is common to all UIs

/datum/browser/proc/set_title(ntitle)
	title = format_text(ntitle)

/datum/browser/proc/add_head_content(nhead_content)
	head_content = nhead_content

/datum/browser/proc/set_title_buttons(ntitle_buttons)
	title_buttons = ntitle_buttons

/datum/browser/proc/set_window_options(nwindow_options)
	window_options = nwindow_options

/datum/browser/proc/set_title_image(ntitle_image)
	//title_image = ntitle_image

/datum/browser/proc/add_stylesheet(name, file)
	stylesheets[name] = file

/datum/browser/proc/add_script(name, file)
	scripts[name] = file

/datum/browser/proc/set_content(ncontent)
	content = ncontent

/datum/browser/proc/add_content(ncontent)
	content += ncontent

/datum/browser/proc/get_header(var/content)
	var/key
	var/filename
	for (key in stylesheets)
		filename = "[ckey(key)].css"
		user << browse_rsc(stylesheets[key], filename)
		head_content += "<link rel='stylesheet' type='text/css' href='[filename]'>"

	var/params = params2list(window_options)

	var/can_close = (text2num(params["can_close"]) ? TRUE : FALSE)
	var/can_resize = (text2num(params["can_resize"]) ? TRUE : FALSE)

	if (can_resize && findtext(window_options, "can_resize=1"))
		// Using JS resize, not BYOND
		window_options = replacetext(window_options, "can_resize=1", "can_resize=0")

	head_content += "<script src='jquery.min.js'></script>"
	head_content += "<script src='jquery.nanoscroller.min.js'></script>"
	head_content += "<script src='chui.js'></script>"
	head_content += "<link rel='stylesheet' type='text/css' href='font-awesome.css'>"

	for (key in scripts)
		filename = "[ckey(key)].js"
		user << browse_rsc(scripts[key], filename)
		head_content += "<script type='text/javascript' src='[filename]'></script>"

	return {"<!DOCTYPE html>
<html>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
	<head>
		<meta name="ref" value="[window_id]">
		<meta name="flags" value="[can_resize ? 1 : 0]">
		<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">
		[head_content]
	</head>
	<body>
		[title ? {"<div id='titlebar'>
			<div class='corner tl'></div>
			<div class='corner tr'></div>
			<h1>[title]</h1>
			[can_close ? "<a href='#' class='close'><i class='fas fa-times'></i></a>" : ""]
		</div>"} : ""]
		<div class='resizeArea top'   rx='0' ry='-1'></div>
		<div class='resizeArea tr'    rx='1' ry='-1'></div>
		<div class='resizeArea right' rx='1' ry='0'></div>
		<div class='resizeArea br'    rx='1' ry='1'></div>
		<div class='resizeArea bottom'rx='0' ry='1'></div>
		<div class='resizeArea bl'    rx='-1' ry='1'></div>
		<div class='resizeArea left'  rx='-1' ry='0'></div>
		<div class='resizeArea tl'    rx='-1' ry='-1'></div>
		<div id="cornerWrap">
			<div class='borderSlants'></div>
			<div class='corner bl'></div>
			<div class='corner br'></div>
			<div id='content' class='nano'>
				<div class='nano-content innerContent'>
					[content]
				</div>
			</div>
		</div>
	"}

/datum/browser/proc/get_footer()
	return {"</body></html>"}

/datum/browser/proc/get_content()
	return {"
	[get_header(content)]
	[get_footer()]
	"}

/datum/browser/proc/open(var/use_onclose = 1)
	if (user && user.client)
		var/datum/asset/directories/chui/A = get_asset_datum(/datum/asset/directories/chui)

		if (!A.check_sent(user.client))
			spawn(5)
				open(use_onclose)

			return

	var/window_size = ""
	if (width && height)
		window_size = "size=[width]x[height];"
	user << browse(get_content(), "window=[window_id];[window_size][window_options]")
	if (use_onclose)
		onclose(user, window_id, ref)

/datum/browser/proc/update(var/force_open = 0, var/use_onclose = 1)
	if(force_open)
		open(use_onclose)
	else
		send_output(user, get_content(), "[window_id].browser")

/datum/browser/proc/close()
	user << browse(null, "window=[window_id]")

// This will allow you to show an icon in the browse window
// This is added to mob so that it can be used without a reference to the browser object
// There is probably a better place for this...
/mob/proc/browse_rsc_icon(icon, icon_state, dir = -1)
	/*
	var/icon/I
	if (dir >= 0)
		I = new /icon(icon, icon_state, dir)
	else
		I = new /icon(icon, icon_state)
		dir = "default"

	var/filename = "[ckey("[icon]_[icon_state]_[dir]")].png"
	src << browse_rsc(I, filename)
	return filename
	*/


// Registers the on-close verb for a browse window (client/verb/.windowclose)
// this will be called when the close-button of a window is pressed.
//
// This is usually only needed for devices that regularly update the browse window,
// e.g. canisters, timers, etc.
//
// windowid should be the specified window name
// e.g. code is	: user << browse(text, "window=fred")
// then use 	: onclose(user, "fred")
//
// Optionally, specify the "ref" parameter as the controlled atom (usually src)
// to pass a "close=1" parameter to the atom's Topic() proc for special handling.
// Otherwise, the user mob's machine var will be reset directly.
//
/proc/onclose(mob/user, windowid, var/atom/ref=null)
	if(!user || !user.client) return
	var/param = "null"
	if(ref)
		param = "\ref[ref]"

	spawn(2)
		if(!user.client) return
		winset(user, windowid, "on-close=\".windowclose [param]\"")

//	log_debug("OnClose [user]: [windowid] : ["on-close=\".windowclose [param]\""]")



// the on-close client verb
// called when a browser popup window is closed after registering with proc/onclose()
// if a valid atom reference is supplied, call the atom's Topic() with "close=1"
// otherwise, just reset the client mob's machine var.
//
/client/verb/windowclose(var/atomref as text)
	set hidden = 1						// hide this verb from the user's panel
	set name = ".windowclose"			// no autocomplete on cmd line

//	log_debug("windowclose: [atomref]")

	if(atomref!="null")				// if passed a real atomref
		var/hsrc = locate(atomref)	// find the reffed atom
		if(hsrc)
//			log_debug("[src] Topic [href] [hsrc]")

			usr = src.mob
			src.Topic("close=1", list("close"="1"), hsrc)	// this will direct to the atom's
			return										// Topic() proc via client.Topic()

	// no atomref specified (or not found)
	// so just reset the user mob's machine var
	if(src && src.mob)
//		log_debug("[src] was [src.mob.machine], setting to null")

		src.mob.unset_machine()
	return
