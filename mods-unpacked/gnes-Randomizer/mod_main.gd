extends Node


const MOD_NAME = "gnes-Randomizer"
const MOD_DIR = str(MOD_NAME, "/")

var dir = ""
var ext_dir = ""
var trans_dir = ""
var content_dir = ""

func _init(modLoader = ModLoader):
	ModLoaderUtils.log_info("Init", MOD_NAME)
	
	dir = modLoader.UNPACKED_DIR + MOD_DIR
	ext_dir = dir + "extensions/"
	trans_dir = dir + "translations/"
	content_dir = dir + "content/"
	
	#Add custom classes
	## Should use the method from the modLoader in development, once a new version is released.
	_register_global_classes_from_array(_get_randomizer_global_classes())
	
	#Add custom singletons
	## Copied from contentLoader, to add a new service to the node. Hopes a utils method is added in the future to the contentLoader to handle this situation.
	_add_child_classes()
	
	
	# Add extensions
	modLoader.install_script_extension(ext_dir + "singletons/item_service.gd")
	modLoader.install_script_extension(ext_dir + "ui/menus/shop/shop.gd")
	
	# Add translations
	modLoader.add_translation_from_resource(trans_dir + "randomizer_text.en.translation")
	


func _ready():
	_load_randomizer_content()


func _load_randomizer_content():
	ModLoaderUtils.log_info("Ready State Started", MOD_NAME)
	
	var contentLoader = get_node("/root/ModLoader/Darkly77-ContentLoader/ContentLoader")
	
	# Categories
	contentLoader.load_data(dir + "content_data/categories/randomizer_categories.tres", MOD_NAME)


func _get_randomizer_global_classes()->Array:
	var classes = []
	
	classes.append({ "base": "ItemParentData", "class": "RandomizerItemData", "language": "GDScript", "path": content_dir + "items/global/randomizer_item_data.gd" })
	classes.append({ "base": "Resource", "class": "ShopCategoryData", "language": "GDScript", "path": content_dir + "items/global/shop_category_data.gd" })
	classes.append({ "base": "ShopCategoryData", "class": "ItemShopCategoryData", "language": "GDScript", "path": content_dir + "items/global/item_shop_category_data.gd" })
	
	return classes


## TEMP FUNCTION. should use the one from modLoader from future versions
func _add_child_classes():
	var RandomizerService = load(content_dir + "singletons/randomizer_service.gd").new()
	RandomizerService.name = "RandomizerService"
	add_child(RandomizerService)

## TEMP FUNCTION. should use the one from modLoader from future versions
func _register_global_classes_from_array(new_global_classes: Array) -> void:
	var registered_classes: Array = ProjectSettings.get_setting("_global_script_classes")
	var registered_class_icons: Dictionary = ProjectSettings.get_setting("_global_script_class_icons")

	for new_class in new_global_classes:
		ModLoaderUtils.log_info("Adding class: " + new_class, MOD_NAME)
		registered_classes.append(new_class)
		registered_class_icons[new_class.class] = "" # empty icon, does not matter
		
	
	ProjectSettings.set_setting("_global_script_classes", registered_classes)
	ProjectSettings.set_setting("_global_script_class_icons", registered_class_icons)
