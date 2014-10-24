Strict
Import angelfont
Import brl.filepath

Class FontCache
	
	Function GetFont:AngelFont(path:String)
		If Cache.Contains(path)
			Return Cache.Get(path)
		Else
			Local font:= New AngelFont
			If (Not font) Return Null
			font.LoadFromXml(path)
			Cache.Set(path, font)
			Return font
		End
	End
	
	Function RemoveFont:Void(font:String)
		Cache.Remove(font)
	End
	
	Private
	Global Cache:StringMap<AngelFont> = New StringMap<AngelFont>
End
