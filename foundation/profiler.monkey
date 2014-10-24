Strict

Import mojo.app

#Rem
---------------------------------------------------------------------------
	Use to messure performance in Millisecs()
	Just enclose the part you want to messure with the following code:
		Profiler.Start()
		YourCode()
		Profiler.Stop()
---------------------------------------------------------------------------
#End
Class Profiler
	
	Private
	Global start:Int
	Global calls:Int
	Global average:Float
	
	
	Public
	Function Start:Void()
		start = Millisecs()
	End
	
	Function Stop:Int(cycles:Int = 1)
		Local result:Int = Millisecs() - start
		average += result
		calls += 1
		If calls >= cycles
			If cycles = 1
				Print "Elapsed Time: " + average
			Else
				Print "Elapsed Time(" + cycles + " cycles): " + (average / calls)
			End
			Local returnCalls:Int = calls
			calls = 0
			average = 0.0
			Return returnCalls
		End
		Return -1
	End
	
End