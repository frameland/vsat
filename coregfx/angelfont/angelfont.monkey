'Angelfont tryouts -- Unofficial AngelFont fixes and more.
'For more information, visit here:  http://github.com/[url]

#TEXT_FILES+="*.xml|*.fnt"

Strict

Private
Import mojo
Import char
Import kernpair
Import vsat.foundation.xml

Public
Class AngelFont

	Private
	Global _list:StringMap<AngelFont> = New StringMap<AngelFont>
	
	Field image:Image[] = New Image[1]	
'	Field blockSize:Int
	Field chars:Char[256]
	
'	Field kernPairs:StringMap<KernPair> = New StringMap<KernPair>
	Field kernPairs:IntMap<IntMap<KernPair>> = New IntMap<IntMap<KernPair>>
	Global firstKp:IntMap<KernPair>
	Global secondKp:KernPair
	
'	Field section:String
	Field iniText:String

	Field xOffset:Int
	Field yOffset:Int
	
	Field prevMouseDown:Bool = False

	Public
	Const ALIGN_LEFT:Int = 0
	Const ALIGN_CENTER:Int = 1
	Const ALIGN_RIGHT:Int = 2
	Const ALIGN_TOP:Int = 3
	
	Global err:String
	
	Field name:String
	Field useKerning:Bool = True

	Field lineGap:Int = 5
	Field height:Int = 0
	Field heightOffset:Int = 9999
	Field scrollY:Int = 0
	
	Field italicSkew:Float = 0.25
	
	Method New(url:String="")
		If url <> ""
			Self.LoadPlain(url)  'Used to be LoadFont(url)
			Self.name = url
			_list.Insert(url,Self)
		Endif
	End Method
	
	Method GetChars:Char[]()
		Return chars
	End

	'Summary: Loads a .fnt encoded in plaintext.  Faster loading than LoadFontXml() on Android?  Hope so... -nobu	
	Method LoadPlain:Void(url:String)
		
		iniText = LoadString(url + ".fnt")
		Local lines:String[] = iniText.Split(String.FromChar(10))
		Local attribs:String[] 'Placeholder for an individual line's attributes, split up
		Local pageCount:Int  'How many pages does this font contain?
		
		For Local line:String = EachIn lines
		
			line = line.Trim()
			
			If line.StartsWith("info") Then 'general info about the font in this line.
				Continue 'Next line
			ElseIf line.StartsWith("common") Then 'common info here
				Continue 'Next line
			ElseIf line.StartsWith("chars") 'number of chars available.
				Continue 'Next line
			ElseIf line.StartsWith("char ") Then 'Char info here. Parse.				
				'Char proto.
				Local id:Int, x:Int, y:Int, w:Int, h:Int, xOffset:Int, yOffset:Int, xAdvance:Int, page:Int
				attribs = line.Split(" ") 'Get each attrib in this line.
				
				For Local i:Int = 0 Until attribs.Length  'Split up the attribs
					attribs[i].Trim()
					If attribs[i] = "" Then 'Residual .Split() cruft; Escape early
						Continue 'Next attrib
					ElseIf attribs[i].StartsWith("id=")
						id = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("x=")
						x = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("y=")
						y = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("width=")
						w = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("height=")
						h = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("xoffset=")
						xOffset = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("yoffset=")
						yOffset = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("xadvance=")
						xAdvance = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("page=")
						page = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
						If pageCount < page pageCount = page
					End If
				Next
				'WARNING: This will crash on unicode chars with "index out of range"  -nobu
				chars[id] = New Char(x, y, w, h, xOffset, yOffset, xAdvance, page)
				
				Local ch:= chars[id]
				If ch.height > Self.height Self.height = ch.height  'Beaker's fix for descenders and ascenders
				If ch.yOffset < Self.heightOffset Self.heightOffset = ch.yOffset

			ElseIf line.StartsWith("kernings") 'number of kernings available.
				Continue 'Next line			
			ElseIf line.StartsWith("kerning ")  'Kern pair info.  Parse.
  				'KernPair proto.
  				Local first:Int, second:Int, amount:Int 
				attribs = line.Split(" ") 'Get each attrib in this line.
				
				For Local i:Int = 0 Until attribs.Length  'Split up the attribs
					attribs[i].Trim()
					If attribs[i] = "" Then 'Residual .Split() cruft; Escape early
						Continue 'Next attrib
					ElseIf attribs[i].StartsWith("first=")
						first = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("second=")
						second = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					ElseIf attribs[i].StartsWith("amount=")
						amount = int(attribs[i][attribs[i].FindLast("=") + 1 ..])
					End If
				Next

				'Start adding what we know based on the attribs we got.
				firstKp = kernPairs.Get(first)
				If firstKp = Null Then 'nothing here. Start building the prototype.
					kernPairs.Add(first, New IntMap<KernPair>)
					firstKp = kernPairs.Get(first)  'Switch to the second char of the pair to add the rest.
				End				
				'Add the rest of the prototype.
				firstKp.Add(second, New KernPair(first, second, amount))
			End If
			
		Next

		'Load the images hungnlfn
		'note:  FIXME,  read from the metadata instead of looking for the file manually.  Set pagecount based on metadata later, too..
		For Local page:= 0 To pageCount
			If image.Length < page+1 image = image.Resize(page+1)
			image[page] = LoadImage(url + "_" + page + ".png")
		End

	End Method

	'Summary:  Loads a font using xml.monkey instead of config.monkey...... -nobu	
	Method LoadFromXml:Void(url:String)
		
		iniText = LoadString(url + ".fnt")
		Local error:= New XMLError

'		Local lines:String[] = iniText.Split(String.FromChar(10))
'		Local firstLine:String = lines[0]
''		Print "lines count="+lines.Length
'		If firstLine.Contains("<?xml")
'			Local lineList:List<String> = New List<String>(lines)
'			lineList.RemoveFirst()
'			lines = lineList.ToArray()
'			iniText = "~n".Join(lines)
'		End	
'		
		
		Local pageCount:Int = 0
		
		Local config:= ParseXML(iniText, error)
		If config = Null and error.error
		        'error
		        Print error.ToString()
		Else
			Local nodes:= config.GetChildrenAtPath("chars/char")
			For Local node:XMLNode = EachIn nodes			
				Local id:Int = Int(node.GetAttribute("id"))
				Local page:Int = Int(node.GetAttribute("page"))
				If pageCount < page pageCount = page
				chars[id] = New Char(Int(node.GetAttribute("x")), Int(node.GetAttribute("y")), Int(node.GetAttribute("width")), Int(node.GetAttribute("height")),  Int(node.GetAttribute("xoffset")),  Int(node.GetAttribute("yoffset")),  Int(node.GetAttribute("xadvance")), page)
				Local ch := chars[id]
				If ch.height > Self.height Self.height = ch.height
				If ch.yOffset < Self.heightOffset Self.heightOffset = ch.yOffset
			Next
			
			nodes = config.GetChildrenAtPath("kernings/kerning")
			For Local node:XMLNode = EachIn nodes
				'If node.name <> "kerning" Then Continue
				Local first:Int = Int(node.GetAttribute("first")) '* 10000
				firstKp = kernPairs.Get(first)
				If firstKp = Null
					kernPairs.Add(first, New IntMap<KernPair>)
					firstKp = kernPairs.Get(first)
				End
				
				Local second:Int = Int(node.GetAttribute("second"))
				
				firstKp.Add(second, New KernPair(first, second, Int(node.GetAttribute("amount"))))
			End
			
			'note:  FIXME,  read from the metadata instead of looking for the file manually.  Set pagecount based on metadata later, too..
			If pageCount = 0
				image[0] = LoadImage(url+".png")
				If image[0] = Null image[0] = LoadImage(url+"_0.png")
			Else
				For Local page:= 0 To pageCount
					If image.Length < page+1 image = image.Resize(page+1)
					image[page] = LoadImage(url+"_"+page+".png")
				End
			End					
		End		
	End
	
	
	Method DrawItalic:Void(txt$,x#,y#)
		Local th#=TextHeight(txt)
		
		PushMatrix
			Transform (1,0,-italicSkew,1, x+th*italicSkew,y)
			DrawText txt,0,0
		PopMatrix		
	End 
	
	Method DrawBold:Void(txt:String, x:Int, y:Int)
		DrawText(txt, x,y)
		DrawText(txt, x+1,y)
	End
	
	
	Method DrawText:Void(txt:String, x:Int, y:Int)
		Local prevChar:Int = 0
		xOffset = 0
		yOffset = 0
		
		For Local i:= 0 Until txt.Length
			Local asc:Int = txt[i]
			Local ac:Char = chars[asc]
			Local thisChar:Int = asc
			
			If (thisChar = 10) Or (thisChar = 13) 'new line
				xOffset = 0
				yOffset += (lineGap + height)
				Continue
			End
			
			If ac  <> Null
				If useKerning
					firstKp = kernPairs.Get(prevChar)
					If firstKp <> Null
						secondKp = firstKp.Get(thisChar)
						If secondKp <> Null
							xOffset += secondKp.amount
						End
					Endif
				Endif
				ac.Draw(image[ac.page], Floor(x + xOffset + 0.5), Floor(y + yOffset + 0.5)) 'Use Floor() + 0.5 to round to nearest int
				xOffset += ac.xAdvance
				prevChar = thisChar
			Endif
		Next
	End Method
	
	Method DrawText:Void(txt:String, x:Int, y:Int, horizontalAlign:Int, verticalAlign:Int)
		xOffset = 0
		
		Select horizontalAlign
			Case ALIGN_CENTER
				x = x - (TextWidth(txt)/2)
			Case ALIGN_RIGHT
				x = x - TextWidth(txt)
			Case ALIGN_LEFT
				'Do nothing
		End
		
		Select verticalAlign
			Case ALIGN_CENTER
				y = y - Self.TextHeight(txt)/2
			Case ALIGN_TOP
				'Do nothing
		End
		
		DrawText(txt, x, y)
	End Method

	Method DrawHTML:Void(txt:String, x:Int, y:Int)
'		Local prevChar:String = ""
		Local prevChar:Int = 0
		xOffset = 0
		Local italic:Bool = False
		Local bold:Bool = False
		Local th#=TextHeight(txt)
		
		For Local i:= 0 Until txt.Length
			'err += txt[i..i+1]
			
			While txt[i..i+1] = "<"
				Select txt[i+1..i+3]
					Case "i>"
						italic = True
						i += 3
					Case "b>"
						bold = True
						i += 3
					Default
						Select txt[i+1..i+4]
							Case "/i>"
								italic = False
								i += 4
							Case "/b>"
								bold = False
								i += 4
							Default
								i += 1
						End
				End
				If i >= txt.Length
					Return
				End
			Wend
			Local asc:Int = txt[i]
			Local ac:Char = chars[asc]
'			Local thisChar:String = String.FromChar(asc)
			Local thisChar:Int = asc
			If ac  <> Null
				If useKerning
					firstKp = kernPairs.Get(prevChar)
					If firstKp <> Null
						secondKp = firstKp.Get(thisChar)
						If secondKp <> Null
							xOffset += secondKp.amount
'							Print prevChar+","+thisChar+"  "+String.FromChar(prevChar)+","+String.FromChar(thisChar)
						End							
					Endif
				Endif
				If italic = False
					ac.Draw(image[ac.page], x+xOffset,y)
					If bold
						ac.Draw(image[ac.page], x+xOffset+1,y)
					End
				Else
					PushMatrix
						Transform 1,0,-italicSkew,1, (x+xOffset)+th*italicSkew,y
						ac.Draw(image[ac.page], 0,0)
						If bold
							ac.Draw(image[ac.page], 1,0)
						Endif					
					PopMatrix		
				End	
				xOffset += ac.xAdvance
				prevChar = thisChar
			Endif
		Next
	End Method
	
	Method DrawHTML:Void(txt:String, x:Int, y:Int, align:Int)
		xOffset = 0
		Select align
			Case ALIGN_CENTER
				DrawHTML(txt,x-(TextWidth(StripHTML(txt))/2),y)
			Case ALIGN_RIGHT
				DrawHTML(txt,x-TextWidth(StripHTML(txt)),y)
			Case ALIGN_LEFT
				DrawHTML(txt,x,y)
		End Select
	End Method
	
	Function StripHTML:String(txt:String)
		Local plainText:String = txt.Replace("</","<")
		plainText = plainText.Replace("<b>","")
		Return plainText.Replace("<i>","")
	End

	Method TextWidth:Int(txt:String)
		Local prevChar:Int = 0
		Local width:Int = 0
		Local lineRecord:Int = 0
		
		For Local i:= 0 Until txt.Length
			Local asc:Int = txt[i]
			Local ac:Char = chars[asc]
			Local thisChar:Int = asc
			
			If (thisChar = 10) Or (thisChar = 13) 'new line
				If width > lineRecord
					lineRecord = width
				End
				width = 0
				Continue
			End
			
			If ac <> Null
				If useKerning
					Local firstKp:= kernPairs.Get(prevChar)
					If firstKp <> Null
						Local secondKp:= firstKp.Get(thisChar)
						If secondKp <> Null
							xOffset += secondKp.amount
						End							
					Endif
				Endif
				width += ac.xAdvance
				prevChar = thisChar
			Endif
		Next
		
		If lineRecord
			Return lineRecord
		End
		Return width
	End Method
	
	Method TextHeight:Int(txt:String)
		Local h:Int = 0
		Local hasNewline:Bool = False
		
		For Local i:= 0 Until txt.Length
			Local asc:Int = txt[i]
			Local ac:Char = chars[asc]
			If (asc = 10) Or (asc = 13) 'new line
				h += lineGap + height
				hasNewline = True
				Continue
			End
			If ac.height+ac.yOffset > h h = ac.height+ac.yOffset
		Next
		If hasNewline
			h -= lineGap
		End
		Return h
	End

End
