class_name MenuButtonModelStrategy extends RefCounted

var rnode:MenuButton
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		rnode.set('button_pressed', gmui.data.rget(model.name))
		rnode.toggled.connect(
			func(flag):
				gmui.data.rset(vnode.model.name, flag, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.button_pressed = value
		)
	
