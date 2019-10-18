/* SAUSAGE */

/obj/item/weapon/reagent_containers/food/snacks/sausage
	name = "Sausage"
	desc = "A piece of mixed, long meat."
	icon_state = "sausage"
	filling_color = "#db0000"
	center_of_mass = "x=16;y=16"
	bitesize = 2

/obj/item/weapon/reagent_containers/food/snacks/sausage/Initialize()
	. = ..()

	reagents.add_reagent(/datum/reagent/nutriment/protein, 6)

/* SMOKED SAUSAGE */

/obj/item/weapon/reagent_containers/food/snacks/smokedsausage
	name = "Smoked sausage"
	desc = "Piece of smoked sausage. Oh, really?"
	icon_state = "smokedsausage"
	center_of_mass = "x=16;y=9"
	bitesize = 3

/obj/item/weapon/reagent_containers/food/snacks/smokedsausage/Initialize()
	. = ..()

	reagents.add_reagent(/datum/reagent/nutriment/protein, 12)
