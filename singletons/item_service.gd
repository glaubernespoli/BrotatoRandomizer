extends Node


const TIER_DANGER_5_COLOR = Color(208.0 / 255, 193.0 / 255, 66.0 / 255, 1)
const TIER_DANGER_4_COLOR = Color(255.0 / 255, 119.0 / 255, 59.0 / 255, 1)
const TIER_DANGER_0_COLOR = Color(230.0 / 255, 230.0 / 255, 230.0 / 255, 1)

const TIER_DANGER_5_COLOR_DARK = Color(26.0 / 255, 24.0 / 255, 8.0 / 255, 1)
const TIER_DANGER_4_COLOR_DARK = Color(36.0 / 255, 17.0 / 255, 8.0 / 255, 1)
const TIER_DANGER_0_COLOR_DARK = Color(0.0 / 255, 0.0 / 255, 0.0 / 255, 1)

const TIER_LEGENDARY_COLOR = Color(255.0 / 255, 59.0 / 255, 59.0 / 255, 1)
const TIER_RARE_COLOR = Color(173.0 / 255, 90.0 / 255, 255.0 / 255, 1)
const TIER_UNCOMMON_COLOR = Color(90.0 / 255, 190.0 / 255, 255.0 / 255, 1)

const TIER_LEGENDARY_COLOR_DARK = Color(36.0 / 255, 9.0 / 255, 9.0 / 255, 1)
const TIER_RARE_COLOR_DARK = Color(16.0 / 255, 10.0 / 255, 27.0 / 255, 1)
const TIER_UNCOMMON_COLOR_DARK = Color(15.0 / 255, 32.0 / 255, 40.0 / 255, 1)

const NB_SHOP_ITEMS: = 4

const CHANCE_WEAPON: = 0.35
const CHANCE_SAME_WEAPON: = 0.2
const CHANCE_SAME_WEAPON_CLASS: = 0.35
const MAX_WAVE_TWO_WEAPONS_GUARANTEED: = 3
const MAX_WAVE_ONE_WEAPON_GUARANTEED: = 6
const BONUS_CHANCE_SAME_WEAPON_CLASS: = 0.15
const CHANCE_WANTED_ITEM_TAG: = 0.05

enum TierData{
	ALL_ITEMS, 
	ITEMS, 
	WEAPONS, 
	CONSUMABLES, 
	UPGRADES, 
	MIN_WAVE, 
	BASE_CHANCE, 
	WAVE_BONUS_CHANCE, 
	MAX_CHANCE
}

enum RandomizerData {
	ITEM_CATEGORIES,
	ITEM_ARMOR,
	ITEM_ATTACK_SPEED,
	ITEM_CRIT_CHANCE,
	ITEM_DODGE,
	ITEM_ELEMENTAL_DAMAGE,
	ITEM_ENGINEERING,
	ITEM_HARVESTING,
	ITEM_HP_REGEN,
	ITEM_LIFESTEAL,
	ITEM_LUCK,
	ITEM_MAX_HP,
	ITEM_MELEE_DAMAGE,
	ITEM_PERCENT_DAMAGE,
	ITEM_RANDOM,
	ITEM_RANGE,
	ITEM_RANGED_DAMAGE,
	ITEM_SECONDARY,
	ITEM_SPEED
}

const randomizer_item_stat_keys = {
	"item_categories": RandomizerData.ITEM_CATEGORIES,
	"stat_armor": RandomizerData.ITEM_ARMOR,
	"stat_attack_speed": RandomizerData.ITEM_ATTACK_SPEED,
	"stat_crit_chance": RandomizerData.ITEM_CRIT_CHANCE,
	"stat_dodge": RandomizerData.ITEM_DODGE,
	"stat_elemental_damage": RandomizerData.ITEM_ELEMENTAL_DAMAGE,
	"stat_engineering": RandomizerData.ITEM_ENGINEERING,
	"stat_harvesting": RandomizerData.ITEM_HARVESTING,
	"stat_hp_regeneration": RandomizerData.ITEM_HP_REGEN,
	"stat_lifesteal": RandomizerData.ITEM_LIFESTEAL,
	"stat_luck": RandomizerData.ITEM_LUCK,
	"stat_max_hp": RandomizerData.ITEM_MAX_HP,
	"stat_melee_damage": RandomizerData.ITEM_MELEE_DAMAGE,
	"stat_percent_damage": RandomizerData.ITEM_PERCENT_DAMAGE,
	"stat_random": RandomizerData.ITEM_RANDOM,
	"stat_range": RandomizerData.ITEM_RANGE,
	"stat_ranged_damage": RandomizerData.ITEM_RANGED_DAMAGE,
	"stat_secondary": RandomizerData.ITEM_SECONDARY,
	"stat_speed": RandomizerData.ITEM_SPEED
}

var _all_items: = []
var _tiers_data:Array
var _randomizer_data:Dictionary

export (Array, Resource) var elites: = []
export (Array, Resource) var effects: = []
export (Array, Resource) var stats: = []
export (Array, Resource) var characters: = []
export (Array, Resource) var items: = []
export (Array, Resource) var weapons: = []
export (Array, Resource) var consumables: = []
export (Array, Resource) var upgrades: = []
export (Array, Resource) var sets: = []
export (Array, Resource) var difficulties: = []
export (Array, Resource) var randomizer_categories: = []
export (Resource) var item_box = null
export (Resource) var legendary_item_box = null
export (Resource) var upgrade_to_process_icon = null


func _ready()->void :
	_all_items.append_array(items)
	_all_items.append_array(weapons)


func reset_tiers_data()->void :
		_tiers_data = [
		[[], [], [], [], [], 0, 1.0, 0.0, 1.0],
		[[], [], [], [], [], 0, 0.0, 0.06, 0.6], 
		[[], [], [], [], [], 2, 0.0, 0.02, 0.25], 
		[[], [], [], [], [], 6, 0.0, 0.0023, 0.08]
	]


func init_unlocked_pool()->void :
	
	reset_tiers_data()
	
	## empties the randomizer
	_randomizer_data = {}
	
	for item in items:
		if ProgressData.items_unlocked.has(item.my_id):
			_tiers_data[item.tier][TierData.ALL_ITEMS].push_back(item)
			_tiers_data[item.tier][TierData.ITEMS].push_back(item)
	
	for weapon in weapons:
		if ProgressData.weapons_unlocked.has(weapon.weapon_id):
			_tiers_data[weapon.tier][TierData.ALL_ITEMS].push_back(weapon)
			_tiers_data[weapon.tier][TierData.WEAPONS].push_back(weapon)
	
	for upgrade in upgrades:
		if ProgressData.upgrades_unlocked.has(upgrade.upgrade_id):
			_tiers_data[upgrade.tier][TierData.UPGRADES].push_back(upgrade)
	
	for consumable in consumables:
		if ProgressData.consumables_unlocked.has(consumable.my_id):
			_tiers_data[consumable.tier][TierData.CONSUMABLES].push_back(consumable)
			
	
	init_randomizer_pool()

func init_randomizer_pool()->void:
	
	## initializing arrays
	for randomizer_entry in RandomizerData:
		_randomizer_data[randomizer_entry] = []
	
	## adding randomizer categories
	_randomizer_data[RandomizerData.CATEGORIES] = []
	
	
	for item in items:
		if ProgressData.items_unlocked.has(item.my_id):
			## always added to random
			_randomizer_data.get(RandomizerData.ITEM_RANDOM).push_back(item)
			
			# adds item to a category based on its tags
			for tag in item.tags:
				if randomizer_item_stat_keys.keys().has(tag):
					var key = randomizer_item_stat_keys.get(tag)
					_randomizer_data.get(key).push_back(item)
				else:
					_randomizer_data.get(RandomizerData.ITEM_SECONDARY).push_back(item)
			
			## also adds based on its effects, be it positive or negative
			for effect in item.effects:
				## checks whether it's a tracked key
				if randomizer_item_stat_keys.keys().has(effect.key):
					var key = randomizer_item_stat_keys.get(effect.key)
					# if the item was already added due to its tag, do not add again
					if not _randomizer_data.get(key).has(item):
						_randomizer_data.get(key).push_back(item)
				elif _randomizer_data.get(RandomizerData.ITEM_SECONDARY).has(item):
					_randomizer_data.get(RandomizerData.ITEM_SECONDARY).push_back(item)
	

func get_consumable_to_drop(tier:int = Tier.COMMON)->ConsumableData:
	return Utils.get_rand_element(_tiers_data[tier][TierData.CONSUMABLES])


func process_item_box(wave:int, _consumable_data:ConsumableData, fixed_tier:int = - 1)->ItemParentData:
	
	return get_rand_item_from_wave(wave, TierData.ITEMS, RunData.locked_shop_items, [], fixed_tier)


func get_shop_items(wave:int, number:int = NB_SHOP_ITEMS, shop_items:Array = [], locked_items:Array = [])->Array:
	
	var new_items = []
	var nb_weapons_guaranteed = 0
	var nb_weapons_added = 0
	
	var nb_locked_weapons = 0
	var nb_locked_items = 0
	
	for locked_item in locked_items:
		if locked_item[0] is ItemData:
			nb_locked_items += 1
		elif locked_item[0] is WeaponData:
			nb_locked_weapons += 1
	
	if RunData.current_wave < MAX_WAVE_TWO_WEAPONS_GUARANTEED:
		nb_weapons_guaranteed = 2
	elif RunData.current_wave < MAX_WAVE_ONE_WEAPON_GUARANTEED:
		nb_weapons_guaranteed = 1
	
	if RunData.effects["minimum_weapons_in_shop"] > nb_weapons_guaranteed:
		nb_weapons_guaranteed = RunData.effects["minimum_weapons_in_shop"]
	
	for i in number:
		
		var type
		
		if RunData.current_wave <= MAX_WAVE_TWO_WEAPONS_GUARANTEED:
			type = TierData.WEAPONS if (nb_weapons_added + nb_locked_weapons < nb_weapons_guaranteed) else TierData.ITEMS
		else :
			type = TierData.WEAPONS if (randf() < CHANCE_WEAPON or nb_weapons_added + nb_locked_weapons < nb_weapons_guaranteed) else TierData.ITEMS
		
		if type == TierData.WEAPONS:
			nb_weapons_added += 1
		
		if RunData.effects["weapon_slot"] <= 0:
			type = TierData.ITEMS
		
		new_items.push_back([get_rand_item_from_wave(wave, type, new_items, shop_items), wave])
	
	return new_items


func get_pool(item_tier:int, type:int)->Array:
	return _tiers_data[item_tier][type].duplicate()


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
	
	var categories_pool:Array = _randomizer_data[RandomizerData.CATEGORIES].duplicate()
	
	
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
		
	
	## if its item, already return categories as an item
	if type == TierData.ITEMS:
		var random_cat = Utils.get_rand_element(categories_pool)
		return convert_randomizer_category_to_item(random_cat)
	
	var elt
	
	if pool.size() == 0:
		if backup_pool.size() > 0:

			elt = Utils.get_rand_element(backup_pool)
		else :

			elt = Utils.get_rand_element(_tiers_data[item_tier][type])
	else :
		elt = Utils.get_rand_element(pool)
	
	return elt

func convert_randomizer_category_to_item(category:ShopCategoryData)->ItemParentData:
		var item_element:ItemParentData = ItemParentData.new()
		item_element.icon = category.icon
		item_element.my_id = category.shop_category_id
		item_element.name = category.name
		
		## random number
		item_element.value = 15
		return item_element

func get_tier_from_wave(wave:int)->int:
	var rand = rand_range(0.0, 1.0)
	var tier = Tier.COMMON
	var luck = Utils.get_stat("stat_luck") / 100.0
	
	for i in range(_tiers_data.size() - 1, - 1, - 1):
		var wave_base_chance = max(0.0, ((wave - 1) - _tiers_data[i][TierData.MIN_WAVE]) * _tiers_data[i][TierData.WAVE_BONUS_CHANCE])
		var wave_chance = 0.0
		
		if luck >= 0:
			wave_chance = wave_base_chance * (1 + luck)
		else :
			wave_chance = wave_base_chance / (1 + abs(luck))
		
		var chance = _tiers_data[i][TierData.BASE_CHANCE] + wave_chance
		var max_chance = _tiers_data[i][TierData.MAX_CHANCE]
		

		
		if rand <= min(chance, max_chance):
			tier = i
			break
	
	return tier


func get_upgrades(level:int, number:int, old_upgrades:Array)->Array:
	var upgrades_to_show = []
	
	for i in number:
		var upgrade = get_upgrade_data(level)
		var tries = 0
		
		while (is_upgrade_already_added(upgrades_to_show, upgrade) or is_upgrade_already_added(old_upgrades, upgrade)) and tries < 50:
			upgrade = get_upgrade_data(level)
			tries += 1
		
		upgrades_to_show.push_back(upgrade)
	
	return upgrades_to_show


func is_upgrade_already_added(p_upgrades:Array, upgrade:UpgradeData)->bool:
	
	for upg in p_upgrades:
		if upg.upgrade_id == upgrade.upgrade_id:
			return true
	
	return false


func get_upgrade_data(level:int)->UpgradeData:
	var tier = get_tier_from_wave(level)
	
	if level == 5:
		tier = Tier.UNCOMMON
	elif level == 10 or level == 15 or level == 20:
		tier = Tier.RARE
	elif level % 5 == 0:
		tier = Tier.LEGENDARY
	
	return Utils.get_rand_element(_tiers_data[tier][TierData.UPGRADES])


func get_color_from_tier(tier:int, dark_version:bool = false)->Color:
	match tier:
		Tier.UNCOMMON:
			return TIER_UNCOMMON_COLOR_DARK if dark_version else TIER_UNCOMMON_COLOR
		Tier.RARE:
			return TIER_RARE_COLOR_DARK if dark_version else TIER_RARE_COLOR
		Tier.LEGENDARY:
			return TIER_LEGENDARY_COLOR_DARK if dark_version else TIER_LEGENDARY_COLOR
		Tier.DANGER_0:
			return TIER_DANGER_0_COLOR_DARK if dark_version else TIER_DANGER_0_COLOR
		Tier.DANGER_4:
			return TIER_DANGER_4_COLOR_DARK if dark_version else TIER_DANGER_4_COLOR
		Tier.DANGER_5:
			return TIER_DANGER_5_COLOR_DARK if dark_version else TIER_DANGER_5_COLOR
		_:
			return Color.white


func get_tier_text(tier:int)->String:
	if tier == 0:return "TIER_COMMON"
	elif tier == 1:return "TIER_UNCOMMON"
	elif tier == 2:return "TIER_RARE"
	else :return "TIER_LEGENDARY"


func get_tier_number(tier:int)->String:
	if tier == 0:return ""
	elif tier == 1:return "II"
	elif tier == 2:return "III"
	else :return "IV"


func get_weapon_classes_text(weapon_classes:Array)->String:
	var text = ""
	
	for weapon_class in weapon_classes:
		text += tr(get_weapon_class_text(weapon_class)) + ", "
	
	text = text.trim_suffix(", ")
	
	return text


func get_weapon_class_text(c:int)->String:
	if c == WeaponClass.PRIMITIVE:return "WEAPON_CLASS_PRIMITIVE"
	elif c == WeaponClass.BLADE:return "WEAPON_CLASS_BLADE"
	elif c == WeaponClass.PRECISE:return "WEAPON_CLASS_PRECISE"
	elif c == WeaponClass.BLUNT:return "WEAPON_CLASS_BLUNT"
	elif c == WeaponClass.ELEMENTAL:return "WEAPON_CLASS_ELEMENTAL"
	elif c == WeaponClass.GUN:return "WEAPON_CLASS_GUN"
	elif c == WeaponClass.HEAVY:return "WEAPON_CLASS_HEAVY"
	elif c == WeaponClass.SUPPORT:return "WEAPON_CLASS_SUPPORT"
	elif c == WeaponClass.UNARMED:return "WEAPON_CLASS_UNARMED"
	elif c == WeaponClass.ETHEREAL:return "WEAPON_CLASS_ETHEREAL"
	elif c == WeaponClass.MEDICAL:return "WEAPON_CLASS_MEDICAL"
	elif c == WeaponClass.TOOL:return "WEAPON_CLASS_TOOL"
	elif c == WeaponClass.EXPLOSIVE:return "WEAPON_CLASS_EXPLOSIVE"
	elif c == WeaponClass.MEDIEVAL:return "WEAPON_CLASS_MEDIEVAL"
	else :return "WEAPON_CLASS_NONE"


func get_category_text(category:int)->String:
	if category == Category.ITEM:return "CATEGORY_ITEM"
	else :return "CATEGORY_WEAPON"


func change_panel_stylebox_from_tier(stylebox:StyleBoxFlat, tier:int, alpha:float = 1)->void :
	var tier_color = get_color_from_tier(tier)
	var dark_tier_color = get_color_from_tier(tier, true)
	
	if tier_color == Color.white:
		tier_color = Color.black
	
	if dark_tier_color == Color.white:
		dark_tier_color = Color.black
	
	if alpha < 1:
		tier_color.a = alpha
		dark_tier_color.a = alpha
	
	stylebox.border_color = tier_color
	stylebox.bg_color = dark_tier_color


func change_inventory_element_stylebox_from_tier(stylebox:StyleBoxFlat, tier:int, alpha:float = 1)->void :
	var tier_color = get_color_from_tier(tier)
	
	if tier_color == Color.white:
		tier_color = Color.black
		tier_color.a = 0.39
	else :
		tier_color.a = alpha
	
	stylebox.bg_color = tier_color


func get_value(wave:int, base_value:int, affected_by_items_price_stat:bool = true, is_weapon:bool = false)->int:
	var value_after_weapon_price = base_value if not is_weapon or not affected_by_items_price_stat else base_value * (1.0 + (RunData.effects["weapons_price"] / 100.0))
	
	var items_price_factor = (1.0 + (RunData.effects["items_price"] / 100.0)) if affected_by_items_price_stat else 1.0
	
	var diff_factor = (RunData.effects["inflation"] / 100.0) if affected_by_items_price_stat else 0.0
	
	return max(1.0, ((value_after_weapon_price + wave + (value_after_weapon_price * wave * (0.1 + diff_factor))) * items_price_factor)) as int


func get_reroll_price(wave:int, last_reroll_value:int)->int:
	return max(1.0, last_reroll_value + max(1.0, 0.5 * wave)) as int


func get_recycling_value(wave:int, from_value:int, is_weapon:bool = false, affected_by_items_price_stat:bool = true)->int:
	return max(1.0, (get_value(wave, from_value, affected_by_items_price_stat, is_weapon) * clamp((0.25 + (RunData.effects["recycling_gains"] / 100.0)), 0.01, 1.0))) as int


func get_element(from_array:Array, id:String = "", value:int = - 1)->Resource:
	for elt in from_array:
		if elt.my_id == id or (id == "" and elt.value == value):
			return elt
	
	return null


func get_set(p_set:int)->SetData:
	for set in sets:
		if set.weapon_class == p_set:
			return set
	
	return SetData.new()


func get_stat_icon(stat_name:String)->Resource:
	for stat in stats:
		if stat.stat_name == stat_name:
			return stat.icon
	
	return null


func get_stat_small_icon(stat_name:String)->Resource:
	for stat in stats:
		if stat.stat_name == stat_name:
			return stat.small_icon
	
	return null
