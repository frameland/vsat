Strict
Import foundation
Import coregfx
Import entity

#REFLECTION_FILTER+="${MODPATH}"


Class Sprite Extends Entity
	
	Field color:Color = New Color
	Field hidden:Bool
	Field flipX:Bool
	Field flipY:Bool
	Field image:Image
	
'--------------------------------------------------------------------------
' * Constructor
'--------------------------------------------------------------------------
	Method New(imagePath:String, x:Float = 0.0, y:Float = 0.0)
		SetImage(imagePath)
		position.Set(x, y)
	End
	
	Method GetCopy:Sprite()
		Local sprite:= New Sprite(imagePath)
		sprite.position.Set(position)
		sprite.scale.Set(scale)
		sprite.rotation = rotation
		sprite.color.Set(color)
		sprite.hidden = hidden
		sprite.flipX = flipX
		sprite.flipY = flipY
		Local attributeMap:= Self.GetAttributeMap()
		If attributeMap
			sprite.SetAttributeMap(attributeMap)
		End
		Return sprite
	End


'--------------------------------------------------------------------------
' * Setters
'--------------------------------------------------------------------------
	Method SetImage:Void(path:String, flags:Int = Image.MidHandle)
		image = ImageCache.GetImage(path, flags)
		If image = Null
			Throw New Exception("Sprite: Could not load image at path: " + path)
		End
		imagePath = path
	End
	
	Method SetHandle:Void(x:Float, y:Float)
		image.SetHandle(x, y)
	End

	Method SetColor:Void(r:Float, g:Float, b:Float)
		color.Set(r, g, b)
	End


'--------------------------------------------------------------------------
' * Properties
'--------------------------------------------------------------------------
	Method Width:Float() Property
		Return image.Width() * scale.x
	End
	
	Method Height:Float() Property
		Return image.Height() * scale.y
	End
	
	Method ImagePath:String() Property
		Return imagePath
	End
	
	Method HandleX:Float() Property
		Return image.HandleX()
	End
	
	Method HandleY:Float() Property
		Return image.HandleY()
	End
	
	Method Alpha:Void(alpha:Float) Property
		color.Alpha = alpha
	End
	
	Method Alpha:Float() Property
		Return color.Alpha
	End
	
	
'--------------------------------------------------------------------------
' * Render
'--------------------------------------------------------------------------
	Method Render:Void()
		If hidden Or color.Alpha < 0.001 Or image = Null
			Return
		End
		
		color.Use()
		
		Local x:Float = 1.0
		Local y:Float = 1.0
		If flipX Then x = -1.0
		If flipY Then y = -1.0
			
		PushMatrix()
			Translate(position.x, position.y)
			Rotate(rotation)
			If (scale.x * x <> 1) Or (scale.y * y <> 1)
				Scale(scale.x * x, scale.y * y)
			End
			Self.DrawImage()
		PopMatrix()
	End
	
	Method DrawImage:Void()
		If image
			mojo.DrawImage(image, 0, 0)
		End
	End
	
	Method Update:Void(dt:Float)
		'sprites do not update
	End
	
	
	Private
	Field imagePath:String
	
End

