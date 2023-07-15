class_name Column extends VBoxContainer

var align:String

func _node_init():
	set_align()

func set_align():
	match align:
		'top':
			set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
			alignment = BoxContainer.ALIGNMENT_BEGIN
		'center':
			set_anchors_and_offsets_preset(Control.PRESET_HCENTER_WIDE)
			alignment = BoxContainer.ALIGNMENT_CENTER
		'bottom':
			set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
			alignment = BoxContainer.ALIGNMENT_END
