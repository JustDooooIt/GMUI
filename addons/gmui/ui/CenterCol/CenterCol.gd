class_name CenterCol extends VBoxContainer

func _init():
	ready.connect(func(): self.set_anchors_preset(Control.PRESET_CENTER, true))
