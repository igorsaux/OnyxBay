/mob
	var/list/psychoscope_icons[2]
	var/list/neuromods

/mob/Initialize()
	. = ..()

	var/image/psychoscope_dot = new /image/hud_overlay('icons/mob/hud.dmi', src, "psychoscope_dot")
	psychoscope_dot.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	var/image/psychoscope_scan = new /image('icons/mob/hud.dmi', src, "psychoscope_scan")
	psychoscope_scan.appearance_flags = RESET_COLOR|RESET_TRANSFORM|KEEP_APART
	psychoscope_scan.plane = EFFECTS_ABOVE_LIGHTING_PLANE

	psychoscope_icons[PSYCHOSCOPE_ICON_DOT] = psychoscope_dot
	psychoscope_icons[PSYCHOSCOPE_ICON_SCAN] = psychoscope_scan
	neuromods = list()

/mob/ShiftClick(mob/user)
	. = ..()

	if (src != user && istype(src, /mob))
		var/mob/M = src

		var/atom/equip = user.get_equipped_item(slot_glasses)

		if (equip && equip.type == /obj/item/clothing/glasses/hud/psychoscope)
			var/obj/item/clothing/glasses/hud/psychoscope/pscope = equip

			pscope.ScanLifeform(M)

/proc/GetLifeformDataByType(var/lifeformType)
	return GLOB.psychoscope_lifeform_data[lifeformType]

/* PSYCHOSCOPE */

/obj/item/clothing/glasses/hud/psychoscope
	name = "psychoscope"
	desc = "Displays information about lifeforms. Scan target must be alive."
	icon = 'icons/obj/psychotronics.dmi'
	icon_state = "psychoscope_on"
	off_state = "psychoscope_off"
	activation_sound = null // DAT SOUND LOUD AS FUCK
	active = FALSE
	hud_type = HUD_PSYCHOSCOPE
	electric = TRUE
	action_button_name = "Toggle Psychoscope"
	toggleable = 1
	body_parts_covered = EYES
	origin_tech = list(TECH_MAGNET = 3, TECH_BIO = 3)
	matter = list(MATERIAL_STEEL = 1500, MATERIAL_REINFORCED_GLASS = 500, MATERIAL_GOLD = 200)

	var/list/scans_journal
	var/datum/psychoscopeLifeformData/selected_lifeform = null
	var/list/total_lifeforms
	var/is_scanning = FALSE

	/* UI MODES */
	//
	// 0 - Main Menu
	// 1 - List of scans
	// 2 - List of known lifeforms
	// 3 - Lifeform Details
	//

	var/ui_mode = 0
	var/old_mode = 0

/obj/item/clothing/glasses/hud/psychoscope/proc/ScanLifeform(mob/M)
	if (!src.active || is_scanning)
		return

	is_scanning = TRUE
	usr.client.images += M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN]
	playsound(src, 'sound/effects/psychoscope/psychoscope_scan.ogg', 10, 0)

	if (!do_after(usr, 40, M, 0, 0, INCAPACITATION_DEFAULT, 1, 1))
		usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		is_scanning = FALSE
		return

	is_scanning = FALSE

	usr.client.images.Remove(M.psychoscope_icons[PSYCHOSCOPE_ICON_SCAN])

	var/datum/psychoscopeLifeformData/lData = src.GetLifeformData(M)

	if (lData == null)
		playsound(src, 'sound/effects/psychoscope/scan_failed.ogg', 10, 0)
		to_chat(usr, "Unknown lifeform.")
		return
	else
		playsound(src, 'sound/effects/psychoscope/scan_success.ogg', 10, 0)
		to_chat(usr, "New data added to your Psychoscope.")

	var/datum/psychoscopeScanData/sData = new(lData, M.name)
	scans_journal.Add(sData)

/obj/item/clothing/glasses/hud/psychoscope/proc/GetLifeformData(mob/M, count_scan=TRUE)
	if (M.type in GLOB.psychoscope_lifeform_data)
		var/datum/psychoscopeLifeformData/lData = GLOB.psychoscope_lifeform_data[M.type]

		if ("\ref[M]" in lData["scanned_list"])
			return 0
		if (count_scan)
			lData.scan_count++
			lData.scanned_list.Add("\ref[M]")
			lData.ProbNeuromods()

		return lData
	else
		return null

/obj/item/clothing/glasses/hud/psychoscope/proc/PrintTechs(datum/psychoscopeLifeformData/lData)
	var/list/techs_list = lData.GetUnlockedTechs()
	var/obj/item/LifeformScanDisk/disk = new(usr.loc)
	disk.origin_tech = list()
	disk.desc += "\nLoaded Technologies:"

	for (var/tech in techs_list)
		disk.origin_tech.Add(list(tech["tech_id"] = tech["tech_level"]))
		disk.desc += "\n[tech["tech_name"]] - [tech["tech_level"]]"

	usr.put_in_hands(disk)

/obj/item/clothing/glasses/hud/psychoscope/proc/PrintNeuromodData(neuromod_type)
	neuromod_type = text2path(neuromod_type)
	if (!ispath(neuromod_type))
		return

	var/datum/neuromodData/D = new neuromod_type
	var/obj/item/neuromodDataDisk/disk = new(usr.loc)

	disk.neuromod_data = D
	disk.name = D.name
	disk.desc += "\n[D.name] - [D.desc]"

	usr.put_in_hands(disk)

/* NOT USED */
/obj/item/clothing/glasses/hud/psychoscope/proc/PrintData(datum/psychoscopeLifeformData/lData)
	to_chat(usr, "Scan Data:")
	to_chat(usr, "Kingdom: [lData.kingdom]")
	to_chat(usr, "class: [lData.class]")
	to_chat(usr, "Genus: [lData.genus]")
	to_chat(usr, "Species: [lData.species]")
	to_chat(usr, "Description: [lData.desc]")

/obj/item/clothing/glasses/hud/psychoscope/verb/TogglePsychoscope()
	set name = "Toggle Psychoscope"
	set desc = "Enables or disables your psychoscope"
	set popup_menu = 1
	set category = "Psychoscope"

	attack_self(usr)

/obj/item/clothing/glasses/hud/psychoscope/verb/ShowPsychoscopeUI()
	set name = "Show Psychoscope UI"
	set desc = "Opens psychoscope's menu."
	set popup_menu = 1
	set category = "Psychoscope"

	ui_interact(usr)

/* OVERRIDES */

/obj/item/clothing/glasses/hud/psychoscope/Initialize()
	. = ..()

	scans_journal = list()
	total_lifeforms = list()
	overlay = GLOB.global_hud.material
	icon_state = "psychoscope_off"

/obj/item/clothing/glasses/hud/psychoscope/Destroy()
	qdel(selected_lifeform)
	selected_lifeform = null

	..()

/obj/item/clothing/glasses/hud/psychoscope/attack_self(mob/user)
	. = ..(user)

	if (!active)
		is_scanning = FALSE
		set_light(0)
	else
		playsound(src, 'sound/effects/psychoscope/psychoscope_on.ogg', 10, 0)
		set_light(2, 5, rgb(105, 180, 255))

/* HotKeys */

/obj/item/clothing/glasses/hud/psychoscope/AltClick(mob/user)
	. = ..()

	ui_interact(user)

/* UI */

/obj/item/clothing/glasses/hud/psychoscope/Topic(href, list/href_list)
	if (..()) return 1

	playsound(src, 'sound/machines/console_click2.ogg', 10, 1)

	switch(href_list["option"])
		if ("togglePsychoscope")
			attack_self(usr)
		if ("showScansJournal")
			old_mode = ui_mode
			ui_mode = 1
		if ("back")
			ui_mode = old_mode
			old_mode = ui_mode
		if ("deleteScan")
			scans_journal.Remove(locate(href_list["scan_reference"]))
		if ("showLifeformsList")
			old_mode = ui_mode
			ui_mode = 2
		if ("showLifeform")
			old_mode = ui_mode
			ui_mode = 3
			selected_lifeform = (locate(href_list["lifeform_reference"]) in total_lifeforms)
		if ("printTechs")
			PrintTechs((locate(href_list["lifeform_reference"]) in total_lifeforms))
		if ("showMainMenu")
			ui_mode = 0
			old_mode = 0
		if ("printNeuromodData")
			PrintNeuromodData(href_list["neuromod_type"])

	return 1

/obj/item/clothing/glasses/hud/psychoscope/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	var/list/data = list()
	total_lifeforms = list()

	for (var/T in GLOB.psychoscope_lifeform_data)
		total_lifeforms.Add(GLOB.psychoscope_lifeform_data[T])

	data["status"] = active
	data["mode"] = ui_mode
	data["scans_journal"] = list()
	data["lifeforms_list"] = list()

	if (selected_lifeform)
		data["lifeform"] = selected_lifeform.ToList(user)
		data["lifeform_reference"] = "\ref[selected_lifeform]"

	switch(ui_mode)
		if (1)
			for (var/datum/psychoscopeScanData/sData in scans_journal)
				data["scans_journal"].Add(list(
					list(
						"scan" = sData.ToList(),
						"scan_reference" = "\ref[sData]",
						"lifeform_reference" = "\ref[sData.lifeform]"
					)
				))
		if (2)
			for (var/I in GLOB.psychoscope_lifeform_data)
				var/datum/psychoscopeLifeformData/D = GetLifeformDataByType(I)

				if (!D || D.species == "Unknown")
					continue

				data["lifeforms_list"].Add(list(
					list(
						"lifeform" = D.ToList(user),
						"lifeform_reference" = "\ref[D]"
					)
				))

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)

	if (!ui)
		ui = new(user, src, ui_key, "psychoscope.tmpl", "Psychoscope UI", 400, 400)

		ui.set_initial_data(data)
		ui.open()
	ui.set_auto_update(TRUE)

	/* HUD */

/obj/item/clothing/glasses/hud/psychoscope/process_hud(mob/M)
	if (active)
		if (!can_process_hud(M))
			return

		var/datum/arranged_hud_process/P = arrange_hud_process(M, 0, GLOB.med_hud_users)

		for(var/mob/living/target in P.Mob.in_view(P.Turf) - M)
			if (!target.is_dead())
				P.Client.images += target.psychoscope_icons[PSYCHOSCOPE_ICON_DOT]

/* DATUMS */

/datum/psychoscopeScanData
	var/datum/psychoscopeLifeformData/lifeform
	var/date = 0
	var/object_name = ""

/datum/psychoscopeScanData/New(lifeform_data, object_name)
	src.date = "[stationdate2text()] - [stationtime2text()]"
	src.lifeform = lifeform_data
	src.object_name = object_name

/datum/psychoscopeScanData/Destroy()
	qdel(lifeform)
	lifeform = null

	..()

/datum/psychoscopeScanData/proc/ToList()
	var/list/L = list()

	L["date"] = date
	L["lifeform"] = lifeform.ToList()
	L["object_name"] = object_name

	return L

/datum/psychoscopeLifeformData
	var/mob/mob_type = null
	var/kingdom = ""
	var/class = ""
	var/genus = ""
	var/species = ""
	var/desc = ""
	var/scan_count = 0
	var/list/scanned_list
	var/list/tech_rewards
	var/list/neuromod_rewards
	var/list/opened_neuromods

/datum/psychoscopeLifeformData/New(mob_type, kingdom, class, genus, species, desc, list/tech_rewards, list/neuromod_rewards)
	src.mob_type = mob_type
	src.kingdom = kingdom
	src.class = class
	src.genus = genus
	src.species = species
	src.desc = desc
	src.tech_rewards = tech_rewards
	src.neuromod_rewards = neuromod_rewards

	scanned_list = list()
	opened_neuromods = list()

/datum/psychoscopeLifeformData/proc/ProbNeuromods()
	if (!neuromod_rewards)
		return

	for (var/scan = scan_count, scan > 0, scan--)
		var/list/neuromods = neuromod_rewards[num2text(scan)]

		if (!neuromods || neuromods.len == 0)
			continue

		for (var/N in neuromods)
			if (!N in subtypesof(/datum/neuromodData))
				continue

			var/datum/neuromodData/nData = N

			if (nData in opened_neuromods)
				continue

			var/unlocked = prob(initial(nData.chance))

			if (unlocked && !isnull(nData) && nData in subtypesof(/datum/neuromodData))
				opened_neuromods.Add(nData)
				to_chat(usr, "New neuromod available!")

/datum/psychoscopeLifeformData/proc/GetUnlockedTechs()
	var/list/tech_list = list()

	for (var/scan = scan_count, scan > 0, scan--)
		var/list/reward = tech_rewards[num2text(scan)]

		if (!reward || reward.len == 0)
			continue

		for (var/I in reward)
			tech_list.Add(list(
				list("tech_name" = CallTechName(I), "tech_level" = reward[I], "tech_id" = I)
			))

		return tech_list

/datum/psychoscopeLifeformData/proc/GetUnlockedNeuromods()
	var/list/neuromods_list = list()

	for (var/N in opened_neuromods)
		var/datum/neuromodData/nData = N

		if (isnull(nData))
			continue

		neuromods_list.Add(list(
			list("neuromod_name" = initial(nData.name), "neuromod_type" = nData, "neuromod_desc" = initial(nData.desc))
		))

	return neuromods_list

/datum/psychoscopeLifeformData/proc/ToList(mob/user)
	var/list/L = list()

	L["img"] = null

	if (user && mob_type)
		L["img"] = icon2html(initial(mob_type.icon), user, initial(mob_type.icon_state), SOUTH, 1, FALSE, "icon", "height:64px;width:64px;")

	L["kingdom"] = kingdom
	L["class"] = class
	L["genus"] = genus
	L["species"] = species
	L["desc"] = desc
	L["scan_count"] = scan_count
	L["opened_techs"] = GetUnlockedTechs()
	L["opened_neuromods"] = GetUnlockedNeuromods()

	return L