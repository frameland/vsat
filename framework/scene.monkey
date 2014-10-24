Strict
Import vsat


Class Scene Implements ActionEventHandler Abstract

	Field name:String
	Field shouldClearScreen:Bool = True
	
	Method OnLoading:Void() End
	Method OnInit:Void() End
	Method OnUpdate:Void(delta:Float) End
	Method OnUpdateWhilePaused:Void() End
	Method OnRender:Void() End
	Method OnExit:Void() End
	Method OnSuspend:Void() End
	Method OnResume:Void() End
	Method OnResize:Void() End
		
	Method OnTouchDown:Void() End
	Method OnTouchRelease:Void() End	
	
	Method HandleEvent:Void(event:Event) End
	Method OnActionEvent:Void(id:Int, action:Action) End
	
	
'--------------------------------------------------------------------------
' * Automatically updated methods
' * Can be overriden (and left empty if unwanted)
'--------------------------------------------------------------------------
	Method ClearScreen:Void()
		ClearScreenWithColor(Color.Gray)
	End
	
	Method UpdateActions:Void(dt:Float)
		Action.UpdateList(__actions, dt)
	End
	
	Method UpdateTouches:Void()
		If TouchDown()
			OnTouchDown()
			__lastFrameTouchDown = True
		Else
			If __lastFrameTouchDown
				OnTouchRelease()
			End
			__lastFrameTouchDown = False
		End
	End
	

'--------------------------------------------------------------------------
' * Action Management
'--------------------------------------------------------------------------	
	Method AddAction:Void(action:Action)
		action.AddToList(__actions)
		action.SetListener(Self)
	End
	
	
	Private
	Field __lastFrameTouchDown:Bool 'true if last frame the mouse was down / display was touched
	Field __actions:List<Action> = New List<Action>
End
