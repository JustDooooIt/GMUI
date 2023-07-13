extends Control

var isGMUI:int = 0
var ast:ASTNode = null
var vnode:VNode = null
var oldVNode:VNode = null
var gmui:GMUI = null
var sceneParent:Node = null
var reactiveData:ReactiveDictionary = ReactiveDictionary.new()
var distPath:String = 'res://addons/gmui/dist'

signal update
signal init_finish
signal init_start
signal before_update
signal init_gmui
signal init_gmui_finish
signal before_mount

func _init():
	_created()
	ready.connect(__init_watcher)
	init_finish.connect(_mounted)
	update.connect(_updated)
	before_mount.connect(_before_mount)
	before_update.connect(_before_update)
	init_finish.connect(__run_node_init.bind(self))

func __init_watcher():
	emit_signal('init_start')
	__set_scene_parent()
	var watcher = Watcher.new(__init_render)
	watcher.getter = __update_render
	if sceneParent != null:
		await sceneParent.init_finish
	emit_signal('init_finish')
	
func __init_render():
	if self == Engine.get_main_loop().current_scene:
		__root_init_render()
	else:
		__other_init_render()

func __root_init_render():
	var scenePath:String = self.scene_file_path
	scenePath = scenePath.replace('%s/scenes' % [TinyXmlParser.distPath], '%s/layouts' % [TinyXmlParser.distPath])
	scenePath = scenePath.replace(scenePath.get_extension(), 'xml')
	ast = TinyXmlParser.parse_xml(scenePath)
	self.set_name.call_deferred(ast.name)
	oldVNode = __init_root_vnode()
	gmui = ast.gmui
	gmui.data = reactiveData
	emit_signal('init_gmui')
	vnode = VnodeHelper.create(ast, 0, oldVNode, true)
	emit_signal('before_mount')
	Patch.patch_node(oldVNode, vnode)
	oldVNode = vnode

func __other_init_render():
	ast = oldVNode.astNode
	gmui = ast.rgmui
#	gmui.reactive(reactiveData.data)
	gmui.data = reactiveData
	emit_signal('init_gmui')
	var tempSceneNode = null
	vnode = VnodeHelper.create(ast, get_index(), oldVNode, true)
	emit_signal('before_mount')
	Patch.patch_node(oldVNode, vnode)
	oldVNode = vnode

func __update_render():
	emit_signal('before_update')
	vnode = VnodeHelper.create(ast, get_index(), oldVNode, false)
	Patch.patch_node(oldVNode, vnode)
	oldVNode = vnode
	emit_signal('update')

func __get_current_vnode(scene:VNode)->VNode:
	for child in scene.children:
		if child.name == self.name:
			return child
	return null

func __get_parent(node = self.get_parent())->Node:
	if 'isGMUI' in node:
		return node
	return __get_parent(node.get_parent())
	
func __init_root_vnode():
	oldVNode = VNode.new()
	oldVNode.type = ast.type
	oldVNode.name = ast.name
	oldVNode.rnode = self
	return oldVNode

func __init_other_vnode():
	oldVNode = VNode.new()
	oldVNode.name = ast.name
	oldVNode.rnode = self
	return oldVNode

func __set_scene_parent(node = self):
	while node != Engine.get_main_loop().current_scene:
		node = node.get_parent()
		if 'isGMUI' in node:
			sceneParent = node
			return

func _created():
	pass

func _before_mount():
	pass

func _mounted():
	pass
	
func _before_update():
	pass

func _updated():
	pass

func __run_node_init(node):
	if node is Control:
		if node.has_method('_node_init'):
			node._node_init()
	for child in node.get_children():
		__run_node_init(child)

func reactive(data:Dictionary):
	reactiveData.merge(data)
	await init_gmui
	emit_signal('init_gmui_finish')
	return gmui.data

func watch(key:String, callback:Callable):
	await init_gmui_finish
	var data:ReactiveDictionary = reactiveData
	var function = func(_key, newValue, oldValue):
		if key == _key: 
			callback.call(newValue, oldValue)
	data.watch.connect(function)

func computed(getset):
	await init_gmui_finish
	if getset is Dictionary:
		pass
	elif getset is Callable:
		var getter = getset
		var watcher:Watcher = Watcher.new(getter, true)
		reactiveData.depMap[getter.get_method()] = Dep.new()
		reactiveData.rset(
			getter.get_method(),
			func():
				if watcher.dirty:
					watcher.eval()
				if Values.curWatcher != null:
					watcher.depend()
				return watcher.value,
			false, false
		)
	else:
		push_error('computed error')

func jump_to(path:String):
	path = path.replace('res://', distPath + '/scenes/').replace('.gmui', '.tscn')
	get_tree().change_scene_to_file(path)
