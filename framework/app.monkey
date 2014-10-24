Strict
Import vsat.foundation
Import vsat.coregfx
Import scene
Import transition
Import mojo

'Vsat is the global handler, you have to initialize it with Vsat = New VsatApp
Global Vsat:VsatApp

Class VsatApp Extends App
	
	Private
	Field activeScene:Scene
	Field nextScene:Scene
	Field clipboard:StringMap<Object> = New StringMap<Object>
	
	Public
	Field displayFps:Bool = False
	Field paused:Bool = False
	Field transition:Transition
	
	
'--------------------------------------------------------------------------
' * Scenes
'--------------------------------------------------------------------------
	Method ChangeScene:Void(scene:Scene)
		Assert(scene)
		Try
			If activeScene
				activeScene.OnExit()
				scene.OnInit()
				activeScene = scene
			Else
				Local dummy:= New DummyScene
				dummy.InitWithScene(scene)
				activeScene = dummy
			End
		Catch e:Exception
			Error(e)
		End
	End
	
	Method ChangeSceneWithTransition:Void(scene:Scene, transition:Transition = New FadeOutTransition(1.0))
		Assert(scene And transition And transition.Duration > 0)
		Try
			If activeScene = Null
				scene.OnInit()
				activeScene = scene
			Else
				Self.transition = transition
				nextScene = scene
			End
		Catch e:Exception
			Error(e)
		End
	End
	
	'Convenience Function: Call from OnInit()
	Method StartFadeIn:Void(transition:Transition = FadeInTransition(1.0))
		Assert(transition And transition.Duration > 0)
		Self.transition = transition
	End
	
	Method IsActiveScene:Bool(scene:Scene)
		Return activeScene = scene
	End
	
	Method CurrentScene:Scene() Property
		Return activeScene
	End
	

'--------------------------------------------------------------------------
' * Callbacks
'--------------------------------------------------------------------------	
	Method OnLoading:Int()
		Try
			If activeScene
				activeScene.OnLoading()
			End
		Catch e:Exception
			Error(e)
		End
		Return 0
	End
	
	Method OnCreate:Int()
		Try
			UpdateScreenSize(DeviceWidth(), DeviceHeight())
			TargetFps = 60
			Local date:Int[] = GetDate()
			Seed = (date[0] + date[1] + date[2] + date[3] + date[4]) * date[5] + date[6]
			systemFont = FontCache.GetFont("sans")
		Catch e:Exception
			Error(e)
		End
		Return 0
	End
	
	Method OnUpdate:Int()
		If paused
			If activeScene
				Try
					activeScene.OnUpdateWhilePaused()
				Catch e:Exception
					Error(e)
				End
			End
			Return 0
		End
		
		Try
			UpdateGameTime()
			UpdateAsyncEvents()
			
			If transition
				transition.Update(deltaTime)
				If Not transition.IsActive
					transition = Null
					If nextScene
						ChangeScene(nextScene)
						nextScene = Null
					End
				End
			End

			If activeScene
				activeScene.UpdateTouches()
				activeScene.UpdateActions(deltaTime)
				activeScene.OnUpdate(deltaTime)
			End
		Catch e:Exception
			Error(e)
		End
		
		Return 0
	End
	
	Method OnRender:Int()
		Try
			If activeScene
				If activeScene.shouldClearScreen Then activeScene.ClearScreen()
				activeScene.OnRender()
			End
			If transition
				transition.Render()
			End
		Catch e:Exception
			Error(e)
		End
		
		UpdateFps()
		If displayFps Then RenderFps()
		
		Return 0
	End
	
	Method OnSuspend:Int()
		Try
			If activeScene
				activeScene.OnSuspend()
			End
		Catch e:Exception
			Error(e)
		End
		Return 0
	End
	
	Method OnResume:Int()
		Try
			If activeScene
				activeScene.OnResume()
			End
		Catch e:Exception
			Error(e)
		End
		Return 0
	End
	
	Method OnResize:Int()
		Try
			UpdateScreenSize(DeviceWidth(), DeviceHeight())
			If activeScene
				activeScene.OnResize()
			End
		Catch e:Exception
			Error(e)
		End
		Return 0
	End
	
	
'--------------------------------------------------------------------------
' * Properties
'--------------------------------------------------------------------------
	Method DeltaTime:Float() Property
		Return deltaTime
	End
	
	Method Seconds:Float() Property
		Return seconds
	End
	
	Method Frame:Int() Property
		Return frame
	End
	
	Method TargetFps:Int() Property
		Return targetFps
	End
	
	Method TargetFps:Void(setTargetFps:Int) Property
		targetFps = setTargetFps
		SetUpdateRate(targetFps)
		frame = 0
	End
	
	Method IsChangingScenes:Bool() Property
		Return transition <> Null
	End
	

'--------------------------------------------------------------------------
' * Screen
'--------------------------------------------------------------------------
	Method ScreenWidth:Int() Property
		Return screenWidth
	End
	
	Method ScreenWidth2:Int() Property
		Return screenWidth2
	End
	
	Method ScreenHeight:Int() Property
		Return screenHeight
	End
	
	Method ScreenHeight2:Int() Property
		Return screenHeight2
	End
	
	Method UpdateScreenSize:Void(w:Int, h:Int)
		screenWidth = w
		screenHeight = h
		screenWidth2 = screenWidth / 2.0
		screenHeight2 = screenHeight / 2.0
	End
	
	Method SystemFont:AngelFont() Property
		Return systemFont
	End
	

'--------------------------------------------------------------------------
' * Events & Clipboard
'--------------------------------------------------------------------------
	Method FireEvent:Void(event:Event)
		If activeScene
			activeScene.HandleEvent(event)
		End
	End

	Method SaveToClipboard:Void(object:Object, withName:String)
		clipboard.Set(withName, object)
	End
	
	Method RestoreFromClipboard:Object(objectName:String)
		Local object:Object = clipboard.Get(objectName)
		If object
			clipboard.Remove(objectName)
		End
		Return object
	End
	
	
	
	Private
	Field lastUpdate:Float
	Field deltaTime:Float
	Field seconds:Float
	Field frame:Int
	
	Field screenWidth:Int
	Field screenHeight:Int
	Field screenWidth2:Int
	Field screenHeight2:Int
	
	Field systemFont:AngelFont
	
	Field targetFps:Int
	
	
	Method UpdateGameTime:Void()
		Local now:Float = Millisecs()
		deltaTime = (now - lastUpdate) / 1000.0
		seconds += deltaTime
		lastUpdate = now
		
		frame += 1
		frame = frame Mod targetFps
	End
	
	Method RenderFps:Void()
		If systemFont
			PushMatrix()
			ResetMatrix()
			Color.White.Use()
			systemFont.DrawText("Fps: " + GetFps(), screenWidth - 4, 2, AngelFont.ALIGN_RIGHT, AngelFont.ALIGN_TOP)
			PopMatrix()
		End
	End
	
End



'This is a private scene needed to bridge the initialization to the first scene
Private
Class DummyScene Extends Scene
	
	Field initScene:Scene
	
	Method InitWithScene:Void(scene:Scene)
		Assert(scene)
		initScene = scene
	End
	
	Method OnUpdate:Void(dt:Float)
		If Not Vsat
			Throw New Exception("Call 'Vsat = New VsatApp' before changing scenes.")
		End
		Vsat.ChangeScene(initScene)
	End
	
End



