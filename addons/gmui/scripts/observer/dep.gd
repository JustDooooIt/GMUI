@tool
class_name Dep extends RefCounted

var subs = []
var id = 0

func _init():
	self.id = _values.depId
	_values.depId += 1

func depend():
	_values.curWatcher.addDep(self)

func addSub(watcher):
	self.subs.append(watcher)

func notify():
	for sub in subs:
		sub.update()
