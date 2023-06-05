@tool
extends Node3D

var oldVNode = null
var ast = null
var vmId = _vms.get_id()
var vm = GoVM.new()
var watcher = null
var isComponent = true
var code = null
var renderFunc = null
var newVNode = null
var staticProps = {}
var dynamicProps = {}

signal mounted
signal updated
signal init_finish
signal sended_ast

func _init():
	_vms.set_vm(vm)
	ready.connect(_init_watcher)
	ready.connect(_set_parent_vm)
	init_finish.connect(_mounted)
	updated.connect(_updated)
#	tree_entered.connect(build_ast)
#	self.set_scene_instance_load_placeholder(true)
#	ready.connect(dont_init)

func _set_parent_vm():
	if self != get_tree().current_scene and self != get_tree().edited_scene_root and get_parent().isComponent:
		vm.parent = get_parent().vm

#func _enter_tree():
#	print(self.name)
#	_vms.set_vm(vm)
#	ready.connect(_init_render)

#func build_ast():
#	oldVNode = _vh.rtree_to_vtree(self)
#	var xmlPath = FileUtils.scene_to_xml_path(self.scene_file_path)
#	ast = TinyXMLParser.parse_xml(xmlPath)

func _ready():
#	print(self.name)
#	var xmlParser = TinyXMLParser.new()
#	var root = xmlParser.parseXML("res://layouts/test.xml")
#	var codeGen = CodeGen.new()
#	var code = codeGen.renderFunc(root)
#	var function = Function.new(code, _vh)
#	var vnode2 = function.exec()
#	var vnode1 = _vh.rtree_to_vtree(self)
#	_patch.run(self, vnode2)

#	var root = TinyXMLParser.parse_xml("res://layouts/component.xml")
#	var codeGen = CodeGen.new()
#	var code = codeGen.renderFunc(root)
#	var function = Function.new(code, _vh)
#	var vnode2 = function.exec()
#	_patch.run(vnode1, vnode2)
	
	pass # Replace with function body.

func _init_watcher():
	watcher = Watcher.new(_init_render)
	watcher.getter = _update
	emit_signal('init_finish')

func _get_current_ast(ast):
	var _path = _get_path()
#	if ast.isScene and ast.path == _path:
#		ast.isRoot = true
#		return ast.sceneXML
#	elif ast.isScene and ast.path != _path:
#		return _get_current_ast(ast.sceneXML)
	if ast.isScene and ast.path == _path:
		staticProps = ast.staticProps
		dynamicProps = ast.dynamicProps
		return ast.sceneXML
	elif ast.isSlot:
		return _get_current_ast(ast.template)
	else:
		for child in ast.children:
			var res
			res = _get_current_ast(child)
			if res != null:
				return res

func _get_current_vnode(node):
	var _path = _get_path()
	if node.path == _path:
		return node
	for child in node.children:
		var res
		res = _get_current_vnode(child)
		if res != null:
			return res

func _get_path():
	return '.'.path_join(get_tree().current_scene.get_path_to(self).get_concatenated_names().lstrip('.'))

func _erase_vnode(node):
	for child in node.children:
		if child.path == _get_path():
			node.children.erase(child)
		_erase_vnode(child)

func _update():
	var code = CodeGen.render_func(ast, vm, staticProps, dynamicProps)
	var renderFunc = Function.new(code, _vh)
	var newVNode = renderFunc.exec()
	_patch.run(oldVNode, newVNode)
	oldVNode = newVNode
	emit_signal('updated')

func _init_render():
	oldVNode = _vh.rtree_to_vtree(self)
	if !Engine.is_editor_hint():
		if self == get_tree().current_scene:
			var xmlPath = FileUtils.scene_to_xml_path(self.scene_file_path)
			ast = TinyXMLParser.parse_xml(xmlPath)
			code = CodeGen.render_func(ast, vm)
			renderFunc = Function.new(code, _vh)
			newVNode = renderFunc.exec()
			_patch.run(oldVNode, newVNode)
			oldVNode = newVNode
		else:
			vm.parent = get_parent().vm
			ast = _get_current_ast(get_parent().ast)
			_init_props()
#			get_parent().ast.children.erase(ast)
#			oldVNode = _get_current_vnode(oldVNode)
#			_erase_vnode(get_parent().newVNode)
			code = CodeGen.render_func(ast, vm, staticProps, dynamicProps)
			renderFunc = Function.new(code, _vh)
			newVNode = renderFunc.exec()
			_patch.run(oldVNode, newVNode)
			oldVNode = newVNode
#	else:
#		if self.owner == null:
#			var xmlPath = FileUtils.scene_to_xml_path(self.scene_file_path)
#			ast = TinyXMLParser.parse_xml(xmlPath)
#		else:
#			ast = _get_current_ast(get_parent().ast)
#			get_parent().ast.children.erase(ast)
#	var code = CodeGen.render_func(ast, vm.data)
#	var renderFunc = Function.new(code, _vh)
#	var newVNode = renderFunc.exec()
#	_patch.run(oldVNode, newVNode)
#	oldVNode = newVNode
#	if self != get_tree().current_scene:
#		oldVNode = _get_current_vnode(oldVNode)
#		get_parent().oldVNode.children.erase(oldVNode)
	pass

#func _get_parent_ast(ast, path = ''):
#	for child in ast.children:
#		_get_parent_ast(child)

func _init_props():
	var data = {}
	vm.staticProps = staticProps
	vm.dynamicProps = dynamicProps
	for key in staticProps.keys():
		data[key] = staticProps[key]
	for key in dynamicProps.keys():
		data[key] = null
	vm.define_props(data)

func _mounted():
	pass

func _updated():
	pass

func _process(delta):
	pass

#func _notification(what):
#	if what == NOTIFICATION_SCENE_INSTANTIATED:
#		print(self.name)
