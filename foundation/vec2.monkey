Strict

Private
Import reflec
#REFLECTION_FILTER+="${MODPATH}"

Public
Class Vec2 Final

	Field x:Float
	Field y:Float


	Method New(setX:Float, setY:Float)
		x = setX
		y = setY
	End
	
	Method New(vector:Vec2)
		x = vector.x
		y = vector.y
	End
	
	Method Copy:Vec2()
		Return New Vec2(Self)
	End
	
	Function FromPolar:Vec2(radius:Float, theta:Float)
		Local v:= New Vec2
		v.x = radius * Cos(theta)
		v.y = radius * Sin(theta)
		Return v
	End
	

	Method Set:Vec2(setX:Float, setY:Float)
		x = setX
		y = setY
		Return Self
	End
	
	Method Set:Vec2(vector:Vec2)
		x = vector.x
		y = vector.y
		Return Self
	End
	
	Method Add:Vec2(vector:Vec2)
		x += vector.x
		y += vector.y
		Return Self
	End
	
	Method Add:Vec2(addX:Float, addY:Float)
		x += addX
		y += addY
		Return Self
	End
	
	Method Sub:Vec2(vector:Vec2)
		x -= vector.x
		y -= vector.y
		Return Self
	End
	
	Method Sub:Vec2(subX:Float, subY:Float)
		x -= subX
		y -= subY
		Return Self
	End
	
	Method Mul:Vec2(scalar:Float)
		x *= scalar
		y *= scalar
		Return Self
	End
	
	Method Div:Vec2(scalar:Float)
		x /= scalar
		y /= scalar
		Return Self
	End
	
	Method Normalize:Vec2()
		Local length:Float = Self.Length
		If Length = 0 
			Return Self
		End
		Set(x/length, y/length)
		Return Self
	End
	
	
	Method Dot:Float(vector:Vec2)
		Return (x * vector.x + y * vector.y)
	End
	
	Method Length:Float() Property
		Return Sqrt (x * x + y * y)
	End
	
	Method Length:Void(length:Float) Property
		Normalize()
		Self.Mul(length)
	End
	
	Method Limit:Void(maxLength:Float)
		Local length:Float = Self.Length
		If length > maxLength
			Self.Length = maxLength
		End
	End
	
	
	Method LengthSquared:Float() Property
		Return x * x + y * y
	End
	
	Method Angle:Float() Property
		Return ATan2(Self.y, Self.x)
	End
	
	Method Angle:Void(value:Float) Property
		Local length:Float = Length
		Self.x = Cos(value) * length
		Self.y = Sin(value) * length
	End

	Method RotateLeft:Void()
		Local temp:Float = -y
		y = x
		x = temp
	End
	

	Method DistanceTo:Float(x:Float, y:Float)
		Local x1:Float = x - Self.x
		Local y1:Float = y - Self.y
		Return Sqrt(x1 * x1 + y1 * y1)
	End
	
	Method DistanceTo:Float(vector:Vec2)
		Return DistanceTo(vector.x, vector.y)
	End
	
	
	Method Equals:Bool(vector:Vec2)
		Return (x = vector.x) And (y = vector.y)
	End
	
	Method Equals:Bool(x:Float, y:Float)
		Return Self.x = x And Self.y = y
	End
	
	Method ProjectOn:Float(axis:Vec2)
		Local normalizedAxis:= New Vec2(axis)
		normalizedAxis.Normalize()
		Return Self.Dot(normalizedAxis)
	End
	
	
	Method ToString:String()
		Return "x: " + x + ", y: " + y
	End

	
	Function Up:Vec2()
		Return New Vec2(0.0, -1.0)
	End
	
	Function Down:Vec2()
		Return New Vec2(0.0, 1.0)
	End
	
	Function Left:Vec2()
		Return New Vec2(-1.0, 0.0)
	End
	
	Function Right:Vec2()
		Return New Vec2(1.0, 0.0)
	End
	
	
	Function Add:Vec2(a:Vec2, b:Vec2)
		Return New Vec2(a).Add(b)
	End
	
	Function Sub:Vec2(a:Vec2, b:Vec2)
		Return New Vec2(a).Sub(b)
	End
	
	Function Mul:Vec2(a:Vec2, scalar:Float)
		Return New Vec2(a).Mul(scalar)
	End
	
	Function Div:Vec2(a:Vec2, scalar:Float)
		Return New Vec2(a).Div(scalar)
	End
	
	Function Dot:Float(a:Vec2, b:Vec2)
		Return a.Dot(b)
	End
	
	Function AngleBetween:Float(a:Vec2, b:Vec2)
		Local dotProduct:Float = a.Dot(b)
		Local result:Float = dotProduct / (a.Length * b.Length)
		Return ACos(result)
	End

End





