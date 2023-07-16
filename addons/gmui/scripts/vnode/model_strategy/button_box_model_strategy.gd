class_name ButtonBoxModelStrategy extends RefCounted

var rnode:ButtonBox
var vnode:VNode

func _init(rnode:ButtonBox, vnode:VNode):
	self.rnode = rnode
	self.vnode = vnode

func operate():
	if vnode.model != null:
		self.reference()
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		await rnode.init_finish
		rnode.buttonGroup.get_buttons()[gmui.data.rget(model.name)].button_pressed = true
		rnode.buttonGroup.pressed.connect(
			func(value:BaseButton):
				gmui.data.rset(vnode.model.name, value.get_index(), true, true)
		)
		gmui.data.setted.connect(
			func(key, value, oldValue):
				if key == vnode.model.name:
					gmui.data.emit_signal('watch', key, value, oldValue)
					rnode.buttonGroup.get_buttons()[value].button_pressed = true
		)
		self.unreference()
