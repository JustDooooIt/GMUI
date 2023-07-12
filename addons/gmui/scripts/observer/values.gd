extends Node

var curWatcher:Watcher = null
var depId = 0
var watId = 0
var stack:Array[Watcher] = []

func push_watcher(watcher:Watcher):
	curWatcher = watcher
	stack.push_back(watcher)
	
func pop_watcher():
	stack.pop_back()
	if stack.size() > 0:
		curWatcher = stack[stack.size() - 1]
	else:
		curWatcher = null
