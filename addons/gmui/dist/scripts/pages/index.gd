extends "res://addons/gmui/dist/super_scripts/pages/index.gd"


var data = await reactive({'firstName': 'zhang', 'lastName': 'san'})

func _ready():
	computed(fullName)

func fullName():
	return data.rget('firstName') + data.rget('lastName')

func _mounted():
	data.rset('firstName', 'li')

