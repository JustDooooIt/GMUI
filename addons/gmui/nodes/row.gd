class_name Row extends HBoxContainer

var align:String

func _node_init():
	set_align()

func set_align():
	set_anchors_and_offsets_preset(PRESET_TOP_WIDE)
	match align:
		'left':
			alignment = ALIGNMENT_BEGIN
		'center':
			alignment = ALIGNMENT_CENTER
		'right':
			alignment = ALIGNMENT_END
		'equal':
			for child in get_children():
				child.size_flags_horizontal = SIZE_EXPAND_FILL
