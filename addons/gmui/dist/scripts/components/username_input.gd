extends "res://addons/gmui/dist/super_scripts/HBoxContainer.gd"

func _updated():
	print(vm.data.rget('username'))
