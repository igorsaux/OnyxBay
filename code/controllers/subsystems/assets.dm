SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/cache = list()
	var/list/preload = list(
		'html/search.js',
		'html/panels.css',
		'html/spacemag.css',
		'html/images/loading.gif',
		'html/images/ntlogo.png',
		'html/images/bluentlogo.png',
		'html/images/sollogo.png',
		'html/images/terralogo.png',
		'html/images/talisman.png'
		)

	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Initialize(timeofday)
	var/newtransporttype = /datum/asset_transport
	switch (config.asset_transport)
		if ("webroot")
			newtransporttype = /datum/asset_transport/webroot

	if (newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype ()
	if (newtransport.validate_config())
		transport = newtransport
	transport.Load()

	for(var/type in typesof(/datum/asset))
		get_asset_datum(type)

	transport.Initialize(preload)

	..()