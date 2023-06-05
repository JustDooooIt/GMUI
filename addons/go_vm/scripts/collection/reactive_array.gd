class_name ReactiveArray extends RefCounted

var arr = []
var rarr = null

func _init(arr):
	self.arr = arr
	self.rarr = arr.duplicate(true)
	observe()

func observe():
	for value in arr:
		if value is Dictionary:
			rarr.append(ReactiveDictionary.new(value))
		elif value is Array:
			rarr.append(ReactiveArray.new(value))
		else:
			rarr.append(value)

func rappend(value):
	if value is Dictionary:
		rarr.append(ReactiveDictionary.new(value))
	arr.append(value)

func rget(index):
	return rarr[index]

func rappend_array(array):
	for value in array:
		rarr.rappend(value)
