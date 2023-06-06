@tool
extends Node

#func vnode(type, name):
#	var vnode = VNode.new()
#	vnode.name = name
#	vnode.type = type
#	return vnode

var _v = vnode

#普通节点
static func vnode(type = '', name = '' , isScene = false, sceneXMLPath = '', properties = {}, vmId = null, model = {}, children = []):
	var vnode = VNode.new()
	vnode.name = name
	vnode.type = type
	vnode.isScene = isScene
	vnode.children = children
	vnode.sceneXMLPath = sceneXMLPath
	vnode.properties = properties
	vnode.vmId = vmId
	vnode.model = model
	return vnode

#设置节点属性
#func svnode(bindDict, data):
#	for key in bindDict.keys():
#		data.rget

func rtree_to_vtree(rnode, vnode = null):
	if vnode == null:
#		var path = '.'.path_join(get_tree().current_scene.get_path_to(rnode).get_concatenated_names().lstrip('.'))
		if rnode == Engine.get_main_loop().current_scene:
			vnode = vnode(rnode.get_class(), rnode.name, false, FileUtils.scene_to_xml_path(rnode.scene_file_path))
		else:
			vnode = vnode(rnode.get_class(), rnode.name, true, FileUtils.scene_to_xml_path(rnode.scene_file_path))	
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
#
#	if vnode == null:
#		vnode = VNode.new()
#		vnode.isRoot = true
#		vnode.type = rnode.get_class()
#		vnode.name = rnode.name
#		vnode.path = PathUtils.get_node_path(rnode)
#		vnode.rnode = rnode
#	for child in rnode.get_children():
#		var newVNode = VNode.new()
#		rtree_to_vtree(child, newVNode)
#		var isRoot = false
#		if child.owner == null:
#			isRoot = true
#		newVNode.isRoot = isRoot
#		newVNode.type = child.get_class()
#		newVNode.name = child.name
#		newVNode.parent = vnode
#		newVNode.path = PathUtils.get_node_path(child)
#		newVNode.rnode = child
#		vnode.children.append(newVNode)
	return vnode
