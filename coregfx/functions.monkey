Strict
Import mojo
Import vsat.foundation
Import color


'------------------------------------------------------------------------------
'	Extends mojo functionality
'------------------------------------------------------------------------------
Function ClearScreenWithColor:Void(color:Color)
	Cls(color.Red * 255, color.Green * 255, color.Blue * 255)
End

Function ResetColor:Void() 
	SetAlpha(1.0)
	SetColor(255, 255, 255)
	If GetBlend() <> AlphaBlend
		SetBlend (AlphaBlend)
	End
End

Function ResetBlend:Void()
	If GetBlend() <> AlphaBlend
		SetBlend (AlphaBlend)
	End
End

Function MakeScreenshot:Image(x:Int = 0, y:Int = 0, w:Int = 0, h:Int = 0)
	If w <= 0
		w = DeviceWidth()
		x = 0
	End

	If h <= 0
		h = DeviceHeight()
		y = 0
	End

	' check that the rectangle is entirely within the screen bounds
	If x < 0 Or y < 0 Or x + w > DeviceWidth() Or y + h > DeviceHeight() Then Return Null

	' create an image
	Local image:Image = CreateImage(w, h)

	' read the screen
	If Not screenshotPixels Or screenshotPixels.Length <> w * h
		screenshotPixels = New Int[w*h]
	End
	ReadPixels(screenshotPixels, x, y, w, h)
	image.WritePixels(screenshotPixels, 0, 0, w, h)

	Return image
End

Function MidHandleImage:Void(image:Image)
	If image
		image.SetHandle(image.Width()/2, image.Height()/2)
	End
End



'--------------------------------------------------------------------------
' * Transformations
'--------------------------------------------------------------------------
Function TranslateV:Void(vector:Vec2)
	mojo.graphics.Translate(vector.x, vector.y)
End

Function ScaleV:Void(vector:Vec2)
	mojo.graphics.Scale(vector.x, vector.y)
End

Function RotateV:Void(vector:Vec2)
	mojo.graphics.Rotate(vector.Angle)
End

Function ScaleAt:Void(vector:Vec2, scaleX:Float, scaleY:Float)
	Translate(vector.x, vector.y)
	mojo.graphics.Scale(scaleX, scaleY)
	Translate(-vector.x, -vector.y)
End

Function ScaleAt:Void(x:Float, y:Float, scaleX:Float, scaleY:Float)
	Translate(x, y)
	mojo.graphics.Scale(scaleX, scaleY)
	Translate(-x, -y)
End

Function RotateAt:Void(vector:Vec2, angle:Float)
	Translate(vector.x, vector.y)
	Rotate(angle)
	Translate(-vector.x, -vector.y)
End

Function RotateAt:Void(x:Float, y:Float, angle:Float)
	Translate(x, y)
	Rotate(angle)
	Translate(-x, -y)
End

Function ResetMatrix:Void()
	SetMatrix(1, 0, 0, 1, 0, 0)
End

Function ResetScissor:Void()
	SetScissor(0, 0, DeviceWidth(), DeviceHeight())
End

Function OverrideMatrix:Void(x:Float, y:Float, angle:Float, scaleX:Float, scaleY:Float)
	SetMatrix(scaleX * Cos(angle), -Sin(angle), Sin(angle), scaleY * Cos(angle), x, y)
End

Function AddMatrix:Void(x:Float, y:Float, angle:Float, scaleX:Float, scaleY:Float)
	Transform(scaleX*Cos(angle),-Sin(angle),Sin(angle),scaleY*Cos(angle),x,y)
End



'--------------------------------------------------------------------------
' * Extended drawing functions with mojo style syntax
' * the detail parameter allows configuration of how many lines the
' * shape will use (e.g. use 6 for a hexagon)
'--------------------------------------------------------------------------

Function DrawRectOutline:Void(x:Float, y:Float, width:Float, height:Float)
	DrawLine(x, y, x + width, y)
	DrawLine(x + width, y, x + width, y + height)
	DrawLine(x + width, y + height, x, y + height)
	DrawLine(x, y + height, x, y)
End

Function DrawCircleOutline:Void(x:Float, y:Float, radius:Float, detail:Int = -1)
	If detail < 0
		detail = radius
	ElseIf detail < 3
		detail = 3
	ElseIf detail > MAX_VERTS
		detail = MAX_VERTS
	End

	Local angleStep:Float = 360.0 / detail
	Local angle:Float
	Local offsetX:Float
	Local offsetY:float
	Local first:Bool = True
	Local firstX:Float
	Local firstY:float
	Local thisX:Float
	Local thisY:float
	Local lastX:Float
	Local lastY:Float

	For Local vertIndex:= 0 Until detail
		offsetX = Sin(angle) * radius
		offsetY = Cos(angle) * radius
		If first
			first = False
			firstX = x + offsetX
			firstY = y + offsetY
			lastX = firstX
			lastY = firstY
		Else
			thisX = x + offsetX
			thisY = y + offsetY
			DrawLine(lastX, lastY, thisX, thisY)
			lastX = thisX
			lastY = thisY
		EndIf
		angle += angleStep
	Next
	DrawLine(lastX, lastY, firstX, firstY)
End

Function DrawRoundRect:Void(x:Float, y:Float, width:Float, height:Float, radius:Float)
	radius = Min(radius, height)
	radius = Min(radius, width)
	DrawOval(x, y, radius, radius)
	DrawOval(x + (width - (radius)), y, radius, radius)
	DrawOval(x, y + (height - (radius)), radius, radius)
	DrawOval(x + (width - (radius)), y + (height - (radius)), radius, radius)
	DrawRect(x + (radius / 2), y, width - radius, height)
	DrawRect(x, y + (radius / 2), width, height - radius)
End

Function DrawRoundRectOutline:Void(x:Float, y:Float, w:Float, h:Float, radius:Float)
	Local radiusHalf:Float = radius * 0.5
	
	DrawRect(x + radiusHalf, y, w - radius, 1)
	DrawRect(x + radiusHalf, y + h, w - radius, 1)
	DrawRect(x, y + radiusHalf, 1, h - radius)
	DrawRect(x + w, y + radiusHalf, 1, h - radius)
	
	DrawArc(x + radiusHalf, y + radiusHalf, radius, 180, 90)
	DrawArc(x + w - radiusHalf, y + radiusHalf, radius, 180, -90)
	DrawArc(x + radiusHalf, y + h - radiusHalf, radius, 0, -90)
	DrawArc(x + w - radiusHalf, y + h - radiusHalf, radius, 0, 90)
End

Function DrawArc:Void(x:Float, y:Float, radius:Float, startAngle:Float, angle:Float, detail:Int = -1)
	Local radiusHalf:Float = radius * 0.5
	If detail = -1
		detail = Ceil(radiusHalf)
	ElseIf detail < 3
		detail = 3
	ElseIf detail > MAX_VERTS
		detail = MAX_VERTS
	End
	
	Local change:Float = 1.0 / detail
	Local time:Float

	Local lastX:Float = x + Sin(startAngle) * radiusHalf
	Local lastY:Float = y + Cos(startAngle) * radiusHalf
	
	For Local i:Int = 0 To detail
		Local offX:Float = Sin(startAngle + angle * time) * radiusHalf
		Local offY:Float = Cos(startAngle + angle * time) * radiusHalf
		Local thisX:Float = x + offX
		Local thisY:Float = y + offY
		DrawLine(lastX, lastY, thisX, thisY)
		lastX = thisX
		lastY = thisY
		time += change
	Next
End

Function DrawThickLine:Void(x1:Float, y1:Float, x2:Float, y2:Float, size:Float, filled:Bool = False, detail:Int = -1)
	Local radius:Float = size / 2.0

	If detail < 0
		detail = size / 5.0
		If detail < 12
			detail = 12
		ElseIf detail > MAX_VERTS
			detail = MAX_VERTS
		EndIf
	EndIf

	Local movementAngle:Float = ATan2ToDegrees(x1 - x2, y1 - y2)
	Local offsetX:Float = (Sin(movementAngle + 90) * radius)
	Local offsetY:Float = (Cos(movementAngle + 90) * radius)
	Local circleIndex:Int
	Local circleAngleStep:Float = 180.0 / (detail + 1)
	Local circleAngle:Float

	If filled = False
		'just draw lines
		Local firstX:Float
		Local firstY:Float
		Local lastX:Float
		Local lastY:Float
		Local thisX:Float
		Local thisY:float

		'edge
		firstX = x1 + offsetX
		firstY = y1 + offsetY
		lastX = x2 + offsetX
		lastY = y2 + offsetY
		DrawLine(firstX, firstY, lastX, lastY)

		'end circle
		If detail > 0
			circleAngle = movementAngle + 90 + circleAngleStep
			For circleIndex = 0 Until detail
				thisX = x2 + (Sin(circleAngle) * radius)
				thisY = y2 + (Cos(circleAngle) * radius)
				DrawLine(lastX, lastY, thisX, thisY)
				lastX = thisX
				lastY = thisY
				circleAngle += circleAngleStep
			Next
		EndIf

		'top/end circle last
		offsetX = -offsetX
		offsetY = -offsetY

		thisX = x2 + offsetX
		thisY = y2 + offsetY
		DrawLine(lastX, lastY, thisX, thisY)
		lastX = thisX
		lastY = thisY

		'edge
		thisX = x1 + offsetX
		thisY = y1 + offsetY
		DrawLine(lastX, lastY, thisX, thisY)
		lastX = thisX
		lastY = thisY

		'start circle
		If detail > 0
			circleAngle = movementAngle - 90 + circleAngleStep
			For circleIndex = 0 Until detail
				thisX = x1 + (Sin(circleAngle) * radius)
				thisY = y1 + (Cos(circleAngle) * radius)
				DrawLine(lastX, lastY, thisX, thisY)
				lastX = thisX
				lastY = thisY
				circleAngle += circleAngleStep
			Next
		EndIf

		'top/end circle last
		DrawLine(lastX, lastY, firstX, firstY)
		
	Else
		'setup verts array
		Local verts:Float[8 + (detail * 2 * 2)]
		Local index:Int

		'edge
		verts[0] = x1 + offsetX
		verts[1] = y1 + offsetY
		verts[2] = x2 + offsetX
		verts[3] = y2 + offsetY
		index = 4

		'end circle
		If detail > 0
			circleAngle = movementAngle + 90 + circleAngleStep
			For circleIndex = 0 Until detail
				verts[index] = x2 + (Sin(circleAngle) * radius)
				verts[index + 1] = y2 + (Cos(circleAngle) * radius)
				index += 2
				circleAngle += circleAngleStep
			Next
		EndIf

		'edge
		offsetX = -offsetX
		offsetY = -offsetY

		verts[index] = x2 + offsetX
		verts[index + 1] = y2 + offsetY
		verts[index + 2] = x1 + offsetX
		verts[index + 3] = y1 + offsetY
		index += 4

		'start circle
		If detail > 0
			circleAngle = movementAngle - 90 + circleAngleStep
			For circleIndex = 0 Until detail
				verts[index] = x1 + (Sin(circleAngle) * radius)
				verts[index + 1] = y1 + (Cos(circleAngle) * radius)
				index += 2
				circleAngle += circleAngleStep
			Next
		EndIf

	'draw it
	DrawPoly(verts)
	EndIf
End

Function DrawLineV:Void(a:Vec2, b:Vec2)
	mojo.DrawLine(a.x, a.y, b.x, b.y)
End

Function DrawImageLine:Void(img:Image, x1:Float, y1:Float, x2:Float, y2:Float, scaleY:Float = 1.0)
	PushMatrix()
	
	Local Angle:Float = ATan2(x2 - x1, y2 - y1)
	Local Size:Float = Sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2))

	Translate(x1, y1)
	Rotate(270 + Angle)
	Scale(Size / img.Width() * 1.0, scaleY)
	DrawImage(img, 0, 0)
	
	PopMatrix()
End



Private
Const MAX_VERTS:Int = 1024
Global screenshotPixels:Int[] 'cached for performance