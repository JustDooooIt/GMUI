extends "res://addons/gmui/dist/super_scripts/pages/index.gd"


func _mounted():
	self.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gmui.refs['my_button'].rnode.pressed.connect(
		func():
			print(gmui.refs['my_button'].rnode.text)
	)
