class_name Watcher extends RefCounted

var getter = null
var deps = []
var obj = Object()
var depIds = {}

func _init(getter):
	var watId = _values.watId
	_values.watId += 1
	self.depIds = {}
	self.getter = getter
	self._get_()

func _get_():
	_values.curWatcher = self
	self.getter.call()
	_values.curWatcher = null

func addDep(dep):
	if !depIds.has(dep.id):
		deps.append(dep)
		depIds[dep.id] = obj
		dep.addSub(self)

func update():
	self._get_()
