extends RichTextLabel

onready var containerWidth = self.rect_size.x
onready var containerHeight = self.rect_size.y
onready var containerFont = self.get_font("normal_font")
onready var containerStyle = self.get_stylebox("normal")
onready var styleMarginLeft:int = containerStyle.content_margin_left
onready var styleMarginRight:int = containerStyle.content_margin_right
onready var contentBoxWidth:int = (containerWidth - (styleMarginLeft + styleMarginRight))
const lineCountMax:int = 25
const lineCountMin:int = 0
var lineCount:int = 0

func _ready():
#	print(containerFont.get_string_size("111111111111111111"))
#	print(containerFont.get_string_size("line1 line2"))
#	print(containerFont.get_string_size(" "))
#	print(containerWidth)
#	print(containerHeight)
	var test = self.get_visible_line_count()
	var pupa = "iiiiiiiiiiiiiiimi"
	var lupa = containerFont.get_string_size(pupa)
#	print(lupa)
#	print(contentBoxWidth)
#	print(test)
#	add_text_to_log("You have added text number one")
#	add_text_to_log("You have added text number two")
#	add_text_to_log("You have added text number three")
#	add_text_to_log("You have added text number four")
#	add_text_to_log("You have added text number five")
#	add_text_to_log("You have added tex")
#	add_text_to_log("Line1")
#	add_text_to_log("Line2")
#	add_text_to_log("Line3")
#	add_text_to_log("Line4")
#	add_text_to_log("Line5")
#	add_text_to_log("Line6")
#	add_text_to_log("Line7")
#	add_text_to_log("Line8")
#	add_text_to_log("Line9")
#	add_text_to_log("Line10")
#	add_text_to_log("Line11")
#	add_text_to_log("Line12")
#	add_text_to_log("Line13")
#	add_text_to_log("Line14")
#	add_text_to_log("Line15")
#	add_text_to_log("Line16")
#	add_text_to_log("Line17")
#	add_text_to_log("Line18")
#	add_text_to_log("Line19")
#	add_text_to_log("Line20")
#	add_text_to_log("Line21")
#	add_text_to_log("Line22")
#	add_text_to_log("Line23")
#	add_text_to_log("Line24")
#	add_text_to_log("Line25")

func add_text_to_log(pushText:String):
	lineCount = self.get_line_count()
	print("LINE COUNT START: %s" %lineCount)
	get_text_total_lines(pushText)
	lineCount = self.get_line_count()
	print("LINE COUNT FINISH: %s" %lineCount)
	if lineCount > lineCountMax:
		for line in (lineCount - lineCountMax):
			remove_line(line)
			pass
		pass
	elif lineCount < lineCountMax:
		pass
	else:
		pass
	format_text_bbcode()

func get_text_total_lines(newText:String):
	var newString:String = "*"
	var currentText:String = self.get_text()
	var latestText:String = newText
	var finalText:String
	var lineSizeMax:int = contentBoxWidth
	var lineSizeMin:int = 0
	var lineSizeOld:int = 0
	var lineSizeNew:int = 0
	var i:int = 0

	while i < latestText.length():
		print("---------------")
		print("CHAR: %s" %latestText[i])
		print("CHAR SIZE: %s" %containerFont.get_string_size(latestText[i]).x)
		lineSizeOld = containerFont.get_string_size(newString).x
		print("old_size: %s" %lineSizeOld)
		lineSizeNew = containerFont.get_string_size(newString + latestText[i]).x
		print("new_size: %s" %lineSizeNew)
		if lineSizeNew <= lineSizeMax:
			print("SMALLER - ADD CHAR")
			if newString[0] == " ":
				print("SPACE - REMOVE")
				newString = "" + latestText[i]
				pass
			else:
				newString = newString + latestText[i]
				print(newString)
				pass
			pass
		elif lineSizeNew > lineSizeMax:
			print("BIGGER - NEW LINE")
			if lineCount == 0:
				self.add_text(newString)
			elif lineCount > 0:
				self.newline()
				self.add_text(newString)
			elif lineCount < 0:
				push_error("TextLog line count is negative")
			else:
				pass
			newString = "" + latestText[i]
			if latestText[i] != " ":
				newString + latestText[i]
			else: 
				pass
			lineCount += 1
			print(newString)
			pass
		else: 
			pass
		i+=1
	self.newline()
	self.add_text(newString)
	pass

func format_text_bbcode():
	pass

#func push_text(valueText:String):
#	splitText = []
#	splitTextFinal = []
#	var splitTextSize:int
#	var lineCountSize:int
#	var lineCount:int
#	var dataCheck:bool
#	var lineA
#	var lineB
#	var lineC
#
#	splitText = valueText.split(" ", true, 0)
#	print(splitText)
#	splitTextSize = splitText.size()
#	if splitTextSize == 1:
#		pass
#	elif splitTextSize > 1:
#		for i in splitTextSize:
#			print("---------------------------")
#			print("THE I IS: %s" %i)
#			if i < (splitTextSize-1):
#				lineA = splitText[i]
#				lineB = splitText[i+1]
#				dataCheck = compare_text(lineA,lineB)
#				print("DATA CHECK IS: %s" %dataCheck)
#				if dataCheck == null:
#					pass
#				elif dataCheck == true:
#					lineC = (lineA + " " + lineB)
#					print("MASHED LINE: %s" %lineC)
#					splitText[i] = lineC
#					splitText.erase(lineB)
#					print(splitText)
#					pass
#				elif dataCheck == false:
#					print(splitText)
#					pass
#			elif i >= (splitTextSize-1):
#				print("REACHED LAST WORD")
#				pass
#	elif splitTextSize < 1:
#		pass
#	else:
#		pass
#
#func compare_text(valueA:String,valueB:String):
#	var compareA = containerFont.get_string_size(valueA).x
#	var compareB = containerFont.get_string_size(valueB).x
#	var compareC = containerFont.get_string_size(" ").x
#	print(compareA++compareB+compareC)
#	if (compareA++compareB+compareC) <= lineMaxLength:
#		print("CAN COMBINE LINES")
#		print(valueA)
#		print(valueB)
#		return true
#	elif (compareA+compareB+compareC) > lineMaxLength:
#		print("CANNOT COMBINE LINES")
#		print(valueA)
#		print(valueB)
#		return false
#	else:
#		pass

#func add_line(listText:Array):
#	var lineCountSize:int
#	var lineCount:int
#
#	newline()
#	self.add_text("listText")
#	lineCount = get_line_count()
#	if lineCount >= lineCountMax:
#		lineCountSize = lineCount - lineCountMax
#		for line in lineCountSize:
#			self.remove_line(line)
#			print(line)
#	elif lineCount < lineCountMax:
#		pass
#	else:
#		pass
#	dataTextLog = self.text
#	self.set_text(dataTextLog)

#func _add_line(valueText:String):
#	lineCount = get_line_count()
#	if lineCount >= lineCountMax:
#		nodeTextLog.remove_line(lineCountMin)
#		newline()
#		nodeTextLog.add_text(valueText)
#	elif lineCount < lineCountMax:
#		newline()
#		nodeTextLog.add_text(valueText)
#	else:
#		pass
#	dataTextLog = nodeTextLog.text
#	nodeTextLog.set_text(dataTextLog)
