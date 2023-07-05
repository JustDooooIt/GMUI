class_name ColorPickerModelStrategy extends RefCounted

var rnode:ColorPicker
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var gmui:GMUI = vnode.gmui
		rnode.color_changed.connect(
			func(value):
				gmui.data.rset(vnode.model.name, value, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.color = value
		)
