extends "res://addons/gmui/scripts/common/gnode_2d.gd"

@onready var data = vm.define_reactive({'text': 'text'})

func _mounted():
	print('mounted')

func _updated():
	print('updated')
