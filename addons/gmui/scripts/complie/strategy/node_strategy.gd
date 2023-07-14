class_name NodeStrategy extends RefCounted

var newNode:ASTNode = null
var xmlParser:XMLParser = null

func _init(xmlParser:XMLParser, newNode:ASTNode):
	self.newNode = newNode
	self.xmlParser = xmlParser
	
func operate():
	var regex = RegEx.create_from_string(':\\w*')
	var count = xmlParser.get_attribute_count()
	for i in count:
		var attrName:String = xmlParser.get_attribute_name(i)
		var attrValue:String = xmlParser.get_attribute_value(i)
		var bindMatch:RegExMatch = regex.search(attrName)
		if attrName == 'g-for':
			newNode.hasFor = true
			newNode.forValue = ForValue.new(attrValue)
		elif attrName.contains('g-bind:') or bindMatch != null:
			var dict = TinyXmlParser.get_value(attrValue)
			if dict.isSuccess:
				newNode.properties[attrName.split(':')[1]] = dict.value
			else:
				var prop:Prop = Prop.new()
				prop.name = attrName.split(':')[1]
				prop.type = Prop.Type.DYNAMIC
				prop.value = attrValue
				newNode.bindDict[attrName.split(':')[1]] = prop
		elif attrName == 'g-model' and \
			newNode.type in \
				['LineEdit', 'TextEdit', 'CodeEdit', 
				'TabBar', 'TabContainer','ColorPicker',
				'CheckButton', 'CheckBox', 'SpinBox', 
				'OptionButton', 'GButtonBox']:
			newNode.model = Model.new(attrValue, TinyXmlParser.input)
		elif attrName == 'ref':
			newNode.refName = attrValue
		elif attrName == 'g-if':
			newNode.ifValue = IfValue.new(IfValue.Type.IF, attrValue)
		elif attrName == 'g-else-if':
			newNode.ifValue = IfValue.new(IfValue.Type.ELSE_IF, attrValue)
		elif attrName == 'g-else':
			newNode.ifValue = IfValue.new(IfValue.Type.ELSE, attrValue)
		else:
			newNode.properties[attrName] = attrValue
