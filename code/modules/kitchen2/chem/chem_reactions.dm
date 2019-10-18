/datum/chemical_reaction/dough
	name = "Dough"
	result = null
	required_reagents = list(/datum/reagent/nutriment/flour = 10,
							/datum/reagent/water = 5)
	result_amount = 1

/datum/chemical_reaction/dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for(var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/dough(location)

/datum/chemical_reaction/biscuit_dough
	name = "Biscuit Dough"
	result = null
	required_reagents = list(/datum/reagent/nutriment/protein/egg = 6,
							/datum/reagent/nutriment/flour = 10,
							/datum/reagent/drink/milk = 5,
							/datum/reagent/sugar = 5)

	result_amount = 1

/datum/chemical_reaction/biscuit_dough/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	for (var/i = 1, i <= created_volume, i++)
		new /obj/item/weapon/reagent_containers/food/snacks/dough/biscuit_dough(location)
