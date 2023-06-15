extends "res://addons/gmui/dist/super_scripts/Control.gd"

@onready var data = vm.define_reactive({'text': 'my text'})
func _updated():
	print(data.rget('text'))
