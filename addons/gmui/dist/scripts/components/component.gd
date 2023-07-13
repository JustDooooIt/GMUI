extends "res://addons/gmui/dist/super_scripts/components/component.gd"


var data = await reactive({'text': 'new text'})

func _mounted():
	data.rset('text', 'new Text 1')
