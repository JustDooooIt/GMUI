@tool
class_name Plugin extends EditorPlugin

var editorInterface = get_editor_interface()
var editorSetting = editorInterface.get_editor_settings()
var scriptEditor = editorInterface.get_script_editor()
var editObj = null
var editorDict = {}
var xmlDict = {}
var xmlContent = {}
var isSyncToScene = false
@onready var vms = Engine.get_singleton('_vms')
@onready var patch = Engine.get_singleton('_patch')
@onready var vh = Engine.get_singleton('_vh')

signal bue_setted

func _enter_tree():
	var _vms_ = preload('res://addons/gmui/scripts/common/vms.gd').new()
	var _patch_ = preload('res://addons/gmui/scripts/vnode/patch.gd').new()
	var _vh_ = preload('res://addons/gmui/scripts/vnode/vnode_helper.gd').new()
	var _values_ = preload('res://addons/gmui/scripts/observer/values.gd').new()
	Engine.register_singleton('_vms', _vms_)
	Engine.register_singleton('_patch', _patch_)
	Engine.register_singleton('_vh', _vh_)
	Engine.register_singleton('_values', _values_)
	add_autoload_singleton('_vms', 'res://addons/gmui/scripts/common/vms.gd')
	add_autoload_singleton('_values', 'res://addons/gmui/scripts/observer/values.gd')
	add_autoload_singleton('_vh', 'res://addons/gmui/scripts/vnode/vnode_helper.gd')
	add_autoload_singleton('_patch', 'res://addons/gmui/scripts/vnode/patch.gd')
	editorSetting.set('docks/filesystem/textfile_extensions', 'txt,md,cfg,ini,log,json,yml,yaml,toml,xml')
#	scene_changed.connect(set_bue)
#	scene_changed.connect(init_node)
#	scene_changed.connect(set_xml_content)
#	scene_changed.connect(bind_load_xml_signal)
	add_custom_type('GNode', 'Node', preload('res://addons/gmui/scripts/common/g_node.gd'), preload('res://addons/gmui/icon/Node.svg'))
	add_custom_type('GNode2D', 'Node2D', preload('res://addons/gmui/scripts/common/g_node_2d.gd'), preload('res://addons/gmui/icon/Node2D.svg'))
	add_custom_type('GNode3D', 'Node3D', preload('res://addons/gmui/scripts/common/g_node_3d.gd'), preload('res://addons/gmui/icon/Node3D.svg'))
	add_custom_type('GControl', 'Control', preload('res://addons/gmui/scripts/common/g_control.gd'), preload('res://addons/gmui/icon/Control.svg'))
#func _ready():
#	print('plugin ready')

func _build():
	add_autoload_singleton('_vms', 'res://addons/gmui/scripts/common/vms.gd')
	add_autoload_singleton('_values', 'res://addons/gmui/scripts/observer/values.gd')
	add_autoload_singleton('_vh', 'res://addons/gmui/scripts/vnode/vnode_helper.gd')
	add_autoload_singleton('_patch', 'res://addons/gmui/scripts/vnode/patch.gd')
	return true

func set_xml_content(rootNode):
	var scenePath = rootNode.scene_file_path
	var xmlPath = FileUtils.scene_to_xml_path(scenePath)
	if !xmlContent.has(xmlPath):
		xmlContent[xmlPath] = FileAccess.get_file_as_string(xmlPath)

#func set_bue(rootNode):
#	if !vms.bueDict.has(vms.get_id()):
#		vms.bueDict[vms.get_id()] = Bue.new({ })
#	emit_signal('bue_setted')
	
func init_node(rootNode):
	if rootNode == null or (vms.isInited.has(rootNode.scene_file_path) and vms.isInited[rootNode.scene_file_path]): 
		return
	vms.isInited[rootNode.scene_file_path] = true
	bind_child_entered_signal(rootNode)
	
func init_scene(rootNode):
#	await bue_setted
	if rootNode == null or (vms.isInited.has(rootNode.scene_file_path) and vms.isInited[rootNode.scene_file_path]): 
		return
	vms.isInited[rootNode.scene_file_path] = true
	var scenePath = rootNode.scene_file_path
	var xmlPath = FileUtils.scene_to_xml_path(scenePath)
	var ast = TinyXMLParser.parseXML(xmlPath)
	var renderFunc = Function.new(CodeGen.render_func(ast, {}), vh)
	var vnode = renderFunc.exec()
	remove_all_child(rootNode)
	patch.run(rootNode, vnode)
	bind_child_entered_signal(rootNode)

func remove_all_child(node):
#	node.child_entered_tree.disconnect(child_added.bind(node))
	for child in node.get_children():
		remove_all_child(child)
		node.remove_child(child)
#		child.owner = null
		child.queue_free()

func bind_child_entered_signal(node):
	node.child_entered_tree.connect(add_xml_node.bind(node))
	for child in node.get_children():
		bind_child_entered_signal(child)

func add_xml_node(node, parent):
	if !isSyncToScene and Engine.is_editor_hint():
		var owner = PathUtils.get_owner(parent)
		if !vms.isInited[owner.scene_file_path]: return
		var xmlPath = FileUtils.scene_to_xml_path(owner.scene_file_path)
		TinyXMLParser.append(xmlPath, '<%s name="%s"></%s>' % [node.get_class(), node.name, node.get_class()], PathUtils.get_node_path(parent))
		if editorDict.has(xmlPath):
			editorDict[xmlPath].text = FileAccess.get_file_as_string(xmlPath)

func _apply_changes():
	if editObj is Node:
		pass
	elif editObj is Resource:
		pass
	pass

func _handles(object):
	if object is Node or object is Resource:
		return true
	else:
		return false

func _edit(object):
	if object != null:
		editObj = object
		if object is Resource and object.resource_path.get_extension() == 'xml':
			if !editorDict.has(object.resource_path):
				var codeEdit = scriptEditor.get_current_editor().get_base_editor()
				editorDict[object.resource_path] = codeEdit
				xmlDict[codeEdit.get_instance_id()] = object.resource_path

func _save_external_data():
	if editObj is Resource and editObj.resource_path.get_extension() == 'xml':
#		print('xml')
#		xml_to_scene()
		pass
	elif editObj is Node:
#		print('node')
		pass

func xml_to_scene():
	isSyncToScene = true
	var codeEdit = scriptEditor.get_current_editor().get_base_editor()
	var scenePath = FileUtils.xml_to_scene_path(editObj.resource_path)
	var scene = load(scenePath)
	var rootNode = scene.instantiate()
	if xmlDict.has(codeEdit.get_instance_id()):
		var xmlPath = xmlDict[codeEdit.get_instance_id()]
		var ast = TinyXMLParser.parse_xml(xmlPath)
		var code = CodeGen.render_func(ast, {})
		var renderFunc = Function.new(code, vh)
		var newVNode = renderFunc.exec()
		var oldVNode = vh.rtree_to_vtree(rootNode)
		patch.run(oldVNode, newVNode)
		set_all_owner(rootNode, newVNode.rnode)
		scene.pack(rootNode)
		ResourceSaver.save(scene, scenePath)
		editorInterface.reload_scene_from_path(scenePath)
	isSyncToScene = false

func set_all_owner(rootNode, node):
	for child in node.get_children():
		set_all_owner(rootNode, child)
	node.owner = rootNode

func _get_plugin_name():
	return 'bue'

func _exit_tree():
	vms.isInited.clear()
#	scene_changed.disconnect(set_bue)
	scene_changed.disconnect(init_node)
	Engine.unregister_singleton('_vms')
	Engine.unregister_singleton('_patch')
	Engine.unregister_singleton('_vh')
	Engine.unregister_singleton('_values')
	remove_autoload_singleton('_vms')
	remove_autoload_singleton('_vh')
	remove_autoload_singleton('_patch')
	remove_autoload_singleton('_values')
	remove_custom_type('RootNode')
