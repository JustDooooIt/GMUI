class_name GMUI extends RefCounted

var name:String = ''
var parent:GMUI = null
var forTempVar:Dictionary = {}
var forIndexName:Dictionary = {}
var forIndexDict:Dictionary = {}
var data:ReactiveDictionary = ReactiveDictionary.new()
var refs:Dictionary = {}
var ids:Dictionary = {}
var props:ReactiveDictionary = ReactiveDictionary.new()
var computedWatchers:Dictionary = {}

func reactive(data:Dictionary, override = false)->ReactiveDictionary:
	self.data.data.merge(data, override)
	self.data.observe()
	for key in data.keys():
		self.data.depMap[key] = Dep.new()
	return self.data

func merge_props(data:Dictionary, override = false):
	self.props.data.merge(data, override)
	for key in data.keys():
		self.props.rset(key, data[key], false, false)
	for key in data.keys():
		self.props.depMap[key] = Dep.new()
	self.props.observe()
