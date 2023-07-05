class_name TextEditModelStrategy extends RefCounted

var rnode:TextEdit
var vnode:VNode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model != null:
		var gmui:GMUI = vnode.gmui
		rnode.text_changed.connect(
			func(value):
				gmui.data.rset(vnode.model.name, value, true, true)
		)
		gmui.data.setted.connect(
			func(key, value): 
				if key == vnode.model.name:
					rnode.text = value
					var col = value.length()
					var row = value.count('\n')
					rnode.set_caret_column(col)
					rnode.set_caret_line(row)
		)
