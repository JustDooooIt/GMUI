class_name ForValue extends RefCounted

var arrName:String = ''
var varName:String = ''
var indexName:String = ''

func _init(code:String):
	var regex:RegEx = RegEx.new()
	regex.compile('(\\w+(?=(\\s+in)))|(?<=\\().*(?=\\))')
	var strs = regex.search(code).strings[0].split(',')
	if strs.size() > 1:
		indexName = strs[1]
		varName = strs[0]
		indexName = indexName.strip_edges()
		varName = varName.strip_edges()
	else:
		varName = strs[0]
		varName = varName.strip_edges()
	regex.compile('(?<=in\\s)\\w*')
	arrName = regex.search(code).strings[0]
