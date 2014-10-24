#Rem monkeydoc Module framekit.extended.rapidmonkey
	Rapidmonkey allows you to change your variables at runtime with sliders.<br>
	Currently only variables of type int and float are supported.<br><br>
	
	The following steps show a short overview of how to integrate Rapidmonkey
	<li> Import rapidmonkey
	<li> Implement the IRapidmonkey interface (usually in your App class) and add the OnValueChange(..) method
	<li> Create a new instance of Rapidmonkey in OnCreate()
	<li> Call the instances Update() and Render() methods in OnUpdate() and OnRender() respectively
	<li> Add values with instance.AddValue(..), e.g: instance.AddValue("Gravity", Rapidmonkey.TYPE_FLOAT, 0.0, 20.0)
	<li> In OnValueChange(changedValue, newValue): if changedValue = "Gravity" Then myGravityValue = newValue
#End
Strict
Import mojo
Import vsat.coregfx.angelfont

#Rem monkeydoc
	Implement the IRapidmonkey interface to be notified when the value of a slider is changed.<br>
	Usually your App class will implement this.
#End
Interface IRapidmonkey
	Method OnValueChange:Void(changedValue:String, newValue:Float)
End

Class Rapidmonkey
	
	Const TYPE_INT:Int = 1
	Const TYPE_FLOAT:Int = 2
	
	#If TARGET = "ios" Or TARGET = "android"
		Field lineHeight:Float = 64
	#Else
		Field lineHeight:Float = 32
	#End
	
	Field lineWidth:Float = 240
	
	#Rem monkeydoc
		This constructor must be called instead of the default one.<br>
		callback: The class that implements the IRapidmonkey interface (usually your App class)<br>
		useFont: an AngelFont instance to use for rendering text
	#End
	Method New(callback:IRapidmonkey)
		listener = callback
		values = New StringMap<RapidmonkeyValue>
		valueList = New Stack<RapidmonkeyValue>
		font = New AngelFont
		font.LoadFromXml("sans")
	End
	
	#Rem monkeydoc
		Add a value/slider with a unique id<br>
		type: can be either Rapidmonkey.TYPE_INT or Rapidmonkey.TYPE_FLOAT<br>
		minimum & maximum: define the range of the slider<br>
		If minimum & maximum are left on their default the following values will be used:<br>
		for TYPE_INT: minimum = 0, maximum = 100<br>
		for TYPE_FLOAT: minimum = 0.0, maximum = 1.0<br>
	#End
	Method AddValue:Void(id:String, type:Int, minimum:Float = 0.0, maximum:Float = 0.0)	
		If (minimum = 0.0 And maximum = 0.0)
			Select type
				Case TYPE_INT
					minimum = 0
					maximum = 100
				Case TYPE_FLOAT
					minimum = 0.0
					maximum = 1.0
				Default
					Error("Rapidmonkey: Unknown type (2nd argument). Use either TYPE_INT or TYPE_FLOAT")
			End
		End
		
		Local value:= New RapidmonkeyValue
		value.id = id
		value.type = type
		value.minimum = minimum
		value.maximum = maximum
		value.value = minimum
		
		values.Set(id, value)
		valueList.Push(value)
	End
	
	#Rem monkeydoc
		Set the value of an already added value/slider
	#End
	Method SetValue:Void(id:String, value:Float)
		Local rapidValue:= values.Get(id)
		If rapidValue
			SetRapidmonkeyValue(rapidValue, value)
		End
	End
	
	#Rem monkeydoc
		Update() should be called once per frame, usually from your Apps OnUpdate()
	#End
	Method Update:Void()
		If Not MouseDown(0)
			If lastMouseDown
				locked = Null
			End
			lastMouseDown = False
			Return
		End
		
		Local mx:Int = MouseX()
		Local my:Int = MouseY()
		
		'convert to local space
		mx -= offsetX + 4
		my -= offsetY

		If Not lastMouseDown 'first click
			Local index:Int = my / lineHeight
			If MouseOverValue(mx, my, index)
				Local value:RapidmonkeyValue = valueList.Get(index)
				Local clickedPercent:Float = mx / lineWidth
				Local finalValue:Float = value.minimum + (clickedPercent * (value.maximum - value.minimum))
				SetRapidmonkeyValue(value, finalValue)
				locked = value
			End
			
		Else 'dragging
			If locked
				Local clickedPercent:Float = Clamp(mx / lineWidth, 0.0, 1.0)
				If KeyDown(KEY_SHIFT)
					clickedPercent = Int(clickedPercent * 100) / 5
					clickedPercent = Int(clickedPercent * 5) / 100.0
				End
				
				Local finalValue:Float = locked.minimum + (clickedPercent * (locked.maximum - locked.minimum))
				SetRapidmonkeyValue(locked, finalValue)
			End
		End
		
		lastMouseDown = True
	End
	
	#Rem monkeydoc
		Render(x, y) should be called once per frame, usually from your Apps OnRender()<br>
		x & y are offsets from the top-left corner
	#End
	Method Render:Void(x:Float = 8, y:Float = 8)
		offsetX = x
		offsetY = y
		SetAlpha(1.0)
		For Local i:Int = 0 Until valueList.Length()
			RenderValue(valueList.Get(i), offsetX, offsetY + i * lineHeight)
		Next
	End
	
	
	Private
	Method New()
		Error("Rapidmonkey: Can't use the default constructor. Use: New Rapidmonkey(callback:IRapidmonkey) instead.")
	End
	
	Method RenderValue:Void(value:RapidmonkeyValue, x:Float, y:Float)
		'Draw Base Container
		SetColor(25, 25, 25)
		DrawRect(x+4, y, lineWidth+2, lineHeight-1)
		SetColor(15, 15, 15)
		DrawRect(x+4, y + lineHeight - 1, lineWidth+2, 1)
		SetColor(41, 151, 208)
		DrawRect(x, y, 4, lineHeight)
		
		'Draw Slider
		Local percent:Float = MapPercent(value.value, value.minimum, value.maximum)
		SetColor(35, 35, 45)
		DrawRect(x+4+1, y, Int(lineWidth * percent), lineHeight-1)
		
		'Draw id
		SetColor(255, 255, 255)
		font.DrawText(value.id, x + 4 + 8, Int(y + lineHeight/2) - 2, AngelFont.ALIGN_LEFT, AngelFont.ALIGN_CENTER)
		
		'Draw percentage
		SetColor(150, 150, 150)
		Select value.type
			Case TYPE_FLOAT
				Local stringValue:String = String(value.value)
				Local index:Int = stringValue.Find(".")
				If index <> -1
					Local fractionalPart:String = stringValue[index+1..]
					If fractionalPart.Length > 5
						fractionalPart = fractionalPart[..5]
						stringValue = stringValue[..index] + "." + fractionalPart
					End
				End
				font.DrawText(stringValue, x + 4 + lineWidth - 8, Int(y + lineHeight/2) - 2, AngelFont.ALIGN_RIGHT, AngelFont.ALIGN_CENTER)
			Case TYPE_INT
				font.DrawText(Int(value.value), x + 4 + lineWidth - 8, Int(y + lineHeight/2) - 2, AngelFont.ALIGN_RIGHT, AngelFont.ALIGN_CENTER)
		End
		
	End
	
	Method SetRapidmonkeyValue:Void(value:RapidmonkeyValue, newValue:Float)
		Select value.type
			Case TYPE_INT
				value.value = Clamp(Int(newValue), Int(value.minimum), Int(value.maximum))
				listener.OnValueChange(value.id, value.value)
			Case TYPE_FLOAT
				value.value = Clamp(newValue, value.minimum, value.maximum)
				listener.OnValueChange(value.id, value.value)
		End
	End
	
	Method MapPercent:Float(value:Float, start1:Float, end1:Float)
		Return (value - start1) / (end1 - start1)
	End
	
	Method MouseOverValue:Bool(mx:Int, my:Int, index:Int)
		Return index < valueList.Length() And mx > 0 And mx < lineWidth And my > index * lineHeight And my < (index+1) * lineHeight
	End
	

	Field offsetX:Float = 8
	Field offsetY:Float = 8
	
	Field values:StringMap<RapidmonkeyValue>
	Field valueList:Stack<RapidmonkeyValue>
	Field listener:IRapidmonkey
	
	Field lastMouseDown:Bool
	Field locked:RapidmonkeyValue
	
	Field font:AngelFont
	
End


Private 'POD
Class RapidmonkeyValue
	Field id:String
	Field type:Int
	Field minimum:Float
	Field maximum:Float
	Field value:Float
End





