@tool
extends EditorPlugin

var dock:Node = preload("res://addons/gmui/scenes/layout_option.tscn").instantiate()
var genBtn:Button = dock.get_node('./GenFileBtn')
var distPath:String = 'res://addons/gmui/dist'
var sceneTag:String = 'eBE2i'
var baseScriptPath:String = 'res://addons/gmui/scripts/common/base_script.gd'
var configJson:Dictionary = {}
var editorInterface = get_editor_interface()
var editorSetting = editorInterface.get_editor_settings()
var editObj = null
var ifGenerate = true

func _enter_tree()->void:
	add_control_to_dock(EditorPlugin.DOCK_SLOT_LEFT_BR, dock)
	genBtn.pressed.connect(gen)
	gen_json()
	configJson = load_json()
	set_main_scene()
	ProjectSettings.set_setting('application/config/name', configJson['name'])
	ProjectSettings.set_setting('application/config/description', configJson['description'])
	ProjectSettings.set_setting('application/config/icon', 'res:/' + configJson['icon'])
	ProjectSettings.set_setting('display/window/size/viewport_width', configJson['screen'].split('x')[0])
	ProjectSettings.set_setting('display/window/size/viewport_height', configJson['screen'].split('x')[1])
	ifGenerate = configJson.get('if_generate')
	editorSetting.set('docks/filesystem/textfile_extensions', 'txt,md,cfg,ini,log,json,yml,yaml,toml,xml,gmui')
	add_autoload_singleton('Values',"res://addons/gmui/scripts/observer/values.gd")
	add_autoload_singleton('VnodeHelper',"res://addons/gmui/scripts/vnode/vnode_helper.gd")
	add_autoload_singleton('TinyXmlParser', "res://addons/gmui/scripts/complie/tiny_xml_parser.gd")
	add_autoload_singleton('Patch', "res://addons/gmui/scripts/vnode/patch.gd")
	
func _build():
	if str_to_var(configJson['if_generate']):
		gen()
	return true

func _handles(object):
	return object is Resource

func _edit(object):
	editObj = object

func _save_external_data():
	if editObj is Resource and editObj.resource_path.get_file() == 'gmui.json':
		set_main_scene()
		configJson = load_json()
		
func gen()->void:
	var filePaths:Array[String] = FileUtils.get_all_gmui_file('res://', ['res://addons'])
	gen_dist(filePaths, 'user')
	filePaths = FileUtils.get_all_gmui_file('res://addons/gmui/ui/')
	gen_dist(filePaths, 'sys')

func gen_dist(filePaths:Array[String], mode)->void:
	for filePath in filePaths:
		var content:String = FileAccess.get_file_as_string(filePath)
		var scriptCode:String = get_ui_script_code(content)
		var uiCode:String = get_ui_tag_code(content, get_script_codes(content))
		var layoutPath:String = gen_layout(filePath, uiCode.strip_edges(), mode)
		var rootType:String = get_root_type(uiCode)
		var scenePath:String = gen_scene(filePath, rootType, mode)
		var superScriptPath:String = gen_super_script(filePath, rootType, mode)
		var scriptPath:String = gen_script(filePath, superScriptPath, scriptCode, mode)
		mount_script(scenePath, scriptPath)
		
func gen_layout(gmuiPath:String, uiCode:String, mode:String):
	var path:String
	if mode == 'user':
		path = get_user_layout_path(gmuiPath)
	else:
		path = get_sys_layout_path(gmuiPath)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	uiCode = '<?xml version="1.0" encoding="UTF-8"?>\n' + uiCode 
	file.store_string(uiCode)
	file.close()
	return path

func mount_script(scenePath:String, scriptPath:String):
	var scene:PackedScene = load(scenePath)
	var root:Node = scene.instantiate()
	var script:GDScript = load(scriptPath)
	root.set_script(script)
	scene.pack(root)
	ResourceSaver.save(scene, scenePath)

func gen_script(filePath:String, superScriptPath:String, scriptCode:String, mode:String):
	var code:String = 'extends "%s"\n' % superScriptPath + '\n' + scriptCode
	var script:GDScript = GDScript.new()
	script.source_code = code
	var scriptPath
	if mode == 'user':
		scriptPath = get_user_script_path(filePath)
	else:
		scriptPath = get_sys_script_path(filePath)
	DirAccess.make_dir_recursive_absolute(scriptPath.get_base_dir())
	ResourceSaver.save(script, scriptPath)
	return scriptPath

func gen_super_script(filePath:String, rootType:String, mode:String):
	var path
	if mode == 'user':
		path = get_user_super_script_path(filePath)
	else:
		path = get_sys_super_script_path(filePath)
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var code:String = FileAccess.get_file_as_string(baseScriptPath)
	code = code.replace('extends Control', 'extends %s\n' % rootType)
	var script:GDScript = GDScript.new()
	script.source_code = code
	ResourceSaver.save(script, path)
	return path
	
func get_root_type(uiCode:String):
	var regex:RegEx = RegEx.create_from_string('<\\w*')
	var regexMatch:RegExMatch = regex.search(uiCode)
	if regexMatch != null:
		var tag:String = regexMatch.strings[0]
		regex.compile('(?<=<)\\w*')
		regexMatch = regex.search(tag)
		if regexMatch != null:
			return regexMatch.strings[0]
	return 'Control'

func gen_scene(filePath:String, rootType:String, mode:String):
	var scenePath
	var xmlFilePath
	if mode == 'user':
		scenePath = get_user_scene_path(filePath)
	else:
		scenePath = get_sys_scene_path(filePath)
	DirAccess.make_dir_recursive_absolute(scenePath.get_base_dir())
	var rootNode:Node = ClassUtils.instantiate(rootType)
	rootNode.name = 'Root'
	var scene:PackedScene = PackedScene.new()
	scene.pack(rootNode)
	ResourceSaver.save(scene, scenePath)
	return scenePath

func get_user_scene_path(gmuiPath:String):
	return gmuiPath.replace('res://', distPath + '/scenes/').replace('.gmui', '.tscn')

func get_sys_scene_path(gmuiPath:String):
	return gmuiPath.replace('res://addons/gmui/ui', distPath + '/scenes/ui').replace('.gmui', '.tscn')

func get_user_super_script_path(gmuiPath:String):
	return gmuiPath.replace('res://', distPath + '/super_scripts/').replace('.gmui', '.gd')

func get_sys_super_script_path(gmuiPath:String):
	return gmuiPath.replace('res://addons/gmui/ui/', distPath + '/super_scripts/ui').replace('.gmui', '.gd')

func get_user_script_path(gmuiPath:String):
	return gmuiPath.replace('res://', distPath + '/scripts/').replace('.gmui', '.gd')
	
func get_sys_script_path(gmuiPath:String):
	return gmuiPath.replace('res://addons/gmui/ui/', distPath + '/scripts/ui/').replace('.gmui', '.gd')

func get_user_layout_path(gmuiPath:String):
	return gmuiPath.replace('res://', distPath + '/layouts/').replace('.gmui', '.xml')
	
func get_sys_layout_path(gmuiPath:String):
	return gmuiPath.replace('res://addons/gmui/ui/', distPath + '/layouts/ui/').replace('.gmui', '.xml')
	
func get_ui_script_code(content:String)->String:
	var codes:Array[String] = get_script_codes(content)
	var scriptCode:String = ''
	for code in codes:
		var startTag:RegEx = RegEx.create_from_string('(?=\\n*)<Script>')
		var startTagMatch:RegExMatch = startTag.search(code)
		var endTag:RegEx = RegEx.create_from_string('(?=\\n*)</Script>')
		var endTagMatch:RegExMatch = endTag.search(code)
		if startTagMatch != null:
			code = code.replace(startTagMatch.strings[0], '')
		if endTagMatch != null:
			code = code.replace(endTagMatch.strings[0], '')
		scriptCode += code
	var regex = RegEx.create_from_string('@import\\(.*\\)')
	var regexMatchs = regex.search_all(scriptCode)
	for regexMatch in regexMatchs:
		scriptCode = scriptCode.replace(regexMatch.strings[0], '')
	scriptCode = conditional_compilation(scriptCode)
	return scriptCode

func get_outter_script(content:String)->String:
	var regex:RegEx = RegEx.create_from_string('(?<=(src="))[^"]*')
	var regexMatch:RegExMatch = regex.search(content)
	if regexMatch != null:
		var src:String = regexMatch.strings[0]
		var script:GDScript = load(src)
		if script != null:
			return script.source_code
	return ''

func get_ui_tag_code(content:String, scriptCodes:Array[String] = [])->String:
	var comDict:Dictionary = get_import(content)
	if scriptCodes.size() == 0:
		var codes = get_script_codes(content)
		for code in codes:
			content = content.replace(code, '')
	else:
		for code in scriptCodes:
			content = content.replace(code, '')
	var scriptCode = get_ui_script_code(content)
	for com in comDict:
		var path:String = comDict[com]
		if path.begins_with('res://addons/gmui/ui'):
			path = path.replace('res://addons/gmui/ui/', distPath + '/layouts/ui/')
		else:
			path = path.replace('res://', distPath + '/layouts/')
		path = path.replace('.gmui', '.xml')
		content = content.replace('<%s' % com, '<Scene %s="%s"' % [sceneTag, path])
		content = content.replace('</%s>' % com, '</Scene>')
#	content = content.replace('<Template>', '').replace('</Template>', '')
	content = conditional_compilation(content)
	return content

func get_import(content:String)->Dictionary:
	var dict:Dictionary = {}
	var regex:RegEx = RegEx.create_from_string('<Script[^>]*([\\s\\S]*?)</Script>')
	var regexMatchs:Array[RegExMatch] = regex.search_all(content)
	for regexMatch in regexMatchs:
		var scriptCode:String = regexMatch.strings[0]
		regex = RegEx.create_from_string('(?<=(@import\\()).*(?=(\\)\\n*))')
		var importMatchs:Array[RegExMatch] = regex.search_all(scriptCode)
		for i in range(0, importMatchs.size()):
			var value:String = importMatchs[i].strings[0]
			value = value.replace("'", '')
			var params:PackedStringArray = value.split(',')
			var comName:String = ''
			var path:String = ''
			if params.size() > 1:
				comName = params[0]
				path = params[1].strip_edges()
			else:
				path = value
				comName = path.get_file().split('.')[0]
			dict[comName] = path
	return dict

func get_script_codes(content:String)->Array[String]:
	var codes:Array[String] = []
	var regex:RegEx = RegEx.create_from_string('<Script[^>]*([\\s\\S]*?)</Script>')
	var regexMatchs:Array[RegExMatch] = regex.search_all(content)
	for regexMatch in regexMatchs:
		codes.append(regexMatch.strings[0])
	return codes

func conditional_compilation(code:String = '')->String:
	var curOsName:String = OS.get_name()
	var regexIf:RegEx = RegEx.create_from_string("(?<ifdefStr>(?<type>((#ifdef)|(#ifndef)))\\s+\\[(?<name>\\w+)\\])\\n*(.|\\n)*?\\n*#endif")
	var regexMatchIfs:Array[RegExMatch] = regexIf.search_all(code)
	var ifdefs:Array[String] = []
	for ifdef in regexMatchIfs:
		var osName = ifdef.get_string('name')
		var type = ifdef.get_string('type')
		var ifdefStr = ifdef.get_string('ifdefStr')
		if type == '#ifdef':
			if osName != curOsName:
				code = code.replace(ifdef.strings[0], '')
		else:
			if osName == curOsName:
				code = code.replace(ifdef.strings[0], '')
		ifdefs.append(ifdefStr)
	for str in ifdefs:
		code = code.replace(str, '')
	code = code.replace('#endif', '')
	return code

func gen_json()->void:
	var json:Dictionary = {
		"name": "demo",
		"description": "a wonderful project",
		"version": "1.0.0",
		"icon": "/addons/gmui/gmui.png",
		"gmui_index": "/pages/index.gmui",
		"screen": "1080x720",
		"environment": "gmui_1.0.0",
		"if_generate": "true"
	}
	if !FileAccess.file_exists('res://gmui.json'):
		var jsonStr = JSON.stringify(json)
		var file:FileAccess = FileAccess.open('res://gmui.json', FileAccess.WRITE)
		file.store_string(jsonStr)
		file.close()

func load_json()->Dictionary:
	var jsonStr = FileAccess.get_file_as_string('res://gmui.json')
	return JSON.parse_string(jsonStr)
	
func set_main_scene()->void:
	var mainScenePath = configJson['gmui_index']
	mainScenePath = distPath + '/scenes' + mainScenePath.replace('.gmui', '.tscn')
	ProjectSettings.set('application/run/main_scene', mainScenePath)
	
func _exit_tree()->void:
	remove_control_from_docks(dock)
	remove_autoload_singleton('Values')
	remove_autoload_singleton('VnodeHelper')
	remove_autoload_singleton('TinyXmlParser')
	remove_autoload_singleton('Patch')
