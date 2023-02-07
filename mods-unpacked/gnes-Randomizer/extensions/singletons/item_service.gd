extends "res://singletons/item_service.gd"


func init_unlocked_pool()->void :
	.init_unlocked_pool()
	
	RandomizerService.reset_randomizer_data()
	RandomizerService.init_randomizer_pool(items)

## completely overriding the original method due to low cohesion, even though only a few lines are changed (for now)
func get_rand_item_from_wave(wave:int, type:int, shop_items:Array = [], prev_shop_items:Array = [], fixed_tier:int = - 1)->ItemParentData:
	var excluded_items = []
	excluded_items.append_array(shop_items)
	excluded_items.append_array(prev_shop_items)
	
	var rand_wanted = randf()
	var item_tier = get_tier_from_wave(wave)
	
	if fixed_tier != - 1:
		item_tier = fixed_tier
	
	if type == TierData.WEAPONS:
		item_tier = clamp(item_tier, RunData.effects["min_weapon_tier"], RunData.effects["max_weapon_tier"])
	
	var pool = get_pool(item_tier, type)
	var backup_pool = get_pool(item_tier, type)
	var items_to_remove = []
	
	## randomizer - pool of categories
	var categories_pool:Array = RandomizerService.get_categories_pool()
	
	
	for shop_item in excluded_items:

		pool.erase(shop_item[0])
	
	if type == TierData.WEAPONS:
		
		var bonus_chance_same_weapon_class = max(0, (MAX_WAVE_ONE_WEAPON_GUARANTEED + 1 - RunData.current_wave) * (BONUS_CHANCE_SAME_WEAPON_CLASS / MAX_WAVE_ONE_WEAPON_GUARANTEED))
		var chance_same_weapon_class = CHANCE_SAME_WEAPON_CLASS + bonus_chance_same_weapon_class

		
		if RunData.effects["no_melee_weapons"] > 0:
			for item in pool:
				if item.type == WeaponType.MELEE:
					backup_pool.erase(item)
					items_to_remove.push_back(item)
		
		if RunData.effects["no_ranged_weapons"] > 0:
			for item in pool:
				if item.type == WeaponType.RANGED:
					backup_pool.erase(item)
					items_to_remove.push_back(item)
		
		if RunData.weapons.size() > 0:
			if rand_wanted < CHANCE_SAME_WEAPON:

				var player_weapon_ids = []
				var nb_potential_same_weapons = 0
				
				for weapon in RunData.weapons:
					for item in pool:
						if item.weapon_id == weapon.weapon_id:
							nb_potential_same_weapons += 1
					player_weapon_ids.push_back(weapon.weapon_id)
				
				if nb_potential_same_weapons > 0:

					for item in pool:
						if not player_weapon_ids.has(item.weapon_id):

							items_to_remove.push_back(item)
				
			elif rand_wanted < chance_same_weapon_class:

				var player_weapon_classes = []
				var nb_potential_same_classes = 0
				
				for weapon in RunData.weapons:
					for weapon_class in weapon.weapon_classes:
						if not player_weapon_classes.has(weapon_class):
							player_weapon_classes.push_back(weapon_class)
				
				var weapons_to_potentially_remove = []
				
				for item in pool:
					var item_has_atleast_one_class = false
					for weapon_class in player_weapon_classes:
						if item.weapon_classes.has(weapon_class):

							nb_potential_same_classes += 1
							item_has_atleast_one_class = true
							break
					
					if not item_has_atleast_one_class:
						weapons_to_potentially_remove.push_back(item)
				
				if nb_potential_same_classes > 0:

					for item in weapons_to_potentially_remove:
						items_to_remove.push_back(item)
	
	elif type == TierData.ITEMS and randf() < CHANCE_WANTED_ITEM_TAG and RunData.current_character.wanted_tags.size() > 0:
		
		var categories_to_remove:Array = []
		## selects only categories favored to the current char
		for category in categories_pool:
			var has_wanted_tag = false
			
			for tag in RunData.current_character.wanted_tags:
				if category.shop_category_id == tag:
					has_wanted_tag = true
					break
			
			if not has_wanted_tag and not category.shop_category_id == "stat_secondary":
				categories_to_remove.push_back(category)
		
		## remove other categories from the pool
		for category in categories_to_remove:
			categories_pool.erase(category);
		
	
	## RANDOMIZER - if its item, already return categories as an item
	if type == TierData.ITEMS:
		var random_cat = Utils.get_rand_element(categories_pool)
		return RandomizerService.convert_randomizer_category_to_item(random_cat, wave)
	
	var elt
	
	if pool.size() == 0:
		if backup_pool.size() > 0:

			elt = Utils.get_rand_element(backup_pool)
		else :

			elt = Utils.get_rand_element(_tiers_data[item_tier][type])
	else :
		elt = Utils.get_rand_element(pool)
	
	return elt
