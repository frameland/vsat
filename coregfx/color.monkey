Strict

Import vsat.foundation.functions
Import mojo.graphics
#REFLECTION_FILTER+="${MODPATH}"

Class Color

	Private
	Field red:Float = 1.0
	Field green:Float = 1.0
	Field blue:Float = 1.0
	Field alpha:Float = 1.0

	Public
	Global Black:= New ImmutableColor(0.0, 0.0, 0.0)
	Global White:= New ImmutableColor(1.0, 1.0, 1.0)
	Global PureRed:= New ImmutableColor(1.0, 0.0, 0.0)
	Global PureGreen:= New ImmutableColor(0.0, 1.0, 0.0)
	Global PureBlue:= New ImmutableColor(0.0, 0.0, 1.0)
	
	'new web colors from: http://clrs.cc
	Global Navy:= New ImmutableColor($001F3F)
	Global NewBlue:= New ImmutableColor($0074D9)
	Global Aqua:= New ImmutableColor($7FDBFF)
	Global Teal:= New ImmutableColor($39CCCC)
	Global Olive:= New ImmutableColor($3D9970)
	Global NewGreen:= New ImmutableColor($2ECC40)
	Global Lime:= New ImmutableColor($01FF70)
	Global Yellow:= New ImmutableColor($FFDC00)
	Global Orange:= New ImmutableColor($FF851B)
	Global NewRed:= New ImmutableColor($FF4136)
	Global Maroon:= New ImmutableColor($85144B)
	Global Fuchsia:= New ImmutableColor($F012BE)
	Global Purple:= New ImmutableColor($B10DC9)
	Global Silver:= New ImmutableColor($DDDDDD)
	Global Gray:= New ImmutableColor($AAAAAA)
	Global NewBlack:= New ImmutableColor($111111)
	
	
	Method New(rgb:Int)
		RGB = rgb
	End
	
	Method New(red:Float, green:Float, blue:Float, alpha:Float = 1.0)
		Set(red, green, blue, alpha)
	End
	
	Method New(withColor:Color)
		Self.Set(withColor)
	End
	
	Method Set:Void(red:Float, green:Float, blue:Float, alpha:Float = 1.0)
		Red = red
		Green = green
		Blue = blue
		Alpha = alpha
	End
	
	Method Set:Void(newColor:Color)
		red = newColor.red
		green = newColor.green
		blue = newColor.blue
		alpha = newColor.alpha
	End
	
	Method Set:Void(rgb:Int)
		RGB = rgb
	End
	
	Method Reset:Void()
		red = 1.0
		green = 1.0
		blue = 1.0
		alpha = 1.0
	End

	
	Method Red:Float() Property
		Return red
	End

	Method Red:Void(value:Float) Property
		red = Clamp(value, 0.0, 1.0)
	End

	Method Green:Float() Property
		Return green
	End

	Method Green:Void(value:Float) Property
		green = Clamp(value, 0.0, 1.0)
	End

	Method Blue:Float() Property
		Return blue
	End

	Method Blue:Void(value:Float) Property
		blue = Clamp(value, 0.0, 1.0)
	End

	Method Alpha:Float() Property
		Return alpha
	End

	Method Alpha:Void(value:Float) Property
		alpha = Clamp(value, 0.0, 1.0)
	End
	
	
	Method RGB:Void(rgb:Int) Property
		red = Float((rgb Shr 16) & $FF) / 255.0
		green = Float((rgb Shr 8) & $FF) / 255.0
		blue = Float(rgb & $FF) / 255.0
		alpha = 1.0 'Float((argb Shr 24) & $FF) / 255.0
	End
	
	Method RGB:Int() Property
		Return (red * 255 Shl 16) | (green * 255 Shl 8) | blue * 255
	End
	
	Method ARGB:Int() Property
		Return (alpha * 255 Shl 24) | (red * 255 Shl 16) | (green * 255 Shl 8) | blue * 255
	End
	
	
	Method Randomize:Void()
		red = Rnd()
		green = Rnd()
		blue = Rnd()
	End
	
	Method Equals:Bool(color:Color)
		Local e:Float = 0.0001
		If (Abs(color.red - red) > e) Return False
		If (Abs(color.green - green) > e) Return False
		If (Abs(color.blue - blue) > e) Return False
		If (Abs(color.alpha - alpha) > e) Return False
		Return True
	End

	Method ToString:String()
		Return "(Red: " + red + " Green: " + green + " Blue: " + blue + " Alpha: " + alpha + ")"
	End
	
	Method Use:Void()
		SetColor(red * 255, green * 255, blue * 255)
		SetAlpha(alpha)
	End
	
	Method UseWithoutAlpha:Void()
		SetColor(red * 255, green * 255, blue * 255)
	End
	
End



Class ImmutableColor Extends Color
	
	Method New()
		NoDefaultConstructorError("ImmutableColor")
	End
	
	Method New(rgb:Int)
		Super.RGB(rgb)
	End
	
	Method New(red:Float, green:Float, blue:Float, alpha:Float = 1.0)
		Super.Red(red)
		Super.Green(green)
		Super.Blue(blue)
		Super.Alpha(alpha)
	End
	
	Method Set:Void(red:Float, green:Float, blue:Float, alpha:Float = 1.0)
		CantChangeError()
	End
	
	Method Set:Void(newColor:Color)
		CantChangeError()
	End
	
	Method Reset:Void()
		CantChangeError()
	End
	
	Method Randomize:Void()
		CantChangeError()
	End
	
	Method Red:Void(value:Float) Property
		CantChangeError()
	End

	Method Green:Void(value:Float) Property
		CantChangeError()
	End

	Method Blue:Void(value:Float) Property
		CantChangeError()
	End

	Method Alpha:Void(value:Float) Property
		CantChangeError()
	End
	
	Method RGB:Void(rgb:Int) Property
		CantChangeError()
	End
	
	Private
	Method CantChangeError:Void()
		Error "ImmutableColor can't be changed.~n" + Self.ToString()
	End
	
End

