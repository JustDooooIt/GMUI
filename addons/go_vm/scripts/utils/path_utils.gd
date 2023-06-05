class_name PathUtils extends RefCounted

static func get_owner(node):
	var owner = node.owner
	if owner == null:
		owner = node
	return owner
	
static func get_node_path(node):
	var owner = get_owner(node)
	var path = ''
	if owner == node:
		path = '.'
	else:
		path = owner.get_path_to(node)
		path = './' + path.get_concatenated_names()
	return path
