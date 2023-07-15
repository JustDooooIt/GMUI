extends "res://addons/gmui/dist/super_scripts/components/check_button_component.gd"



@onready var buttonGroup:ButtonGroup = ButtonGroup.new()
@onready var data = await reactive({'index': 0})

func _mounted():
	for checkButton in gmui.refs['checkButton']:
		checkButton.exec_func('set_button_group', [buttonGroup])
