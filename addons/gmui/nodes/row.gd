class_name Row extends HBoxContainer

var align:String

func _node_init():
	set_align()

func set_align():
	match align:
		'left':
			set_anchors_and_offsets_preset(Control.PRESET_LEFT_WIDE)
			alignment = BoxContainer.ALIGNMENT_BEGIN
		'center':
			set_anchors_and_offsets_preset(Control.PRESET_VCENTER_WIDE)
			alignment = BoxContainer.ALIGNMENT_CENTER
		'right':
			set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
			alignment = BoxContainer.ALIGNMENT_END
