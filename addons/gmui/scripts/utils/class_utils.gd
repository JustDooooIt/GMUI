class_name ClassUtils extends RefCounted

static func instantiate(className:String):
	if ClassDB.class_exists(className) and ClassDB.can_instantiate(className):
		return ClassDB.instantiate(className)
	else:
		var classList:Array[Dictionary] = ProjectSettings.get_global_class_list()
		for classDict in classList:
			if classDict['class'] == className:
				return load(classDict['path']).new()
	push_error('create %s fail' % className)
