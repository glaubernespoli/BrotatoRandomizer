class_name AnvilEffect
extends Effect

export (int) var stat_value = 1
export (String) var stat_name = "stat_armor"


static func get_id()->String:
	return "anvil"


func get_args()->Array:
	return [str(stat_value), tr(str(stat_name.to_upper()))]
