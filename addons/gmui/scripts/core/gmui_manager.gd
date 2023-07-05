extends Node

var gmuis:Dictionary = {}

func add_gmui(name:String, gmui:GMUI, parent:GMUI)->void:
	gmui.name = name
	gmui.parent = parent
	gmuis[name] = gmui
