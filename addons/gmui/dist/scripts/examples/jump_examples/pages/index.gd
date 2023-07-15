extends "res://addons/gmui/dist/super_scripts/examples/jump_examples/pages/index.gd"


func _mounted():
	gmui.refs['btn'].rnode.pressed.connect(
		func():
			self.jump_to('res://pages/page2.gmui')
	)
