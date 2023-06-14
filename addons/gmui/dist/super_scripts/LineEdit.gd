extends LineEdit

var oldVNode = null
var ast = null
var vmId = _vms.get_id()
var vm = GMUI.new()
var watcher = null
var isComponent = true
var code = null
var renderFunc = null
var newVNode = null
var staticProps = {}
var dynamicProps = {}
var modelName = ''
var isInit = true
var gmuiParent = null
var distPath = 'res://addons/gmui/dist'
var isReplace = false
var commands = []

signal mounted
signal updated
signal init_finish
signal sended_ast

func _init():
	super._init()
	_vms.set_vm(vm)
	ready.connect(_init_watcher)
#	ready.connect(_set_parent_vm)
	init_finish.connect(_mounted)
	updated.connect(_updated)
#	tree_entered.connect(build_ast)
#	self.set_scene_instance_load_placeholder(true)
#	ready.connect(dont_init)

func _set_parent_vm(node = get_parent()):
	if 'isComponent' in node and node.scene_file_path != '':
		vm.parent = node.vm
		gmuiParent = node
	elif node.get_parent() != null:
		_set_parent_vm(node.get_parent())

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
#	_mounted()
#	_updated()
	emit_signal('init_finish')
	exec_commands()
#	emit_signal('updated')

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
		modelName = ast.modelName
		return ast.sceneXML
	elif ast.isBuiltComponent and ast.path == _path:
		return ast
	elif ast.isSlot:
		return _get_current_ast(ast.template)
	else:
		for child in ast.children:
			var res = _get_current_ast(child)
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
#	var code = CodeGen.render_func(ast, vm, staticProps, dynamicProps)
#	var renderFunc = Function.new(code, _vh)
#	var newVNode = renderFunc.exec()
	newVNode = VNodeHelper.create_vnodes(ast, vm)
	_patch.run(oldVNode, newVNode)
	oldVNode = newVNode
	_set_ref(oldVNode)
	emit_signal('updated')

func _init_render():
	oldVNode = VNodeHelper.rtree_to_vtree(self)
#	oldVNode.isRoot = true
	if !Engine.is_editor_hint():
		if self == get_tree().current_scene or oldVNode.isReplace:
			var xmlPath = FileUtils.scene_to_xml_path(self.scene_file_path)
			ast = TinyXMLParser.parse_xml(xmlPath)
			self.name = ast.name
			oldVNode.name = ast.name
#			code = CodeGen.render_func(ast, vm)
#			renderFunc = Function.new(code, _vh)
#			newVNode = renderFunc.exec()
			newVNode = VNodeHelper.create_vnodes(ast, vm)
			_patch.run(oldVNode, newVNode)
		else:
			_set_parent_vm()
			ast = _get_current_ast(gmuiParent.ast)
			_init_props()
			_set_ast_model(ast)
#			get_parent().ast.children.erase(ast)
#			oldVNode = _get_current_vnode(oldVNode)
#			_erase_vnode(get_parent().newVNode)
#			code = CodeGen.render_func(ast, vm, staticProps, dynamicProps)
#			renderFunc = Function.new(code, _vh)
#			newVNode = renderFunc.exec()
			newVNode = VNodeHelper.create_vnodes(ast, vm)
			_set_component_model(newVNode)
			_patch.run(oldVNode, newVNode)
	oldVNode = newVNode
	_set_ref(oldVNode)
	normalize_refs()
	if vm.parent != null:
		if !oldVNode.ref.is_empty() and vm.parent.refs.has(oldVNode.ref['name']):
			vm.parent.refs[oldVNode.ref['name']] = oldVNode
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

func _set_ast_model(ast):
	if !ast.model.is_empty() and ast.model.rName == modelName:
		vm.define_props({modelName: vm.parent.data.rget(modelName)})
	for child in ast.children:
		_set_ast_model(child)

func _set_component_model(vnode):
	if !vnode.model.is_empty() and vnode.model.rName == modelName:
		vnode.model['isCompModel'] = true
	for child in vnode.children:
		_set_component_model(child)

func _mounted():
	pass

func _updated():
	pass

func _process(delta):
	pass

func _remove_children(node):
	for child in node.get_children():
		_remove_children(child)
		child.queue_free()

func _set_ref(vnode):
	if vnode!=null:
		if vnode.isScene:
			if !vnode.ref.is_empty() or !vnode.id.is_empty():
				if !vm.refs.has(vnode.ref['name']):
					vm.refs[vnode.ref['name']] = [vnode.rnode.vm]
				else:
					vm.refs[vnode.ref['name']].append(vnode.rnode.vm)
				if !vm.ids.has(vnode.id['name']):
					vm.ids[vnode.id['name']] = [vnode.rnode.vm]
				else:
					vm.ids[vnode.id['name']].append(vnode.rnode.vm)
		else:
			if !vnode.ref.is_empty() or !vnode.id.is_empty():
				if !vm.refs.has(vnode.ref['name']):
					vm.refs[vnode.ref['name']] = [vnode]
				else:
					vm.refs[vnode.ref['name']].append(vnode)
				if !vm.ids.has(vnode.id['name']):
					vm.ids[vnode.id['name']] = [vnode]
				else:
					vm.ids[vnode.id['name']].append(vnode)
	for child in vnode.children:
		_set_ref(child)

func normalize_refs():
	for key in vm.refs.keys():
		if vm.refs[key] is Array and vm.refs[key].size() <= 1:
			vm.refs[key] = vm.refs[key][0]
			vm.ids[key] = vm.ids[key][0]
			
func change_component_from_file(path):
	path = path.replace('res://components', 'res://addons/gmui/dist/scenes/components')
	path = path.replace('.gmui', '.tscn')
	var scene = load(path)
	_remove_children(self)
	var root = scene.instantiate()
	root.isReplace = true
	self.replace_by(root)

func change_scene_from_file(path):
	path = path.replace('res://pages', 'res://addons/gmui/dist/scenes/pages')
	path = path.replace('.gmui', '.tscn')
	get_tree().change_scene_to_file(path)
	
func exec_commands():
	for command in commands:
		command.call()
#func _notification(what):
#	if what == NOTIFICATION_SCENE_INSTANTIATED:
#		print(self.name)
