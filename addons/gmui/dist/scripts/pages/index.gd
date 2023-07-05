extends "res://addons/gmui/dist/super_scripts/pages/index.gd"



@onready var data = await reactive(
	{
		'textArr': ['slot1', 'slot2', 'slot3'],
		'items': [1,2,3]
	}
)
