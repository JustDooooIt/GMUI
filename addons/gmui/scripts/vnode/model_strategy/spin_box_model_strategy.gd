class_name SpinBoxModelStrategy extends RefCounted

var rnode:SpinBox
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		rnode.set('value', gmui.data.rget(model.name))
		rnode.value_changed.connect(
			func(value):
				gmui.data.rset(vnode.model.name, value, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.value = value
		)
