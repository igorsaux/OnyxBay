/* DOUGH */

/obj/item/weapon/reagent_containers/food/snacks/dough
	name = "dough"
	desc = "A piece of dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "dough"
	bitesize = 2
	center_of_mass = "x=16;y=13"
	nutriment_desc = list("dough" = 3)
	nutriment_amt = 3

/obj/item/weapon/reagent_containers/food/snacks/dough/Initialize()
	. = ..()

	reagents.add_reagent(/datum/reagent/nutriment/protein, 1)

/obj/item/weapon/reagent_containers/food/snacks/dough/proc/FlatDough()
	var/atom/flat_dough = new /obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough(src)

	reagents.trans_to_holder(flat_dough.reagents, reagents.total_volume)
	flat_dough.name = "flat [src.name]"
	flat_dough.desc = "A flattened [src.name]"

	qdel(src)

// Dough + rolling pin = flat dough
/obj/item/weapon/reagent_containers/food/snacks/dough/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W,/obj/item/weapon/material/kitchen/rollingpin))
		if (do_after(usr, 30, src, FALSE, TRUE, INCAPACITATION_DEFAULT, TRUE, FALSE))
			FlatDough()
			to_chat(user, "You flatten the dough.")

/* BISCUIT DOUGH */

/obj/item/weapon/reagent_containers/food/snacks/dough/biscuit_dough
	name = "biscuit dough"
	desc = "A piece of biscuit dough."
	nutriment_desc = list("dough" = 3, "sugar" = 5, "eggs" = 5)

/obj/item/weapon/reagent_containers/food/snacks/dough/biscuit_dough/Initialize()
	. = ..()

	reagents.add_reagent(/datum/reagent/sugar, 5)
	reagents.add_reagent(/datum/reagent/drink/milk, 5)
	reagents.add_reagent(/datum/reagent/nutriment/protein/egg, 6)

/* FLAT DOUGH */

// slicable into 3xdoughslices
/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough
	name = "flat dough"
	desc = "A flattened dough."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "flat dough"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/doughslice
	slices_num = 3
	center_of_mass = "x=16;y=16"

/obj/item/weapon/reagent_containers/food/snacks/sliceable/flatdough/Initialize()
	. = ..()

	reagents.add_reagent(/datum/reagent/nutriment/protein, 1)
	reagents.add_reagent(/datum/reagent/nutriment, 3)

/* DOUGH SLICE */

/obj/item/weapon/reagent_containers/food/snacks/doughslice
	name = "dough slice"
	desc = "A building block of an impressive dish."
	icon = 'icons/obj/food_ingredients.dmi'
	icon_state = "doughslice"
	slice_path = /obj/item/weapon/reagent_containers/food/snacks/spagetti
	slices_num = 1
	bitesize = 2
	center_of_mass = "x=17;y=19"
	nutriment_desc = list("dough" = 1)
	nutriment_amt = 1
