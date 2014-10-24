# Vsat - Monkey-X game framework

**Vsat** is a framework for the [Monkey-X programming language](http://monkey-x.com). It buids on top of the standard monkey modules and enables you to build your games faster.

##Features

* **foundation**
	* XML
	* Localization
	* Math functions
	* Vector2
	* Easing functions
	* Show Fps
	* UUID
* **coregfx**
	* Bitmap fonts
	* Color class
	* Cache for images and fonts
* **framework**
	* Director & Scenes to manage game flow + Transitions
	* Sprites
	* Entities – objects to be drawn; can easily be extended for your own objects
	* Actions – move, scale, rotate any object over time with 1 line of code
	* Particle System with sample emitters
	* Frame Animation
* **extra**
	* Rapidmonkey – change variables at runtime


All code is written in pure monkey so it is cross platform. If you don't like the framework part you can just use **foundation** and **coregfx** – they don't impose any structure on your project. All **extra** modules have to be imported.

##Example
	'buildopt: run
	Import vsat

	Function Main:Int()
		Vsat = New VsatApp 'this line is mandatory
		Vsat.displayFps = True
		Vsat.ChangeScene(New TestScene)
		Return 0
	End

	Class TestScene Extends Scene
		Field shapes:List<Shape> = New List<Shape>
		
		Method OnInit:Void()
			'FadeIn
			Local fade:= New FadeInTransition(0.5)
			fade.SetColor(Color.Black)
			Vsat.StartFadeIn(fade)
			
			'Create some shapes
			Local circle:= New Circle(100, 100, 30)
			circle.renderOutline = True
			Local rect:= New Rect(300, 200, 20, 100)
			rect.renderOutline = True
			
			shapes.AddLast(circle)
			shapes.AddLast(rect)
		End
		
		Method OnUpdate:Void(dt:Float)
			'Get the first shape in the list (circle here)
			Local shape:Shape = shapes.First()
			
			'Right Key: shape gets bigger
			'Left Key: shape gets smaller
			If KeyHit(KEY_RIGHT)
				Local move:= New ScaleBy(shape.scale, 1.0, 1.0, 1.0, EASE_OUT_BACK)
				move.Name = "scale up"
				AddAction(move)
			ElseIf KeyHit(KEY_LEFT)
				Local move:= New ScaleBy(shape.scale, -1.0, -1.0, 1.0, EASE_OUT_BOUNCE)
				move.Name = "scale down"
				AddAction(move)
			End
		End
		
		'Just call render for each entity to be drawn
		Method OnRender:Void()
			For Local a:= EachIn shapes
				a.Render()
			Next
		End
		
		'You can be informed when an action starts, finishes or repeats
		Method OnActionEvent:Void(id:Int, action:Action)
			Select id
				Case Action.STARTED
					Print "starting action: " + action.Name
				Case Action.FINISHED
					Print "action finished: " + action.Name
			End
		End
	
	End
