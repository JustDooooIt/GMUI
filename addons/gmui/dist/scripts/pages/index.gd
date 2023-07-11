extends "res://addons/gmui/dist/super_scripts/pages/index.gd"


var data = await reactive({'text': 'text'})

func _ready():
	watch('text', change_text)

func change_text(newValue, oldValue):
	print(newValue, ',', oldValue)
