class_name LineEditModelStrategy extends RefCounted

var rnode:LineEdit
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model != null:
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		rnode.set('text', gmui.data.rget(model.name))
		rnode.text_changed.connect(
			func(text):
				gmui.data.rset(vnode.model.name, text, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.text = value
					if value.length() > 0: 
						rnode.caret_column = value.length()
		)
