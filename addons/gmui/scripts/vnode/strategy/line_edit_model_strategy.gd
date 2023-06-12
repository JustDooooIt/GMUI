class_name LineEditModelStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var vm = vnode.vm
		rnode.text_changed.connect(
			func(text):
				vm.data.rset(vnode.model['rName'], text)
		)
		vm.data.setted.connect(
			func(key, value): 
				if value.length() > 0: rnode.caret_column = value.length()
		)
		if vnode.model.isCompModel:
			vm.parent.data.setted.connect(
				func(key, value):
					vm.data.rset(key, value)
			)
			rnode.text_changed.connect(
				func(text):
					vm.parent.data.rset(vnode.model['rName'], text)
			)
#	rnode.caret_column = rnode.text.length - 1
