class_name AdditionalWeaponEffect
extends StatEffect


func get_args()->Array:
	var args = .get_args()
	var nb_weapons = RunData.weapons.size()
	var val = nb_weapons * value
	
	args.append(str(val))
	
	return args
