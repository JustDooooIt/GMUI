extends Node

var scene = 'Scene'
var template = 'Template'
var slot = 'Slot'
var input = 'Input'
var gslot= '#'
var scenePathTag = 'eBE2i'
var default = 'default'
var gForPlaceholder = 'gFor'
var distPath = 'res://addons/gmui/dist'
var cache:Dictionary = {}

func parse_xml(content, isBuffer:bool = false)->ASTNode:
	var root = __parse_xml(content, true, null, null, isBuffer)
	__set_default_template(root)
	__set_gmui(root)
	return root

func __parse_xml(content:String, isRoot = false, gmui:GMUI = null, sceneRoot:ASTNode = null, isBuffer:bool = false)->ASTNode:
	var bytes:PackedByteArray = []
	var xmlParser:XMLParser = XMLParser.new()
	if isBuffer:
		bytes = content.to_utf8_buffer()
		xmlParser.open_buffer(bytes)
	else:
		xmlParser.open(content)
		bytes = FileAccess.get_file_as_bytes(content)
	var root:ASTNode = null
	var cur:ASTNode = null
	var regex = RegEx.new()
	var curGmui:GMUI = gmui
	var preLevel = 0
	var curLevel = 0
	var index = 0
	while xmlParser.read() == OK:
		var nodeType:int = xmlParser.get_node_type()
		if nodeType == XMLParser.NODE_ELEMENT:
			var newNode:ASTNode = ASTNode.new()
			var type:String = xmlParser.get_node_name()
			var count:int = xmlParser.get_attribute_count()
			if preLevel == curLevel:
				index += 1
			newNode.index = index
			newNode.type = type
			newNode.name = str(randi())
			cache[newNode.name] = newNode
			if root == null:
				root = newNode
				root.isRoot = isRoot
				if curGmui == null:
					curGmui = GMUI.new()
					root.gmui = curGmui
					root.rgmui = curGmui
#					GmuiManager.add_gmui(root.name, curGmui, null)
			if type == scene:
				var templateInfo:TemplateInfo = __get_template_attr(xmlParser, bytes)
				newNode.templateInfo = templateInfo
				var path = xmlParser.get_named_attribute_value(scenePathTag)
				var sceneGmui = GMUI.new()
				var sceneNode:ASTNode = __parse_xml(path, false, sceneGmui, newNode)
				newNode.sceneXmlPath = path
				sceneNode.parent = newNode
				newNode.sceneNode = sceneNode
#				GmuiManager.add_gmui(sceneNode.name, sceneGmui, curGmui)
				sceneGmui.parent = curGmui
				newNode.gmui = curGmui
				newNode.rgmui = sceneGmui
				curGmui = sceneGmui
				sceneRoot = newNode
				SceneStarategy.new(xmlParser, newNode).operate()
			elif type == template:
				var templateInfo:TemplateInfo = __get_template_attr(xmlParser, bytes)
				newNode.templateInfo = templateInfo
				newNode.gmui = curGmui.parent
				newNode.rgmui = curGmui
				TemplateStarategy.new(xmlParser, newNode).operate()
			elif type == slot:
				SlotStrategy.new(xmlParser, newNode).operate()
				newNode.gmui = curGmui
				newNode.rgmui = curGmui
			else:
				regex.compile(':\\w*')
				NodeStrategy.new(xmlParser, newNode).operate()
				newNode.gmui = curGmui
				newNode.rgmui = curGmui
			if cur != null:
				cur.children.append(newNode)
				newNode.parent = cur
			cur = newNode
			newNode.sceneRoot = sceneRoot
		elif nodeType == XMLParser.NODE_ELEMENT_END:
			if xmlParser.get_node_name() == scene:
				curGmui = curGmui.parent
			cur = cur.parent
	return root

func __get_template_attr(xmlParser:XMLParser, bytes:PackedByteArray)->TemplateInfo:
	var symbol:int = '>'.to_utf8_buffer()[0]
	var start = xmlParser.get_node_offset()
	for i in range(start, bytes.size()):
		if bytes[i] == symbol:
			bytes = bytes.slice(start, i + 1)
			break
	var tag:String = bytes.get_string_from_utf8()
	var regex:RegEx = RegEx.create_from_string('g-slot(:?)[^\\s>]+')
	var regexMatch:RegExMatch = regex.search(tag)
	var sugarRegex:RegEx = RegEx.create_from_string('#\\[?\\w*\\]?="\\w*"')
	var sugarMatch:RegExMatch = sugarRegex.search(tag)
	var templateInfo:TemplateInfo = TemplateInfo.new()
	if regexMatch != null:
		var templateAttr = regexMatch.strings[0]
		regex.compile('(?<=:)\\w*')
		regexMatch = regex.search(templateAttr)
		var templateName:String = default
		if regexMatch != null and regexMatch.strings[0] != '':
			templateInfo.name = regexMatch.strings[0]
		regex.compile('(?<=")\\w*[^"]')
		regexMatch = regex.search(templateAttr)
		var params:String = ''
		if regexMatch != null:
			templateInfo.params = regexMatch.strings[0]
		return templateInfo
	elif sugarMatch != null:
		var templateAttr = sugarMatch.strings[0]
		regex.compile('(?<=(="))(\\w*)')
		sugarMatch = regex.search(templateAttr)
		templateInfo = TemplateInfo.new()
		if sugarMatch != null:
			templateInfo.params = sugarMatch.strings[0]
		regex.compile('(?<=#)\\[?\\w*\\]?')
		sugarMatch = regex.search(templateAttr)
		if sugarMatch != null:
			templateInfo.name = sugarMatch.strings[0]
		return templateInfo
	else:
		return templateInfo

func __set_default_template(ast:ASTNode, gmui:GMUI = ast.gmui):
	if ast.type == scene and ast.children.size() > 0:
		if ast.children[0].type != template:
			var templateNode = ASTNode.new()
			templateNode.name = str(randi())
			templateNode.type = template
			var children = ast.children
			templateNode.parent = ast
			templateNode.gmui = gmui
			templateNode.rgmui = ast.rgmui
			ast.children = [templateNode]
			templateNode.children = children
			templateNode.templateInfo = ast.templateInfo
			var nodes:Array[ASTNode] = [ast]
			while !nodes.is_empty():
				var node:ASTNode = nodes.pop_front()
				node.gmui = gmui
				for child in node.children:
					nodes.push_front(child)
			for node in ast.children:
				node.parent = templateNode
	for child in ast.children:
		__set_default_template(child, gmui)
	if ast.type == scene:
		__set_default_template(ast.sceneNode, ast.gmui)

func __set_gmui(ast:ASTNode):
	if ast.type == scene:
		for child in ast.children:
			if child.type == template:
				var gmui = child.gmui
				var nodes:Array[ASTNode] = [ast]
				while !nodes.is_empty():
					var node:ASTNode = nodes.pop_front()
					node.gmui = gmui
					for c in node.children:
						nodes.push_front(c)
	for child in ast.children:
		__set_gmui(child)

func __set_parent_scene(node:ASTNode, scene:ASTNode = node):
	if node.type == scene:
		scene = node
	node.parentScene = scene
	if node.type == scene:
		__set_parent_scene(node.sceneNode, scene)
	elif node.type == slot:
		__set_parent_scene(node.template, scene)
	else:
		for child in node.children:
			__set_parent_scene(child, scene)

func get_value(code:String)->Dictionary:
	var exp = Expression.new()
	var err = exp.parse(code)
	if err == OK:
		var value = exp.execute()
		if exp.has_execute_failed():
			return {'isSuccess': false, 'value': code}
		else:
			return {'isSuccess': true, 'value': value}
	else:
		return {'isSuccess': false, 'value': code}
