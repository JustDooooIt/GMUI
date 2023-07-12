extends "res://addons/gmui/dist/super_scripts/pages/index1.gd"


func _mounted():
	gmui.refs['my_button'].rnode.pressed.connect(
		func():
			print(gmui.refs['my_button'].rnode.text)
	)
