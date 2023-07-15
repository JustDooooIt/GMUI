extends "res://addons/gmui/dist/super_scripts/components/check_box_component.gd"



@onready var buttonGroup:ButtonGroup = ButtonGroup.new()
@onready var data = await reactive({'index': 0})

func _mounted():
	for checkBox in gmui.refs['checkBox']:
		checkBox.exec_func('set_button_group', [buttonGroup])
