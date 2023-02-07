extends Node

## different data types from the randomizer
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

## map of stat keys to a randomizer category
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

var _randomizer_data:Dictionary

export (Array, Resource) var randomizer_categories: = []

## Empties the data
func reset_randomizer_data()->void :
	_randomizer_data = {}

## Initializes the pool of items to category
func init_randomizer_pool(items)->void:
	
	## initializing arrays
	for randomizer_entry in RandomizerData:
		_randomizer_data[randomizer_entry] = []
	
	## adding randomizer categories
	get_items_from(RandomizerData.ITEM_CATEGORIES).append_array(randomizer_categories)
	
	
	for item in items:
		if ProgressData.items_unlocked.has(item.my_id):
			
			var categories_added_to = []
			
			## always added to random
			push_item_to_category(item, RandomizerData.ITEM_RANDOM, categories_added_to)
			
			# adds item to a category based on its tags
			for tag in item.tags:
				if randomizer_item_stat_keys.keys().has(tag):
					var category = randomizer_item_stat_keys.get(tag)
					push_item_to_category(item, category, categories_added_to)
				else:
					push_item_to_category(item, RandomizerData.ITEM_SECONDARY, categories_added_to)
			
			## also adds based on its effects, be it positive or negative
			for effect in item.effects:
				## checks whether it's a tracked key
				if randomizer_item_stat_keys.keys().has(effect.key):
					var category = randomizer_item_stat_keys.get(effect.key)
					# if the item was already added due to its tag, do not add again
					if not get_items_from(category).has(item):
						push_item_to_category(item, category, categories_added_to)
				elif get_items_from(RandomizerData.ITEM_SECONDARY).has(item):
					push_item_to_category(item, RandomizerData.ITEM_SECONDARY, categories_added_to)

# Utility function to deal with how enums as a key work in GDScript
func get_items_from(entry)->Array:
	return _randomizer_data[RandomizerData.keys()[entry]]

## Adds an item to a category if it hasn't been added to that category yet
func push_item_to_category(item, category, categories_added_to)->void:
	if not categories_added_to.has(category):
		get_items_from(category).push_back(item)
		categories_added_to.push_back(category)

## Returns a random item based on the id of the category that was passed as a mocked item to the shop
func get_random_item_from_randomizer_category(item)->ItemParentData:

	var items = get_items_from(randomizer_item_stat_keys.get(item.my_id))
	return Utils.get_rand_element(items)

## Returns the pool of categories
func get_categories_pool()->Array:
	return get_items_from(RandomizerData.ITEM_CATEGORIES).duplicate()

## Converts a randomizer category to a Item data that is recognized by the game, using a new class to override the text method. 
## Wave is used to calculate the item price
func convert_randomizer_category_to_item(category:ShopCategoryData, wave:int)->ItemParentData:
		var item_element:ItemParentData = RandomizerItemData.new()
		item_element.icon = category.icon
		item_element.my_id = category.shop_category_id
		item_element.name = category.name
		
		## random numberfor price
		item_element.value = generate_random_item_price_for(item_element, wave)
		return item_element


##TODO
## Generates a random price value for the item, based on the current wave
func generate_random_item_price_for(item:ItemParentData, wave:int)->int:
	return 15
