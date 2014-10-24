'--------------------------------------------------------------------------
' * Allows for up to 2^32 unique ids at a time
' * Call RemoveId everytime an id is no longer needed
'--------------------------------------------------------------------------
Alias ID = Int


Interface UUIDProvider
	Method GetID:ID()
	Method RemoveID:Void(id:ID)
End


Class UUID Implements UUIDProvider

	Private
	Field stack:IntStack = New IntStack
	Field counter:Int = 0
	
	Public
	Method GetID:ID()
		If stack.IsEmpty()
			counter += 1
			Return counter
		End
		Return stack.Pop()
	End

	Method RemoveID:Void(id:ID)
		stack.Push(id)
	End
	
End

