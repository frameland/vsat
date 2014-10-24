#Rem
------------------------------------------------------------------------------
	A key-value-pair intended to be used with a file (e.g. user preferences)
	The format of the file should be in the following form:
		
		# This is a comment (empty lines will be ignored)
		key = value
		"key " = value
		key = " value "
	
	Any of the above is legal, although quotes are optional you will need them
	for strings where a space at the beginning or end has to be considered
------------------------------------------------------------------------------
#End

Strict
Import mojo.app
Import error
Import functions


Class KeyValuePair
	
	Method InitWithFileNamed:Bool(fileURL:String, error:VError)
		Local theString:String = app.LoadString(fileURL)
		If Not theString
			If error
				error.message = "File at path " + fileURL + " could not be loaded."
			End
			Return False
		End
		Return Self.InitWithString(theString, error)
	End
	
	Method InitWithString:Bool(theString:String, error:VError)
		dictonary = New StringMap<String>
		Local lines:String[] = theString.Split("~n")
		For Local i:Int = 0 Until lines.Length
			Local line:String = lines[i].Trim()

			If line.Length = 0 Or line.StartsWith("#")
				Continue
			End
			
			Local delimiterIndex:Int = line.Find(DELIMITER)
			If delimiterIndex = -1
				Self.GenerateError(error, "Attempting to parse line " + (i+1) + ": " + line + "~nbut could not find the delimiter " + DELIMITER)
				Return False
			End

			Local leftSide:String = Self.ParseString(line[0..delimiterIndex])
			Local rightSide:String = Self.ParseString(line[delimiterIndex+1..])
			If (leftSide.Length = 0)
				Self.GenerateError(error, "Attempting to parse line " + (i+1) + ": " + line + "~nbut key (left hand side) is either empty or has mismatched quotes.")
				Return False
			ElseIf (rightSide.Length = 0)
				Self.GenerateError(error, "Attempting to parse line " + (i+1) + ": " + line + "~nbut value (right hand side) is either empty or has mismatched quotes.")
				Return False
			End
			
			dictonary.Set(leftSide, rightSide)
		Next
		
		Return True
	End
	
	Method GetString:String(forKey:String, fallbackValue:String = "")
		AssertWithException(dictonary, "Your KeyValuePair has not been initialized yet, or the initialization failed.\n")
		Local result:String = dictonary.Get(forKey)
		If result Then Return (result)
		Return fallbackValue
	End
	
	Method GetInt:Int(forKey:String, fallbackValue:Int = 0)
		AssertWithException(dictonary, "Your KeyValuePair has not been initialized yet, or the initialization failed.\n")
		Local result:String = dictonary.Get(forKey)
		If result
			If IsNumber(result[0]) Or (result[0] = "-"[0] And IsNumber(result[1]))
				Return Int(result)
			End
		End
		Return fallbackValue
	End
	
	Method GetFloat:Float(forKey:String, fallbackValue:Float = 0.0)
		AssertWithException(dictonary, "Your KeyValuePair has not been initialized yet, or the initialization failed.\n")
		Local result:String = dictonary.Get(forKey)
		If result
			If IsNumber(result[0]) Or (result[0] = "-"[0] And IsNumber(result[1]))
				Return Float(result)
			End
		End
		Return fallbackValue
	End
	
	Method GetBool:Bool(forKey:String, fallbackValue:Bool = False)
		AssertWithException(dictonary, "Your KeyValuePair has not been initialized yet, or the initialization failed.\n")
		Local result:String = dictonary.Get(forKey)
		result = result.ToLower()
		Select result
			Case "0", "no", "false"
				Return False
			Case "1", "yes", "true"
				Return True
		End
		Return fallbackValue
	End
	
	Private
	Field dictonary:StringMap<String>
	Const DELIMITER:String = "="
	
	Method ParseString:String(rawString:String)
		Local trimmed:String = rawString.Trim()
		Local findQuote:Int = trimmed.Find("~q")
		
		If findQuote = -1 Return trimmed
		
		If trimmed[0] = "~q"[0] And trimmed[trimmed.Length-1] = "~q"[0]
			Return trimmed[1..trimmed.Length-1]
		End
		
		Return ""	
	End
	
	Method GenerateError:Void(error:VError, message:String)
		If error
			error.message = message
		End
		dictonary = Null
	End
	
End
