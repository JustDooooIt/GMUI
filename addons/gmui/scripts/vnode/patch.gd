@tool
extends Node

var initDict = {}

func run(oldVNode, newVNode):
	if oldVNode is Node:
		_create_rnode_tree(oldVNode, newVNode)
	else:
		if !_is_same_node(oldVNode, newVNode):
			var newRoot = _create_rnode_tree_with_root(null, newVNode)
#			set_all_owner(PathUtils.get_owner(oldVNode.rnode), newRoot)
			oldVNode.rnode.replace_by(newRoot)
			return oldVNode
		_patch_properties(oldVNode, newVNode)
		if oldVNode.children.size() > 0 and newVNode.children.size() > 0:
			_updateChildren(oldVNode.rnode, oldVNode.children, newVNode.children)
		elif oldVNode.children.size() > 0:
			_remove_all_child(oldVNode.rnode)
#			__remove_all_child_vnode(oldVNode)
		elif newVNode.children.size() > 0:
			_create_rnode_tree(oldVNode.rnode, newVNode)
#			_add_all_child_vnode(oldVNode, newVNode)
		newVNode.rnode = oldVNode.rnode
	return newVNode
		
func _add_rnode_by_vnode(rnode, vnode, mode = Node.INTERNAL_MODE_DISABLED):
	var newRNode = null
	if vnode.isScene:
		var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXMLPath))
		newRNode = scene.instantiate()
#		dont_init(newRNode)
		rnode.add_child(newRNode)
	else:
		newRNode = ClassDB.instantiate(vnode.type)
		newRNode.name = vnode.name
		if newRNode is LineEdit:
			LineEditModelStrategy.new(newRNode, vnode).operate()
		rnode.add_child(newRNode)
#		newRNode.owner = PathUtils.get_owner(rnode)
		for child in vnode.children:
			_add_rnode_by_vnode(newRNode, child)

func _create_rnode_tree(rnode, vnode, mode = Node.INTERNAL_MODE_DISABLED):
	vnode.rnode = rnode
	for child in vnode.children:
		var newRNode = null
		if child.isScene:
			var scene = load(FileUtils.xml_to_scene_path(child.sceneXMLPath))
			newRNode = scene.instantiate()
#			dont_init(newRNode)
			newRNode.name = child.name
			_set_properties_tree(newRNode, child)
			rnode.add_child(newRNode)
		else:
			newRNode = ClassDB.instantiate(child.type)
			newRNode.name = child.name
			if newRNode is LineEdit:
				LineEditModelStrategy.new(newRNode, child).operate()
			rnode.add_child(newRNode)
#		newRNode.owner = PathUtils.get_owner(rnode)
			_set_properties(newRNode,child)
			_create_rnode_tree(newRNode, child)
			

#func get_scene_child(rootNode, node = rootNode, map = {}):
#	for child in node.get_children:
#		if child.scene_file_path != '':
#			map['./'.path_join(rootNode.get_path_to(node).lstrip('.'))] = child
#		get_scene_child(rootNode, child, map)
#	return map

#func set_ast_child(ast, rootMap = {}):
#	if !ast.isScene and !ast.isTemplate and !ast.isSlot:
#		if rootMap.has(ast.path):
#			rootMap[ast.path].ast = ast
#	for child in ast.children:
#		set_ast_child(child, rootMap)

#func dont_init(node):
#	if !Engine.is_editor_hint():
#		if node.scene_file_path != '':
#			node.canInit = false
#		for child in node.get_children():
#			dont_init(child)

func _create_rnode_tree_with_root(rnode, vnode):
	var newRNode = null
	if vnode.isScene: 
		var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXMLPath))
		newRNode = scene.instantiate()
		_set_properties_tree(newRNode, vnode)
#		dont_init(newRNode)
		vnode.rnode = rnode
		if rnode != null:
			rnode.add_child(newRNode)
	else:
		newRNode = ClassDB.instantiate(vnode.type)
		newRNode.name = vnode.name
		vnode.rnode = rnode
		if newRNode is LineEdit:
			LineEditModelStrategy.new(newRNode, vnode).operate()
		_set_properties(rnode, vnode)
		if rnode != null:
			rnode.add_child(newRNode)
		for child in vnode.children:
			_create_rnode_tree_with_root(newRNode, child)
	return newRNode

func _patch_properties(oldVNode, newVNode):
	if oldVNode.properties != newVNode.properties:
		for key in oldVNode.properties.keys():
			oldVNode.rnode.set(key, null)
		oldVNode.properties = newVNode.properties
		for key in oldVNode.properties.keys():
			oldVNode.rnode.set(key, oldVNode.properties[key])

func _updateChildren(rnode, oldVNodes, newVNodes):
	var oldStart = 0
	var oldEnd = oldVNodes.size() - 1
	var newStart = 0
	var newEnd = newVNodes.size() - 1
	var oldStartNode = oldVNodes[oldStart]
	var oldEndNode = oldVNodes[oldEnd]
	var newStartNode = newVNodes[newStart]
	var newEndNode = newVNodes[newEnd]
	var tempEnd = null
	var tempStart = null
	var keyMap = {}
	var dict = _get_dict(oldVNodes)
	while oldStart <= oldEnd and newStart <= newEnd:
		if oldStartNode == null:
			oldStart += 1
			oldStartNode = oldVNodes[oldStart]
		elif oldEndNode == null:
			oldEnd -= 1
			oldEndNode = oldVNodes[oldEnd]
		elif _is_same_node(oldVNodes[oldStart], newVNodes[newStart]):
			run(oldVNodes[oldStart], newVNodes[newStart])
			oldStart += 1
			newStart += 1
			if oldStart < oldVNodes.size():
				oldStartNode = oldVNodes[oldStart]
			if newStart < newVNodes.size():
				newStartNode = newVNodes[newStart]
		elif _is_same_node(oldVNodes[oldEnd], newVNodes[newEnd]):
			run(oldVNodes[oldEnd], newVNodes[newEnd])
			oldEnd -= 1
			newEnd -= 1
			if oldEnd >= 0:
				oldEndNode = oldVNodes[oldEnd]
			if newEnd >= 0:
				newEndNode = newVNodes[newEnd]
		elif _is_same_node(oldVNodes[oldEnd], newVNodes[newStart]):
			run(oldVNodes[oldEnd], newVNodes[newStart])
			rnode.move_child(oldVNodes[oldEnd].rnode, rnode.get_children().find(oldVNodes[oldStart].rnode))
			newStart += 1
			oldEnd -= 1
			if oldEnd >= 0:
				oldEndNode = oldVNodes[oldEnd]
			if newStart < newVNodes.size():
				newStartNode = newVNodes[newStart]
		elif _is_same_node(oldVNodes[oldStart], newVNodes[newEnd]):
			run(oldVNodes[oldStart], newVNodes[newEnd])
			rnode.move_child(oldVNodes[oldStart].rnode, rnode.get_children().find(oldVNodes[oldEnd].rnode))
			oldStart += 1
			newEnd -= 1
			if newEnd >= 0:
				newEndNode = newVNodes[newEnd]
			if oldStart < oldVNodes.size():
				oldStartNode = oldVNodes[oldStart]
		else:
			var index = dict.get(newStartNode.name, null)
			if index != null:
				var tempVNode = oldVNodes[index]
				rnode.move_child(tempVNode.rnode, rnode.get_children().find(oldStartNode.rnode))
				oldVNodes[index] = null
				run(tempVNode, newStartNode)
			else:
				var newRoot = _create_rnode_tree_with_root(null, newStartNode)
				rnode.add_child(newRoot)
#				set_all_owner(PathUtils.get_owner(rnode), newRoot)
				rnode.move_child(newRoot, rnode.get_children().find(oldVNodes[oldStart].rnode))
			newStart += 1
			if newStart < newVNodes.size():
				newStartNode = newVNodes[newStart]
		
	if oldStart <= oldEnd:
		for i in range(oldStart, oldEnd + 1):
			if oldVNodes[i] != null:
				rnode.remove_child(oldVNodes[i].rnode)
	elif newStart <= newEnd:
		if newEnd < newVNodes.size():
			for i in range(newStart, newEnd + 1):
				_add_rnode_by_vnode(rnode, newVNodes[i])
		else:
			for i in range(newStart, newEnd + 1):
				_add_rnode_by_vnode(rnode, newVNodes[i], Node.INTERNAL_MODE_FRONT)

func _remove_all_child(node):
	for child in node.children:
		_remove_all_child(node)
		node.remove_child(child)
		child.free()

func __remove_all_child_vnode(node):
	node.children.clear()

func _add_all_child_vnode(oldVNode, newVNode):
	oldVNode.children = newVNode.children

func _is_same_node(oldNode, newNode):
#	return oldNode.isRoot or (oldNode.path == newNode.path and oldNode.type == newNode.type)
	return oldNode.isRoot or (oldNode.name == newNode.name and oldNode.type == newNode.type)
	
func _get_dict(children):
	var dict = {}
	for i in children.size():
		dict[children[i].name] = i
	return dict

func _set_properties(rnode, vnode):
	var vProperties = vnode.properties
	for key in vProperties.keys():
		rnode.set(key, vProperties[key])

func _set_properties_tree(rnode, vnode):
	_set_properties(rnode, vnode)
	for i in vnode.children.size():
		_set_properties_tree(rnode.get_children()[i], vnode.children[i])
