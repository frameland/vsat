Strict
Import entity
#REFLECTION_FILTER+="${MODPATH}"


Class Shape Extends Entity Abstract
	
	Field color:Color = New Color
	Field renderOutline:Bool = False

	Method Radius:Float() Abstract
	
	Method Render:Void()
		color.Use()
		PushMatrix()
			Translate(position.x, position.y)
			Rotate(rotation)
			Scale(scale.x, scale.y)
			If Not renderOutline
				Draw()
			Else
				DrawOutline()
			End
		PopMatrix()
	End
	
	Method Draw:Void() Abstract
	Method DrawOutline:Void() Abstract
	Method PointInside:Bool(point:Vec2) Abstract
	
	Method CollidesWith:Bool(shape:Shape)
		If Rect(shape)
			Return CollidesWith(Rect(shape))
		ElseIf Circle(shape)
			Return CollidesWith(Circle(shape))
		End
		Return False
	End
	
	Method CollidesWith:Bool(with:Rect) Abstract
	Method CollidesWith:Bool(with:Circle) Abstract
		
End


Class Rect Extends Shape

	Field size:Vec2
	
'--------------------------------------------------------------------------
' * Constructor
'--------------------------------------------------------------------------
	Method New(x:Float, y:Float, w:Float, h:Float)
		position.Set(x, y)
		size = New Vec2(w, h)
	End
	
	'a = TopLeft
	'b = TopRight
	'c = BottomLeft
	'd = BottomRight
	Method New(a:Vec2, b:Vec2, c:Vec2, d:Vec2)
		position.Set(a)
		size = New Vec2
		size.x = b.x - a.x
		size.y = c.y - a.y
	End
	
	Method Copy:Rect()
		Return New Rect(position.x, position.y, size.x, size.y)
	End


'--------------------------------------------------------------------------
' * Draw
'--------------------------------------------------------------------------
	Method Draw:Void()
		DrawRect(0, 0, size.x, size.y)
	End
	
	Method DrawOutline:Void()
		DrawRectOutline(0, 0, size.x, size.y)
	End
	
	
'--------------------------------------------------------------------------
' * Properties
'--------------------------------------------------------------------------
	Method Width:Float() Property
		Return size.x * scale.x
	End
	
	Method Height:Float() Property
		Return size.y * scale.y
	End
	
	Method Radius:Float() Property
		Return RectRadius(size.x, size.y)
	End
	
	
'--------------------------------------------------------------------------
' * Corners
'--------------------------------------------------------------------------
	Method TopLeft:Vec2() Property
		Return New Vec2(position.x, position.y)
	End
	
	Method TopRight:Vec2() Property
		Local point:= TopRightUntransformed
		If rotation = 0 Then Return point
		Return RotatePoint(point, -rotation, position)
	End
	
	Method BottomLeft:Vec2() Property
		Local point:= BottomLeftUntransformed
		If rotation = 0 Then Return point
		Return RotatePoint(point, -rotation, position)
	End
	
	Method BottomRight:Vec2() Property
		Local point:= BottomRightUntransformed
		If rotation = 0 Then Return point
		Return RotatePoint(point, -rotation, position)
	End
	
	Method TopLeftUntransformed:Vec2() Property
		Return New Vec2(position.x, position.y)
	End
	
	Method TopRightUntransformed:Vec2() Property
		Return New Vec2(position.x + size.x, position.y)
	End
	
	Method BottomLeftUntransformed:Vec2() Property
		Return New Vec2(position.x, position.y + size.y)
	End
	
	Method BottomRightUntransformed:Vec2() Property
		Return New Vec2(position.x + size.x, position.y + size.y)
	End
	
	
'--------------------------------------------------------------------------
' * Collision
'--------------------------------------------------------------------------
	Method PointInside:Bool(point:Vec2)
		If rotation = 0
			Return PointInRect(point.x, point.y, position.x, position.y, size.x, size.y)
		End
		Local transformedPoint:= RotatePoint(point, rotation, position)
		Return PointInRect(transformedPoint.x, transformedPoint.y, position.x, position.y, size.x, size.y)
	End
	
	'TODO: REPLACE WITH Seperating Axis Theorem. code - inefficiency is over 9000!
	Method CollidesWith:Bool(with:Rect)
		'if we have 2 non-rotated rectangles => just use normal overlap check
		If rotation = 0 And with.rotation = 0
			Return RectsOverlap(position.x, position.y, size.x, size.y, with.position.x, with.position.y, with.size.x, with.size.y)
		End
				
		Local a1:= TopLeft
		Local b1:= TopRight
		Local c1:= BottomLeft
		Local d1:= BottomRight
		
		Local a2:= with.TopLeft
		Local b2:= with.TopRight
		Local c2:= with.BottomLeft
		Local d2:= with.BottomRight
		
		If LinesIntersect(a1, b1, a2, b2) Return True
		If LinesIntersect(b1, d1, a2, b2) Return True
		If LinesIntersect(c1, d1, a2, b2) Return True
		If LinesIntersect(a1, c1, a2, b2) Return True
			
		If LinesIntersect(a1, b1, b2, d2) Return True
		If LinesIntersect(b1, d1, b2, d2) Return True
		If LinesIntersect(c1, d1, b2, d2) Return True
		If LinesIntersect(a1, c1, b2, d2) Return True	

		If LinesIntersect(a1, b1, c2, d2) Return True
		If LinesIntersect(b1, d1, c2, d2) Return True
		If LinesIntersect(c1, d1, c2, d2) Return True
		If LinesIntersect(a1, c1, c2, d2) Return True	
	
		If LinesIntersect(a1, b1, a2, c2) Return True
		If LinesIntersect(b1, d1, a2, c2) Return True
		If LinesIntersect(c1, d1, a2, c2) Return True
		If LinesIntersect(a1, c1, a2, c2) Return True	
		
		'check if 1 of the corners is inside
		b1 = RotatePoint(b1, rotation, a1)
		c1 = RotatePoint(c1, rotation, a1)
		d1 = RotatePoint(d1, rotation, a1)
		Local helpRect:= New Rect(a1, b1, c1, d1)
		
		a2 = RotatePoint(a2, rotation, a1)
		b2 = RotatePoint(b2, rotation, a1)
		c2 = RotatePoint(c2, rotation, a1)
		d2 = RotatePoint(d2, rotation, a1)
		
		If helpRect.PointInside(a2) Then Return True
		If helpRect.PointInside(b2) Then Return True
		If helpRect.PointInside(c2) Then Return True
		If helpRect.PointInside(d2) Then Return True
			
		Return False
	End
	
	Method CollidesWith:Bool(circle:Circle)
		If PointInside(circle.position)
			Return True
		End
		
		Local topLeft:= TopLeftUntransformed
		Local topRight:= TopRightUntransformed
		Local bottomLeft:= BottomLeftUntransformed
		Local bottomRight:= BottomRightUntransformed
		
		'transform position into local space of rect
		Local rotatedCircle:Circle = circle.Copy()
		rotatedCircle.position = RotatePoint(circle.position, rotation, position)
		
		Return  rotatedCircle.CollidesWithLine(topLeft, topRight) Or
				rotatedCircle.CollidesWithLine(topRight, bottomRight) Or
				rotatedCircle.CollidesWithLine(topLeft, bottomLeft) Or
				rotatedCircle.CollidesWithLine(bottomLeft, bottomRight)
	End
	
End


Class Circle Extends Shape
	
	Field radius:Float
	
	Method New(x:Float, y:Float, radius:Float)
		position.Set(x, y)
		Self.radius = radius
	End
	
	Method Copy:Circle()
		Return New Circle(position.x, position.y, radius)
	End
	
	
	Method Draw:Void()
		DrawCircle(0, 0, radius)
	End
	
	Method DrawOutline:Void()
		DrawCircleOutline(0, 0, radius)
	End
	
	Method Radius:Float() Property
		Return radius
	End
	
	
'--------------------------------------------------------------------------
' * Collision
'--------------------------------------------------------------------------
	Method PointInside:Bool(point:Vec2)
		Return PointInCircle(point.x, point.y, position.x, position.y, radius)
	End
	
	Method CollidesWith:Bool(with:Circle)
		Return CirclesOverlap(position.x, position.y, radius, with.position.x, with.position.y, with.radius)
	End
	
	Method CollidesWith:Bool(with:Rect)
		Return with.CollidesWith(Self)
	End
	
	Method CollidesWithLine:Bool(lineStart:Vec2, lineEnd:Vec2)
		Return PerpendicularDistance(Self.position, lineStart, lineEnd) <= radius + 1
	End
	
End














