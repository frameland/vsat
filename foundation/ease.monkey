#rem
---------------------------------------------------------------------------
Disclaimer for Robert Penner's Easing Equations license:

TERMS OF USE - EASING EQUATIONS

Open source under the BSD License.

Copyright © 2001 Robert Penner
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
* Neither the name of the author nor the names of contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

---------------------------------------------------------------------------
For all easing functions:
t = elapsed time
b = begin
c = change = ending - beginning
d = duration (total time)
---------------------------------------------------------------------------
#end


Strict

#Rem
---------------------------------------------------------------------------
	
	Callback API built on top of Robert Penners Functions
	
	Simply call Tweening() function every Update()
	
	- type: one of the Constants below (LINEAR_TWEEN, EASE_IN_QUAD, ...)
	- Returns: A float value which represents the current progress
	
---------------------------------------------------------------------------
#End

Function Tweening:Float (type:Int, t:Float, b:Float, c:Float, d:Float)
	If Not initialized
		InitTweenSystem()
	End
	Return TweenFunc[type].Do (t, b, c , d)
End

Function TweenSetPower:Void (power:Float)
	Power = power
End

Function TweenSetBounce:Void (bounce:Float)
	Bounce = bounce
End

Function TweenSetAmplitude:Void (amplitude:Float)
	Amplitude = amplitude
End


Const LINEAR_TWEEN		:Int = 0

Const EASE_IN_QUAD		:Int = 1
Const EASE_OUT_QUAD		:Int = 2
Const EASE_IN_OUT_QUAD	:Int = 3

Const EASE_IN_CUBIC		:Int = 4
Const EASE_OUT_CUBIC	:Int = 5
Const EASE_IN_OUT_CUBIC	:Int = 6

Const EASE_IN_QUART		:Int = 7
Const EASE_OUT_QUART	:Int = 8
Const EASE_IN_OUT_QUART	:Int = 9

Const EASE_IN_QUINT		:Int = 10
Const EASE_OUT_QUINT	:Int = 11
Const EASE_IN_OUT_QUINT	:Int = 12

Const EASE_IN_SINE		:Int = 13
Const EASE_OUT_SINE		:Int = 14
Const EASE_IN_OUT_SINE	:Int = 15

Const EASE_IN_EXPO		:Int = 16
Const EASE_OUT_EXPO		:Int = 17
Const EASE_IN_OUT_EXPO	:Int = 18

Const EASE_IN_CIRC		:Int = 19
Const EASE_OUT_CIRC		:Int = 20
Const EASE_IN_OUT_CIRC	:Int = 21

Const EASE_IN_BACK		:Int = 22
Const EASE_OUT_BACK		:Int = 23
Const EASE_IN_OUT_BACK	:Int = 24

Const EASE_IN_BOUNCE	:Int = 25
Const EASE_OUT_BOUNCE	:Int = 26
Const EASE_IN_OUT_BOUNCE:Int = 27

Const EASE_IN_ELASTIC	:Int = 28
Const EASE_OUT_ELASTIC	:Int = 29
Const EASE_IN_OUT_ELASTIC:Int = 30



Private
'--------------------------------------------------------------------------
' * Every Tweener Implements this
'--------------------------------------------------------------------------
Interface Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
End

Function InitTweenSystem:Void()
	TweenFunc[LINEAR_TWEEN] = New LinearTween
	
	TweenFunc[EASE_IN_QUAD] = New EaseInQuad
	TweenFunc[EASE_OUT_QUAD] = New EaseOutQuad
	TweenFunc[EASE_IN_OUT_QUAD] = New EaseInOutQuad
	
	TweenFunc[EASE_IN_CUBIC] = New EaseInCubic
	TweenFunc[EASE_OUT_CUBIC] = New EaseOutCubic
	TweenFunc[EASE_IN_OUT_CUBIC] = New EaseInOutCubic
	
	TweenFunc[EASE_IN_QUART] = New EaseInQuart
	TweenFunc[EASE_OUT_QUART] = New EaseOutQuart
	TweenFunc[EASE_IN_OUT_QUART] = New EaseInOutQuart
	
	TweenFunc[EASE_IN_QUINT] = New EaseInQuint
	TweenFunc[EASE_OUT_QUINT] = New EaseOutQuint
	TweenFunc[EASE_IN_OUT_QUINT] = New EaseInOutQuint
	
	TweenFunc[EASE_IN_SINE] = New EaseInSine
	TweenFunc[EASE_OUT_SINE] = New EaseOutSine
	TweenFunc[EASE_IN_OUT_SINE] = New EaseInOutSine
	
	TweenFunc[EASE_IN_EXPO] = New EaseInExpo
	TweenFunc[EASE_OUT_EXPO] = New EaseOutExpo
	TweenFunc[EASE_IN_OUT_EXPO] = New EaseInOutExpo
	
	TweenFunc[EASE_IN_EXPO] = New EaseInExpo
	TweenFunc[EASE_OUT_EXPO] = New EaseOutExpo
	TweenFunc[EASE_IN_OUT_EXPO] = New EaseInOutExpo
	
	TweenFunc[EASE_IN_CIRC] = New EaseInCirc
	TweenFunc[EASE_OUT_CIRC] = New EaseOutCirc
	TweenFunc[EASE_IN_OUT_CIRC] = New EaseInOutCirc
	
	TweenFunc[EASE_IN_BACK] = New EaseInBack
	TweenFunc[EASE_OUT_BACK] = New EaseOutBack
	TweenFunc[EASE_IN_OUT_BACK] = New EaseInOutBack
	
	TweenFunc[EASE_IN_BOUNCE] = New EaseInBounce
	TweenFunc[EASE_OUT_BOUNCE] = New EaseOutBounce
	TweenFunc[EASE_IN_OUT_BOUNCE] = New EaseInOutBounce
	
	TweenFunc[EASE_IN_ELASTIC] = New EaseInElastic
	TweenFunc[EASE_OUT_ELASTIC] = New EaseOutElastic
	TweenFunc[EASE_IN_OUT_ELASTIC] = New EaseInOutElastic
	
End



'--------------------------------------------------------------------------
' * Linear
'--------------------------------------------------------------------------
Class LinearTween Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return c*t/d + b
	End
End



'--------------------------------------------------------------------------
' * Quad
'--------------------------------------------------------------------------
Class EaseInQuad Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return c*t*t + b
	End
End
	
Class EaseOutQuad Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return -c * t*(t-2) + b
	End
End

Class EaseInOutQuad Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1) Return c/2*t*t + b
		t -= 1
		Return -c/2 * (t*(t-2) - 1) + b
	End
End



'--------------------------------------------------------------------------
' * Cubic
'--------------------------------------------------------------------------
Class EaseInCubic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return c*t*t*t + b
	End
End

Class EaseOutCubic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		t -= 1
		Return c*(t*t*t + 1) + b
	End
End

Class EaseInOutCubic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1) Return c/2*t*t*t + b
		t -= 2
		Return c/2*(t*t*t + 2) + b
	End
End


'--------------------------------------------------------------------------
' * Quart
'--------------------------------------------------------------------------
Class EaseInQuart Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return c*t*t*t*t + b
	End
End

Class EaseOutQuart Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		t -= 1
		Return -c * (t*t*t*t - 1) + b
	End
End

Class EaseInOutQuart Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1) Return c/2*t*t*t*t + b
		t -= 2
		Return -c/2 * (t*t*t*t - 2) + b
	End
End



'--------------------------------------------------------------------------
' * Quintic
'--------------------------------------------------------------------------
Class EaseInQuint Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return c*t*t*t*t*t + b
	End
End

Class EaseOutQuint Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		t -= 1
		Return c*(t*t*t*t*t + 1) + b
	End
End

Class EaseInOutQuint Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1)
			Return c/2*t*t*t*t*t + b
		End
		t -= 2
		Return c/2*(t*t*t*t*t + 2) + b
	End
End
	
	
		
'--------------------------------------------------------------------------
' * Sinus
'--------------------------------------------------------------------------
Class EaseInSine Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return -c * Cos((t/d * (PI/2)) * 57.2957795) + c + b
	End
End

Class EaseOutSine Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return c * Sin((t/d * (PI/2)) * 57.2957795) + b
	End
End

Class EaseInOutSine Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return -c/2 * (Cos((PI*t/d) * 57.2957795) - 1) + b
	End
End



'--------------------------------------------------------------------------
' * Exponential
'--------------------------------------------------------------------------
Class EaseInExpo Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return c * Pow( 2, 10 * (t/d - 1) ) + b
	End
End

Class EaseOutExpo Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return c * ( -Pow( 2, -10 * t/d ) + 1 ) + b
	End
End

Class EaseInOutExpo Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1)
			Return c/2 * Pow( 2, 10 * (t - 1) ) + b
		End
		t -= 1
		Return c/2 * ( -Pow( 2, -10 * t) + 2 ) + b
	End
End
		
		

'--------------------------------------------------------------------------
' * Circ
'--------------------------------------------------------------------------
Class EaseInCirc Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return -c * (Sqrt(1 - t*t) - 1) + b
	End
End

Class EaseOutCirc Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		t -= 1
		Return c * Sqrt(1 - t*t) + b
	End
End

Class EaseInOutCirc Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d/2
		If (t < 1)
			Return -c/2 * (Sqrt(1 - t*t) - 1) + b
		End
		t -= 2
		Return c/2 * (Sqrt(1 - t*t) + 1) + b
	End
End



'--------------------------------------------------------------------------
' * Back
'--------------------------------------------------------------------------
Class EaseInBack Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		Return c * t * t * ((Bounce + 1) * t - Bounce) + b
	End
End

Class EaseOutBack Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t = t / d - 1
		Return c * (t * t * ((Bounce + 1) * t + Bounce) + 1) + b
	End
End

Class EaseInOutBack Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d / 2
		If ((t) < 1)
			Bounce*=1.525+1
			Return c/2*(t*t*(Bounce*t - Bounce)) + b
		End
		t-=2
		Bounce*=1.525+1
		Return c/2*(t*t*(Bounce*t + Bounce) + 2) + b
	End
End



'--------------------------------------------------------------------------
' * Bounce
'--------------------------------------------------------------------------
Class EaseInBounce Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Return c - Tweening (EASE_OUT_BOUNCE, d - t, 0, c, d) + b
	End
End

Class EaseOutBounce Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		t /= d
		If (t < (1 / 2.75))
			Return c * (7.5625 * t * t) + b
		ElseIf (t < (2 / 2.75))
			t -= (1.5 / 2.75)
			Return c * (7.5625 * t * t + .75) + b
		ElseIf (t < (2.5 / 2.75))
			t -= (2.25 / 2.75)
			Return c * (7.5625 * t  * t + .9375) + b
		Else
			t -= (2.625 / 2.75)
			Return c * (7.5625 * t * t + .984375) + b
		End
	End
End

Class EaseInOutBounce Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		If (t < d/2)
			Return Tweening (EASE_IN_BOUNCE, t*2, 0, c, d) * .5 + b
		End
		Return Tweening (EASE_OUT_BOUNCE, t*2-d, 0, c, d) * .5 + c*.5 + b
	End
End



'--------------------------------------------------------------------------
' * Elastic
'--------------------------------------------------------------------------
Class EaseInElastic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Local s:Float
		If (t = 0)
			Return b
		End
		t /= d
		If (t = 1)
			Return b+c
		End
		
		If (Not Power)
			Power = d * .3
		End
		If (Not Amplitude) Or Amplitude < Abs(c)
			Amplitude = c 
			s = Power/4
		Else
			s = Power/(2*PI) * ASin(c/Amplitude)
		End
		t-=1
		Return -(Amplitude*Pow(2,10*(t)) * Sin((t*d-s)*(2*PI)/Power)) + b
	End
End

Class EaseOutElastic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Local s:Float
		If (t = 0)
			Return b
		End
		t /= d
		If (t = 1)
			Return b+c
		End
		
		If (Not Power)
			Power = d * .3
		End
		If (Not Amplitude) Or Amplitude < Abs(c)
			Amplitude = c 
			s = Power/4
		Else
			s = Power/(2*PI) * ASin(c/Amplitude)
		End
		Return (Amplitude*Pow(2,-10*t) * Sin((t*d-s)*(2*PI)/Power)+c+b)
	End
End

Class EaseInOutElastic Implements Tweener
	Method Do:Float (t:Float, b:Float, c:Float, d:Float)
		Local s:Float
		If (t = 0)
			Return b
		End
		t /= d / 2
		If (t = 2)
			Return b+c
		End
		
		If (Not Power)
			Power = d * .3 * 1.5
		End
		If (Not Amplitude) Or Amplitude < Abs(c)
			Amplitude = c 
			s = Power/4
		Else
			s = Power/(2*PI) * ASin(c/Amplitude)
		End
		
		If (t < 1)
			t -= 1
			Return -0.5*(Amplitude*Pow(2,10*(t)) * Sin((t*d-s)*(2*PI)/Power)) + b
		End
		
		t -= 1
		Return (Amplitude*Pow(2,-10*t) * Sin((t*d-s)*(2*PI)/Power)*0.5 +c+b)
	End
End




Global TweenFunc:Tweener[31]

Global Bounce:Float = 1.70158
Global Power:Float = 1
Global Amplitude:Float = 1

Global initialized:Bool = False


