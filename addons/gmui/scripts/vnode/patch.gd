extends Node

var initDict = {}

func patch_node(oldVNode:VNode, newVNode:VNode):
	if !__is_same_node(oldVNode, newVNode):
		if oldVNode.rnode != Engine.get_main_loop().current_scene:
			var newRoot = __create_rnode_tree_with_root(null, newVNode)
			oldVNode.rnode.replace_by(newRoot)
			newVNode.rnode = __get_parent(newRoot.get_parent())
			return newVNode
		else:
			push_error('The root node cannot be replaced')
	__patch_properties(oldVNode, newVNode)
	if oldVNode.children.size() > 0 and newVNode.children.size() > 0:
		__updateChildren(oldVNode.rnode, oldVNode.children, newVNode.children)
	elif oldVNode.children.size() > 0:
		__remove_all_child(oldVNode.rnode)
	elif newVNode.children.size() > 0:
		__create_rnode_tree(oldVNode.rnode, newVNode)
	newVNode.rnode = oldVNode.rnode
	return newVNode
		
func __add_rnode_by_vnode(rnode:Node, vnode:VNode, mode = Node.INTERNAL_MODE_DISABLED):
	var newRNode = null
	if vnode.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT:
		for childVNode in vnode.children:
			var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXmlPath))
			newRNode = scene.instantiate()
			newRNode.name = childVNode.name
			newRNode.oldVNode = childVNode
			childVNode.rnode = newRNode
			rnode.add_child(newRNode)
			bind_model(newRNode, childVNode)
		vnode.rnode = rnode
	elif vnode.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT:
		var sceneNode:VNode = vnode.children[0]
		var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXmlPath))
		newRNode = scene.instantiate()
		newRNode.name = sceneNode.name
		newRNode.oldVNode = sceneNode
		bind_model(newRNode, sceneNode)
		sceneNode.rnode = newRNode
		rnode.add_child(newRNode)
	elif vnode.vnodeType != VNode.VNodeType.NORMAL:
		for child in vnode.children:
			__add_rnode_by_vnode(rnode, child)
	else:
		newRNode = ClassUtils.instantiate(vnode.type)
		newRNode.name = vnode.name
		vnode.rnode = newRNode
		__set_properties(newRNode, vnode)
		bind_model(newRNode, vnode)
		rnode.add_child(newRNode)
		for child in vnode.children:
			__add_rnode_by_vnode(newRNode, child)
			
func __create_rnode_tree(rnode, vnode, mode = Node.INTERNAL_MODE_DISABLED):
	vnode.rnode = rnode
	for child in vnode.children:
		var newRNode = null
		if child.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT:
			for childVNode in child.children:
				var scene:PackedScene = load(FileUtils.xml_to_scene_path(childVNode.sceneXmlPath))
				newRNode = scene.instantiate()
				newRNode.name = childVNode.name
				newRNode.oldVNode = childVNode
				childVNode.rnode = newRNode
				rnode.add_child(newRNode)
				bind_model(newRNode, childVNode)
#				__create_rnode_tree(newRNode, childVNode)
#				__set_properties_tree(newRNode, childVNode)
			child.rnode = rnode
		elif child.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT:
			var sceneNode = child.children[0]
			var scene = load(FileUtils.xml_to_scene_path(child.sceneXmlPath))
			newRNode = scene.instantiate()
			newRNode.name = sceneNode.name
			newRNode.oldVNode = sceneNode
			sceneNode.rnode = newRNode
			rnode.add_child(newRNode)
			__set_properties_tree(rnode, sceneNode)
		elif child.vnodeType != VNode.VNodeType.NORMAL:
			__create_rnode_tree(rnode, child)
			bind_model(newRNode, child)
		else:
			newRNode = ClassUtils.instantiate(child.type)
			newRNode.name = child.name
			child.rnode = newRNode
			rnode.add_child(newRNode)
			__create_rnode_tree(newRNode, child)
			__set_properties(newRNode,child)
			bind_model(newRNode, child)

func __create_rnode_tree_with_root(rnode, vnode:VNode):
	var newRNode = null
	if vnode.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT: 
		for childVNode in vnode.children:
			var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXmlPath))
			newRNode = scene.instantiate()
			newRNode.name = childVNode.name
			newRNode.oldVNode = childVNode
			childVNode.rnode = newRNode
#			__set_properties_tree(newRNode, childVNode)
			bind_model(newRNode, childVNode)
			if rnode != null:
				rnode.add_child(newRNode)
	elif vnode.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT:
		var sceneNode:VNode = vnode.children[0]
		var scene = load(FileUtils.xml_to_scene_path(vnode.sceneXmlPath))
		newRNode = scene.instantiate()
		newRNode.name = sceneNode.name
		newRNode.oldVNode = sceneNode
		__set_properties_tree(newRNode, sceneNode)
		sceneNode.rnode = newRNode
		bind_model(newRNode, sceneNode)
		if rnode != null:
			rnode.add_child(newRNode)
	elif vnode.vnodeType != VNode.VNodeType.NORMAL:
		__create_rnode_tree_with_root(rnode, vnode)
	else:
		newRNode = ClassUtils.instantiate(vnode.type)
		newRNode.name = vnode.name
		bind_model(newRNode, vnode)
		__set_properties(newRNode, vnode)
		vnode.rnode = newRNode
		if rnode != null:
			rnode.add_child(newRNode)
		for child in vnode.children:
			__create_rnode_tree_with_root(newRNode, child)
	return newRNode

func __patch_properties(oldVNode, newVNode):
	if oldVNode.properties != newVNode.properties and oldVNode.rnode != null:
		for key in newVNode.properties:
			oldVNode.rnode.set(key, newVNode.properties[key])
		oldVNode.properties = newVNode.properties.duplicate(true)

func __updateChildren(rnode, oldVNodes, newVNodes):
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
		elif __is_same_node(oldVNodes[oldStart], newVNodes[newStart]):
			patch_node(oldVNodes[oldStart], newVNodes[newStart])
			oldStart += 1
			newStart += 1
			if oldStart < oldVNodes.size():
				oldStartNode = oldVNodes[oldStart]
			if newStart < newVNodes.size():
				newStartNode = newVNodes[newStart]
		elif __is_same_node(oldVNodes[oldEnd], newVNodes[newEnd]):
			patch_node(oldVNodes[oldEnd], newVNodes[newEnd])
			oldEnd -= 1
			newEnd -= 1
			if oldEnd >= 0:
				oldEndNode = oldVNodes[oldEnd]
			if newEnd >= 0:
				newEndNode = newVNodes[newEnd]
		elif __is_same_node(oldVNodes[oldEnd], newVNodes[newStart]):
			patch_node(oldVNodes[oldEnd], newVNodes[newStart])
			rnode.move_child(oldVNodes[oldEnd].rnode, rnode.get_children().find(oldVNodes[oldStart].rnode))
			newStart += 1
			oldEnd -= 1
			if oldEnd >= 0:
				oldEndNode = oldVNodes[oldEnd]
			if newStart < newVNodes.size():
				newStartNode = newVNodes[newStart]
		elif __is_same_node(oldVNodes[oldStart], newVNodes[newEnd]):
			patch_node(oldVNodes[oldStart], newVNodes[newEnd])
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
				patch_node(tempVNode, newStartNode)
			else:
				var newRoot = __create_rnode_tree_with_root(null, newStartNode)
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
				__add_rnode_by_vnode(rnode, newVNodes[i])
		else:
			for i in range(newStart, newEnd + 1):
				__add_rnode_by_vnode(rnode, newVNodes[i], Node.INTERNAL_MODE_FRONT)

func __remove_all_child(node):
	for child in node.get_children():
		__remove_all_child(child)
		node.remove_child(child)
		child.free()

func __remove_all_child_vnode(node):
	node.children.clear()

func __is_same_node(oldNode, newNode):
	return oldNode.name == newNode.name
	
func _get_dict(children):
	var dict = {}
	for i in children.size():
		dict[children[i].name] = i
	return dict

func __set_properties(rnode, vnode):
	var vProperties = vnode.properties
	if rnode != null:
		for key in vProperties.keys():
			rnode.set(key, vProperties[key])

func __set_properties_tree(rnode, vnode):
	__set_properties(rnode, vnode)
	for i in rnode.get_children().size():
		if i < vnode.children.size():
			__set_properties_tree(rnode.get_children()[i], vnode.children[i])

func __get_parent(node:Node):
	if 'isGMUI' in node:
		return node
	return __get_parent(node.get_parent())
	
func bind_model(newRNode, vnode):
	if newRNode is LineEdit:
		LineEditModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is TabBar:
		TabBarModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is TabContainer:
		TabContainerModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is ColorPicker:
		ColorPickerModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is CheckButton:
		CheckButtonModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is CheckBox:
		CheckBoxModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is TextEdit:
		TextEditModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is CodeEdit:
		CodeEditModelStrategy.new(newRNode, vnode).operate()
	elif newRNode is OptionButton:
		OptionButtonModelStrategy.new(newRNode, vnode).operate()
