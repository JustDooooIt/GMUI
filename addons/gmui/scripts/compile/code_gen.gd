class_name CodeGen extends RefCounted

static func render_func(ast, vm, staticProps = {}, dynamicProps = {}):
	return vnode_func(ast, false, '', ast.bindDict, staticProps, dynamicProps, vm)
	
static func vnode_func(ast, isScene, sceneXMLPath, bindDict, staticProps, dynamicProps, vm):
	var vnodes = []
	if ast.isScene:
		var node = ast.sceneXML
		return 'vnode("%s", "%s", %s, "%s", %s, [])' % [node.type, node.name, true, ast.sceneXMLPath, node.properties]
#		vnodes.append(vnode_func(node, true, path, ast.sceneXMLPath, ast.staticProps, ast.dynamicProps, node.bindDict, vm))
#		return ','.join(vnodes)
	elif ast.isSlot:
		var template = ast.template
		if template != null:
			for child in template.children:
				vnodes.append(vnode_func(child, false, '', child.bindDict, staticProps, dynamicProps, vm))
			return ','.join(vnodes)
		else:
			return ''
	elif ast.isTemplate:
		return ''
	else:
		if ast.children.size() == 0:
#			vm.emit_signal('send_props')
#			if vm.parent != null:
#				bind_send_props_signal(vm)
			for key in dynamicProps.keys():
				vm.data.rset(key, vm.parent.data.rget(key), false)
			for key in ast.bindDict.keys():
				ast.properties[key] = vm.data.rget(ast.bindDict[key])
			return 'vnode("%s", "%s", %s, "%s", %s, [])' % [ast.type, ast.name, isScene, sceneXMLPath, ast.properties]
		else:
#			vm.emit_signal('send_props')
#			if vm.parent != null:
#				bind_send_props_signal(vm)
			for key in dynamicProps.keys():
				vm.data.rset(key, vm.parent.data.rget(key), false)
			for child in ast.children:
				for key in child.bindDict.keys():
					child.properties[key] = vm.data.rget(child.bindDict[key])
				var vnode = vnode_func(child, false,  '', child.bindDict, staticProps, dynamicProps, vm)
				if vnode != '':
					vnodes.append(vnode)
			return 'vnode("%s", "%s", %s, "%s", %s, [%s])' % [ast.type, ast.name, isScene, sceneXMLPath, ast.properties, ','.join(vnodes)]

#static func bind_send_props_signal(vm):
#	if !vm.parent.send_props.is_connected(vm.set_props):
#		vm.parent.send_props.connect(vm.set_props)
