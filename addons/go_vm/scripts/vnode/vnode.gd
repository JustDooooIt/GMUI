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
var parent = null
var children = []
var rnode = null

func replace(newVNode):
	if parent == null:
		return
	var index = parent.children.find(self)
	parent.children[index] = newVNode
	
