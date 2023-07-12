class_name ReactiveArray extends RefCounted

var arr:Array = []
var rarr = []
var ids:Dictionary = {}
var dep:Dep = Dep.new()

func _init(arr):
	self.arr = arr
	observe()

func observe():
	for value in arr:
		if value is Dictionary:
			rarr.append(ReactiveDictionary.new(value))
		elif value is Array:
			rarr.append(ReactiveArray.new(value))
		else:
			rarr.append(value)

func gen_ids(rootName):
	if !ids.has(rootName):
		ids[rootName] = []
		for value in arr:
			ids[rootName].append(str(randi()))

func rappend(value):
	if value is Dictionary:
		rarr.append(ReactiveDictionary.new(value))
	else:
		rarr.append(value)
	for key in ids:
		ids[key].append(str(randi()))
	arr.append(value)
	dep.notify()

func rinsert(index, value):
	if value is Dictionary:
		rarr.insert(index, ReactiveDictionary.new(value))
	else:
		rarr.insert(index, value)
	arr.insert(index, value)
	for key in ids:
		ids[key].insert(index, str(randi()))
	dep.notify()

func remove(index):
	rarr.remove_at(index)
	arr.remove_at(index)
	for key in ids:
		ids[key].remove_at(index)
	dep.notify()
	
func rsize():
	if Values.curWatcher != null:
		dep.depend()
	return rarr.size()

func rget(index):
	if Values.curWatcher != null:
		dep.depend()
	return rarr[index]

func rset(index, value)->void:
	arr[index] = value
	if value is Dictionary:
		rarr[index] = ReactiveDictionary.new(value)
	else:
		rarr[index] = value
	dep.notify()

func rappend_array(array):
	for value in array:
		rappend(value)
	dep.notify()
