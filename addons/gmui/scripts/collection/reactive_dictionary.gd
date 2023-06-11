class_name ReactiveDictionary extends RefCounted

var data = {}
var rdata = null
var dep = Dep.new()
signal setted(key, value)

func _init(data = {}):
	self.data = data
	self.rdata = data.duplicate(true)
	observe()
	
func observe():
	if data == null or data.is_empty(): return
	if data is Dictionary:
		for key in data.keys():
			if data[key] is Dictionary:
				self.rdata[key] = ReactiveDictionary.new(data[key])
			elif data[key] is Array:
				self.rdata[key] = ReactiveArray.new(data[key])

func rget(key):
	if _values.curWatcher != null:
		dep.depend()
	var keys = key.split('.')
	if keys.size() < 2:
#		if data[key] is Dictionary:
#			return rdata[key]
#		elif data[key] is Array:
#			return rdata[key]
#		else:
		return data[key]
	else:
		var d = data[keys[0]]
		for i in range(1, keys.size()):
			if d is Dictionary:
				d = d[keys[i]]
		return d

func rset(key, value, canNotify = true):
	var keys = key.split('.')
	if keys.size() < 2:
		self.data[key] = value
		self.rdata[key] = value
	else:
		var d = data[keys[0]]
		for i in range(1, keys.size() - 1):
			if d is Dictionary:
				d = d[keys[i]]
		d[keys[keys.size() - 1]] = value
#	if value is Dictionary:
#		self.rdata[key] = ReactiveDictionary.new(data[key])
	if canNotify:
		dep.notify()
	emit_signal('setted', key, value)

func rset_rnode(key, rnode):
	var value = rnode.get(key)
	rset(key, value)

func _rset(value, key, canNotify = true):
	rset(key, value, canNotify)
