#Rem
------------------------------------------------------------------------------
	Init with SetLanguage, this will load an xml file from the
	language directory. This defaults to "lang" but can be set
	with SetLanguageDirectory
	
	Format:
	<words>
		<word>
			<key>Hello</key>
			<value>Hallo</value>
		</word>
		<word>
			<key>Germany</key>
			<value>Deutschland</value>
		</word>
	</words>
	
	TRACK_UNLOCALIZED_WORDS can be set to true to save Words that
	are requested but can't be found
	Retrieve them calling Localize.UnlocalizedWords()
------------------------------------------------------------------------------
#End

Strict
Import xml
Import brl.filepath
Import mojo.app
Import error

#TRACK_UNLOCALIZED_WORDS = False


Class Localize
	
	Function SetLanguage:Void(language:String)
		Local path:String = CurrentDirectory + "/" + language + ".xml"
		Local langText:String = LoadString(path)
		If Not langText
			Throw New FileNotFoundException(path)
		End
		
		Local error:= New XMLError
		Local root:= ParseXML(langText, error)
		If root = Null And error.error
			Throw New Exception("Localize Error: trying to load language " + language + ".~n" + error.ToString())
		End
		
		Words = New StringMap<String>
		If root.valid = False
			Throw New Exception("Localize Error for language " + language + ". Your xml file must have a root node called words.")
		End
		Local children:= root.GetChildren()
		For Local node:= EachIn children
			If node.name = "word"
				Local keyNode:= node.GetChild("key")
				Local valueNode:= node.GetChild("value")
				If (keyNode.valid = False) Or (valueNode.valid = False)
					Throw New Exception("Localize Error for language " + language + ". Your word element on line " + node.line + " does not have a valid key/value pair.")
				End
				SetValue(keyNode.value, valueNode.value)
			End
		Next
		
		#If TRACK_UNLOCALIZED_WORDS
			Unlocalized = New StringStack
		#End
		
		CurrentLanguage = language
	End
	
	'Return value found for key, or key when not found
	Function GetValue:String(key:String)
		Local value:String = Words.Get(key)
		If value
			Return value
		End
		#If TRACK_UNLOCALIZED_WORDS
			If Unlocalized.Contains(key) = False
				Unlocalized.Push(key)
			End
		#End
		Return key
	End
	
	Function SetValue:Void(key:String, value:String)
		If Words = Null
			Throw New Exception("Language has not been set.")
		End
		Words.Set(key, value)
	End
	
	Function GetCurrentLanguage:String()
		Return CurrentLanguage
	End
	
	Function SetLanguageDirectory:Void(path:String)
		CurrentDirectory = ExtractDir(path)
	End
	
	Function GetLanguageDirectory:String()
		Return CurrentDirectory
	End
	
	Function UnlocalizedWords:String()
		#If TRACK_UNLOCALIZED_WORDS
			Return Unlocalized.Join("~n")
		#Else
			Return "Tracking of unlocalized words is turned off. To turn it on set the preprocessor #TRACK_UNLOCALIZED_WORDS = True"
		#End
	End

	
	Private
	Global DefaultLanguage:String = "en"
	Global CurrentLanguage:String = "en"
	Global DefaultDirectory:String = "lang"
	Global CurrentDirectory:String = "lang"
	
	Global Words:StringMap<String>
	Global Unlocalized:StringStack
	
End
