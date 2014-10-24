Strict

Private
Import mojo.app

Public
Function UpdateFps:Void()
	If (Millisecs() - startTime) >= 1000
		currentRate = fpsCount
		fpsCount = 0
		startTime = Millisecs()
	Else
		fpsCount += 1
	End
End

Function GetFps:Int()
	Return currentRate
End

Private
Global fpsCount:Int
Global startTime:Int
Global currentRate:Int