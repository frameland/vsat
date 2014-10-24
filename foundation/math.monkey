Strict
Import vec2


'Map Value from old range, to new range
Function MapValue:Float(value:Float, start1:Float, end1:Float, start2:Float, end2:Float)
	Return start2 + (end2 - start2) * ((value - start1) / (end1 - start1))
End

Function Round:Float(value:Float)
	Return Floor(value + 0.5)
End



Function RectsOverlap:Bool(x1:Float, y1:Float, w1:Float, h1:Float, x2:Float, y2:Float, w2:Float, h2:Float)
	If x1 > (x2 + w2) Or (x1 + w1) < x2
		Return False
	End
	If y1 > (y2 + h2) Or (y1 + h1) < y2
		Return False
	End
	Return True
End

Function PointInRect:Bool (x:Float, y:Float, rectX:Float, rectY:Float, rectW:Float, rectH:Float)
	Return (x > rectX) And (x < rectX+rectW) And (y > rectY) And (y < rectY+rectH)
End

Function CirclesOverlap:Bool(x1:Float, y1:Float, r1:Float, x2:Float, y2:Float, r2:Float)
	Return Sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) ) - r1 - r2 < 0
End

Function PointInCircle:Bool(pointX:Float, pointY:Float, circleX:Float, circleY:Float, radius:Float)
	Return DistanceOfPoints(pointX,pointY,circleX,circleY) <= radius
End

Function LinesIntersect:Bool(a:Vec2, b:Vec2, c:Vec2, d:Vec2)
    Local denominator:Float = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x))
    Local numerator1:Float = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y))
    Local numerator2:Float = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y))

    If (denominator = 0) 
		Return numerator1 = 0 And numerator2 = 0
	End

    Local r:Float = numerator1 / denominator
    Local s:Float = numerator2 / denominator

    Return (r >= 0 And r <= 1) And (s >= 0 And s <= 1)
End
	


Function DistanceOfPoints:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Return Sqrt( (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) )
End Function

Function PerpendicularDistance:Float(point:Vec2, lineStart:Vec2, lineEnd:Vec2)
	Local A:Float = point.x - lineStart.x
	Local B:Float = point.y - lineStart.y
	Local C:Float = lineEnd.x - lineStart.x
	Local D:Float = lineEnd.y - lineStart.y

	Local dot:Float = A * C + B * D
	Local len_sq:Float = C * C + D * D
	Local param:Float = dot / len_sq

	Local xx:Float
	Local yy:Float

	If (param < 0 Or (lineStart.x = lineEnd.x And lineStart.y = lineEnd.y))
	  xx = lineStart.x
	  yy = lineStart.y
	ElseIf (param > 1)
	  xx = lineEnd.x
	  yy = lineEnd.y
	Else
	  xx = lineStart.x + param * C
	  yy = lineStart.y + param * D
	End

	Local dx:Float = point.x - xx
	Local dy:Float = point.y - yy
	Return Sqrt(dx * dx + dy * dy)
End

Function RectRadius:Float(w:Float, h:Float)
	Local x2:Float = w / 2
	Local y2:Float = h / 2
	Return Sqrt(x2 * x2 + y2 * y2)
End



Function RadToDeg:Float(radians:Float)
	Return radians * 180 / PI
End

Function DegToRad:Float(degrees:Float)
	Return degrees * (PI / 180)
End

'convert atan into sensible angle
Function ATan2ToDegrees:Float(x:Float, y:float)
	Local angle:Float = ATan2(x, y)
	If angle < 0 Return 180.0 + (180.0 + angle)
	Return angle
End

'wrap into positive range: 0 - 360
Function WrapAngle:Float(angle:Float)
	angle = angle / 360.0
	Return (angle - Floor(angle)) * 360.0        
End



Function Lerp:Float(startValue:Float, endValue:Float, percent:Float)
	Return startValue + (endValue - startValue) * percent
End

Function Slope:Float(x1:Float, y1:Float, x2:Float, y2:Float)
	Return (y2 - y1) / (x2 - x1)
End

Function Slope:Float(a:Vec2, b:Vec2)
	Return (b.y - a.y) / (b.x - a.x)
End



'rotate a point around the origin, returns a new vector
Function RotatePoint:Vec2(point:Vec2, angle:Float, origin:Vec2)
	Local p:Vec2 = New Vec2
	p.x = Cos(angle) * (point.x - origin.x) - Sin(angle) * (point.y - origin.y) + origin.x
	p.y = Sin(angle) * (point.x - origin.x) + Cos(angle) * (point.y - origin.y) + origin.y
	Return p
End



Function QuadraticBezier:Vec2(t:Float, P0:Vec2, P1:Vec2, C:Vec2)
    Local x:Float = (1 - t) * (1 - t) * P0.x + (2 - 2 * t) * t * C.x + t * t * P1.x
    Local y:Float = (1 - t) * (1 - t) * P0.y + (2 - 2 * t) * t * C.y + t * t * P1.y
    Return New Vec2(x, y)
End

'todo: optimze, dont create 3 temporary vectors
Function CubicBezier:Vec2(t:Float, p0:Vec2, p1:Vec2, p2:Vec2, p3:Vec2)
	Local u:Float = 1.0 - t
	Local tt:Float = t*t
	Local uu:Float = u*u
	Local uuu:Float = uu * u
	Local ttt:Float = tt * t

	Local p:Vec2 = Vec2.Mul(p0, uuu)
	p.Add(Vec2.Mul(p1, 3 * uu * t))
	p.Add(Vec2.Mul(p2, 3 * u * tt))
	p.Add(Vec2.Mul(p3, ttt))
	
	Return p
End


