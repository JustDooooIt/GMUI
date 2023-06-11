@tool
class_name VNodeHelper extends Node

#func vnode(type, name):
#	var vnode = VNode.new()
#	vnode.name = name
#	vnode.type = type
#	return vnode

#普通节点
#static func vnode(type = '', name = '' , isScene = false, sceneXMLPath = '', properties = {}, bindDict = {}, vmId = null, model = {}, children = []):
#	var vnode = VNode.new()
#	vnode.name = name
#	vnode.type = type
#	vnode.isScene = isScene
#	vnode.children = children
#	vnode.sceneXMLPath = sceneXMLPath
#	vnode.properties = properties
#	vnode.vmId = vmId
#	vnode.model = model
#	vnode.bindDict = bindDict
#	return vnode

static func create_vnode(type = '', name = '' , isScene = false, sceneXMLPath = '', properties = {}, bindDict = {}, vm = null, model = {}, ref = {}, children = []):
	var vnode = VNode.new()
	vnode.name = name
	vnode.type = type
	vnode.isScene = isScene
	vnode.children = children
	vnode.sceneXMLPath = sceneXMLPath
	vnode.properties = properties.duplicate(true)
	vnode.vm = vm
	vnode.model = model
	vnode.bindDict = bindDict
	vnode.ref = ref
	return vnode

static func create_vnodes(ast, vm, staticProps = {}, dynamicProps = {}):
	return create(ast, ast.isScene, ast.sceneXMLPath, ast.bindDict, staticProps, dynamicProps, vm)

static func create(ast, isScene, sceneXMLPath, bindDict, staticProps, dynamicProps, vm):
	var vnodes = []
	if ast.isScene:
		var node = ast.sceneXML
		if !node.ref.is_empty():
			vm.refs = {node.ref['name']: null}
		return create_vnode(node.type, node.name, true, ast.sceneXMLPath, node.properties, vm, ast.model, ast.ref)
#		return 'vnode("%s", "%s", %s, "%s", %s, %s, %s, [])' % [node.type, node.name, true, ast.sceneXMLPath, node.properties, id, ast.model]
#		vnodes.append(vnode_func(node, true, path, ast.sceneXMLPath, ast.staticProps, ast.dynamicProps, node.bindDict, vm))
#		return ','.join(vnodes)
	elif ast.isSlot:
		var template = ast.template
		if template != null:
			for child in template.children:
				vnodes.append(create(child, false, '', child.bindDict, staticProps, dynamicProps, vm))
			return vnodes
		else:
			return null
	elif ast.isTemplate:
		return null
	else:
		if ast.children.size() == 0:
			for key in dynamicProps.keys():
				vm.data.rset(key, vm.parent.data.rget(key), false)
			for key in ast.bindDict.keys():
				ast.properties[key] = vm.data.rget(ast.bindDict[key])
			if !ast.ref.is_empty():
				vm.refs = {ast.ref['name']: null}
			if !ast.model.is_empty():
				ast.properties[ast.model.cName] = vm.data.rget(ast.model.rName)
			return create_vnode(ast.type, ast.name, isScene, sceneXMLPath, ast.properties, ast.bindDict, vm, ast.model, ast.ref)
		else:
			for key in dynamicProps.keys():
				vm.data.rset(key, vm.parent.data.rget(key), false)
			for child in ast.children:
				for key in child.bindDict.keys():
					child.properties[key] = vm.data.rget(child.bindDict[key])
				if !child.ref.is_empty():
					vm.refs = {child.ref['name']: null}
				if !child.model.is_empty():
					child.properties[child.model.cName] = vm.data.rget(child.model.rName)
				var vnode = create(child, false,  '', child.bindDict, staticProps, dynamicProps, vm)
				if vnode != null:
					vnodes.append(vnode)
			return create_vnode(ast.type, ast.name, isScene, sceneXMLPath, ast.properties, ast.bindDict, vm, ast.model, ast.ref, vnodes)

static func rtree_to_vtree(rnode, vnode = null):
	if vnode == null:
#		var path = '.'.path_join(get_tree().current_scene.get_path_to(rnode).get_concatenated_names().lstrip('.'))
		if rnode == Engine.get_main_loop().current_scene:
			vnode = create_vnode(rnode.get_class(), rnode.name, false, FileUtils.scene_to_xml_path(rnode.scene_file_path))
		else:
			vnode = create_vnode(rnode.get_class(), rnode.name, true, FileUtils.scene_to_xml_path(rnode.scene_file_path))	
		vnode.rnode = rnode
	for child in rnode.get_children():
		var newVNode = VNode.new()
		rtree_to_vtree(child, newVNode)
#			newVNode.isRoot = false
		if child.scene_file_path != null or child.scene_file_path != '':
			newVNode.sceneXMLPath = FileUtils.scene_to_xml_path(child.scene_file_path)
			newVNode.isScene = true
		newVNode.type = child.get_class()
		newVNode.name = child.name
		newVNode.parent = vnode
		newVNode.rnode = child
		vnode.children.append(newVNode)
	return vnode

