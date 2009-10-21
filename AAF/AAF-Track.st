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
	instanceVariableNames: 'trackFunctions trackImage'
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

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/22/2009 01:53'!
findRacingLine
	"Imagine you rotated the track at 90 degree clockwise. It will turn into a nice set of functions."
	| lastPoint leftBorder trackWidth trackHalfWidth |
	
	trackWidth := 62. "if I knew a safe way to compute this ..."
	trackHalfWidth := trackWidth * 0.5.
	lastPoint := (0 @ 0).
	leftBorder := trackFunctions at: 1.
	
	(1 to: (leftBorder size))
		do: [:yIndex || xIndex currentPoint transformed |
			
			xIndex := leftBorder at: yIndex.
			
			(nil ~= xIndex)
				ifTrue: [
					currentPoint := (xIndex @ yIndex).
					transformed := self transform: (currentPoint - lastPoint)
					                    rotateBy: 270
					                    scaleTo: trackHalfWidth.
					trackImage surface colorAt: (currentPoint + transformed)
					                   put: (Color green).
				] ifFalse: [
					currentPoint := (0 @ yIndex).
				].
			
			lastPoint := currentPoint. 
		].! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/22/2009 01:25'!
findTrackPoints: trackFileName writeTo: resultFileName

	| xLoop yLoop onTrack xOffset color lineBitmap |

	

	trackImage surfaceFromFile: trackFileName.

	

	"Basically fill up the dictionaries with nils for every height value."

	self setupTrackFunctions: (trackImage track height).



	"The first 15 pixels (0-14) are traditionally used to encode track information, so we skip them."

	xOffset := 15. 

	

	"Storing the loop conditions explicitly speeds up loop iteration in Squeak. Yup, sad."

	yLoop :=	(0 to: ((trackImage track height) - 1)).

	xLoop := (xOffset to: ((trackImage track width) - 1)).

	

	(yLoop)

		do: [:yIndex || lBorder rBorderMaybe rBorder functionIndex |

					

			lBorder := -1.

			rBorderMaybe := -1.

			rBorder := -1.

			"Remember to which function we have to add the next interesting value."

			functionIndex := 1.

			

			onTrack := false.



			"Using a new lineBitmap for every yIndex is quite inefficient. We could just draw directly on one form, if that wouldn't create runtime errors. Forms and BitBlits are notoriously bad tested in Squeak. Also, it makes some stuff easier (proper cleanup for each yIndex, at least)."

			lineBitmap := trackImage createLineFormFromSurface.



			(xLoop)

				do: [:xIndex|

					 

					color := (trackImage track colorAt: (xIndex @ yIndex)).

					

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

							

							"lineBitmap fillGray."

							lineBitmap colorAt: (lBorder @ 0) put: (Color red);

							           colorAt: (rBorder @ 0) put: (Color red).

							           "colorAt: ((lBorder + ((rBorder - lBorder) * 0.50)) @ 0) put: (Color yellow)."

							trackImage copyBitsOf: lineBitmap origin: (0 @ yIndex).



							lBorder := -1.

							rBorder := -1. 

						].           

				].

		].


	self writeTrackImageTo: resultFileName.! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 16:49'!
initialize

	super initialize.



	trackFunctions := OrderedCollection new.

	trackImage := AAFTrackImage new.! !

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

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 14:38'!
transform: aPoint rotateBy: angleDeg scaleTo: length

	| x y vecLength scaleBy rotatedBy |

	

	(length = 0) ifTrue: [^false].

	

	rotatedBy := self rotate: aPoint by: angleDeg.



	x := rotatedBy x.

	y := rotatedBy y.

	

	vecLength := (((x raisedTo: 2) + (y raisedTo: 2)) sqrt).

	scaleBy := length / vecLength.



	^((x * scaleBy) @ (y * scaleBy))! !

!AAFTrackAnalyzer methodsFor: 'as yet unclassified' stamp: 'HM 10/22/2009 01:10'!
writeTrackImageTo: fileName
	trackImage writeToFile: fileName.! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFTrackAnalyzer class
	instanceVariableNames: ''!

!AAFTrackAnalyzer class methodsFor: 'as yet unclassified' stamp: 'HM 10/6/2009 01:03'!
maxBranches

	^5! !


Object subclass: #AAFTrackImage
	instanceVariableNames: 'surface surfaceBlt track'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Track'!

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 16:21'!
copyBitsOf: aForm origin: origin



	surfaceBlt sourceForm: aForm.



	surfaceBlt destOrigin: origin.

	surfaceBlt copyBits.! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 16:24'!
createLineFormFromSurface

	"Creates a form that has same depth, width as surface but height of 1px"

	| lineForm |

	

	lineForm := Form new.

	lineForm setExtent: ((surface width) @ 1) depth: (surface depth).

	

	^lineForm! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 15:55'!
initialize

	super initialize.! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 16:41'!
surface

	^surface! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/22/2009 01:45'!
surfaceFromFile: fileName

	| surfaceExtent |

	

	track := Form fromBMPFileNamed: fileName.

	

	surface := Form extent: (track extent)

	                depth: (track depth).

	

	surfaceExtent := ((surface width) @ (surface height)).



	surfaceBlt := (BitBlt destForm: surface

	                      sourceForm: nil

	                      halftoneForm: nil

	                      combinationRule: Form blendAlpha

	                      destOrigin: 0@0

	                      sourceOrigin: 0@0

	                      extent: surfaceExtent

	                      clipRect: (0@0 extent: surfaceExtent)).! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 17:11'!
track

	^track! !

!AAFTrackImage methodsFor: 'as yet unclassified' stamp: 'HM 10/20/2009 16:42'!
writeToFile: fileName

	surface writeBMPfileNamed: fileName.! !
