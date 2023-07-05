class_name BaseStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode

func get_parent_comp(rnode):
	var parent = rnode.get_parent()
	if parent != null:
		if 'isComponent' in parent:
			return parent
		get_parent_comp(parent)
