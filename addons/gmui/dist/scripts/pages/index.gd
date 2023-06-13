extends "res://addons/gmui/dist/super_scripts/Column.gd"

@onready var data = vm.define_reactive({'username': 'name', 'password': '123'})
func _mounted():
	vm.refs['loginBtn'].rnode.pressed.connect(
		func():
			print('username:', data.rget('username'))
			print('password:', data.rget('password'))
	)
	vm.refs['resetBtn'].rnode.pressed.connect(
		func():
			data.rset('username', '')
			data.rset('password', '')
	)
func _updated():
	print('username:', data.rget('username'))
	print('password:', data.rget('password'))
