class_name TextEditModelStrategy extends RefCounted

var rnode
var vnode

func _init(rnode, vnode):
	self.rnode = rnode
	self.vnode = vnode
	
func operate():
	if vnode.model.has('rName'):
		var vm = vnode.vm
		rnode.text_changed.connect(vm.data.rset_rnode.bind(vnode.model['rName'], rnode))
		vm.data.setted.connect(
			func(key, value): 
				var col = value.length()
				var row = value.count('\n')
				rnode.set_caret_column(col)
				rnode.set_caret_line(row)
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
