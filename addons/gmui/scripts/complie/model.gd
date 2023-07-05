class_name Model extends RefCounted

var name:String = ''
var type:String = ''
#父组件
var pName:String = ''
#子组件
var cName:String = ''

func _init(name:String, type:String):
	self.name = name
	self.type = type
