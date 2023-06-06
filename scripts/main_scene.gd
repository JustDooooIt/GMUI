extends "res://addons/gmui/scripts/common/g_node_2d.gd"

@onready var data = vm.define_reactive({'visible': false, 'text': 'text'})
	
func _mounted():
	await get_tree().create_timer(5).timeout
	data.rset('visible', true)
	print('mounted')

func _updated():
	print('updated')
