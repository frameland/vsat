#Rem
------------------------------------------------------------------------------
	Will load an image from the specified path
	Don't forget to call SetPath() if your directory is different than graphics/
	Once you loaded an atlas with LoadAtlas() get the image with GetImage(atlas.png/image.png)
------------------------------------------------------------------------------
#End

Strict
Import mojo
Import brl.filepath


Class ImageCache
	
	Function GetImage:Image(path:String, flags:Int = Image.DefaultFlags)
		If ImageCache.Contains(path)
			Return ImageCache.Get(path)
		Else
			Local image:Image = mojo.LoadImage(path, 1, flags)
			If (Not image) Return Null
			ImageCache.Set(path, image)
			Return image
		End
	End
	
	Function LoadAtlas:Bool(path:String)
		Local atlas:Image = mojo.LoadImage(path)
		If Not atlas
			Return False
		End
		
		Local fileText:String = LoadString(path[..path.Length-3] + "txt")
		If Not fileText
			Return False
		End
		Local file:String[] = fileText.Trim().Split("~n")
		
		Local i:Int
		Local startIndex:Int = 0
		Local endIndex:Int = 0
		Local line:String[5] 'path, x, y, w, h
		Local image:Image
		Local loadedImages:Image[file.Length]
		
		For i = 0 Until file.Length
			If (file[i] = "") Continue
			line = file[i].Split (":")
			image = atlas.GrabImage(Int(line[1]), Int(line[2]), Int(line[3]), Int(line[4]), 1, Image.DefaultFlags)
			line[0] = path + "/" + line[0]
			ImageCache.Set(line[0], image) 'SetCachedImage
		End
		
		Return True
	End
	
	Function SetCachedImage:Void(image:Image, path:String)
		ImageCache.Set(path, image)
	End
	
	Function Clear:Void()
		For Local path:String = Eachin ImageCache.Keys()
			Local image:Image = ImageCache.Get(path)
			image.Discard()
			ImageCache.Remove(path)
		Next
	End
	
	Function RemoveImage:Void(withName:String)
		Local image:Image = ImageCache.Get(withName)
		If image
			image.Discard()
			ImageCache.Remove(withName)
		End
	End
	
	Function PrecacheImages:Void()
		Local image:Image
		For image = EachIn ImageCache.Values()
			DrawImage(image, 0, 0)
		Next
		Cls()
	End
	
	Private
	Global ImageCache:StringMap<Image> = New StringMap<Image>

End


