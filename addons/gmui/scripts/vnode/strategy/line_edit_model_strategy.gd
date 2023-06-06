class_name LineEditModelStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	var vm = instance_from_id(vnode.vmId)
	rnode.text_changed.connect(vm.data._reverse_rset.bind(vnode.model['rName']))
