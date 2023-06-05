@tool
class_name Function extends RefCounted

var expression = Expression.new()
var instance = null
var node = null

func _init(str, instance):
	expression.parse(str)
	self.instance = instance

func exec():
	var vnode = expression.execute([],instance)
	return vnode
