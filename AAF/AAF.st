Object subclass: #AAFControl
	instanceVariableNames: 'isDebugRun nodes nodesToVisit'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

!AAFControl methodsFor: 'as yet unclassified' stamp: 'MH 7/5/2009 20:08'!
addNode: anAAFNode
	nodes addLast: anAAFNode.! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 23:12'!
connectParent: parent withChild: child
	(nil == parent)
		ifFalse: [
			parent addChild: child.
		].
	
	"A parent takes ownership of its children, hence we only use addNode on the child."
	child addParent: parent.
	self addNode: child.! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 22:58'!
createGraphWithRoot: root
	nodes := OrderedCollection new.
	invertVisitedFlag := false.
	self connectParent: nil
	     withChild: root.! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 20:40'!
graphSize
	^(nodes size)! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:14'!
initialize
	super initialize.
	
	nodes := OrderedCollection new: 32.
	nodesToVisit := OrderedCollection new: 32.
	isDebugRun := false.! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 00:34'!
isDebugRun: aBoolean
	isDebugRun := aBoolean.! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 04:07'!
processGraph: aSamState
	(nodes isEmpty)
		ifTrue: [
			"Nothing to do!! Return unmodified state."
			^aSamState
		].

	^(self processGraph: aSamState startAt: (self root) endAt: (self sink)).! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 23:12'!
processGraph: aSamState startAt: root endAt: sink	
	"If nodesToVisit wasn't properly emptied during the last run we know something went terribly wrong, so we complain!!"
	(nodesToVisit isEmpty)
		ifFalse: [self break].
		
	nodesToVisit addLast: root.
	root result: aSamState.
	
	(nodes)
		do: [
			:node |
		"Reset visited flag for each node. Increases runtime cost by O(n). I should NOT optimize this ..."
		"I tested the difference when using an evil hack to toggle the meaning of the nodes' visited flag with each run (We know that the visited flags switch from true to false (and vice versa) with each run of the BFS). It would save -O(n), in theory. But I don't think this is noticable. In fact, I tested it, and for 640.000 nodes it was the difference of 9.7secs to 10.2 secs. Not worth using an evil hack like this (which easily breaks, if the next dev comes along). The reason is that the AAFAgent>>compute costs are much much higher (read: the constant part of big-O) than the constat part of flipping a bit in a list."
		node isVisited: false.
	].
	
	"Run BFS. For a Graph G = (V, E), runtime costs are O(|V| + |E|), plus the potentially expensive computations run by the agents."
	[nodesToVisit isEmpty]
		whileFalse: [
			| node |
			
			node := nodesToVisit removeFirst.
			node isVisited: true.
			node  compute.
			
			(node children)
				do: [
					:child |
			
					(false = (child isVisited))
						ifTrue: [
							nodesToVisit addLast: child.
						].
				].
		].

	^(sink result)! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:19'!
processGraphWithProxy: anAAFProxy
	"Process the graph, reading and writing the SAM state from a given proxy instance."
	anAAFProxy state: (self processGraph: (anAAFProxy state)).! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 14:07'!
root
	^(nodes first)
	! !

!AAFControl methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 01:19'!
sink
	"This is just a clever guess. But if you think about it - it's the same assumption as with the root node!!"
	^(nodes last)
	! !


!AAFControl methodsFor: 'testing' stamp: 'HM 7/16/2009 02:42'!
testBreaksGraph
	| root |
	
	root := AAFNode new
		             agent: (AAFBreaksAgent new).
		
	self createGraphWithRoot: root.! !

!AAFControl methodsFor: 'testing' stamp: 'HM 7/16/2009 13:25'!
testBreaksInversionGraph
	| breaks inversion |
	
	breaks := AAFNode new agent: (AAFBreaksAgent new).
	inversion := AAFNode new agent: (AAFInversionAgent new).

	self createGraphWithRoot: breaks.
	self connectParent: breaks withChild: inversion.! !

!AAFControl methodsFor: 'testing' stamp: 'MH 7/7/2009 18:01'!
testInversionGraph
	| root |
	
	root := AAFNode new
		             agent: (AAFInversionAgent new).
		
	self createGraphWithRoot: root.! !

!AAFControl methodsFor: 'testing' stamp: 'HM 7/23/2009 19:50'!
testLinearGraphWith: anAAFAgent size: size
	| node parent |
	
	node := AAFNode new
		             agent: anAAFAgent.
		
	self createGraphWithRoot: node.
	parent := node.
	
	(2 to: size)
		do: [
			:idx |
			
			node := AAFNode new
			                agent: (anAAFAgent copy).
			self connectParent: parent withChild: node.
			parent := node.		
		].! !

!AAFControl methodsFor: 'testing' stamp: 'HM 7/26/2009 10:57'!
testLoopedGraphProcessingWith: anAAFAgent times: anInt
	| pathLength |
	
	pathLength := 64.
	proxy := AAFProxy reset getInstance.
	
	self testLinearGraphWith: anAAFAgent size: pathLength.

	(1 to: anInt)
		do: [
			:iter |

			proxy testFetchDataFromSam.
			self processGraph: (proxy state).
		].! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFControl class
	instanceVariableNames: 'instance'!

!AAFControl class methodsFor: 'as yet unclassified' stamp: 'HM 7/25/2009 19:40'!
garbageCollect
	"Taken from http://onsmalltalk.com/squeak-smalltalk-image-maintenance"
    | tasks |
    tasks := OrderedCollection new
                add: [MCFileBasedRepository flushAllCaches];
                "add: [WARegistry clearAllHandlers];"
                add: [SMSqueakMap default clearCaches];
                add: [Smalltalk removeEmptyMessageCategories];
                add: [Workspace
                        allSubInstancesDo: [:each | each setBindings: Dictionary new]];
                add: [Undeclared removeUnreferencedKeys];
                add: [Categorizer sortAllCategories];
                "add: [ODBCConnection cleanAll];"
                add: [Symbol compactSymbolTable];
                add: [ReleaseBuilderDeveloper new fixObsoleteReferences];
                add: [Smalltalk garbageCollectMost];
                 yourself.
    Utilities
        informUserDuring: [:bar | tasks
                do: [:block | 
                    bar value: block printString.
                    [block value]
                        on: Error
                        do: [:error | Transcript show: error;
                                 cr]]].
    SystemNavigation default obsoleteClasses isEmpty
        ifTrue: [SmalltalkImage current saveSession]
        ifFalse: [SystemNavigation default obsoleteClasses
                do: [:each | [PointerFinder on: each]
                        on: Error
                        do: [:error | Transcript show: error; cr]]]
! !

!AAFControl class methodsFor: 'as yet unclassified' stamp: 'HM 7/25/2009 16:03'!
getInstance
	( nil = instance )
	ifTrue: [
		"I refuse to be judged by our 'poor' performance only because the Squeak VM doesn't do its job properly.'"
		AAFControl setSaneVmDefaults.
		instance := (AAFControl new).
	].

	^instance! !

!AAFControl class methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 13:17'!
reset
	instance := nil.! !

!AAFControl class methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 11:01'!
setSaneVmDefaults
	"The Squeak developers love to see the IGC doing its work, as often as possible. Well, I don't. Certainly not for every 4k allocations."
	SmalltalkImage current vmParameterAt: 5 put: 400000.
	SmalltalkImage current vmParameterAt: 6 put: 12000.
	
! !


EventSensor subclass: #AAFEventSensor
	instanceVariableNames: 'joystickDiffs joysticksOffsets joysticks'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!
!AAFEventSensor commentStamp: 'MH 6/22/2009 21:48' prior: 0!
The AAFEventSensor class adds a user-specified differential between sensor reads. The differential is reset to 0@0 after each read.!


!AAFEventSensor methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 12:17'!
initialize
	super initialize.
	
	self resetJoysticks.
! !

!AAFEventSensor methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 12:17'!
joysticks: anArray
	joysticks := (anArray copy).! !

!AAFEventSensor methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 12:19'!
resetJoysticks
	joysticks := Array
		with: (super joystickXY: 1)
		with: (super joystickXY: 2).! !


!AAFEventSensor methodsFor: 'override' stamp: 'MH 7/6/2009 12:20'!
joystickXY: index
	^(joysticks at: index)

! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFEventSensor class
	instanceVariableNames: 'instance joystickDiffs'!

!AAFEventSensor class methodsFor: 'as yet unclassified' stamp: 'MH 6/23/2009 15:35'!
fetchDataFrom: anAAFProxy
	| sensor |
	"This method fetches modified tracking data from ATEO's Automatic Framework."

	sensor := AAFEventSensor getInstance.! !

!AAFEventSensor class methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 21:35'!
getInstance
	( nil = instance )
	ifTrue: [
		instance := (AAFEventSensor basicNew) initialize.
	].

	^instance
! !

!AAFEventSensor class methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 22:34'!
reset
	instance := nil.! !


!AAFEventSensor class methodsFor: 'nil' stamp: 'MH 6/23/2009 15:33'!
fetchDataFromProxy
	| sensor state |
	"This method fetches modified tracking data from ATEO's Automatic Framework."

	sensor := AAFEventSensor getInstance.
	state := SamState new.! !


Object subclass: #AAFNode
	instanceVariableNames: 'agent children parents result hasResult id isVisited'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 13:13'!
addChild: aNode
	^(self
		addToCollection: (self children)
		node: aNode)! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 13:13'!
addParent: aNode
	^(self
		addToCollection: (self parents)
		node: aNode)! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 13:14'!
addToCollection: aCollection node: node
	(self ~= node and: [nil ~= node])
		ifTrue: [
			aCollection addLast: node.
		].

	^node! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/7/2009 19:50'!
agent
	^agent! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/29/2009 21:46'!
agent: anAAFAgent
	agent := anAAFAgent.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/29/2009 20:02'!
children
	^children! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'HM 9/14/2009 23:05'!
compute
	"(self hasResult)
		ifFalse: [
			self mergeParentResults.
		]."
	
	self result: (agent compute: result).! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'HM 7/25/2009 13:30'!
hasOnlyOneChild
	^(1 = (children size))! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 14:36'!
hasResult
	^hasResult and: [result ~= nil]! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 01:45'!
haveParentResults
	| tmp |
	
	tmp := false.

	parents do: [
		:node |
		
		tmp := node hasResult.
		(tmp)
			ifFalse: [
				^false
			].
	].

	^tmp! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 17:43'!
id
	^id! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 17:43'!
id: anInt
	id := anInt.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 23:32'!
initialize
	super initialize.

	id := AAFNode autoId.
	result := nil.
	hasResult := false.
	isVisited := false.
	parents := OrderedCollection new.
	children := OrderedCollection new.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 23:06'!
isVisited
	^isVisited! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 23:07'!
isVisited: aBoolean
	isVisited := aBoolean.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:38'!
mergeParentResults
	| tmp nodeResult |
	
	"No need to use complex merge if only one parent exists."
 	(1 = (parents size))
		ifTrue: [
			| parent |
			
			"No need to copy the result if we are the only descendant of the parent."
			parent := parents first.
			(parent hasOnlyOneChild)
				ifTrue:  [self result: (parent takeResult)]
				ifFalse: [self result: (parent takeResult copy)].
				
			^self.
		].
	

	"We have to wait until all parent results were computed.
	Consider root->sink, root->child, child->sink. Without this check, we would compute sink's result before visiting child, given BFS"
	(self haveParentResults)
		ifFalse: [^self].

	"This 'new' call might be too expensive ..."
	tmp := SamState new.
	
	(self parents)
		do: [
			:node |
		
			"Do we really need a copy? the parents are not going to use their results anymore, after all. Hm, but we could have several merge nodes for the same parents ..."
			nodeResult := node takeResult copy.
			"TODO: use simple vector addition to merge different joystick results of sibblings."
		].

	self result: tmp.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 11:20'!
parents
	^parents! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 00:27'!
result
	^result! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 15:16'!
result: aSamState
	result := aSamState.
	hasResult := true.! !

!AAFNode methodsFor: 'as yet unclassified' stamp: 'MH 7/6/2009 01:46'!
takeResult
	hasResult := false.
	^result
! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFNode class
	instanceVariableNames: 'count log'!

!AAFNode class methodsFor: 'as yet unclassified' stamp: 'MH 6/30/2009 17:45'!
autoId
	(nil = count)
	ifTrue: [
		self resetCounter.
	] ifFalse: [
		count := count + 1.
	].

	^count! !

!AAFNode class methodsFor: 'as yet unclassified' stamp: 'MH 6/29/2009 22:08'!
resetCounter
	count := 0.! !


Object subclass: #AAFProxy
	instanceVariableNames: 'state isDebugRun trackingState'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'HM 9/14/2009 22:06'!
initialize
	super initialize.
	
	isDebugRun := false.
	state := SamState new.
! !

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 20:53'!
isDebugRun: aBoolean
	isDebugRun := aBoolean.! !

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:27'!
readUpdatesFromSam: SAMModelData
	state := SamState new.
	state readUpdatesFromTrackingState: SAMModelData.! !

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 20:20'!
state
	^state
! !

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'HM 7/23/2009 04:08'!
state: currentSamState
	state := currentSamState.! !

!AAFProxy methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:30'!
writeUpdatesToSam: SAMModelData
	"Update SAM with correction from the AAF."
	state writeUpdatesToTrackingState: SAMModelData.

	
! !


!AAFProxy methodsFor: 'deprecated' stamp: 'HM 7/29/2009 05:07'!
fetchDataFromSam
	"This method fetches tracking data of the current state of SAM."
	
	"trackingState holds read-only data only"
	trackingState frand: JoyID frand;
	              carPos: CarID aktpos;
	              speed: JoyID schritt;
	              currentSection: ParID currentSection;
	              distanceTotal: JoyID summschritt.
		
	"state is a composite structure allowing rw access to its member variables, and read-only access to members of members (here: trackingState)"
	"We read the raw joystick data since if we were to read from SAM we'd end up reading the values we just manipulated."
	state joystickXY: 1 put: (Sensor joystickXY: 1);
	      joystickXY: 2 put: (Sensor joystickXY: 1).! !

!AAFProxy methodsFor: 'deprecated' stamp: 'HM 7/31/2009 22:54'!
loadRacingLine
	"A track is a collection of track section."
	| imageFile racingLine xmlFile offset racingLineAsArray |
	
	
	(ParID isKindOf: ATEOPar)
		ifFalse: [^self].

	racingLine := Dictionary new.
	offset := 0.
	(ParID track)
		do: [:segment |
			
			imageFile := ParID images at: segment.
			xmlFile := ('racinglines\xml\', imageFile, '.xml') asByteString. 
			AAFRacingLine parseFile: xmlFile
			              appendTo: racingLine
			              offset: offset.
			
			"Computing the offset only works if we read all xml files in order and skipped none."
			(0 < (racingLine size))
				ifTrue: [offset := racingLine keysSortedSafely last].
		].
	
	"Copying racingline from a dictionary to an array."
	racingLineAsArray := Array new: (racingLine size).
	(1 to: (racingLine size))
		do: [:idx |
				racingLineAsArray at: idx
				                  put: (racingLine at: idx).
			].
	
	trackingState racingLine: racingLineAsArray.! !

!AAFProxy methodsFor: 'deprecated' stamp: 'HM 7/23/2009 04:09'!
testFetchDataFromSam
	"This method fetches tracking data of the current state of SAM."
	
	"state trackingState: trackingState."
		   "joystickXY: 1 put: (1024@1024);
		   joystickXY: 2 put: (-1024@-1024)."! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFProxy class
	instanceVariableNames: 'instance'!

!AAFProxy class methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 20:55'!
getInstance
	( nil = instance )
	ifTrue: [
		instance := (AAFProxy basicNew) initialize.
	].

	^instance
! !

!AAFProxy class methodsFor: 'as yet unclassified' stamp: 'MH 6/22/2009 20:56'!
reset
	instance := nil.! !


Object subclass: #AAFRacingLine
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFRacingLine class
	instanceVariableNames: ''!

!AAFRacingLine class methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 05:16'!
parseFile: fileName appendTo: yxPairs
	^(AAFRacingLine parseFile: fileName
	                appendTo: yxPairs
	                offset: 0)! !

!AAFRacingLine class methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 05:15'!
parseFile: fileName appendTo: yxPairs offset: offset
	| file xmlDoc elements yValue xValues xValue |

	(FileStream isAFileNamed: fileName asByteString)
		ifFalse: [^yxPairs].
			
	file := FileStream fileNamed: fileName asByteString.	
	xmlDoc := XMLDOMParser parseDocumentFrom: file.
	file close.
	elements := xmlDoc elements at: 1.
	
	elements tagsNamed: #y
		do: [:yNode |
			
			yValue := (yNode attributeAt: #val) asInteger.
			xValues := OrderedCollection new.
			yNode tagsNamed: #x
				do: [:xNode |

					xValue := (xNode attributeAt: #val) asInteger.
					xValues add: xValue.
				].
			yxPairs at: (yValue + offset) put: xValues.
		].
	
	^yxPairs! !


Object subclass: #SamState
	instanceVariableNames: 'trackingState joystickXAxis joystickYAxis'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:41'!
initialize
	super initialize.

	joystickXAxis     := Array with: 0 with: 0.
	joystickYAxis     := Array with: 0 with: 0.

	trackingState := SAMModelData getInstance.! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/14/2009 18:15'!
joystickXAxisAt: mwbIndex
	^(joystickXAxis at: mwbIndex)! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:41'!
joystickXAxisAt: mwbIndex put: value
	joystickXAxis at: mwbIndex put: value.! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/14/2009 18:16'!
joystickYAxisAt: mwbIndex
	^(joystickYAxis at: mwbIndex)! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:40'!
joystickYAxisAt: mwbIndex put: value
	joystickYAxis at: mwbIndex put: value.! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:28'!
readUpdatesFromTrackingState: SAMModelData
	trackingState := SAMModelData.

	"Copies writeable parameters into SamState members."
	joystickXAxis at: 1
	              put: (trackingState joystick1XAxis asInteger).
	joystickYAxis at: 1
	              put: (trackingState joystick1YAxis asInteger).

	joystickXAxis at: 2
	              put: (trackingState joystick2XAxis asInteger).
	joystickYAxis at: 2
	              put: (trackingState joystick2YAxis asInteger).
	! !

!SamState methodsFor: 'as yet unclassified' stamp: 'MH 7/5/2009 15:48'!
trackingState
	^trackingState! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:29'!
trackingState: samModelData
	trackingState := samModelData.! !

!SamState methodsFor: 'as yet unclassified' stamp: 'HM 9/15/2009 00:29'!
writeUpdatesToTrackingState: SAMModelData
	SAMModelData joystick1XAxis: (self joystickXAxisAt: 1);
	             joystick1YAxis: (self joystickYAxisAt: 1);
	             joystick2XAxis: (self joystickXAxisAt: 2);
	             joystick2YAxis: (self joystickYAxisAt: 2).
	! !


!SamState methodsFor: 'deprecated' stamp: 'MH 7/5/2009 17:55'!
joystickXY: index
	^(joysticks at: index)! !

!SamState methodsFor: 'deprecated' stamp: 'HM 7/23/2009 02:02'!
joystickXY: index put: aPoint
	joysticks at: index put: aPoint.! !

!SamState methodsFor: 'deprecated' stamp: 'MH 7/5/2009 17:56'!
joysticks
	^joysticks! !

!SamState methodsFor: 'deprecated' stamp: 'MH 7/5/2009 17:56'!
joysticks: anArray
	joysticks := anArray.! !


Object subclass: #SamTrackingState
	instanceVariableNames: 'carPos frand speed racingLine currentSection distanceTotal'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF'!

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'MH 7/5/2009 15:51'!
carPos
	^carPos! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/16/2009 02:31'!
carPos: aPoint
	(nil ~= aPoint)
		ifTrue: [carPos := aPoint].! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 04:50'!
currentSection
	^currentSection! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 04:50'!
currentSection: aNumber
	currentSection := aNumber.! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 05:07'!
distanceTotal
	^distanceTotal! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 05:06'!
distanceTotal: aNumber
	distanceTotal := aNumber.! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'MH 7/5/2009 15:52'!
frand
	^frand! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 17:11'!
frand: aColor
	frand := aColor.! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 04:52'!
initialize
	super initialize.

	carPos := 0@0.
	frand := nil.
	speed := 0.
	images := nil.
	currentSection := -1.
	racingLine := Dictionary new.
	! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 04:42'!
racingLine: racingLineDict
	racingLine := racingLineDict.! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 05:28'!
racingLineAt: yPos
	^(racingLine at: (yPos rounded)
	             ifAbsent: [nil])! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/15/2009 21:28'!
speed
	^speed! !

!SamTrackingState methodsFor: 'as yet unclassified' stamp: 'HM 7/16/2009 02:31'!
speed: aNumber
	(nil ~= aNumber)
		ifTrue: [speed := aNumber].! !
