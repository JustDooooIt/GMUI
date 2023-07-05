class_name Dep extends RefCounted

var subs:Array[Watcher] = []
var id:int = 0

func _init():
	self.id = Values.depId
	Values.depId += 1

func depend()->void:
	Values.curWatcher.addDep(self)

func addSub(watcher:Watcher)->void:
	self.subs.append(watcher)

func notify()->void:
	for sub in subs:
		sub.update()
