class_name VNode extends RefCounted

var type:String = ''
var name:String = ''
var parent:VNode = null
var isStatic:bool = false
var vnodeType:VNodeType = VNodeType.NORMAL
var rnode = null
var isSceneRoot:bool = false
var sceneXmlPath:String = ''
var sceneNode = null
var sceneAst:ASTNode = null
var astNode:ASTNode = null
var isRoot:bool = false
var properties:Dictionary = {}
var ref:Dictionary = {}
var id:Dictionary = {}
var refName:String = ''
var gmui:GMUI = null
var __gmui:GMUI = null
var hasFor = false
var forValue:ForValue = null
var templates:Dictionary = {}
var slots:Dictionary = {}
var slotName:String = ''
var templateName:String = ''
var commands:Array[Dictionary] = []
var index:int = 0
var props:Array[Prop] = []
var bindDict:Dictionary = {}
var ifValue:IfValue = null
var model:Model = null
var models:Array[Model] = []
var sceneRoot:VNode = null
var slotParam:String = ''
var children:Array[VNode] = []

func exec_func(funcName, args = []):
	var callable = Callable(rnode, funcName)
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

enum VNodeType {
	NORMAL, STATIC, MULTI_SCENE_ROOT, SINGAL_SCENE_ROOT, LIST_ROOT
}
#组件跟节点为sceneRoot
