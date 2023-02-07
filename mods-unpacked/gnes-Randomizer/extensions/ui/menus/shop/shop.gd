extends "res://ui/menus/shop/shop.gd"

func on_shop_item_bought(shop_item:ShopItem)->void :
	.on_shop_item_bought(shop_item)
	
	if shop_item.item_data.get_category() == Category.ITEM:
		## removes category item from bought item
		RunData.remove_item(shop_item.item_data)
		
		## adds a random item based on the category
		shop_item.item_data = ItemService.get_random_item_from_randomizer_category(shop_item.item_data)
		RunData.add_item(shop_item.item_data)
		
		## emits signal to the item bought after updating the shop_item.item_data
		emit_signal("item_bought", shop_item.item_data)
