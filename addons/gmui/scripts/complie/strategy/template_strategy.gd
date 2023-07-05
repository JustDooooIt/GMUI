class_name TemplateStarategy extends RefCounted

var newNode:ASTNode = null
var xmlParser:XMLParser = null

func _init(xmlParser:XMLParser, newNode:ASTNode):
	self.newNode = newNode
	self.xmlParser = xmlParser
	
func operate():
	var count = xmlParser.get_attribute_count()
	for i in count:
		var attrName:String = xmlParser.get_attribute_name(i)
		var attrValue:String = xmlParser.get_attribute_value(i)
		if attrName.begins_with('g-slot'):
			continue
		elif attrName == 'g-for':
			newNode.hasFor = true
			newNode.forValue = ForValue.new(attrValue)
