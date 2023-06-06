class_name ReactiveDictionary extends RefCounted

var data = {}
var rdata = null
var dep = Dep.new()

func _init(data = {}):
	self.data = data
	self.rdata = data.duplicate(true)
	observe()
	
func observe():
	if data == null: return
	if data is Dictionary:
		for key in data.keys():
			if data[key] is Dictionary:
				self.rdata[key] = ReactiveDictionary.new(data[key])
			elif data[key] is Array:
				self.rdata[key] = ReactiveArray.new(data[key])				

func rget(key):
	if _values.curWatcher != null:
		dep.depend()
	if data[key] is Dictionary:
		return rdata[key]
	elif data[key] is Array:
		return rdata[key]
	else:
		return data[key]

func rset(key, value, canNotify = true):
	self.data[key] = value
	self.rdata[key] = value
	if value is Dictionary:
		self.rdata[key] = ReactiveDictionary.new(data[key])
	if canNotify:
		dep.notify()

func _reverse_rset(value, key, canNotify = true):
	rset(key, value, canNotify)
