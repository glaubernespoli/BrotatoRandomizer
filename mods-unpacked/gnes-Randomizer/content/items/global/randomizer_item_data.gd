class_name RandomizerItemData
extends ItemParentData

func get_category()->int:
	return Category.ITEM

#TODO
func get_effects_text()->String:
	var text = ""
	
	for effect in effects:
		var effect_text = effect.get_text()
		
		text += effect_text
		
		if effect_text != "":
				text += "\n"
	
	if RunData.tracked_item_effects.has(my_id):
		text += "[color=#" + Utils.SECONDARY_FONT_COLOR.to_html() + "]" + Text.text(tracking_text, [str(RunData.tracked_item_effects[my_id])]) + "[/color]"
	
	return text
