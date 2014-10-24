#Rem
------------------------------------------------------------------------------
	Entity is a simple object in the world
	All Objects that you place in your scene should be/extend Entity
------------------------------------------------------------------------------
#End

Strict
Import vsat.foundation
Import vsat.coregfx
#REFLECTION_FILTER+="${MODPATH}"


Class Entity Abstract

	Private
	Field attributes:StringMap<String>
	
	Public
	Field name:String
	Field position:Vec2 = New Vec2
	Field scale:Vec2 = New Vec2(1.0, 1.0)
	Field rotation:Float
	
	
'--------------------------------------------------------------------------
' * Attributes
'--------------------------------------------------------------------------
	Method SetAttribute:Void(name:String, value:String)
		If Not attributes
			attributes = New StringMap<String>
		End
		attributes.Set(name, value)
	End
	
	Method SetAttribute:Void(name:String, value:Bool)
		If Not attributes
			attributes = New StringMap<String>
		End
		attributes.Set(name, Int(value))
	End
	
	Method Attribute:String(name:String)
		If Not attributes
			Return ""
		End
		Return attributes.Get(name)
	End
	
	Method HasAttribute:Bool(name:String)
		If Not attributes
			Return False
		End
		Return attributes.Contains(name)
	End
	
	Method NumberOfAttributes:Int() Property
		If Not attributes
			Return 0
		End
		Return attributes.Count()
	End
	
	Method GetAttributeMap:StringMap<String>()
		If Not attributes Then Return Null
		
		Local map:= New StringMap<String>
		For Local key:String = EachIn attributes.Keys()
			Local value:String = attributes.Get(key)
			map.Set(key, value)
		Next
		Return map
	End
	
	Method SetAttributeMap:Void(map:StringMap<String>)
		attributes = map
	End
	

'--------------------------------------------------------------------------
' * Other
'--------------------------------------------------------------------------
	Method SetScale:Void(scalar:Float) Property
		Self.scale.Set(scalar, scalar)
	End
	
	Method ApplyTransform:Void()
		TranslateV(position)
		Rotate(rotation)
		ScaleV(scale)
	End
	
	Method Update:Void(dt:Float) End
	Method Render:Void() End
	
End
