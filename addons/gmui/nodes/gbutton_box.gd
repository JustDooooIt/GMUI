class_name GButtonBox extends BoxContainer

var buttonGroup:ButtonGroup = ButtonGroup.new()
signal init_finish

func _node_init():
	for child in get_children():
		child.button_group = buttonGroup
	emit_signal('init_finish')
