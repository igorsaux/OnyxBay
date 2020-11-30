//DEFINITIONS FOR ASSET DATUMS START HERE.

/datum/asset/group/onyxchat
	children = list(
		/datum/asset/simple/jquery,
		/datum/asset/simple/onyxchat,
		/datum/asset/simple/fontawesome
	)

/datum/asset/simple/jquery
	keep_local_name = TRUE
	assets = list(
		"jquery.min.js"            = 'code/modules/onyxchat/browserassets/js/jquery.min.js',
	)

/datum/asset/simple/onyxchat
	keep_local_name = TRUE
	assets = list(
		"json2.min.js"             	= 'code/modules/onyxchat/browserassets/js/json2.min.js',
		"browserOutput.js"         	= 'code/modules/onyxchat/browserassets/js/browserOutput.js',
		"browserOutput.css"	       	= 'code/modules/onyxchat/browserassets/css/browserOutput.css',
		"browserOutput_white.css"  	= 'code/modules/onyxchat/browserassets/css/browserOutput_white.css',
		"browserOutput_marines.css" = 'code/modules/onyxchat/browserassets/css/browserOutput_marines.css'
	)

/datum/asset/simple/fontawesome
	keep_local_name = TRUE
	assets = list(
		"fa-regular-400.eot"  = 'html/font-awesome/webfonts/fa-regular-400.eot',
		"fa-regular-400.woff" = 'html/font-awesome/webfonts/fa-regular-400.woff',
		"fa-solid-900.eot"    = 'html/font-awesome/webfonts/fa-solid-900.eot',
		"fa-solid-900.woff"   = 'html/font-awesome/webfonts/fa-solid-900.woff',
		"font-awesome.css"    = 'html/font-awesome/css/all.min.css',
		"v4shim.css"          = 'html/font-awesome/css/v4-shims.min.css'
	)

/datum/asset/simple/tgui
	keep_local_name = TRUE
	assets = list(
		// tgui-next
		"tgui-main.html" 		= 'tgui-next/packages/tgui/public/tgui-main.html',
		"tgui-fallback.html" 	= 'tgui-next/packages/tgui/public/tgui-fallback.html',
		"tgui.bundle.js" 		= 'tgui-next/packages/tgui/public/tgui.bundle.js',
		"tgui.bundle.css" 		= 'tgui-next/packages/tgui/public/tgui.bundle.css',
		"shim-html5shiv.js" 	= 'tgui-next/packages/tgui/public/shim-html5shiv.js',
		"shim-ie8.js" 			= 'tgui-next/packages/tgui/public/shim-ie8.js',
		"shim-dom4.js" 			= 'tgui-next/packages/tgui/public/shim-dom4.js',
		"shim-css-om.js" 		= 'tgui-next/packages/tgui/public/shim-css-om.js'
	)

/datum/asset/group/tgui
	children = list(
		/datum/asset/simple/fontawesome,
		/datum/asset/simple/tgui
	)

/datum/asset/simple/directories/nanoui
	keep_local_name = TRUE

	directories = list(
		"nano/js/",
		"nano/css/",
		"nano/images/",
		"nano/templates/",
		"nano/images/torch/",
		"nano/images/status_icons/",
		"nano/images/source/",
		"nano/images/modular_computers/",
		"nano/images/exodus/",
		"nano/images/example/"
	)

/datum/asset/simple/directories/pda
	directories = list(
		"icons/pda_icons/",
	)
