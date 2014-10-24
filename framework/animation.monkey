Strict
Import sprite

Class FrameAnimation
	
	Method New(sprite:Sprite, frames:Image[])
		Self.sprite = sprite
		Self.frames = frames
		nextAnimation = 0
		Intervall = 0.2
	End
	
	Method Update:Void(dt:Float)
		If paused Then Return
		nextAnimation += dt
		If nextAnimation >= intervall
			nextAnimation = 0
			frame += 1
			If frame >= frames.Length
				frame = 0
			End
			sprite.image = frames[frame]
		End
	End
	
	Method Stop:Void()
		paused = True
		frame = 0
	End
	
	Method Pause:Void()
		paused = True
	End
	
	Method Play:Void()
		paused = False
	End
	
	Method Frame:Int() Property
		Return frame
	End
	
	Method Frame:Void(frame:Int) Property
		Assert(frame >= 0 And frame < frames.Length)
		Self.frame = frame
		sprite.image = frames[frame]
	End
	
	Method Height:Int(frame:Int = 0)
		Assert(frame >= 0 And frame < frames.Length)
		Return frames[frame].Height()
	End
	
	Method TotalFrames:Int() Property
		Return frames.Length
	End
	
	Method Intervall:Float() Property
		Return intervall
	End
	
	Method Intervall:Void(newIntervall:Float) Property
		intervall = newIntervall
	End
	
	Private
	Field frame:Int
	Field frames:Image[]
	Field sprite:Sprite
	Field intervall:Float
	Field nextAnimation:Float
	Field paused:Bool
	
	Method New()
		NoDefaultConstructorError("VFrameAnimation")
	End

End


