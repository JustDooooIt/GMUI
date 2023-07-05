class_name SlotStrategy extends RefCounted

var newNode:ASTNode = null
var xmlParser:XMLParser = null

func _init(xmlParser:XMLParser, newNode:ASTNode):
	self.newNode = newNode
	self.xmlParser = xmlParser
	
func operate():
	var hasName = false
	var regex = RegEx.create_from_string(':\\w*')
	var count = xmlParser.get_attribute_count()
	for i in count:
		var attrName:String = xmlParser.get_attribute_name(i)
		var attrValue:String = xmlParser.get_attribute_value(i)
		var bindMatch:RegExMatch = regex.search(attrName)
		if attrName == 'name':
			newNode.slotName = attrValue
			hasName = true
		elif attrName == 'g-bind:name' or attrName == ':name':
			newNode.slotName = '[%s]' % attrValue
			hasName = true
		elif attrName.contains('g-bind:') or bindMatch != null:
			var dict = TinyXmlParser.get_value(attrValue)
			var prop:Prop = Prop.new()
			prop.name = attrName.split(':')[1]
			if dict.isSuccess:
				prop.value = dict.value
				prop.type = Prop.Type.STATIC
			else:
				prop.value = attrValue
				prop.type = Prop.Type.DYNAMIC
			newNode.props.append(prop)
		elif attrName == 'g-for':
			newNode.hasFor = true
			newNode.forValue = ForValue.new(attrValue)
		else:
			var prop:Prop = Prop.new()
			prop.value = attrValue
			prop.type = Prop.Type.STATIC
			prop.name = attrName
			newNode.props.append(prop)
	if !hasName:
		newNode.slotName = TinyXmlParser.default
