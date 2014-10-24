#Rem
------------------------------------------------------------------------------
	Helper functions that extend monkey
------------------------------------------------------------------------------
#End

Strict
Import error


'--------------------------------------------------------------------------
' * Chars / Strings
'--------------------------------------------------------------------------
Function IsChar:Bool(value:Int)
	If value > 96 And value < 123
		Return True
	End
	If value > 64 And value < 91
		Return True
	End
	Return False
End

Function IsNumber:Bool(value:Int)
	Return (value > 47) And (value < 58)
End

Function IsWhitespace:Bool(value:Int)
	Return value = 9 Or value = 10 Or value = 13 Or value = 32
End

Function FormatFloat:String(value:Float, digits:Int = 2)
	Local index:Int = String(value).Find(".",1)
	Local realNumber:String = String(value)[..index]
	Local floatPart:String = String(value)[index+1..]
	While floatPart.Length < digits
		floatPart += "0"
	Wend
	Return realNumber + "." + floatPart[..digits]
End

Function CountLines:Int(input:String)
	Const NEW_LINE:Int = "~n"[0]
	Local count:Int
	For Local i:Int = 0 Until input.Length
		If input[i] = NEW_LINE
			count += 1
		End
	Next
	Return count + 1
End



'--------------------------------------------------------------------------
' * Generic functions, use with any type T
' * e.g. Generic<Int>.PrintArray(myArray)
'--------------------------------------------------------------------------
Class Generic<T> Abstract
	

'--------------------------------------------------------------------------
' * Arrays
'--------------------------------------------------------------------------	
	Function RandomChoice:T(options:T[])
		Return options[Int(Rnd(0, options.Length()))]
	End

	Function Randomize:Void(input:T[])
		Local len:Int = input.Length()
		For Local idx:Int = 0 Until len
			Local randomIdx:Int = Floor(Rnd(0, len))
			Local swap:T = input[idx]
			input[idx] = input[randomIdx]
			input[randomIdx] = swap
		End
	End

	Function Array2D:T[][](rows:Int, cols:Int)
		Local a:T[][] = New T[rows][]
		For Local i:Int = 0 Until rows
			a[i] = New T[cols]
		End
		Return a
	End

	Function Array3D:T[][][](x:Int, y:Int, z:Int)
		Local a:T[][][] = New T[x][][]
		For Local i:Int = 0 Until x
			a[i] = New T[y][]
			For Local j:Int = 0 Until y
				a[i][j] = New T[z]
			End
		End
		Return a
	End

	Function PrintArray:Void(arr:T[])
		For Local i:Int = 0 Until arr.Length
			Print arr[i]
		End
	End
	
	Function PrintArray:Void(arr:T[][], delimiter:String = " ")
		For Local y:Int = 0 Until arr[1].Length
			Local line:String
			For Local x:Int = 0 Until arr.Length
				line += arr[x][y]
				If x <> arr.Length-1
					line += delimiter
				End
			Next
			Print line
		End
	End
	
	Function FillArray:Void(arr:T[], fillWith:T)
		For Local i:Int = 0 Until arr.Length
			arr[i] = fillWith
		Next
	End
	
	Function FillArray:Void(arr:T[][], fillWith:T)
		For Local y:Int = 0 Until arr[1].Length
			For Local x:Int = 0 Until arr.Length
				arr[x][y] = fillWith
			Next
		Next
	End
	
	
	
'--------------------------------------------------------------------------
' * Stacks
'--------------------------------------------------------------------------
	Function Slice:Stack<T>(stack:Stack<T>, startIndex:Int, endIndex:Int)
		Local length:Int = stack.Length
		If (length = 0)
			Throw New Exception("SliceStack: Stack is empty.")
		ElseIf (startIndex >= length)
			Throw New OutOfBoundsException("SliceStack: Stack", startIndex, length-1)
		ElseIf (endIndex > length)
			Throw New OutOfBoundsException("SliceStack: Stack", endIndex, length)
		End
		
		Local slicedStack:= New Stack<T>
		For Local i:Int = startIndex Until endIndex
			slicedStack.Push(stack.Get(i))
		Next
		
		Return slicedStack
	End
	
	'Merge 2 stacks, return new concated stack
	Function Concat:Stack<T>(stack1:Stack<T>, stack2:Stack<T>)
		Local concatedStack:= New Stack<T>
		For Local i:Int = 0 Until stack1.Length
			concatedStack.Push(stack1.Get(i))
		Next
		For Local i:Int = 0 Until stack2.Length
			concatedStack.Push(stack2.Get(i))
		Next
		
		Return concatedStack
	End
	
	'Merge 2 stacks into stack1
	Function Merge:Void(stack1:Stack<T>, stack2:Stack<T>)
		For Local i:Int = 0 Until stack2.Length
			stack1.Push(stack2.Get(i))
		Next
	End
	
End












