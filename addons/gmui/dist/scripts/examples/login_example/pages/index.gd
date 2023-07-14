extends "res://addons/gmui/dist/super_scripts/examples/login_example/pages/index.gd"


@onready var data = await reactive({'username': 'name', 'password': '123'})
func _mounted():
	gmui.refs['loginBtn'].rnode.pressed.connect(
		func():
			print('username:', data.rget('username'))
			print('password:', data.rget('password'))
	)
	gmui.refs['resetBtn'].rnode.pressed.connect(
		func():
			data.rset('username', '')
			data.rset('password', '')
	)
func _updated():
	print('username:', data.rget('username'))
	print('password:', data.rget('password'))
