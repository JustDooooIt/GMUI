@tool
class_name GMUI extends Node

var data = ReactiveDictionary.new()
var dynamicProps = {}
var staticProps = {}
var parent = null
var children = []
var refs = {}

#signal send_props()

func define_reactive(data):
#	self.data = ReactiveDictionary.new(data)
	for key in data.keys():
		self.data.data[key] = data[key]
	self.data.observe()
	return self.data

func define_props(data):
	for key in data.keys():
		self.data.data[key] = data[key]
		self.data.rset(key, data[key])
	self.data.observe()

#func set_props():
#	if parent != null:
#		for key in dynamicProps.keys():
#			self.data.rset(key, parent.data.rget(dynamicProps[key]))
