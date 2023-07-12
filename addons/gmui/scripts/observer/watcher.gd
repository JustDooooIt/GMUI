class_name Watcher extends RefCounted

var getter = null
var deps:Array[Dep] = []
var obj = Object()
var depIds = {}
var value
var dirty = true
var lazy = false


func _init(getter:Callable, lazy:bool = false):
	var watId = Values.watId
	Values.watId += 1
	self.depIds = {}
	self.getter = getter
	self.lazy = lazy
	if !lazy:
		self._get_()

func eval():
	self.value = _get_()
	self.dirty = false

func _get_():
	Values.push_watcher(self)
	var value = self.getter.call()
	Values.pop_watcher()
	return value

func depend():
	var i:int = deps.size()
	while i >= 0:
		i -= 1
		deps[i].depend()

func addDep(dep):
	if !depIds.has(dep.id):
		deps.append(dep)
		depIds[dep.id] = obj
		dep.addSub(self)

func update():
	if lazy:
		self.dirty = true
	self._get_()
