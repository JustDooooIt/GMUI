class_name Row extends HBoxContainer

var align

func _node_init():
	if 'left' == align:
		set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
		alignment = BoxContainer.ALIGNMENT_BEGIN
	elif 'center' == align:
		set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
		alignment = BoxContainer.ALIGNMENT_CENTER
	elif 'right' == align:
		set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		alignment = BoxContainer.ALIGNMENT_END
