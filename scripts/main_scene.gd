extends "res://addons/go_vm/scripts/common/root_node_2d.gd"


@onready var data = vm.define_reactive({'visible': false})
	
func _mounted():
#	data.rset('visible', true)
	print('mounted')

func _updated():
	print('updated')
