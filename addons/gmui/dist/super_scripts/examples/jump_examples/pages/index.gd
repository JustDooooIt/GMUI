extends BoxContainer


var isGMUI:int = 0
var ast:ASTNode = null
var vnode:VNode = null
var oldVNode:VNode = null
var gmui:GMUI = null
var __parent:Node = null
var __children:Array[Node] = []
var parent:GMUI = null
var children:Array[GMUI] = []
var reactiveData:ReactiveDictionary = ReactiveDictionary.new()
var distPath:String = 'res://addons/gmui/dist'

signal update
signal root_init_finish
signal init_finish
signal init_start
signal before_update
signal init_gmui
signal init_gmui_finish
signal before_mount
signal unmounted

func _init():
	ready.connect(__init_watcher)
	init_finish.connect(__run_node_init.bind(self))
	init_finish.connect(_mounted)
	update.connect(_updated)
	before_mount.connect(_before_mount)
	before_update.connect(_before_update)
	tree_exiting.connect(_unmounted)
	tree_exited.connect(__clear_setting)
	_created()

func __init_watcher():
	emit_signal('init_start')
	__set_scene_parent()
	var watcher = Watcher.new(__init_render)
	watcher.getter = __update_render
	if __parent != null:
		await __parent.init_finish
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
#	gmui.data = reactiveData
	emit_signal('init_gmui')
	emit_signal('before_mount')
	vnode = VnodeHelper.create(ast, 0, oldVNode, true)
	Patch.patch_node(oldVNode, vnode)
	__set_scene_parent()
	__set_scene_children()
	oldVNode = vnode
	emit_signal('root_init_finish')

func __other_init_render():
	ast = oldVNode.astNode
	gmui = ast.rgmui
#	gmui.data = reactiveData
	emit_signal('init_gmui')
	var tempSceneNode = null
	emit_signal('before_mount')
	vnode = VnodeHelper.create(ast, get_index(), oldVNode, true)
	Patch.patch_node(oldVNode, vnode)
	__set_scene_parent()
	oldVNode = vnode

func __update_render():
	emit_signal('before_update')
	vnode = VnodeHelper.create(ast, get_index(), oldVNode, false)
	Patch.patch_node(oldVNode, vnode)
	oldVNode = vnode
	__set_scene_parent()
	__set_scene_children(self, self.parent)
	emit_signal('update')

func __get_current_vnode(scene:VNode)->VNode:
	for child in scene.children:
		if child.name == self.name:
			return child
	return null

func __init_root_vnode():
	oldVNode = VNode.new()
	oldVNode.type = ast.type
	oldVNode.name = ast.name
	oldVNode.rnode = self
	return oldVNode

func __set_scene_parent(node = self):
	while node != Engine.get_main_loop().current_scene:
		node = node.get_parent()
		if 'isGMUI' in node:
			self.__parent = node
			self.parent = node.gmui
			return

func __set_scene_children(node = Engine.get_main_loop().current_scene, parent = null):
	if 'isGMUI' in node:
		parent = node
		parent.__children.clear()
		parent.children.clear()
	for child in node.get_children():
		if 'isGMUI' in child:
			parent.__children.append(child)
			parent.children.append(child.gmui)
		__set_scene_children(child, parent)

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
	
func _unmounted():
	pass

func __run_node_init(node):
	if node.has_method('_node_init'):
		node._node_init()
	for child in node.get_children():
		if !'isGMUI' in child:
			__run_node_init(child)

func reactive(data:Dictionary):
#	reactiveData.merge(data)
	await init_gmui
	gmui.merge_data(data)
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

func __clear_setting():
	pass
