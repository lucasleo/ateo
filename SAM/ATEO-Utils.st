Object subclass: #ATEOFileInOut
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ATEO-Utils'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ATEOFileInOut class
	instanceVariableNames: ''!

!ATEOFileInOut class methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 21:31'!
getCategoriesOf: aModule

	"A list of categories that ATEOFileInOut should take care of."

	| categories |

	

	categories := OrderedCollection new.
	
	(#'SAM' = aModule)
		ifTrue: [
			categories add: #'ATEO-SAM';
			           add: #'ATEO-Utils'.
		].


	(#'OA' = aModule)
		ifTrue: [
			"categories add: #aSymbol."
		].
	
	(#'AAF' = aModule)
		ifTrue: [
			categories add: #'AAF';
			           add: #'AAF-Agents';
			           add: #'AAF-AgentUis';
			           add: #'AAF-GUI';
			           add: #'AAF-Test';
			           add: #'AAF-Track'.
		].


	^categories! !

!ATEOFileInOut class methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 21:30'!
prefixOf: aModule

	"A directory prefix for all fileIn/fileOut operations."

	"Empty prefix should equal current directory."
	
	(#'SAM' = aModule)
		ifTrue: [^'..\SAM\'].

	(#'OA' = aModule)
		ifTrue: [^'..\OA\'].
	
	(#'AAF' = aModule)
		ifTrue: [^'..\AAF\'].! !


ATEOFileInOut subclass: #ATEOFileIn
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ATEO-Utils'!


ATEOFileInOut subclass: #ATEOFileOut
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'ATEO-Utils'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

ATEOFileOut class
	instanceVariableNames: ''!

!ATEOFileOut class methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 21:35'!
allCategories
	ATEOFileOut categoriesOf: #SAM;
	            categoriesOf: #OA;
	            categoriesOf: #AAF.! !

!ATEOFileOut class methodsFor: 'as yet unclassified' stamp: 'HM 10/19/2009 21:32'!
categoriesOf: aModule



	(ATEOFileInOut getCategoriesOf: aModule)

		do: [:cat || fName fStream |

			

			fName := ((ATEOFileInOut prefixOf: aModule), cat asString, '.st') asByteString.
			"We use CR/LF newlines since we effectively develop on windows ... and git can handle automatic LF/CRLF conversion." 

			fStream := CrLfFileStream forceNewFileNamed: fName.
			

			SystemOrganization fileOutCategory: cat

                            on: fStream.

		].! !
