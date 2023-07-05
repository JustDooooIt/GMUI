extends Node

var randState:int = randi()
var randomDict:Dictionary = {}
var isInit:bool = false
var templateNames:Dictionary = {}
var slots:Dictionary = {}
var templates:Dictionary = {}

func vnode(
	ast:ASTNode = null,
	vnodeType:VNode.VNodeType = VNode.VNodeType.NORMAL,
	index:int = -1,
	parent:VNode = null,
	children:Array[VNode] = []
)->VNode:
	var vnode:VNode = VNode.new()
	vnode.name = ast.name
	vnode.type = ast.type
	vnode.children = children
	vnode.sceneAst = ast.sceneRoot
	vnode.vnodeType = vnodeType
	vnode.bindDict = ast.bindDict
	vnode.gmui = ast.rgmui
	vnode.ifValue = ast.ifValue
	vnode.index = index
	vnode.parent = parent
	vnode.model = ast.model
	vnode.astNode = ast
	vnode.slotName = ast.slotName
	vnode.props = ast.props
	vnode.__gmui = ast.gmui
	vnode.refName = ast.refName
	vnode.models = ast.models
	if ast.templateInfo != null:
		vnode.slotParam = ast.templateInfo.params
	vnode.properties = ast.properties.duplicate()
	if ast.sceneRoot != null:
		vnode.sceneXmlPath = ast.sceneRoot.sceneXmlPath
	return vnode

func vnode_with_name(
	ast:ASTNode,
	name:String,
	vnodeType:VNode.VNodeType = VNode.VNodeType.NORMAL,
	index:int = 0,
	parent:VNode = null,
	children:Array[VNode] = []
):
	var vnode:VNode = VNode.new()
	vnode.name = name
	vnode.type = ast.type
	vnode.children = children
	vnode.sceneAst = ast.sceneRoot
	vnode.vnodeType = vnodeType
	vnode.bindDict = ast.bindDict
	vnode.gmui = ast.rgmui
	vnode.ifValue = ast.ifValue
	vnode.index = index
	vnode.parent = parent
	vnode.model = ast.model
	vnode.astNode = ast
	vnode.__gmui = ast.gmui
	vnode.slotName = ast.slotName
	vnode.refName = ast.refName
	vnode.props = ast.props
	vnode.models = ast.models
	if ast.templateInfo != null:
		vnode.slotParam = ast.templateInfo.params
	vnode.properties = ast.properties.duplicate()
	if ast.sceneRoot != null:
		vnode.sceneXmlPath = ast.sceneRoot.sceneXmlPath
	return vnode
	
func create(ast:ASTNode, index:int = -1, sceneRoot:VNode = null)->VNode:
	self.isInit = isInit
	var vnode = create_vnodes(ast, sceneRoot.name, null, index, sceneRoot.parent)
	create_template(ast.sceneRoot, vnode.parent, 0)
	move_template()
	set_if(vnode)
	set_for_gmui(vnode)
	set_model(vnode)
	bind_slot_props(vnode)
	bind_scene_props(vnode)
	bind_vnode_value(vnode)
	set_refs(vnode)
	return vnode

func set_for_gmui(node:VNode, need:Dictionary = {}):
	if node.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT:
		var nodes:Array[VNode] = [node]
		while !nodes.is_empty():
			var _node:VNode = nodes.pop_front()
			var gmui = copy_gmui(node.__gmui)
			var rgmui = copy_gmui(node.gmui)
			_node.gmui = rgmui
			_node.__gmui = gmui
			need[_node.name] = true
			for child in _node.children:
				nodes.push_front(child)
	for child in node.children:
		if !need.has(child.name):
			set_for_gmui(child)

func set_model(vnode:VNode):
	if vnode.model != null:
		var model:Model = vnode.model
		var gmui:GMUI = vnode.gmui
		gmui.data.rget(model.name)
	if vnode.models.size() > 0:
		for model in vnode.models:
			var gmui:GMUI = vnode.__gmui
			var rgmui:GMUI = vnode.gmui
			var value = gmui.data.rget(model.pName)
			rgmui.data.rset(model.cName, value, true, false)
	for child in vnode.children:
		set_model(child)
		
func set_refs(node:VNode):
	if node.refName != '':
		if !node.__gmui.refs.has(node.refName):
			node.__gmui.refs[node.refName] = node
		else:
			var ref = node.__gmui.refs[node.refName]
			if ref is Array:
				ref.append(node)
			else:
				node.__gmui.refs[node.refName] = [ref, node]
			
	for child in node.children:
		set_refs(child)

func set_if(vnode:VNode):
	var vnodes:Array[VNode] = vnode.children
	for child in vnode.children:
		set_if(child)
	set_vnode_if(vnodes)
		
func move_template():
	for key in templates:
		if slots.has(key):
			var slot:VNode = slots[key]
			slot.children = [templates[key]]
			templates[key].parent = slot
			
func bind_vnode_value(node:VNode):
	if !node.bindDict.is_empty() and node.vnodeType == VNode.VNodeType.NORMAL:
		set_bind_value(node.__gmui, node, node.bindDict)
	for child in node.children:
		bind_vnode_value(child)

func bind_slot_props(node:VNode):
	for key in templates:
		if slots.has(key):
			var slot:VNode = slots[key]
			var template:VNode = templates[key]
			var param:String = template.slotParam
			var props:Dictionary = get_props(slot)
			props = {param: props}
			template.__gmui.merge_props(props, true)
	for child in node.children:
		bind_slot_props(child)

func bind_scene_props(node:VNode):
	if node.parent != null:
		if node.parent.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT or node.parent.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT:
			var gmui:GMUI = node.parent.__gmui
			var rgmui:GMUI = node.parent.gmui
			var props:Array[Prop] = node.parent.props
			var dict:Dictionary = {}
			for prop in props:
				var value
				if prop.type == Prop.Type.DYNAMIC:
					value = get_var(gmui, node, prop.value)
				else:
					value = prop.value
				dict[prop.name] = value
			node.gmui.merge_props(dict, true)
	for child in node.children:
		bind_scene_props(child)

func create_vnodes(
	ast:ASTNode,
	name:String,
	sceneAst:ASTNode,
	index:int = 0, 
	parent:VNode = null
)->VNode:
	var vnodes:Array[VNode] = []
	var rootVNode:VNode = null
	if ast.type == TinyXmlParser.scene:
		var vnodeType
		if !ast.hasFor:
			vnodeType = VNode.VNodeType.SINGAL_SCENE_ROOT
		else:
			vnodeType = VNode.VNodeType.MULTI_SCENE_ROOT
		rootVNode = vnode(ast, vnodeType, index, parent, vnodes)
		vnodes.append_array(get_scene_nodes(parent, ast))
	elif ast.type == TinyXmlParser.slot:
		rootVNode = create_slot(ast, name, parent, index)
	elif ast.type == TinyXmlParser.template:
		rootVNode = vnode_with_name(ast, name, VNode.VNodeType.STATIC, index, parent, vnodes)
		for i in range(ast.children.size()):
			var node:ASTNode = ast.children[i]
			rootVNode.children.append(create_normal_nodes(node, node.sceneRoot, name, rootVNode, i))
	else:
		rootVNode = create_normal_nodes(ast, ast.sceneRoot, name, parent, index)
	return rootVNode

func create_template(ast:ASTNode, sceneVNode:VNode, index:int):
	if ast == null or ast.children.size() == 0: return
	var rootVNode:VNode = null
	var nodes:Array[VNode] = []
	var templateVNode:VNode
	for i in range(ast.children.size()):
		var template:ASTNode = ast.children[i]
		if template.hasFor:
			rootVNode = vnode(ast, VNode.VNodeType.LIST_ROOT, index, sceneVNode, nodes) 
			nodes.append_array(create_for_template(template, sceneVNode))
			for node in nodes:
				templates[node.templateName] = node
		else:
			var templateName:String = get_template_name(template.gmui, null, template.templateInfo.name)
			templateVNode = vnode(template, VNode.VNodeType.STATIC, index, sceneVNode, nodes)
			templateVNode.templateName = templateName
			for j in range(template.children.size()):
				var normalNode:ASTNode = template.children[j]
				nodes.append(create_vnodes(normalNode, normalNode.name, normalNode.sceneRoot, i, templateVNode))
			templates[templateName] = templateVNode
			rootVNode = templateVNode
	return rootVNode

func create_for_template(ast:ASTNode, parent:VNode = null):
	var vnodes:Array[VNode] = []
	var arrName:String = ast.forValue.arrName
	var varName:String = ast.forValue.varName
	var indexName:String = ast.forValue.indexName
	var gmui:GMUI = ast.gmui
	var arr:ReactiveArray = gmui.data.__rget(arrName)
	arr.gen_ids(parent.name)
	ast.hasFor = false
	for i in range(arr.rsize()):
		var name = arr.ids[parent.name][i]
		set_for_index(gmui, indexName, name)
		set_for_var(gmui, varName, indexName, arr)
		var vnode = create_vnodes(ast, name, ast.sceneRoot, i, parent)
		vnode.templateName = get_template_name(gmui, vnode, ast.templateInfo.name)
		vnodes.append(vnode)
	ast.hasFor = true
	return vnodes

func create_slot(ast:ASTNode, name:String, parent:VNode, index:int):
	var rootVNode:VNode
	if ast.hasFor:
		rootVNode = vnode(ast, VNode.VNodeType.LIST_ROOT, index, parent, [])
		rootVNode.children = create_for_slot(ast, rootVNode)
	else:
		rootVNode = vnode_with_name(ast, name, VNode.VNodeType.STATIC, index, parent, [])
		for i in range(ast.children.size()):
			var astNode:ASTNode = ast.children[i]
			var root = create_vnodes(astNode, astNode.name, astNode.sceneRoot, i, rootVNode)
			rootVNode.children.append(root)
		rootVNode.slotName = get_slot_name(ast.gmui, rootVNode, ast.slotName)
		slots[rootVNode.slotName] = rootVNode
	return rootVNode

func get_slot_name(gmui:GMUI, vnode:VNode, slotName:String):
	var regex:RegEx = RegEx.create_from_string('\\[\\w*\\]')
	var regexMatch:RegExMatch = regex.search(slotName)
	if regexMatch != null:
		regex.compile('(?<=\\[)\\w*')
		regexMatch = regex.search(slotName)
		if regexMatch != null:
			slotName = get_var(gmui, vnode, regexMatch.strings[0])
	return slotName

func get_slots(vnode:VNode, slots:Dictionary = {})->Dictionary:
	if vnode.type == TinyXmlParser.slot:
		slots[vnode.slotName] = vnode
	for child in vnode.children:
		get_slots(child, slots)
	return slots

#func create_template(astNode:ASTNode):
	
	
#func create_slot(ast:ASTNode, parent:VNode, index = 0, slots:Dictionary = {}):
#	if ast.hasFor:
#		var root = create_for_slot(ast, ast.sceneRoot, parent)
#		parent.children.append(root)
#		for child in root.children:
#			slots[child.slotName] = child
#		return root
#	else:
#		var rootVNode:VNode = vnode(ast, VNode.VNodeType.STATIC, 0, parent, [])
#		for i in range(ast.children.size()):
#			var astNode:ASTNode = ast.children[i]
#			var root = create_vnodes(astNode, astNode.name, astNode.sceneRoot, i)
#			rootVNode.children.append(root)
#		var slotName = ast.slotName
#		var templateNames:Array = ast.sceneRoot.children.map(func(value:ASTNode): return value.templateInfo.name)
#		for i in range(templateNames.size()):
#			var templateName:String = get_template_name(ast.sceneRoot.gmui, parent, templateNames[i])
#			if templateName != '' and slotName == templateName:
#				var template:VNode = create_template(rootVNode, ast.sceneRoot.children[i])
#				rootVNode.children = [template]
#				break
#		return rootVNode

func get_template_name(gmui:GMUI, vnode:VNode, templateName:String)->String:
	var regex:RegEx = RegEx.create_from_string('\\[\\w*\\]')
	var regexMatch:RegExMatch = regex.search(templateName)
	if regexMatch != null:
		regex.compile('(?<=\\[)\\w*')
		regexMatch = regex.search(templateName)
		if regexMatch != null:
			var varName = regexMatch.strings[0]
			templateName = get_var(gmui, vnode, varName)
			return templateName
	return templateName
		
#func create_template(slotVNode:VNode, templateNode:ASTNode)->VNode:
#	var vnodes:Array[VNode] = []
#	var rootVNode:VNode = vnode(templateNode, VNode.VNodeType.STATIC, 0, slotVNode, vnodes)
#	for i in range(templateNode.children.size()):
#		var child:ASTNode = templateNode.children[i]
#		vnodes.append(create_vnodes(child, child.name, child.sceneRoot, i, rootVNode))
#	return rootVNode

func create_normal_nodes(ast:ASTNode, sceneAst:ASTNode, name:String, parent:VNode, index:int):
	var vnodes:Array[VNode] = []
	var rootVNode:VNode = null
	if ast.hasFor:
		rootVNode = vnode(ast, VNode.VNodeType.LIST_ROOT, index, parent, vnodes)
		vnodes.append_array(create_for_node(ast, sceneAst, rootVNode))
	else:
		rootVNode = vnode_with_name(ast, name, VNode.VNodeType.NORMAL, index, parent, vnodes)
		for i in range(ast.children.size()):
			var child = ast.children[i]
			var vnode = create_vnodes(child, child.name, sceneAst, i, rootVNode)
			if vnode != null:
				vnodes.append(vnode)
#		set_bind_value(ast.gmui, rootVNode, ast.bindDict)
	return rootVNode

#func create_scene_nodes(vnode:VNode, astNode:ASTNode, index:int):
#	if vnode.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT:
#		for i in range(astNode.children.size()):
#
#	else:
#		for i in range(astNode.children.size()):
#			var scene:ASTNode = vnode(ast)

func get_scene_nodes(parentVNode:VNode = null, astNode:ASTNode = null, index:int = 0)->Array[VNode]:
	var vnodeType
	var newVNode
	if astNode != astNode.sceneRoot and parentVNode.vnodeType == VNode.VNodeType.MULTI_SCENE_ROOT:
		return create_for_scene(astNode.sceneRoot, parentVNode)
#		return create_for_scene(astNode, parentVNode)
	else:
		vnodeType = get_vnode_type(astNode)
		newVNode = vnode(astNode, vnodeType, index, parentVNode)
		if astNode != astNode.sceneRoot and parentVNode.vnodeType == VNode.VNodeType.SINGAL_SCENE_ROOT:
			return [newVNode]
	if astNode.type == TinyXmlParser.scene:
		return get_scene_nodes(newVNode, astNode.sceneNode)
	else:
		var nodes = []
		for i in range(astNode.children.size()):
			nodes.append_array(get_scene_nodes(newVNode, astNode.children[i], i))
		return nodes

func get_template(sceneASTNode:ASTNode, slot:ASTNode, parentVNode:VNode):
	for child in sceneASTNode.children:
		var templateInfo:TemplateInfo = sceneASTNode.templateInfo
		if templateInfo.name == slot.slotName:
			return create_vnodes(child, child.name, sceneASTNode, 0, parentVNode)

func get_vnode_type(astNode:ASTNode):
	var vnodeType:VNode.VNodeType
	if astNode.type in [TinyXmlParser.slot, TinyXmlParser.template]:
		if astNode.hasFor:
			vnodeType = VNode.VNodeType.LIST_ROOT
		else:
			vnodeType = VNode.VNodeType.STATIC
	elif astNode.type == TinyXmlParser.scene:
		if astNode.hasFor:
			vnodeType = VNode.VNodeType.MULTI_SCENE_ROOT
		else:
			vnodeType = VNode.VNodeType.SINGAL_SCENE_ROOT
	else:
		if astNode.hasFor:
			vnodeType = VNode.VNodeType.LIST_ROOT
		else:
			vnodeType = VNode.VNodeType.NORMAL
	return vnodeType
			
#func create_scene_nodes(rootVNode:VNode, astNode:ASTNode, index:int = 0):
#	var astNodes:Array[ASTNode] = [astNode]
#	var normalNode:VNode = null
#	var preVNode:VNode = null
#	while !astNodes.is_empty():
#		var curAstNode:ASTNode = astNodes.pop_front()
#		var vnodeType:VNode.VNodeType
#		if curAstNode.type in [TinyXmlParser.slot, TinyXmlParser.template]:
#			if curAstNode.hasFor:
#				vnodeType = VNode.VNodeType.LIST_ROOT
#			else:
#				vnodeType = VNode.VNodeType.STATIC
#		elif curAstNode.type != TinyXmlParser.scene:
#			if curAstNode.hasFor:
#				vnodeType = VNode.VNodeType.LIST_ROOT
#			else:
#				vnodeType = VNode.VNodeType.NORMAL
#		var curVNode:VNode = vnode(curAstNode.name, curAstNode.type, rootVNode.sceneAst, vnodeType, curAstNode.bindDict, curAstNode.rgmui, curAstNode.ifValue, index)
##		if preVNode != null:
##			preVNode.children.append()
#		preVNode = curVNode
#		if curAstNode.parent.type == TinyXmlParser.scene:
#			return curAstNode
			
#func create_vnodes(
#	ast:ASTNode, 
#	name:String, 
#	sceneAst:ASTNode, 
#	isOtherInit:bool = false, 
#	index:int = -1, 
#	parent:VNode = null
#)->VNode:
#	var vnodes:Array[VNode] = []
#	var rootVNode:VNode = null
#	if ast.type == TinyXmlParser.scene:
#		var props:Array[Prop] = ast.props
##		set_props(ast)
#		rootVNode = vnode(ast.name, ast.type, ast, VNode.VNodeType.SCENE_ROOT, ast.bindDict, ast.sceneNode.rgmui, ast.ifValue, index, null, ast.properties, ast.model, vnodes)
#		rootVNode.parent = parent
#		if ast.hasFor and !isOtherInit:
#			var sceneRoots:Array[VNode] = create_for_scene(ast, isOtherInit, rootVNode)
#			vnodes.append_array(sceneRoots)
#			set_vnode_if(vnodes)
#		elif ast.hasFor and isOtherInit:
#			rootVNode.children = set_for_template(ast, rootVNode)
#			set_vnode_if(rootVNode.children)
#		else:
#			var sceneNode:VNode = set_template(ast, isOtherInit, rootVNode, -1, null)
#			rootVNode.children = [sceneNode]
#			set_vnode_if(rootVNode.children)
#	elif ast.type == TinyXmlParser.slot:
#		if ast.hasFor:
#			rootVNode = vnode(name, '', null, VNode.VNodeType.LIST_ROOT, {}, null, null, index, parent, {}, null, vnodes)
#			vnodes.append_array(create_for_slot(ast, sceneAst, false, parent))
#		else:
#			rootVNode = vnode(ast.name, ast.type, sceneAst, VNode.VNodeType.STATIC, {}, null, null, index, parent, {}, null, vnodes)
#			var props = ast.props
#			var i = 0
#			for child in ast.children:
#				vnodes.append(create_vnodes(child, child.name, sceneAst, isOtherInit, i, rootVNode))
#				i += 1
#			rootVNode.slotName = ast.slotName
#			rootVNode.props = props
#	elif ast.type == TinyXmlParser.template:
#		if ast.hasFor:
#			rootVNode = vnode(name, '', null, VNode.VNodeType.LIST_ROOT, {}, null, null, index, parent, {}, null, vnodes)
#			vnodes.append_array(create_for_template(ast, sceneAst, isOtherInit, parent))
#		else:
#			rootVNode = vnode(ast.name, ast.type, sceneAst, VNode.VNodeType.STATIC, {}, null, null, index, parent, {}, null, vnodes)
#			var i = 0
#			for child in ast.children:
#				if child.type == TinyXmlParser.scene:
#					if child.hasFor:
#						vnodes.append_array(create_for_scene(child, false, rootVNode))
#					else:
#						vnodes.append(vnode(child.name, child.type, child, VNode.VNodeType.NORMAL, child.bindDict, child.rgmui, child.ifValue, index, parent, child.properties, child.model))
#				else:
#					vnodes.append(create_vnodes(child, child.name, sceneAst, isOtherInit, i, rootVNode))
#				i += 1
#			var templateName = get_template_name(ast.gmui, rootVNode, ast.templateInfo)
#			rootVNode.templateName = templateName
#			set_vnode_if(vnodes)
#	else:
#		if ast.hasFor:
#			rootVNode = vnode(name, '', null, VNode.VNodeType.LIST_ROOT, {}, null, null, index, parent, {}, null, vnodes)
#			vnodes.append_array(create_for_node(ast, sceneAst, isOtherInit, rootVNode))
#		else:
#			rootVNode = vnode(name, ast.type, sceneAst, VNode.VNodeType.NORMAL, ast.bindDict, ast.rgmui, ast.ifValue, index, parent, ast.properties, ast.model, vnodes)
#			set_ref(ast, rootVNode)
#			var i = 0
#			for child in ast.children:
#				var vnode = create_vnodes(child, child.name, sceneAst, isOtherInit, i, rootVNode)
#				if vnode != null:
#					vnodes.append(vnode)
#				i += 1
#			if rootVNode.sceneAst != null and rootVNode.sceneAst.forFlag:
#				var sceneNode:ASTNode = rootVNode.sceneAst
#				set_bind_value(sceneNode.childRgmuis[index], rootVNode, ast.bindDict)
#			else:
#				set_bind_value(ast.gmui, rootVNode, ast.bindDict)
#			set_vnode_if(vnodes)
#			if ast.model!= null and ast.rgmui.data.has(ast.model.name):
#				var value = ast.rgmui.data.rget(ast.model.name)
#				rootVNode.properties[ast.model.name] = value
#	rootVNode.isRoot = ast.isRoot
#	return rootVNode
#
#func collect_slot(vnode, slots:Dictionary = {}):
#	if vnode.type == TinyXmlParser.slot:
#		slots[vnode.slotName] = vnode
#	for child in vnode.children:
#		collect_slot(child, slots)
#	return slots
#
#func set_scene_props(sceneNode:ASTNode, rgmui:GMUI, vnode:VNode, index:int):
#	var props:Array[Prop] = sceneNode.props
#	var gmui = sceneNode.gmui
#	var dict:Dictionary = {}
#	for prop in props:
#		var value
#		if prop.type == Prop.Type.DYNAMIC:
#			value = get_var(gmui, vnode, prop.name)
#		else:
#			value = prop.value
#		dict[prop.name] = value
#	gmui.merge_props(dict)

func set_for_index(gmui:GMUI, indexName:String, nodeName:String):
	if gmui.forIndexName.has(indexName):
		gmui.forIndexName[indexName][nodeName] = true
	else:
		gmui.forIndexName[indexName] = {nodeName: true}

func set_for_var(gmui:GMUI, varName:String, indexName:String, arr:ReactiveArray):
	if gmui.forTempVar.has(varName):
		var forTempVars:Dictionary = gmui.forTempVar[varName]
		for index in gmui.forIndexName[indexName]:
			if !forTempVars.has(index):
				gmui.forTempVar[varName][index] = arr
	else:
		gmui.forTempVar[varName] = {gmui.forIndexName[indexName].keys()[0]: arr}
#	print(gmui.forTempVar)

func create_for_scene(ast:ASTNode, parent:VNode = null)->Array[VNode]:
	var vnodes:Array[VNode] = []
	var arrName:String = ast.forValue.arrName
	var varName:String = ast.forValue.varName
	var indexName:String = ast.forValue.indexName
	var gmui:GMUI = ast.gmui
	var arr:ReactiveArray = gmui.data.__rget(arrName)
	arr.gen_ids(ast.name)
	var node = ast.sceneNode
	for i in range(arr.rsize()):
		var name = arr.ids[parent.name][i]
		set_for_index(gmui, indexName, name)
		set_for_var(gmui, varName, indexName, arr)
		var vnode = vnode_with_name(node, name, VNode.VNodeType.NORMAL, i, parent, [])
		vnodes.append(vnode)
	return vnodes

func set_scene_gmui(ast:ASTNode, vnode:VNode, index:int):
	var gmuis = ast.childRgmuis
	if index > ast.childRgmuis.size() - 1:
		var rgmui = copy_gmui(ast.rgmui)
		ast.childRgmuis.append(rgmui)
		vnode.gmui = rgmui
	else:
		return ast.childRgmuis[index]

func copy_gmui(gmui:GMUI):
	var data:ReactiveDictionary = gmui.data.copy()
	var props:ReactiveDictionary = gmui.props.copy()
	var forTempVar = gmui.forTempVar.duplicate(true)
	var forIndexName = gmui.forIndexName.duplicate(true)
	var forIndexDict = gmui.forIndexDict.duplicate(true)
	gmui = GMUI.new()
	gmui.data = data
	gmui.props = props
	gmui.forTempVar = forTempVar
	gmui.forIndexName = forIndexName
	gmui.forIndexDict = forIndexDict
	return gmui

func create_for_node(ast:ASTNode, sceneAST:ASTNode, parent:VNode = null)->Array[VNode]:
	var vnodes:Array[VNode] = []
	var arrName:String = ast.forValue.arrName
	var varName:String = ast.forValue.varName
	var indexName:String = ast.forValue.indexName
	var gmui:GMUI = ast.gmui
	var arr:ReactiveArray = gmui.data.__rget(arrName)
	arr.gen_ids(parent.name)
	ast.hasFor = false
	for i in range(arr.rsize()):
		var name = arr.ids[parent.name][i]
		set_for_index(gmui, indexName, name)
		set_for_var(gmui, varName, indexName, arr)
		var vnode = create_vnodes(ast, name, sceneAST, i, parent)
		vnodes.append(vnode)
	ast.hasFor = true
	return vnodes

func create_for_slot(ast:ASTNode, parent:VNode = null):
	var vnodes:Array[VNode] = []
	var arrName:String = ast.forValue.arrName
	var varName:String = ast.forValue.varName
	var indexName:String = ast.forValue.indexName
	var gmui:GMUI = ast.gmui
	var arr:ReactiveArray = gmui.data.__rget(arrName)
	var slotDict:Dictionary = {}
	arr.gen_ids(parent.name)
	ast.hasFor = false
	for i in range(arr.rsize()):
		var name = arr.ids[parent.name][i]
		set_for_index(gmui, indexName, name)
		set_for_var(gmui, varName, indexName, arr)
		var vnode = create_vnodes(ast, name, ast.sceneRoot, i, parent)
		vnodes.append(vnode)
	ast.hasFor = true
	return vnodes

#func get_template_name(gmui:GMUI, vnode:VNode, templateInfo:TemplateInfo)->String:
#	var regex:RegEx = RegEx.create_from_string('(?<=\\[)\\w*')
#	var regexMatch = regex.search(templateInfo.name)
#	if regexMatch != null:
#		return get_var(gmui, vnode, regexMatch.strings[0])
#	return templateInfo.name

func get_var(gmui:GMUI, vnode:VNode, key:String)->Variant:
	var data:ReactiveDictionary = gmui.data
	var props:ReactiveDictionary = gmui.props
	if props.has(key):
		return props.rget(key)
	elif gmui.forIndexName.has(key):
		var parent = __get_parent(gmui.forIndexName[key], vnode)
		return parent.index
	elif gmui.forTempVar.has(key):
		var indexDict = {}
		for item in gmui.forTempVar[key].keys():
			indexDict[item] = true
		var parent = __get_parent(indexDict, vnode)
		return gmui.forTempVar[key][parent.name].rget(parent.index)
	elif key.begins_with('self.'):
		return data.rget(key.lstrip('self.'))
	elif data.has(key):
		return data.rget(key)
	return null

func __get_parent(nameDict:Dictionary, vnode:VNode):
	var vn = vnode
	while !nameDict.has(vn.name):
		vn = vn.parent
	return vn

func set_bind_value(gmui:GMUI, vnode:VNode, bindDict:Dictionary):
	var dict:Dictionary = {}
	for key in bindDict:
		var varName = bindDict[key]
		dict[key] = get_var(gmui, vnode, varName)
	vnode.properties.merge(dict, true)

func get_props(slot:VNode):
	var gmui:GMUI = slot.sceneAst.rgmui
	var props = slot.props
	var propDict:Dictionary = {}
	for prop in props:
		if prop.name != 'NULL':
			var value = null
			if prop.type == Prop.Type.STATIC:
				value = prop.value
			else:
				value = gmui.data.rget(prop.value)
			propDict[prop.name] = value
	return propDict
#
#func set_template_props(vnode:VNode, index:int):
#	if vnode.vnodeType == VNode.VNodeType.NORMAL:
#		set_bind_value(vnode.sceneAst.gmui, vnode, vnode.bindDict)
#	for child in vnode.children:
#		set_template_props(child, index)
#
#func set_for_template(ast:ASTNode, parent:VNode):
#	var arrName:String = ast.forValue.arrName
#	var varName:String = ast.forValue.varName
#	var indexName:String = ast.forValue.indexName
#	var gmui:GMUI = ast.gmui
#	var arr:ReactiveArray = gmui.data.__rget(arrName)
#	var slotDict:Dictionary = {}
#	var sceneRoots:Array[VNode] = []
#	ast.hasFor = false
#	for i in range(arr.rsize()):
#		sceneRoots.append(set_template(ast, false, parent, i, arr))
#	ast.hasFor = true
#	return sceneRoots
#
#func set_template(ast:ASTNode, isOtherInit:bool, parent:VNode, index:int, arr:ReactiveArray)->VNode:
#	var i = 0
#	var templates:Array[VNode] = []
#	var sceneNode:VNode = create_vnodes(ast.sceneNode, ast.sceneNode.name, ast, i, parent)
#	set_ref(ast, sceneNode)
#	var slots:Dictionary = collect_slot(sceneNode)
#	var tempArr:Array[VNode] = []
#	var gmui:GMUI
#	if arr != null:
#		gmui = ast.childRgmuis[index]
#	if ast.children.size() > 0:
#		for astNode in ast.children:
#			if arr != null:
#				astNode.gmui = gmui
#			if astNode.forValue != null:
#				set_for_index(astNode.gmui, astNode.forValue.indexName, astNode.name)
#				set_for_var(astNode.gmui, astNode.forValue.varName, astNode.forValue.indexName, astNode.gmui.data.__rget(astNode.forValue.arrName))
#			var template:VNode = create_vnodes(astNode, astNode.name, ast, i, parent)
#			if astNode.hasFor:
#				for temp in template.children:
#					template_props(astNode, slots, temp, tempArr)
#			else:
#				template_props(astNode, slots, template, tempArr)
#			i += 1
#		sceneNode.children.clear()
#		sceneNode.children.append_array(tempArr)
#	return sceneNode
#
#func template_props(astNode:ASTNode, slots:Dictionary, template:VNode, arr:Array[VNode]):
#	var templateName = template.templateName
#	var slot:VNode = slots[templateName]
#	var props = get_props(slot)
#	var param = astNode.templateInfo.params.replace('"', '')
#	astNode.gmui.merge_props({param: props})
#	slot.children = [template]
#	template.parent = slot
#	arr.append(slot)
#
#func set_props(sceneNode:ASTNode):
#	var props:Array[Prop] = sceneNode.props
#	var gmui = sceneNode.gmui
#	var rgmui = sceneNode.rgmui
#	var dict:Dictionary = {}
#	for prop in props:
#		var value
#		if prop.type == Prop.Type.DYNAMIC:
#			value = gmui.data.rget(prop.value)
#		else:
#			value = prop.value
#		dict[prop.name] = value
#	rgmui.merge_props(dict)
#
func set_ref(ast:ASTNode, vnode:VNode):
	if ast.refName == '': return
	var ref
	if ast.type == TinyXmlParser.scene:
		ref = ast.gmui.refs.get(ast.refName, null)
		if ref != null and ref is Array:
			var names = ref.map(func(ref): return ref.name)
			if names.find(vnode.name) == -1:
				ref.append(vnode.gmui)
		elif ref != null:
			if ref.name == vnode.name:
				ast.gmui.refs[ast.refName] = vnode.gmui
		else:
			ast.gmui.refs[ast.refName] = vnode.gmui
	else:
		ref = ast.gmui.refs.get(ast.refName, null)
		if ref != null and ref is Array:
			var names = ref.map(func(ref): return ref.name)
			if names.find(vnode.name) == -1:
				ref.append(vnode)
		elif ref != null:
			if ref.name == vnode.name:
				ast.gmui.refs[ast.refName] = vnode
		else:
			ast.gmui.refs[ast.refName] = vnode
#
func set_vnode_if(vnodes:Array[VNode]):
	var ifDict:Dictionary = {}
	for i in range(vnodes.size()):
		if vnodes[i].ifValue != null and vnodes[i].ifValue.type == IfValue.Type.IF:
			ifDict[i] = vnodes[i]
	var ifs:Array[Dictionary] = []
	var tindex = 0
	for key in ifDict:
		ifs.append({key: ifDict[key]})
		for i in range(key + 1, vnodes.size()):
			if i < vnodes.size() and vnodes[i].ifValue != null:
				if vnodes[i].ifValue.type == IfValue.Type.ELSE_IF or vnodes[i].ifValue.type == IfValue.Type.ELSE:
					ifs[tindex][i] = vnodes[i]
				else:
					break
		tindex += 1
	var eraseArr:Array[VNode] = []
	for i in range(ifs.size()):
		var trueItem
		for key in ifs[i]:
			var ifValue:IfValue = ifs[i][key].ifValue
			var gmui:GMUI
			if ifs[i][key].sceneAst == null:
				gmui = ifs[i][key].gmui
			else:
				gmui = ifs[i][key].sceneAst.gmui
			var boolValue
			if ifValue.varType == Prop.Type.STATIC:
				boolValue = ifValue.value
			else:
				#数学表达式
				var regex = RegEx.create_from_string('[A-Za-z][\\w]+')
				var regexMatchs = regex.search_all(ifValue.value)
				var code:String = ifValue.value
				for regexMatch in regexMatchs:
					var name:String = regexMatch.strings[0]
					if !name in ['true', 'false']:
						var value = get_var(gmui, null, name)
						code = code.replace(name, str(value))
				var exp = Expression.new()
				exp.parse(code)
				boolValue = exp.execute()
			if boolValue:
				if ifValue.type == IfValue.Type.IF or ifValue.type == IfValue.Type.ELSE_IF or ifValue.type == IfValue.Type.ELSE:
					trueItem = ifs[i][key]
					break
		for key in ifs[i]:
			if trueItem != ifs[i][key]:
				eraseArr.append(ifs[i][key])
	for item in eraseArr:
		vnodes.erase(item)
