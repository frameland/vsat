Strict
Import framework

Class Transition Abstract

	Private
	Field duration:Float
	Field time:Float
	Field active:Bool = True
	Field color:Color = New Color(Color.Black)
	
	Public
	Method New(duration:Float)
		Duration = duration
	End
	
	Method New()
		NoDefaultConstructorError("Transition")
	End
	
	
	Method Update:Void(dt:Float)
		If active
			time += dt
			If time >= duration
				active = False
				time = duration
			End
		End
	End
	
	Method Render:Void()
	End
	
	
	Method IsActive:Bool() Property
		Return active
	End
	
	Method Duration:Void(duration:Float) Property
		Self.duration = duration
	End
	
	Method Duration:Float() Property
		Return duration
	End
	
	Method Time:Float() Property
		Return time
	End
	
	Method Progress:Float() Property
		Return Time / Duration
	End

	Method SetColor:Void(color:Color)
		Self.color.Set(color)
	End
	
	
End

Class FadeOutTransition Extends Transition
	
	Method New()
		Super.New()
	End
	
	Method New(duration:Float)
		Super.New(duration)
	End
	
	Method Render:Void()
		PushMatrix()
		ResetMatrix()
		ResetBlend()
		Local alpha:Float = time / duration
		SetAlpha(alpha)
		color.UseWithoutAlpha()
		DrawRect(0, 0, Vsat.ScreenWidth, Vsat.ScreenHeight)
		PopMatrix()
	End

End

Class FadeInTransition Extends Transition
	
	Method New()
		Super.New()
	End
	
	Method New(duration:Float)
		Super.New(duration)
	End
	
	Method Render:Void()
		PushMatrix()
		ResetMatrix()
		ResetBlend()
		Local alpha:Float = 1.0 - (time / duration)
		SetAlpha(alpha)
		color.UseWithoutAlpha()
		DrawRect(0, 0, Vsat.ScreenWidth, Vsat.ScreenHeight)
		PopMatrix()
	End

End




