class_name ControlStrategy extends RefCounted

var node = null
var xmlParser = null
var cName = ''

func _init(node, cName, xmlParser):
	self.node = node
	self.xmlParser = xmlParser
	self.cName = cName
	
func operate():
	var nodeType = xmlParser.get_node_name()
	var count = xmlParser.get_attribute_count()
	node.type = nodeType
	for i in count:
		var attrName = xmlParser.get_attribute_name(i)
		var attrValue = xmlParser.get_attribute_value(i)
		if attrName == 'name':
			node.name = attrValue
		elif attrName == 'g-model':
			node.model = {'cName': cName, 'rName': attrValue, 'isCompModel': false}
		elif attrName == 'ref':
			node.ref['name'] = attrValue
		else:
			node.properties[attrName] = attrValue
