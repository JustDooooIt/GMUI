extends "res://addons/gmui/dist/super_scripts/Row.gd"

func _updated():
	print(vm.data.rget('username'))
