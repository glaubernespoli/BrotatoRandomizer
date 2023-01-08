class_name UniqueWeaponEffect
extends StatEffect


func get_args()->Array:
	var args = .get_args()
	var nb_weapons = RunData.get_unique_weapon_ids().size()
	var val = nb_weapons * value
	
	args.append(str(val))
	
	return args
