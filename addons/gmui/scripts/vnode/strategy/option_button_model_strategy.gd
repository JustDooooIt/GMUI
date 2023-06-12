class_name OptionButtonModelStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var vm = vnode.vm
		rnode.item_selected.connect(
			func(id):
				vm.data.rset(vnode.model['rName'], id)
		)
		if vnode.model.isCompModel:
			vm.parent.data.setted.connect(
				func(key, value):
					vm.data.rset(key, value)
			)
			rnode.item_selected.connect(
				func(text):
					vm.parent.data.rset(vnode.model['rName'], text)
			)
