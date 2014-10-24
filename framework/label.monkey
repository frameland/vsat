Strict
Import vsat


Class Label Extends Rect
	
	Field alignHorizontal:Int = AngelFont.ALIGN_LEFT
	Field alignVertical:Int = AngelFont.ALIGN_TOP
	
	Method New(text:String)
		Super.New(0, 0, 0, 0)
		Self.text = text
	End
	
	Method SetFont:Void(fontName:String)
		usedFont = FontCache.GetFont(fontName)
		UpdateSize()
	End
	
	Method SetFont:Void(font:AngelFont)
		usedFont = font
		UpdateSize()
	End
	
	Method UpdateSize:Void()
		If usedFont
			size.x = usedFont.TextWidth(text)
			size.y = usedFont.TextHeight(text)
		End
	End
	
	Method Draw:Void()
		NeedsFont()
		usedFont.DrawText(text, 0, 0, alignHorizontal, alignVertical)
	End
	
	Method DrawOutline:Void()
		AssertWithException(False, "VLabel with text: " + text + "~nCannot draw outline.")
	End
	
	Method Text:Void(text:String) Property
		NeedsFont()
		Self.text = text
		UpdateSize()
	End
	
	Method Text:String() Property
		Return text
	End
	
	Private
	Field usedFont:AngelFont
	Field text:String
	
	Method NeedsFont:Void()
		AssertWithException(usedFont, "VLabel with text: " + text + " has no font set")
	End
	
End

