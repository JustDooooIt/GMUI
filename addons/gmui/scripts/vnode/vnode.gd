class_name VNode extends RefCounted

var type = ''
var name = ''
var path = ''
var isComponent = false
var sceneXMLPath = ''
var isRoot = false
var isScene = false
var bindDict = {}
var slotDict = {}
var properties = {}
var model = {}
var vmId = null
var vm = null
var ref = {}
var id = {}
var parent = null
var children = []
var rnode = null
var isReplace = false
var isBuiltComponent = false
var commands = []

func replace(newVNode):
	if parent == null:
		return
	var index = parent.children.find(self)
	parent.children[index] = newVNode
	
func exec_func(funcName, args=[]):
	var callable = Callable(rnode, funcName)
#	callable = callable.bindv(args)
	var res = callable.callv(args)
	for key in properties:
		var prop = properties[key]
		if prop != rnode.get(key):
			properties[key] = rnode.get(key)
	return res

func set(name, value):
	rnode.set(name, value)
	for key in properties:
		var prop = properties[key]
		if prop != rnode.get(key):
			properties[key] = rnode.get(key)
