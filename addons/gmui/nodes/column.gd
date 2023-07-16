class_name Column extends VBoxContainer

var align:String

func _node_init():
	set_align()

func set_align():
	set_anchors_and_offsets_preset(PRESET_LEFT_WIDE)
	match align:
		'top':
			alignment = ALIGNMENT_BEGIN
		'center':
			alignment = ALIGNMENT_CENTER
		'bottom':
			alignment = ALIGNMENT_END
		'equal':
			for child in get_children():
				child.size_flags_vertical = SIZE_EXPAND_FILL
