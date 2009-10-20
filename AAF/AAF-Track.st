Dictionary subclass: #AAFDictionary
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Track'!

!AAFDictionary methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 03:13'!
at: index
	"Make the dictionary behave sane by default. In a dynamic language I surely dont want an out-of-boundaries access to throw up a fatal error."
	^(super at: index ifAbsent: nil).! !


Object subclass: #AAFTrackAnalyzer
	instanceVariableNames: 'trackFunctions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Track'!

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 02:08'!
findCounterparts
	"trackPoints is a collection of y_i: (x_i to x_i+1)* elements, that is, pairs of horizontal trackPoints for each vertical point."

	| fnLoop |
	fnLoop := (1 to: (trackFunctions size)).
	
	(fnLoop)
		do: [:fnIndex || fn |
			
			fn := trackFunctions at: fnIndex.
			
			(0 to: ((fn size) - 1))
				do: [:fnArg || fnVal |
					
					fnVal := fn at: fnArg.
					(nil ~= fnVal)
						ifTrue: [
							Transcript show: ((fn at: fnArg) @ fnArg);
							           cr.
						].
				].
		].! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 12:35'!
findRacingLine! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/7/2009 08:54'!
findTrackPoints: trackFileName
	^(self findTrackPoints: trackFileName writeToForm: nil)
! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 12:35'!
findTrackPoints: trackFileName writeToForm: resultBitmap
	| track xLoop yLoop onTrack xOffset trackExtent resultBlt color lineBitmap haveToCreateBitmap |
	
	track := Form fromBMPFileNamed: trackFileName.
	trackExtent := ((track width) @ (track height)).
	
	"Basically fill up the dictionaries with nils for every height value."
	self setupTrackFunctions: (track height).
	
	haveToCreateBitmap := false.
	(resultBitmap isKindOf: Form)
		ifTrue: [haveToCreateBitmap := true].
	
	(haveToCreateBitmap)
		ifTrue: [
			resultBitmap setExtent: trackExtent depth: (track depth).
			
			resultBlt := (BitBlt destForm: resultBitmap  
			                     sourceForm: nil
			                     halftoneForm: nil
			                     combinationRule: Form over
			                     destOrigin: 0@0
			                     sourceOrigin: 0@0
			                     extent: trackExtent
			                     clipRect: (0@0 extent: trackExtent)).
		].

	"The first 15 pixels (0-14) are used to encode track information, so we skip them."
	xOffset := 15. 
	
	"Storing the loop conditions explicitly speeds up loop iteration in Squeak. Yup, sad."
	yLoop :=	(0 to: ((track height) - 1)).
	xLoop := (xOffset to: ((track width) - 1)).
	
	(yLoop)
		do: [:yIndex || lBorder rBorderMaybe rBorder functionIndex |
					
			lBorder := -1.
			rBorderMaybe := -1.
			rBorder := -1.
			"Remember to which function we have to add the next interesting value."
			functionIndex := 1.
			
			onTrack := false.

			(haveToCreateBitmap)
				ifTrue: [
					"Using a new lineBitmap for every yIndex is quite inefficient. We could just draw directly on one form, if that wouldn't create runtime errors. Forms and BitBlits are notoriously bad tested in Squeak. Also, it makes some stuff easier (proper cleanup for each yIndex, at least)."
					lineBitmap := Form new.
					lineBitmap setExtent: ((track width) @ 1) depth: (track depth).
					resultBlt sourceForm: lineBitmap.
				].

			(xLoop)
				do: [:xIndex|
					 
					color := (track colorAt: (xIndex @ yIndex)).
					
					((onTrack not) and: [self isWhiteish: color])
						ifTrue: [
							lBorder := xIndex.
							(trackFunctions at: functionIndex) at: yIndex put: lBorder.
							functionIndex := functionIndex + 1.
							onTrack := true.
						].
					
					(onTrack and: [self isWhiteish: color])
						ifTrue: [
							rBorderMaybe := xIndex.
						].
					
					(onTrack and: [self isGreenish: color])
						ifTrue: [
							rBorder := rBorderMaybe.
							(trackFunctions at: functionIndex) at: yIndex put: rBorder.
							functionIndex := functionIndex + 1.
							onTrack := false.
							
							(haveToCreateBitmap)
								ifTrue: [

									"lineBitmap fillGray."
									lineBitmap colorAt: (lBorder @ 0) put: (Color red);
									           colorAt: (rBorder @ 0) put: (Color red).
									           "colorAt: ((lBorder + ((rBorder - lBorder) * 0.50)) @ 0) put: (Color yellow)."
									
									resultBlt destOrigin: (0 @ yIndex).
									resultBlt copyBits.
								].
							
							lBorder := -1.
							rBorder := -1. 
						].           
				].
		].! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/7/2009 08:52'!
initialize
	super initialize.

	trackFunctions := OrderedCollection new.! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/5/2009 01:26'!
isGreenish: aColor

	^((aColor red > 0.15) and: [(aColor red < 0.25) and:
	  [(aColor green > 0.55) and: [(aColor green < 0.65) and:
	  [(aColor blue > 0.15) and: [(aColor blue < 0.35)]]]]])! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/5/2009 01:13'!
isWhiteish: aColor
	| threshold |
	
	threshold := 0.9.
	
	^((aColor red > threshold) and:
	  [aColor green > threshold] and:
	  [aColor blue > threshold])! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 00:03'!
rotate: aPoint by: angleDeg
	| x y angle tempX |
	
	x := aPoint x.
	y := aPoint y.
	
	angle := angleDeg * ((Float pi)  / 180).
	
	tempX := ((angle cos) * x) + (((angle sin) negated) * y).
	y := ((angle sin) * x) + ((angle cos) * y).
	x := tempX.
	
	^(x @ y)
! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 02:49'!
setupTrackFunctions: argsAmount

	(1 to: (AAFTrackAnalyzer maxBranches * 2))
		do: [:unused | trackFunctions add: (AAFDictionary new)].! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 01:30'!
trackFunctions
	^trackFunctions! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 00:28'!
transform: aPoint rotateBy: angleDeg scaleBy: length
	| x y vecLength scaleBy rotatedBy |
	
	(length = 0) ifTrue: [^false].
	
	rotatedBy := self rotate: aPoint by: angleDeg.

	x := rotatedBy x.
	y := rotatedBy y.

	
	vecLength := (((x raisedTo: 2) + (y raisedTo: 2)) sqrt).
	scaleBy := length / vecLength.

	^((x * scaleBy) @ (y * scaleBy))! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 00:30'!
transform: aPoint rotateBy: angleDeg scaleTo: length
	| x y vecLength scaleBy rotatedBy |
	
	(length = 0) ifTrue: [^false].
	
	rotatedBy := self rotate: aPoint by: angleDeg.

	x := rotatedBy x.
	y := rotatedBy y.

	
	vecLength := (((x raisedTo: 2) + (y raisedTo: 2)) sqrt).
	scaleBy := length / vecLength.

	^((x * scaleBy) @ (y * scaleBy))! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFTrackAnalyzer class
	instanceVariableNames: ''!

!AAFTrackAnalyzer class methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 01:03'!
maxBranches
	^5! !
