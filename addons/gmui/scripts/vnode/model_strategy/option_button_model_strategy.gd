class_name OptionButtonModelStrategy extends RefCounted

var rnode:OptionButton
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		rnode.set('selected', gmui.data.rget(model.name))
		rnode.item_selected.connect(
			func(id):
				gmui.data.rset(vnode.model.name, id, true, true)
		)
		gmui.data.setted.connect(
			func(key, value, oldValue):
				if key == vnode.model.name:
					gmui.data.emit_signal('watch', key, value, oldValue)
					rnode.button_pressed = value
		)
