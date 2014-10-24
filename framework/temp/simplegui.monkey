#Rem
------------------------------------------------------------------------------
	A simple gui module
	
	Notes:
	* You should have at least 1 GUI instance and call Update() and Render() on it
	* Register a listener of type GuiEventHandler to get noticed about events
	* Scaling the widgets is supported but they will not update that way
	* SetHandle() and Midhandle only affect scaling, widgets are always handled from the top left
------------------------------------------------------------------------------
#End

Strict
Import vsat


Interface WidgetContainer
	Method AddWidget:Void(widget:Widget)
	Method RemoveWidget:Void(widget:Widget)
	Method Children:WidgetList()
	Method __SortWidgets:Void()
	Method __SetDirty:Void()
End

Interface GuiEventHandler
	Method OnGuiEvent:Void(event:Int, widget:Widget)
End


Const EVENT_MOUSE_DOWN:Int = 1
Const EVENT_MOUSE_UP:Int = 2
Const EVENT_MOUSE_CLICK:Int = 4
Const EVENT_MOUSE_ENTER:Int = 8
Const EVENT_MOUSE_LEAVE:Int = 16
Const EVENT_MOUSE_HOVER:Int = 32
Const EVENT_MOUSE_LEFT:Int = 64
Const EVENT_MOUSE_RIGHT:Int = 128


Const GUI_ALIGN_LEFT:Int     = 1
Const GUI_ALIGN_RIGHT:Int    = 2
Const GUI_ALIGN_CENTER_X:Int = 4
Const GUI_ALIGN_TOP:Int      = 8
Const GUI_ALIGN_BOTTOM:Int   = 16
Const GUI_ALIGN_CENTER_Y:Int = 32
Const GUI_ALIGN_CENTER:Int = GUI_ALIGN_CENTER_X | GUI_ALIGN_CENTER_Y



'--------------------------------------------------------------------------
' * GUI is the manager class of all widgets
'--------------------------------------------------------------------------
Class GUI Implements WidgetContainer
	
	Private
	Field children:WidgetList
	Field activeWidget:Widget
	Field isDirty:Bool 'if dirty __SortWidgets() will be called the next Render()
	Field DefaultFont:AngelFont
	Field listener:GuiEventHandler
	
	Public
	
	Method New()
		children = New WidgetList
	End
	
	Method Listener:Void(listener:GuiEventHandler) Property
		Self.listener = listener
	End
	
	Method Update:Void(dt:Float)
		Local leftMouseDown:Int = MouseDown(MOUSE_LEFT)
		Local rightMouseDown:Int = MouseDown(MOUSE_RIGHT)
		Local mouseX:Float = MouseX()
		Local mouseY:Float = MouseY()
		UpdateWidgetsRecursive(children, leftMouseDown, rightMouseDown, mouseX, mouseY)
	End
	
	Method UpdateWidgetsRecursive:Void(list:WidgetList, leftMouseDown:Int, rightMouseDown:Int, mouseX:Float, mouseY:Float)
		For Local w:= EachIn list
			If ValidForUpdating(w)
				Local state:Int = 0
				
				If w = activeWidget And leftMouseDown
					w.OnMouseDown()
					state |= WidgetState.MouseDownLeft
				End
				
				If w.lastState & WidgetState.MouseDownLeft And (leftMouseDown = False)
					w.OnMouseUp()
					activeWidget = Null
				End
				If w.lastState & WidgetState.MouseDownRight And (rightMouseDown = False)
					w.OnRightMouseUp()
					activeWidget = Null
				End
				
				If PointInRect(mouseX, mouseY, w.X, w.Y, w.Width, w.Height) And activeWidget = Null
					w.OnMouseOver()
					state |= WidgetState.MouseOver
					If (w.lastState & WidgetState.MouseOver) = False
						w.OnMouseEnter()
					End
					If leftMouseDown 
						w.OnMouseDown()
						state |= WidgetState.MouseDownLeft
						If (w.lastState & WidgetState.MouseDownLeft) = False
							w.OnMouseHit()
						End
						ActivateWidget(w)
					ElseIf rightMouseDown
						w.OnRightMouseDown()
						state |= WidgetState.MouseDownRight
						If (w.lastState & WidgetState.MouseDownRight) = False
							w.OnRightMouseHit()
						End
						ActivateWidget(w)
					End
					
				ElseIf w.lastState & WidgetState.MouseOver
					w.OnMouseLeave()
					state |= WidgetState.MouseLeave
				End
				
				If WidgetContainer(w)
					UpdateWidgetsRecursive(WidgetContainer(w).Children(), leftMouseDown, rightMouseDown, mouseX, mouseY)
				End
				
				w.lastState = state
			End
		Next
	End
	
	
	Method Render:Void()
		__SortWidgets()
		For Local w:= EachIn children
			If w.hidden = False
				w.Render()				
			End
		Next
	End
	
	Method AddWidget:Void(widget:Widget)
		widget.link = children.AddLast(widget)
		widget.gui = Self
	End
	
	Method RemoveWidget:Void(widget:Widget)
		widget.link.Remove()
	End
	
	Method ActivateWidget:Void(widget:Widget)
		If widget And widget <> activeWidget
			widget.OnActivate()
		End
		If Not WidgetContainer(widget)
			activeWidget = widget
		End
	End
	
	Method Children:WidgetList()
		Return children
	End
	
	Method SetDefaultFont:Void(path:String)
		DefaultFont = FontCache.Get(path)
	End
	
	Method __SortWidgets:Void()
		If isDirty
			children.Sort()
			isDirty = False
		End
	End
	
	Method __SetDirty:Void()
		isDirty = True
	End
	
	Private
	Method OnEvent:Void(event:Int, widget:Widget)
		If listener
			listener.OnGuiEvent(event, widget)
		End
	End
	
	Method ValidForUpdating:Bool(widget:Widget)
		Return (widget.ScaleX = 1.0) And (widget.ScaleY = 1.0) And (widget.hidden = False)
	End
	
End



'--------------------------------------------------------------------------
' * Widget Base Class
'--------------------------------------------------------------------------
Class Widget Extends Entity Abstract
	
	Private
	Field parent:Widget
	Field hidden:Bool
	Field size:Vector2 = New Vector2
	Field gui:GUI
	Field link:list.Node<Widget>
	Field zIndex:Float
	Field lastState:Int
	Field handle:Vector2 = New Vector2
	
	Public
	Field color:Color = New Color
	
	Method New(x:Float, y:Float, w:Float, h:Float)
		position.Set(x, y)
		SetSize(w, h)
	End
	
	' Method Update:Void(dt:Float) End
	Method Render:Void() End
	
	Method OnMouseHit:Void() End
	Method OnMouseDown:Void() End
	Method OnMouseUp:Void() End
	Method OnRightMouseHit:Void() End
	Method OnRightMouseDown:Void() End
	Method OnRightMouseUp:Void() End
	Method OnMouseOver:Void() End
	Method OnMouseEnter:Void() End
	Method OnMouseLeave:Void() End
	Method OnActivate:Void() End
	

	Method Hide:Void()
		hidden = True
	End
	
	Method Show:Void()
		hidden = False
	End
	
	
	Method Align:Void(align:Int)
		Local x:Float
		Local y:Float
		Local w:Float
		Local h:Float
		
		If parent
			x = parent.X
			y = parent.Y
			w = parent.Width
			h = parent.Height
		Else
			x = 0
			y = 0
			w = SCREEN_WIDTH
			h = SCREEN_HEIGHT
		End
		
		If align & GUI_ALIGN_LEFT
			position.Set(0, position.y)
		ElseIf align & GUI_ALIGN_RIGHT
			position.Set(w - Width, position.y)
		ElseIf align & GUI_ALIGN_CENTER_X
			position.Set(Floor ((w - Width) / 2.0), position.y)
		End
		
		If align & GUI_ALIGN_TOP
			position.Set(position.x, 0)
		ElseIf align & GUI_ALIGN_BOTTOM
			position.Set(position.x, h - Height)
		ElseIf align & GUI_ALIGN_CENTER_Y
			position.Set(position.x, Floor ((h - Height) / 2.0))
		End
	End
	
	Method ZIndex:Float() Property
		Return ZIndex
	End
	
	Method ZIndex:Void(z:Float) Property
		If parent = Null
			If Not gui
				Throw New Exception("Before setting the zIndex you have to add your widget to a container (GUI, Panel).")
			End
			gui.__SetDirty()
		Else
			If Not parent
				Throw New Exception("Before setting the zIndex you have to add your widget to a container (GUI, Panel).")
			End
			WidgetContainer(parent).__SetDirty()
		End
		zIndex = z
	End
	
	Method IsActive:Bool() Property
		Return gui.activeWidget = Self
	End
	
	Method SetSize:Void(x:Float, y:Float)
		size.Set(x, y)
	End
	
	
	Method Width:Float() Property
		Return size.x * ScaleX
	End
	
	Method Height:Float() Property
		Return size.y * ScaleY
	End
	
	Method X:Float() Property
		If parent
			Return position.x + parent.X
		Else
			Return position.x
		End
	End
	
	Method Y:Float() Property
		If parent
			Return position.y + parent.Y
		Else
			Return position.y
		End
	End
	
	Method ScaleX:Float() Property
		If parent
			Return scale.x * parent.ScaleX
		Else
			Return scale.x
		End
	End
	
	Method ScaleY:Float() Property
		If parent
			Return scale.y * parent.ScaleY
		Else
			Return scale.y
		End
	End
	
	Method Alpha:Float() Property
		If parent
			Return color.Alpha * parent.Alpha
		Else
			Return color.Alpha
		End
	End
	
	
	Method SetHandle:Void(x:Float, y:Float)
		handle.Set(x, y)
	End
	
	Method Midhandle:Void()
		Self.SetHandle(size.x/2, size.y/2)
	End
	
	
	Private
	Method Notify:Void(event:Int)
		gui.OnEvent(event, Self)
	End
	
End

Class WidgetState
	Const MouseDownLeft:Int = 1
	Const MouseDownRight:Int = 2
	Const MouseUpLeft:Int = 4
	Const MouseUpRight:Int = 8
	Const MouseOver:Int = 16
	Const MouseLeave:Int = 32
End

Class WidgetList Extends List<Widget>
	Method Equals:Bool(w1:Widget, w2:Widget)
		Return (w1.zIndex = w2.zIndex)
	End
	
	Method Compare:Int(w1:Widget, w2:Widget)
		If (w1.zIndex > w2.zIndex)
			Return 1
		End
		Return -1
	End
End



'--------------------------------------------------------------------------
' * Widgets
'--------------------------------------------------------------------------
Class Panel Extends Widget Implements WidgetContainer
	
	Private
	Field children:WidgetList
	Field isDirty:Bool
	
	Public
	Field shouldRender:Bool = False
	
	Method New(x:Float, y:Float, w:Float, h:Float)
		Super.New(x, y, w, h)
		children = New WidgetList
	End
	
	#rem
	Method Update:Void(dt:Float)
		For Local w:= EachIn children
			If w.hidden = False
				w.Update(dt)
			End
		Next
	End
	#end
	
	Method Render:Void()
		PushMatrix()
		TranslateV(position)
		TranslateV(handle)
		ScaleV(Self.scale)
		Translate(-handle.x, -handle.y)
		If shouldRender
			color.UseWithoutAlpha()
			SetAlpha(Self.Alpha)
			DrawRect(0, 0, size.x, size.y)
		End
		
		__SortWidgets()
		For Local w:= EachIn children
			If w.hidden = False
				w.Render()
			End
		Next
		
		PopMatrix()
	End
	
	Method AddWidget:Void(widget:Widget)
		widget.link = children.AddLast(widget)
		widget.gui = gui
		widget.parent = Self
	End
	
	Method RemoveWidget:Void(widget:Widget)
		widget.link.Remove()
	End
	
	Method Children:WidgetList()
		Return children
	End

	Method __SortWidgets:Void()
		If isDirty
			children.Sort()
			isDirty = False
		End
	End
	
	Method __SetDirty:Void()
		isDirty = True
	End
	
End

Class Button Extends Widget
	
	Private
	Field image:Image
	Field hoverImage:Image
	Field downImage:Image
	Field activeImage:Image
	Field hoverColor:Color
	Field downColor:Color
	Field activeColor:Color = New Color
	Field label:Label
	
	Public
	Method New(x:Float, y:Float, w:Float, h:Float)
		Super.New(x, y, w, h)
	End
	
	Method SetImage:Void(path:String)
		image = Cache.LoadImage(path, Image.XYPadding)
		size.x = image.Width()
		size.y = image.Height()
		activeImage = image
	End
	
	Method SetHoverImage:Void(path:String)
		hoverImage = Cache.LoadImage(path, Image.XYPadding)
	End
	
	Method SetClickImage:Void(path:String)
		downImage = Cache.LoadImage(path, Image.XYPadding)
	End
	
	Method SetColor:Void(color:Color)
		Self.color.Set(color)
		activeColor.Set(color)
	End
	
	Method SetHoverColor:Void(color:Color)
		If Not hoverColor
			hoverColor = New Color
		End
		hoverColor.Set(color)
	End
	
	Method SetDownColor:Void(color:Color)
		If Not downColor
			downColor = New Color
		End
		downColor.Set(color)
	End
	
	Method Text:Void(text:String) Property
		If Not label
			label = New Label(text, 0, 0, gui.DefaultFont)
			label.parent = Self
			label.gui = gui
		Else
			label.Text = text
		End
		label.Align(GUI_ALIGN_CENTER)
		label.position.y -= 2
	End
	
	Method Text:String() Property
		If Not label
			Return ""
		End
		Return label.Text
	End
	
	
	Method Update:Void(dt:Float)
		
	End
	
	Method Render:Void()
		SetAlpha(Self.Alpha)
		
		PushMatrix()
		TranslateV(position)
		TranslateV(handle)
		ScaleV(Self.scale)
		Translate(-handle.x, -handle.y)
		
		If activeImage
			color.UseWithoutAlpha()
			DrawImage(activeImage, 0, 0)
		Else
			activeColor.UseWithoutAlpha()
			DrawRect(0, 0, size.x, size.y)
		End
		
		If label
			label.Render()
		End
		
		PopMatrix()
	End
	
	
	Method OnMouseDown:Void()
		Notify(EVENT_MOUSE_DOWN|EVENT_MOUSE_LEFT)
		If downImage
			activeImage = downImage
		ElseIf downColor
			activeColor.Set(downColor)
		End
	End
	
	Method OnMouseUp:Void()
		Notify(EVENT_MOUSE_UP|EVENT_MOUSE_LEFT)
		If (lastState & WidgetState.MouseOver)
			If hoverImage
				activeImage = hoverImage
			ElseIf hoverColor
				activeColor.Set(hoverColor)
			End
		ElseIf image
			activeImage = image
		ElseIf color
			activeColor.Set(color)
		End
	End
	
	Method OnMouseEnter:Void()
		Notify(EVENT_MOUSE_ENTER|EVENT_MOUSE_LEFT)
		If hoverImage
			activeImage = hoverImage
		ElseIf hoverColor
			activeColor.Set(hoverColor)
		End
	End
	
	Method OnMouseLeave:Void()
		Notify(EVENT_MOUSE_LEAVE|EVENT_MOUSE_LEFT)
		If image
			If (lastState & WidgetState.MouseDownLeft)
				Return
			End
			activeImage = image
		ElseIf color
			If (lastState & WidgetState.MouseDownLeft)
				Return
			End
			activeColor.Set(color)
		End
	End
	
End

Class Label Extends Widget
	
	Private
	Field font:AngelFont
	Field text:String
	
	Public
	Method New(text:String, x:Float, y:Float, font:AngelFont)
		Super.New(x, y, 0, 0)
		Self.font = font
		Self.Text = text
	End
	
	Method Text:Void(text:String) Property
		Self.text = text
		UpdateSize()
	End
	
	Method Text:String() Property
		Return text
	End
	
	Method SetFont:Void(path:String)
		font = FontCache.Get(path)
		If font And text
			UpdateSize()
		End
	End
	
	Method Render:Void()
		SetAlpha(Self.Alpha)
		color.UseWithoutAlpha()
		
		PushMatrix()
		TranslateV(position)
		TranslateV(handle)
		ScaleV(Self.scale)
		Translate(-handle.x, -handle.y)
		font.DrawText(text, 0, 0)
		PopMatrix()
	End
	
	Private
	Method UpdateSize:Void()
		If font And text
			size.x = font.TextWidth(text)
			size.y = font.TextHeight(text)
		End
	End
	
	
End













