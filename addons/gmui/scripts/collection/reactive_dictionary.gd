class_name ReactiveDictionary extends RefCounted

var data:Dictionary = {}
var rdata:Dictionary = {}
var dep = Dep.new()
signal setted(key, value)

#暂时无法处理props和data命名冲突问题
func _init(data = {}):
	self.data = data
	self.rdata = data.duplicate(true)
	observe()

func merge(data= {}):
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

func has(key):
	var keys = key.split('.')
	if keys.size() < 2:
		return data.has(key)
	else:
		var d = data.get(keys[0], null)
		if d == null:
			return false
		var index = 1
		for i in range(1, keys.size() - 1):
			if d is Dictionary:
				d = d[keys[i]]
				index += 1
		return d.has(keys[index])

func __rget(key):
	if Values.curWatcher != null:
		dep.depend()
	var keys = key.split('.')
	if keys.size() < 2:
		return rdata[key]
	else:
		var d = rdata.get(keys[0])
		for i in range(1, keys.size()):
			if d is ReactiveDictionary:
				d = d.rget(keys[i])
		return d

func rget(key):
	if Values.curWatcher != null:
		dep.depend()
	var keys = key.split('.')
	if keys.size() < 2:
		if !data.has(key): return null
		if data[key] is Array:
			return rdata[key]
		else:
			return data[key]
	else:
		var d = data.get(keys[0])
		var rd = rdata.get(keys[0])
		for i in range(1, keys.size()):
			if !d.has(keys[i]):
				return null
			if d is Dictionary:
				d = d.get(keys[i])
				rd = rd.get(keys[i])
		if d is Array:
			return rd
		else:
			return d

func rset(key, value, canNotify = true, isEmit = true):
	var keys = key.split('.')
	if keys.size() < 2:
		self.data[key] = value
		self.rdata[key] = value
	else:
		var d = data[keys[0]]
		var rd = null
		for i in range(1, keys.size() - 1):
			if d is Dictionary:
				d = d[keys[i]]
				rd = rd.rget(key[i])
		d[keys[keys.size() - 1]] = value
		rd.rset(keys[keys.size() - 1], value)
#	if value is Dictionary:
#		self.rdata[key] = ReactiveDictionary.new(data[key])
	if canNotify:
		dep.notify()
	if isEmit:
		emit_signal('setted', key, value)

func copy():
	var reactiveDict = ReactiveDictionary.new()
	reactiveDict.data = self.data.duplicate()
	reactiveDict.rdata = self.rdata.duplicate()
	return reactiveDict
