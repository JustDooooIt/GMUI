extends Node

func box(value:Variant):
	var boxValue:RefCounted = null
	if value is String:
		boxValue = StringBox.new()
	elif value is int:
		boxValue = IntBox.new()
	boxValue.value = value
	return boxValue

func unBox(boxValue:RefCounted):
	return boxValue.value
