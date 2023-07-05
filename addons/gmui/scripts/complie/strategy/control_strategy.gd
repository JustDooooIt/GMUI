class_name ControlStrategy extends RefCounted

var xmlParser:XMLParser = null
var newNode:ASTNode = null

func _init(xmlParser:XMLParser, newNode:ASTNode):
	self.newNode = newNode
	self.xmlParser = xmlParser
	
func operate():
	var count = xmlParser.get_attribute_count()
	for i in count:
		var attrName = xmlParser.get_attribute_name(i)
		var attrValue = xmlParser.get_attribute_value(i)
		if attrName == 'g-model':
			
			pass
