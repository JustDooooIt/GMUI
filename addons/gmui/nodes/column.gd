class_name Column extends VBoxContainer

var align

func _node_init():
	if 'top' == align:
		set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
		alignment = BoxContainer.ALIGNMENT_BEGIN
	elif 'center' == align:
		set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
		alignment = BoxContainer.ALIGNMENT_CENTER
	elif 'bottom' == align:
		set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
		alignment = BoxContainer.ALIGNMENT_END
