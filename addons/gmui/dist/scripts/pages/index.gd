extends "res://addons/gmui/dist/super_scripts/pages/index.gd"


@onready var data = await reactive({'textArr': ['text1', 'text2', 'text3']})
func _mounted():
	data.rget('textArr').rappend('text4')
