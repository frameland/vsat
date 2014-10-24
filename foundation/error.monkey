Strict


'--------------------------------------------------------------------------
' * General Error object
'--------------------------------------------------------------------------
Class VError
	Field message:String
	Field object:Object
End


'--------------------------------------------------------------------------
' * Errors
'--------------------------------------------------------------------------
Function Assert:Void(obj:Object)
	#If CONFIG = "debug"
		If Not obj
			Error("Assertion Failed. Object is Null!")
		End
	#End
End

Function Assert:Void(assumption:Bool)
	#If CONFIG = "debug"
		If assumption = False
			Error("Assertion Failed.")
		End
	#End
End

Function AssertWithException:Void(obj:Object, message:String)
	#If CONFIG = "debug"
		If Not obj
			Throw New Exception(message)
		End
	#End
End

Function AssertWithException:Void(assumption:Bool, message:String)
	#If CONFIG = "debug"
		If Not assumption
			Throw New Exception(message)
		End
	#End
End

Function NoDefaultConstructorError:Void(className:String)
	Error(className + ": Use of default constructor is not allowed.")
End


'--------------------------------------------------------------------------
' * Exceptions
'--------------------------------------------------------------------------
Class Exception Extends Throwable
	
	Method New()
		NoDefaultConstructorError("Exception")
	End
	
	Method New(message:String)
		Self.message = message
	End
	
	Method ToString:String()
		Return message
	End
	
	Private
	Field message:String
End

Class FileNotFoundException Extends Exception
	Method New()
		NoDefaultConstructorError("FileNotFoundException")
	End
	
	Method New(path:String)
		Super.New("The file " + path + " could not be found.")
	End

End

Class OutOfBoundsException Extends Exception
	Method New()
		NoDefaultConstructorError("OutOfBoundsException")
	End
	
	Method New(type:String, index:Int, rangeMax:Int)
		Super.New(type + " is out of bounds. Trying to access index " + index + ".~n" + "The maximum index is " + rangeMax)
	End
End

