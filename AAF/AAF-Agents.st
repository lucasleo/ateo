Object subclass: #AAFAgent
	instanceVariableNames: 'inactiveSelection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 02:08'!
compute: aSamState
	self subclassResponsibility.! !

!AAFAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 22:07'!
initialize
	super initialize.

	active := true.
	activeSelection := nil.
	inputMwb1 := 0.5.
	inputMwb2 := 0.5.! !


!AAFAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 17:41'!
inactiveSelection: selection
	"For the agent this is a read-only property, that is, the agent is not allowed to change this list (or rather the agent could do it, but no one will listen ...)."
	inactiveSelection := selection.! !

!AAFAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 17:19'!
isInactive: aSamState
	(nil = inactiveSelection)
		ifTrue: [^false]. "Agents are active for all sections, by default"
	
	^(inactiveSelection at: (aSamState trackingState currentSection))! !


!AAFAgent methodsFor: 'signals' stamp: 'HM 7/26/2009 21:46'!
agentPropertyChanged
	self changed: #agentPropertyChanged.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFAgent class
	instanceVariableNames: ''!

!AAFAgent class methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 23:55'!
virtualPos: trackingState
	"Return where the car would be, given the current speed. Does not regard x movement."
	^(trackingState carPos x) @ ((trackingState distanceTotal + (trackingState speed)) asInteger)! !


AAFAgent subclass: #AAFBreaksAgent
	instanceVariableNames: 'lastKnownVirtualPos distance lerpedColor lookAheadScaling dotSize pointerVisible'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFBreaksAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 17:39'!
compute: aSamState
	| virtualPos lerpedPos xDiff yDiff dot color |

	(self isInactive: aSamState)
		ifTrue: [^aSamState].
	
	"speed := aSamState trackingState speed.
	distance := distance + (speed asInteger).
	virtualPos := (aSamState trackingState carPos x) @ (distance)."
	virtualPos := AAFAgent virtualPos: (aSamState trackingState).
	yDiff := (virtualPos y) - (lastKnownVirtualPos y).
	xDiff := (virtualPos x) - (lastKnownVirtualPos x).
	yDiff := yDiff * lookAheadScaling.
	xDiff := xDiff * lookAheadScaling.
	
	"TODO: replace magic ysize of 700 with something sane."
	lerpedPos := ((virtualPos x) + xDiff) @ (700 - yDiff).
	lastKnownVirtualPos := virtualPos copy.

	color := Display colorAt: lerpedPos.
	(0.5 <= color green and: [0.5 > color red])
		ifTrue: [
			dotSize := dotSize + (1@1).
		] ifFalse: [
			dotSize := (3@3).
		].

	(self isPointerVisible)
		ifTrue: [
			dot := Form extent: dotSize depth: 8.
			dot fillColor: Color red;
			    displayAt: lerpedPos.
		].
	
	((3@3) < dotSize)
		ifTrue: [
			| joystick slowDown |
			
			slowDown := (dotSize y).
			
			joystick := (aSamState joystickXY: 1).			
			joystick := (joystick x) @  (joystick y / slowDown).
			aSamState joystickXY: 1 put: joystick.

			joystick := (aSamState joystickXY: 2).			
			joystick := (joystick x) @  (joystick y / slowDown).
			aSamState joystickXY: 2 put: joystick.
		].
	
	^aSamState
	
	! !

!AAFBreaksAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/15/2009 21:57'!
computeAngle: aPoint
	| v1 v2 aSamState direction toDeg angle |

	v1 := (aSamState joystickXY: 1).
	
	v2 := (0@-1).
	
	direction := 1.
	(0 > (v1 x))
		ifTrue: [direction := -1.].
	
	toDeg := (180 / (Float pi)).
	
	angle := 0.
	(0@0 ~= v1 and: [-1 ~= v1 x])
		ifTrue: [
			angle := ((((v1 x) * (v2 x)) + ((v1 y) * (v2 y))) / ((((v1 x raisedTo: 2) + (v1 y raisedTo: 2)) sqrt) * (((v2 x raisedTo: 2) + (v2 y raisedTo: 2)) sqrt))) arcCos.
		].

	^angle! !

!AAFBreaksAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 02:56'!
initialize
	super initialize.

	lastKnownVirtualPos := 0@0.
	distance := 0.
	lookAheadScaling := 3.
	dotSize := 3@3.
	pointerVisible := false.! !


!AAFBreaksAgent methodsFor: 'properties' stamp: 'HM 7/22/2009 02:55'!
isPointerVisible
	^pointerVisible! !

!AAFBreaksAgent methodsFor: 'properties' stamp: 'HM 7/26/2009 21:44'!
pointerVisible: aBoolean
	(aBoolean == (pointerVisible not))
		ifTrue: [
			pointerVisible := aBoolean.
			self agentPropertyChanged.
		].! !


AAFAgent subclass: #AAFDummyAgent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFDummyAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 17:39'!
compute: aSamState
	(self isInactive: aSamState)
		ifTrue: [^aSamState].

	aSamState joystickXY: 1 put: ((aSamState joystickXY: 1) + (1@1)).
	^aSamState! !


AAFAgent subclass: #AAFIdleAgent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFIdleAgent methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 13:51'!
compute: aSamState
	^aSamState! !


AAFAgent subclass: #AAFInputDistributionAgent
	instanceVariableNames: 'inputMwb1 inputMwb2'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFInputDistributionAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:03'!
compute: aSamState
	(self isInactive: aSamState)
		ifTrue: [^aSamState].
	
	"This will only work if at the same time we can tell SAM to not scale the inputMwbs itself. If not, we need a inputDistribution value in the SamState anyway, and we just update that instead, without doing the input scaling here."
	aSamState joystickXY: 1 put: (inputMwb1 * (aSamState joystickXY: 1)).
	aSamState joystickXY: 2 put: (inputMwb1 * (aSamState joystickXY: 2)).
	
	^aSamState! !

!AAFInputDistributionAgent methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 17:16'!
initialize
	super initialize.

	inputMwb1 := 0.5.
	inputMwb2 := 0.5.! !


!AAFInputDistributionAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 18:04'!
inputDistribution
	^(Array with: inputMwb1
	        with: inputMwb2)! !

!AAFInputDistributionAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 17:16'!
inputDistribution: mwb1 with: mwb2
	(mwb1 ~= inputMwb1 and: [mwb2 ~= inputMwb2]
	                   and: [(mwb1 + mwb2) asInteger == 1]
		                and: [0 <= mwb1]
	                   and: [0 <= mwb2])
		ifTrue: [
			inputMwb1 := mwb1.
			inputMwb2 := mwb2.

			self agentPropertyChanged.
		].! !


AAFAgent subclass: #AAFInversionAgent
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFInversionAgent methodsFor: 'as yet unclassified' stamp: 'HM 9/14/2009 20:54'!
compute: aSamState
	(self isInactive: aSamState)
		ifTrue: [^aSamState].
	
	"Manually unrolling the 1 to: 2 loop because the loop variable counts as mem allocation for the GC. Sad, I know ..."
	aSamState joystickXAxisAt: 1
	          put: ((aSamState joystickXAxisAt: 1) negated).
	aSamState joystickYAxisAt: 1
	          put: ((aSamState joystickYAxisAt: 1) negated).
	
	aSamState joystickXAxisAt: 2
	          put: ((aSamState joystickXAxisAt: 2) negated).
	aSamState joystickYAxisAt: 2
	          put: ((aSamState joystickYAxisAt: 2) negated).
	
	^aSamState
		
! !


AAFAgent subclass: #AAFSteeringAgent
	instanceVariableNames: 'lookAhead threshold adjustmentRate adjustment adjustmentLimit'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Agents'!

!AAFSteeringAgent methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 22:05'!
adjustSteeringFor: joystickXY to: xValue given: carPosX
	((xValue - carPosX) > threshold) "too far left"
		ifTrue: [
			(adjustmentLimit > adjustment)
				ifTrue: [
					adjustment := adjustment + adjustmentRate.
					^((joystickXY x + adjustment) @ joystickXY y)
				].
		].
					
	((carPosX - xValue) > threshold) "too far right"
		ifTrue: [
			(adjustmentLimit > adjustment)
				ifTrue: [
					adjustment := adjustment + adjustmentRate.
					^((joystickXY x - adjustment) @ joystickXY y)
				].
		].

	adjustment := adjustmentRate.
	^joystickXY
! !

!AAFSteeringAgent methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 00:20'!
compute: aSamState
	| dist xValues |
	
	(self isInactive: aSamState)
		ifTrue: [^aSamState].
	
	"Something doesn't match heare, lookAhead should be 0 and therefore, match the car position."	
	dist := (aSamState trackingState distanceTotal) + lookAhead.
	xValues := aSamState trackingState racingLineAt: dist.
	
	"We currently only check against the first value in the xValues collection. If done correctly, we should attempt to steer to whatever x value is nearest. But let's see the performance of this first."
	(nil ~= xValues and: [xValues isEmpty not])
		ifTrue: [| carPosX |
			
			"Again, no loop since that saves a variable, lol ..."
			carPosX := (aSamState trackingState carPos x).
			aSamState joystickXY: 1
			          put: (self adjustSteeringFor: (aSamState joystickXY: 1)
			                     to: (xValues at: 1)
			                     given: carPosX).

			aSamState joystickXY: 2
			          put: (self adjustSteeringFor: (aSamState joystickXY: 2)
			                     to: (xValues at: 1)
			                     given: carPosX).
		].
	
	^aSamState! !

!AAFSteeringAgent methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 22:03'!
initialize
	super initialize.

	"Just a guessed value that seems to fit with the on-screen display though."
	lookAhead := -255.
	
	"The threshold smoothens out the manipulation. That is, we start once we are outside and stop once we are inside again."
	threshold := 5.
	
	"Now this one needs more planning. A too high value and the SteeringAgent will just drive along the racinglines, with no mistakes. BUT, if we increase the adjustmentRate only during a manipulation run it would simulate some kind of physics and considerably nerf the effect of this agent (which sadly is preferable ...)"
	adjustmentRate := 128.
	adjustment := adjustmentRate copy.
	adjustmentLimit := 1024.
	
! !


!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 21:41'!
adjustmentRate
	^adjustmentRate! !

!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 21:43'!
adjustmentRate: aNumber
	"Hum, I have no idea what the boundaries are ... [1,1024]? [-1024,1024]?"
	(aNumber ~= adjustmentRate)
		ifTrue: [
			adjustmentRate := aNumber.
			self agentPropertyChanged.
		].! !

!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 8/2/2009 00:30'!
lookAhead
	^lookAhead! !

!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 8/2/2009 00:30'!
lookAhead: aNumber
	(aNumber ~= lookAhead)
		ifTrue: [
			lookAhead := aNumber.
			self agentPropertyChanged.
		].! !

!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 21:42'!
threshold
	^threshold! !

!AAFSteeringAgent methodsFor: 'properties' stamp: 'HM 7/31/2009 21:43'!
threshold: aNumber
	(aNumber ~= threshold)
		ifTrue: [
			threshold := aNumber.
			self agentPropertyChanged.
		].! !
