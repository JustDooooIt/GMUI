class_name IfValue extends RefCounted

var type:Type
var varType:Prop.Type
var value:Variant

func _init(type, value):
	self.type = type
	var res = TinyXmlParser.get_value(value)
	var resValue
	if res.isSuccess:
		self.varType = Prop.Type.STATIC
		self.value = res.value
	else:
		self.varType = Prop.Type.DYNAMIC
		self.value = value

enum Type{ IF, ELSE_IF, ELSE }
