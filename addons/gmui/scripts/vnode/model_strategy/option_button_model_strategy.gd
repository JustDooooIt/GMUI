class_name OptionButtonModelStrategy extends RefCounted

var rnode:OptionButton
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var gmui:GMUI = vnode.gmui
		rnode.item_selected.connect(
			func(id):
				gmui.data.rset(vnode.model.name, id, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.button_pressed = value
		)
