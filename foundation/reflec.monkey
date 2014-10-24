#Rem
------------------------------------------------------------------------------
	Sample:
	
	Local v:= Vec2(Reflection.FieldValue(entity, "position"))
	If v
		Local m:= Reflection.GetMethod(v, "Add", [GetClass(New Vec2)])
		If m
			m.Invoke(v, [Object(New Vec2(200, -200))])
		End
	End
------------------------------------------------------------------------------
#End

Strict
Import reflection
#REFLECTION_FILTER+="monkey*"


Class Reflection Abstract
	
	Function ClassName:String(ofObject:Object)
		Return SingleClassName(ClassInfo(ofObject).Name)
	End
	
	Function SuperClassName:String(ofObject:Object)
		Return SingleClassName(ClassInfo(ofObject).SuperClass.Name)
	End
	
	
	'value has to be boxed for primitives (also strings!)
	Function SetField:Void(ofObject:Object, name:String, value:Object)
		Local f:= ClassInfo(ofObject).GetField(name, True)
		If f
			f.SetValue(ofObject, value)
		End
	End
	
	'Return value has to be unboxed for primitives
	Function FieldValue:Object(ofObject:Object, name:String)
		Local f:= ClassInfo(ofObject).GetField(name, True)
		If f
			Return f.GetValue(ofObject)
		End
		Return Null
	End
	
	Function FieldType:String(ofObject:Object, name:String)
		Local f:= ClassInfo(ofObject).GetField(name, True)
		If f
			Return SingleClassName(f.Type.Name)
		End
		Return ""
	End
	
	Function FieldNames:String[](ofObject:Object, recursive:Bool = True)
		Local fields:FieldInfo[] = ClassInfo(ofObject).GetFields(recursive)
		Local fieldNames:String[fields.Length]
		For Local i:Int = 0 Until fields.Length
			fieldNames[i] = fields[i].Name
		End
		Return fieldNames
	End
	
	
	'argTypes: for primitives use IntClass(), FloatClass(), StringClass()
	Function GetMethod:MethodInfo(ofObject:Object, name:String, argTypes:ClassInfo[] = [])
		Local info:= ClassInfo(ofObject)
		Local methodInfo:= info.GetMethod(name, argTypes, True)
		Return methodInfo
	End
	
	Function ClassInfo:ClassInfo(ofObject:Object)
		Return GetClass(ofObject)
	End
	
	
	Function SerializeObject:String(obj:Object)
		Local serialize:String = "<object>~n"
		serialize += "<type>" + ClassName(obj) + "</type>~n"
		Local fields:= FieldNames(obj)
		For Local i:Int = 0 Until fields.Length
			Local name:String = fields[i]
			Local type:String = FieldType(obj, name)
			Select type
				Case "FloatObject"
					serialize += "<field>~n"
					serialize += "<name>" + name + "</name>~n"
					serialize += "<type>" + type + "</type>~n"
					serialize += "<value>" + UnboxFloat(FieldValue(obj, name)) + "</value>~n"
					serialize += "</field>~n"
				Case "IntObject"
					serialize += "<field>~n"
					serialize += "<name>" + name + "</name>~n"
					serialize += "<type>" + type + "</type>~n"
					serialize += "<value>" + UnboxInt(FieldValue(obj, name)) + "</value>~n"
					serialize += "</field>~n"
				Case "StringObject"
					serialize += "<field>~n"
					serialize += "<name>" + name + "</name>~n"
					serialize += "<type>" + type + "</type>~n"
					serialize += "<value>" + UnboxString(FieldValue(obj, name)) + "</value>~n"
					serialize += "</field>~n"
				Case "BoolObject"
					serialize += "<field>~n"
					serialize += "<name>" + name + "</name>~n"
					serialize += "<type>" + type + "</type>~n"
					serialize += "<value>" + Int(UnboxBool(FieldValue(obj, name))) + "</value>~n"
					serialize += "</field>~n"
				Default
					If type.Contains("Map") Or type.Contains("List") Or type.Contains("Array")
						'serialize += SerializeObject(FieldValue(obj, name))
					Else
						serialize += SerializeObject(FieldValue(obj, name))
					End
			End
		Next
		serialize += "</object>"
		
		Return serialize
	End
	
End

'input: a string with dot limited class names, e.g: monkey.lang.Object
'returns: only the last class name after the dot, e.g: Object
Function SingleClassName:String(classSignature:String)
	Local enclosed:String
	If classSignature.Contains("<") 'replace the part between <>
		Local start:Int = classSignature.Find("<")
		If start <> -1
			enclosed = classSignature[start + 1..enclosed.Length-1]
			If enclosed.Contains(".")
				Local enclosedSplit:String[] = enclosed.Split(".")
				classSignature = classSignature.Replace(enclosed, enclosedSplit[enclosedSplit.Length - 1])
			End
		End
	End
	Local signature:String[] = classSignature.Split(".")
	Local last:Int = signature.Length - 1
	Return signature[last]
End










