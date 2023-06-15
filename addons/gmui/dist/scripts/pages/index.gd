extends "res://addons/gmui/dist/super_scripts/Column.gd"

func _mounted():
	vm.refs['btn'].rnode.pressed.connect(
		func():
			self.jump_to('res://pages/page.gmui')
	)
