class_name TabContainerModelStrategy extends RefCounted

var rnode:TabContainer
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model != null:
		var gmui:GMUI = vnode.gmui
		var model:Model = vnode.model
		rnode.set('current_tab', gmui.data.rget(model.name))
		rnode.tab_changed.connect(
			func(value):
				gmui.data.rset(vnode.model.name, value, true, true)
		)
		gmui.data.setted.connect(
			func(key, value):
				if key == vnode.model.name:
					rnode.current_tab = value
		)
