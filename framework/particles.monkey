Strict
Import vsat

'--------------------------------------------------------------------------
' * Base
' * Extend ParticleEmitter for your own emitters (see the ones below for examples)
'--------------------------------------------------------------------------
Class ParticleEmitter
	
	Field Particles:Particle[]
	
	'Basics
	Field emissionRate:Int 'particles per second
	Field duration:Float
	Field particleLifeSpan:Float, particleLifeSpanVariance:Float
	Field oneShot:Bool
	Field emitDelay:Float
	Field active:Bool
	
	'Position & Movement
	Field position:Vec2, positionVariance:Vec2
	Field speed:Float, speedVariance:Float
	Field emissionAngle:Float, emissionAngleVariance:Float
	Field gravity:Vec2
	
	'Size
	Field size:Vec2, sizeVariance:Vec2
	Field endSize:Vec2, endSizeVariance:Vec2
	Field scaleUniform:Bool = True
	
	'Rotation
	Field startRotation:Float, startRotationVariance:Float
	Field rotatePerSecond:Float, rotatePerSecondVariance:Float
	Field faceMovementDirection:Bool
	
	'Color
	Field startColor:Color, startColorVariance:Color
	Field endColor:Color, endColorVariance:Color
	Field additiveBlend:Bool
	

'--------------------------------------------------------------------------
' * Init
'--------------------------------------------------------------------------
	Method New()
		position = New Vec2()
		positionVariance = New Vec2()
		size = New Vec2 (1.0, 1.0)
		sizeVariance = New Vec2()
		endSize = New Vec2 (1.0, 1.0)
		endSizeVariance = New Vec2()
		gravity = New Vec2()
		startColor = New Color()
		startColorVariance = New Color(0, 0, 0, 0)
		endColor = New Color()
		endColorVariance = New Color(0, 0, 0, 0)
		duration = -1.0
		particleLifeSpan = 1.0
		emissionRate = 20
	End

	Method InitWithSize:Void(maxParticles:Int)
		Particles = New Particle[maxParticles]
		For Local i:Int = 0 Until maxParticles
			Particles[i] = New Particle
		Next
		Self.maxParticles = maxParticles
	End


'--------------------------------------------------------------------------
' * Particle Management
'--------------------------------------------------------------------------	
	Method InitParticle:Void(particle:Particle)
		'Lifetime
		particle.lifeTime = particleLifeSpan + particleLifeSpanVariance * Rnd(-1, 1)
		
		'Position
		particle.position.x = position.x + positionVariance.x * Rnd(-1, 1)
		particle.position.y = position.y + positionVariance.y * Rnd(-1, 1)
		
		'Direction
		Local newAngle:Float = emissionAngle + emissionAngleVariance * Rnd(-1, 1)
		Local vectorSpeed:Float = speed + speedVariance * Rnd(-1, 1)
		particle.SetDirectionUsingAngle(newAngle, vectorSpeed)
		
		'Size
		particle.size.x = size.x + sizeVariance.x * Rnd(-1, 1)
		particle.size.y = size.y + sizeVariance.y * Rnd(-1, 1)
		Local endX:Float = endSize.x + endSizeVariance.x * Rnd(-1, 1)
		Local endY:Float = endSize.y + endSizeVariance.y * Rnd(-1, 1)
		particle.deltaSize.x = (endX - particle.size.x)/particle.lifeTime
		particle.deltaSize.y = (endY - particle.size.y)/particle.lifeTime
		If scaleUniform
			particle.size.y = particle.size.x
			particle.deltaSize.y = particle.deltaSize.x
		End
		
		'Rotation
		particle.rotation = startRotation + startRotationVariance * Rnd(-1, 1)
	    particle.deltaRotation = rotatePerSecond + rotatePerSecondVariance * Rnd(-1, 1)
		
		'Start Color
		Local r:Float = startColor.Red + startColorVariance.Red * Rnd(-1, 1)
		Local g:Float = startColor.Green + startColorVariance.Green * Rnd(-1, 1)
		Local b:Float = startColor.Blue + startColorVariance.Blue * Rnd(-1, 1)
		Local a:Float = startColor.Alpha + startColorVariance.Alpha * Rnd(-1, 1)
		r = Max(0.0, r)
		g = Max(0.0, g)
		b = Max(0.0, b)
		a = Max(0.0, a)
		r = Min(1.0, r)
		g = Min(1.0, g)
		b = Min(1.0, b)
		a = Min(1.0, a)
		particle.color.Set(r, g, b, a)
		
		'End Color
		Local endR:Float = endColor.Red + endColorVariance.Red * Rnd(-1, 1)
		Local endG:Float = endColor.Green + endColorVariance.Green * Rnd(-1, 1)
		Local endB:Float = endColor.Blue + endColorVariance.Blue * Rnd(-1, 1)
		Local endA:Float = endColor.Alpha + endColorVariance.Alpha * Rnd(-1, 1)
		endR = Max(0.0, endR)
		endG = Max(0.0, endG)
		endB = Max(0.0, endB)
		endA = Max(0.0, endA)
		endR = Min(1.0, endR)
		endG = Min(1.0, endG)
		endB = Min(1.0, endB)
		endA = Min(1.0, endA)
		
		'Delta Color
		particle.deltaColor[0] = (endR - r) / Float (particle.lifeTime)
		particle.deltaColor[1] = (endG - g) / Float (particle.lifeTime)
		particle.deltaColor[2] = (endB - b) / Float (particle.lifeTime)
		particle.deltaColor[3] = (endA - a) / Float (particle.lifeTime)
	End
	
	Method AddParticle:Bool()
		If particleCount >= maxParticles
			Return False
		End
		Local particle:Particle = Particles[particleCount]
		InitParticle(particle)
		particleCount += 1
		Return True
	End
	
	Method Start:Void()
		active = True
	End
	
	Method Stop:Void()
		active = False
		elapsedTime = 0.0
		emitCounter = 0
	End
	
	Method StopNow:Void()
		Stop()
		particleCount = 0
	End
	
	Method FastForward:Void(time:Float, withStep:Float)
		Local savedActive:Bool = active
		active = True
		
		Local counter:Float
		While counter < time
			counter += withStep
			Update(withStep)
		End
		
		active = savedActive
	End
	
	Method ActiveParticles:Int() Property
		Return particleCount
	End
	
	
'--------------------------------------------------------------------------
' * Updating
' * Override UpdateParticles(dt) for custom emitter behaviour
'--------------------------------------------------------------------------
	Method Update:Void(dt:Float)
		'Create Particles
		If active And (emissionRate > 0)
			elapsedTime += dt
			If elapsedTime < emitDelay Return
			
			If oneShot
				Local shootNr:Int = Particles.Length
				While (particleCount < shootNr)
					AddParticle()
				Wend
				Stop()
			Else
				Local rate:Float = 1.0/emissionRate
				emitCounter += dt
				While (particleCount < maxParticles And emitCounter > rate)
					AddParticle()
					emitCounter -= rate
				Wend
				If (duration <> -1) And (elapsedTime > duration + emitDelay)
					Stop()
				End
			End
		End
		
		'After creation => update all particles
		UpdateParticles(dt)
	End
	
	Method UpdateParticles:Void(dt:Float)
		Local i:Int = 0
		Local currentParticle:Particle

		While (i < particleCount)
			currentParticle = Particles[i]
			currentParticle.lifeTime -= dt
			
			If currentParticle.lifeTime > 0
				'Position
				currentParticle.position.x += (currentParticle.direction.x + gravity.x) * dt
				currentParticle.position.y += (currentParticle.direction.y + gravity.y) * dt
				
				'Size
				currentParticle.size.x += currentParticle.deltaSize.x * dt
				currentParticle.size.y += currentParticle.deltaSize.y * dt
				
				'Angle
				currentParticle.rotation += currentParticle.deltaRotation * dt

				'Color
				currentParticle.color.Red   += currentParticle.deltaColor[0] * dt
				currentParticle.color.Green += currentParticle.deltaColor[1] * dt
				currentParticle.color.Blue  += currentParticle.deltaColor[2] * dt
				currentParticle.color.Alpha += currentParticle.deltaColor[3] * dt
				
				'Increase Particle Counter
				i += 1
				
			'Particle dies + last particle replaces it's position in the array
			'This way the active particles are always at the beginning of the array
			Else
				If (i <> particleCount-1)
					Local tmp:Particle = Particles[i]
					Particles[i] = Particles[particleCount-1]
					Particles[particleCount-1] = tmp
				End
				particleCount -= 1
			End
		End
	End
	

'--------------------------------------------------------------------------
' * Render
' * Override Draw for custom shape/image
' * Override Render for a completely different rendering process
'--------------------------------------------------------------------------	
	Method Render:Void()
		If additiveBlend
			SetBlend (AdditiveBlend)
		Else
			SetBlend (AlphaBlend)
		End
		
		Local i:Int
		Local currentParticle:Particle
		For i = 0 Until particleCount
			PushMatrix()
				currentParticle = Particles[i]
				TranslateV(currentParticle.position)
				If currentParticle.rotation
					Rotate(currentParticle.rotation)
				End
				currentParticle.color.UseWithoutAlpha()
				SetAlpha(currentParticle.color.Alpha)
				Self.Draw(currentParticle)
			PopMatrix()
		Next
		
		ResetBlend()
	End
	
	Method Draw:Void(p:Particle)
		DrawRect(-p.size.x/2, -p.size.y/2, p.size.x, p.size.y)
	End
	
	
	Private
	Field emitCounter:Float
	Field elapsedTime:Float
	Field maxParticles:Int
	Field particleCount:Int
	
End

Class Particle
	
	Field lifeTime:Float
	
	Field position:Vec2
	Field direction:Vec2
	Field speed:Float
	Field size:Vec2
	Field deltaSize:Vec2
	
	Field angle:Float
	Field rotation:Float
	Field deltaRotation:Float
	
	Field color:Color
	Field deltaColor:Float[]
	
	Method New()
		position = New Vec2()
		direction = New Vec2()
		size = New Vec2()
		deltaSize = New Vec2()
		color = New Color()
		deltaColor = New Float[4]
	End
	
	Method SetDirectionUsingAngle:Void(angle:Float, speed:Float = 1.0)
		direction.Set(Cos(angle), Sin(angle))
		direction.Mul(speed)
		Self.angle = angle
		Self.speed = speed
	End
	
	Method ChangeSpeed:Void(newSpeed:Float)
		Local unit:Vec2 = direction.Copy()
		unit.Normalize()
		unit.Mul(newSpeed)
		direction.Set(unit)
		Self.speed = newSpeed
	End
	
End


'--------------------------------------------------------------------------
' * Sample Particle Emitters
'--------------------------------------------------------------------------
Class SparkEmitter Extends ExplosionEmitter
	
	Method New()
		Local baseUnit:Float = Vsat.ScreenWidth * 0.5
		size.Set(2, 2)
		endSize.Set(0.5, 0.5)
		speed = baseUnit * 0.5
		endColor.Alpha = 0.0
		emissionAngleVariance = 20
		Start()
	End
	
	Method SetEmissionRate:Void(rate:Int)
		baseEmission = rate
		emissionRate = rate
	End
	
	Method SetPosition:Void(x:Float, y:Float)
		Local distance:Float = Abs(lastPosition.y - y)
		If distance < 0.01
			Stop()
		Else
			emissionRate = Min(Int(baseEmission * distance * 0.1), baseEmission * 2)
			Start()
		End
		
		lastPosition.Set(Self.position)
		Self.position.Set(x, y)
	End
	
	Private
	Field lastPosition:Vec2 = New Vec2
	Field baseEmission:Int
	
End

Class ExplosionEmitter Extends ParticleEmitter
	
	Field slowDownSpeed:Float = 0.92
	
	Method Stop:Void()
		For Local i:Int = 0 Until Particles.Length
			Local p:= Particles[i]
			Local newAngle:Float = -emissionAngle + (emissionAngleVariance*2 / Particles.Length * (i+1))
			p.SetDirectionUsingAngle(WrapAngle(newAngle), p.speed)
		Next
		Super.Stop()
	End
	
	Method UpdateParticles:Void(dt:Float)
		Local i:Int = 0
		Local currentParticle:Particle

		While (i < particleCount)
			currentParticle = Particles[i]
			currentParticle.lifeTime -= dt
			
			If currentParticle.lifeTime > 0
				'Position
				currentParticle.position.x += (currentParticle.direction.x + gravity.x) * dt
				currentParticle.position.y += (currentParticle.direction.y + gravity.y) * dt
				
				'Speed
				currentParticle.ChangeSpeed(currentParticle.speed * slowDownSpeed)
				
				'Size
				currentParticle.size.x += currentParticle.deltaSize.x * dt
				currentParticle.size.y += currentParticle.deltaSize.y * dt
				
				'Angle
				currentParticle.rotation += currentParticle.deltaRotation * dt

				'Color
				currentParticle.color.Red   += currentParticle.deltaColor[0] * dt
				currentParticle.color.Green += currentParticle.deltaColor[1] * dt
				currentParticle.color.Blue  += currentParticle.deltaColor[2] * dt
				currentParticle.color.Alpha += currentParticle.deltaColor[3] * dt
				
				'Increase Particle Counter
				i += 1
				
			'Particle dies + last particle replaces it's position in the array
			'This way the active particles are always at the beginning of the array
			Else
				If (i <> particleCount-1)
					Local tmp:Particle = Particles[i]
					Particles[i] = Particles[particleCount-1]
					Particles[particleCount-1] = tmp
				End
				particleCount -= 1
			End
		End
	End
	
End

Class CircleParticleEmitter Extends ParticleEmitter
	
	Method Draw:Void(p:Particle)
		DrawCircle(0, 0, p.size.x/2)
	End
	
End


