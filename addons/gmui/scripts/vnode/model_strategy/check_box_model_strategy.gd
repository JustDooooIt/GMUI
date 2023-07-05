class_name CheckBoxModelStrategy extends RefCounted

var rnode:CheckBox
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model != null:
		var gmui:GMUI = vnode.gmui
		rnode.toggled.connect(
			func(value):
				gmui.data.rset(vnode.model.name, value, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.button_pressed = value
		)
