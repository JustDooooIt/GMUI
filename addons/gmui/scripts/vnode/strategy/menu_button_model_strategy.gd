class_name MenuButtonModelStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var vm = vnode.vm
		rnode.toggled.connect(
			func(flag):
				vm.data.rset(vnode.model['rName'], flag)
		)
	
