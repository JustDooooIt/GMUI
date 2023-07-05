class_name SceneStarategy extends RefCounted

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
			newNode.forFlag = true
			var forValue = ForValue.new(attrValue)
			newNode.forValue = forValue
		elif attrName.contains('g-model'):
			var regex = RegEx.create_from_string('(?<=:)\\w*')
			var cName = regex.search(attrName).strings[0]
			regex.compile('(?<=(="))\\w*')
			var pName = attrValue
			var name = attrValue
			var type = TinyXmlParser.scene
			var model = Model.new(name, type)
			model.pName = pName
			model.cName = cName
			newNode.models.append(model)
		elif !attrName in ['g-for', 'g-model', TinyXmlParser.scenePathTag, 'ref', 'g-if', 'g-else-if', 'g-else']:
			var dict = TinyXmlParser.get_value(attrValue)
			var prop:Prop = Prop.new()
			var regex = RegEx.create_from_string(':\\w*')
			var bindMatch:RegExMatch = regex.search(attrName)
			if attrName.contains('g-bind:') or bindMatch != null:
				prop.name = attrName.split(':')[1]
				prop.value = dict.value
				if dict.isSuccess:
					prop.type = Prop.Type.STATIC
				else:
					prop.type = Prop.Type.DYNAMIC
			else:
				prop.name = attrName
				prop.value = attrValue
				prop.type = Prop.Type.STATIC
			newNode.props.append(prop)
		elif attrName == 'ref':
			newNode.refName = attrValue
		elif attrName == 'g-if':
			newNode.ifValue = IfValue.new(IfValue.Type.IF, attrValue)
		elif attrName == 'g-else-if':
			newNode.ifValue = IfValue.new(IfValue.Type.ELSE_IF, attrValue)
		elif attrName == 'g-else':
			newNode.ifValue = IfValue.new(IfValue.Type.ELSE, attrValue)
		
