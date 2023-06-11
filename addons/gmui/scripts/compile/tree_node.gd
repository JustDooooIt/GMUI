class_name TreeNode extends RefCounted

var type = ''
var name = ''
var parent = null
var path = ''
var isRoot = false
var commandStr = ''
var commandType = null
var ifValue = null
var bindDict = {}
var isScene = false
var isSlot = false
var slotDict = {}
var isTemplate = false
var template = null
#var propertyFile = ''
var sceneXMLPath = ''
var sceneXML = null
var model = {}
var modelName = ''
var staticProps = {}
var dynamicProps = {}
var properties = {}
var ref = {}
var children = []

func _init():
	match commandStr:
		'b-if':
			commandType = CommandType.IF
		'b-for':
			commandType = CommandType.FOR
		'b-bind':
			commandType = CommandType.BIND

func copy_tree(node = self):
	var newNode = TreeNode.new()
	var list = self.get_property_list()
	for property in list:
		if property.usage == PROPERTY_USAGE_SCRIPT_VARIABLE:
			newNode.set(property.name, self.get(property.name))
	for child in self.children:
		var newChild = copy_tree(child)
		newNode.children.append(newChild)
	return newNode
