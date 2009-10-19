TestCase subclass: #AAFAgentUiTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Test'!

!AAFAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 11:13'!
agentNew
	^(AAFAgent new)! !

!AAFAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 11:13'!
agentUiNew
	^(AAFAgentUi new)! !

!AAFAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/31/2009 17:42'!
testAgentDefaults: agent
	"Currently empty"! !

!AAFAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/31/2009 21:52'!
testModelView
	"We want to set a value in the AAFAgent (model) and check whether the view gets updated, and vice versa. To do so, we iterate over the submorphs of AAFAgentUi's (controller) dialog (view)."
	| model ctrl view |
	
	"Make sure to override self>>agentNew, self>>agentUiNew correctly in subclasses, else we test the wrong stuff there!!"
	model := self agentNew.
	ctrl  := self agentUiNew.
	ctrl agent: model.
	view  := ctrl show dialog.
	
	"Check the default values of the model, to avoid silly mistakes."
	self testAgentDefaults: model.

	(view viewport submorphs)
		do: [ :morph |
			
			"Override self>>testMorph:withAgent:withMethod: to test for other model/ctrl combos. Ignore the PLM. God this is ugly ..."
			(nil = (morph findA: PluggableListMorph))
				ifTrue: [ 
					self testMorph: morph
					     withAgent: (morph target)
					     withMethod: (morph actionSelector).
				]. 
		].

	"We have to delete the view explicitly because it is opened in the world."
	view hide delete.! !

!AAFAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/31/2009 21:49'!
testMorph: morph withAgent: agent withMethod: method
	(agent isKindOf: AAFAgent)
		"If wrong agent then force test runner into a failed assertion."
		ifFalse: [self shouldnt: [true]]
		ifTrue: [
			"Switch through the methods we know, since they (= event handlers) are mapped 1:1 to UI elements. W.o.w., if we know the method, we know the UI element."
			"No general UI elements to test, other than the PLMoM ..."
		].! !


AAFAgentUiTestCase subclass: #AAFBreaksAgentUiTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Test'!

!AAFBreaksAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 11:14'!
agentNew
	^(AAFBreaksAgent new)! !

!AAFBreaksAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 11:14'!
agentUiNew
	^(AAFBreaksAgentUi new)! !

!AAFBreaksAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 11:59'!
testAgentDefaults: agent
	super testAgentDefaults: agent.
	
	self shouldnt: [agent isPointerVisible].! !

!AAFBreaksAgentUiTestCase methodsFor: 'testing' stamp: 'HM 7/26/2009 12:04'!
testMorph: morph withAgent: agent withMethod: method
	(agent isKindOf: AAFBreaksAgent)
		"If wrong agent then force test runner into a failed assertion."
		ifFalse: [self shouldnt: [true]]
		ifTrue: [
			
			"Test the pointerVisibleButton."
			(#pointerVisible: = method asSymbol)
				ifTrue: [
					"Let's turn the agent's property on."
					agent pointerVisible: true.
					self  should: [morph isOn].
					
					"Now let's press the button."
					morph turnOff doButtonAction.
					self shouldnt: [agent isPointerVisible].
				].
		].! !


TestCase subclass: #AAFControlTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Test'!

!AAFControlTestCase methodsFor: 'testing' stamp: 'MH 7/7/2009 16:39'!
testGraphProcessing
	| control root lchild rchild sink state |

	control := AAFControl new.
	control isDebugRun: true.
	
	AAFNode resetCounter.
	
	root := AAFNode new
		agent: (AAFIdleAgent new).
	control createGraphWithRoot: root.
	
	self should: [root parents isEmpty];
		  should: [root children isEmpty].
	
	lchild := AAFNode new
		agent: (AAFDummyAgent new).
	rchild := AAFNode new
		agent: (AAFDummyAgent new).
	sink   := AAFNode new
		agent: (AAFDummyAgent new).

	control connectParent: root withChild: lchild.
	self should: [root parents isEmpty];
		  should: [lchild == root children first];
		  should: [root == lchild parents first];	
		  should: [lchild children isEmpty]. 
	
	self shouldnt: [lchild haveParentResults].
	root result: (SamState new).
	self should: [lchild haveParentResults].
	
	state := control processGraph: (SamState new).
	self should: [(1@1) = (state joystickXY: 1)].
	
	control connectParent: root withChild: rchild.
	control connectParent: lchild withChild: sink.
	control connectParent: rchild withChild: sink.

	state := control processGraph: (SamState new).

	"**
	  *  root: adds 1@1 to 0@0
	  *  lchild: adds 1@1 to 1@1
	  *  rchild: adds 1@1 to 1@1
	  *  sink: merges lchild and rchild by adding 2@2 and 2@2. Adds 1@1
	  **"
	self should: [(5@5) = (state joystickXY: 1)].! !

!AAFControlTestCase methodsFor: 'testing' stamp: 'HM 7/23/2009 21:06'!
testSamIntegration
	"TODO: extend integration tests as soon as SamState (and therefore, the integration) grows more complex."
	"TODO: run inside a short sample 'simulation', to check whether states are correctly reset and so on."
	| proxy control sensor joystick1 joystick2 |
	
	"Get fresh singleton instances."
	proxy := AAFProxy reset getInstance.
	control := AAFControl reset getInstance.
	sensor := AAFEventSensor reset getInstance.
	
	"Create a test graph containing one node using the inversion agent."
	control testInversionGraph.
	self should:   [control root isKindOf: AAFNode];
	     shouldnt: [control root hasResult];
		  should:   [control root agent isKindOf: AAFInversionAgent].
	
	"Using AAFProxy>>testFetchDataFromSam instead of the real AAFProxy>>fetchDataFromSam."
	proxy testFetchDataFromSam.
	
	"Store the the proxy's joystick values, for later comparision."
	joystick1 := proxy state joystickXY: 1.
	joystick2 := proxy state joystickXY: 2.
	
	"Run the automation graph for the current simulation state." 
	proxy state: (control processGraph: (proxy state)).
	
	"Feed the proxy data to the sensor that would be used by SAM."
	sensor joysticks: (Array with: (proxy state joystickXY: 1)
	                         with: (proxy state joystickXY: 2)).

	self should: [joystick1 = (sensor joystickXY: 1) negated];
	     should: [joystick2 = (sensor joystickXY: 2) negated].! !


AAFAgentUiTestCase subclass: #AAFInputDistributionAgentUiTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Test'!

!AAFInputDistributionAgentUiTestCase methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 21:31'!
agentNew
	^(AAFInputDistributionAgent new)! !

!AAFInputDistributionAgentUiTestCase methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 21:31'!
agentUiNew
	^(AAFInputDistributionAgentUi new)! !

!AAFInputDistributionAgentUiTestCase methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 21:33'!
testAgentDefaults: agent
	| fiftyfifty |
	
	super testAgentDefaults: agent.
	
	fiftyfifty := (Array with: 0.5 with: 0.5).
	self should: [fiftyfifty = (agent inputDistribution)].! !

!AAFInputDistributionAgentUiTestCase methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 21:50'!
testMorph: morph withAgent: agent withMethod: method
	(agent isKindOf: AAFInputDistributionAgent)
		"If wrong agent then force test runner into a failed assertion."
		ifFalse: [self shouldnt: [true]]
		ifTrue: [
			
			"Test the input distribution."
			(#inputDistribution:with: = method asSymbol)
				ifTrue: [
					agent inputDistribution: 0.1 with: 0.9.
					self should: [(Array with: 0.1 with: 0.9) = (morph values)].
												
					morph onMwb2Clicked.
					self should: [(Array with: 0.0 with: 1.0) = (agent inputDistribution)].
						
					"This event should be ignored since MWB2 already has 100%."
					morph onMwb2Clicked.
					self should: [(Array with: 0.0 with: 1.0) = (agent inputDistribution)].
						
					morph onMwb1Clicked onMwb1Clicked onMwb1Clicked.
					self should: [(Array with: 0.3 with: 0.7) = (agent inputDistribution)].
				].
			].! !


TestCase subclass: #AAFPerformanceTestCase
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-Test'!

!AAFPerformanceTestCase methodsFor: 'testing' stamp: 'HM 7/28/2009 20:49'!
testLoopedGraphProcessing
	| ctrl times timeEllapsed |
	
	ctrl := AAFControl reset getInstance.
	times := 10000.

	"This test runs a linear graph of 64 AAFInversionAgents 10.000 times. So basically we measure how long it takes to call 'AAFAgent>>compute:' 640.000 times, with all its needed infrastructure to fetch the data and such."
	timeEllapsed := MessageTally time: [
		ctrl testLoopedGraphProcessingWith: (AAFInversionAgent new)
		     times: times.
	].

	"Takes less than 3 secs on my 2.2 DualCore."
	self should: [4000 > timeEllapsed].
	self should: [64 = (ctrl graphSize)].
	
	"Ditto, now with the more expensive AAFBreaksAgent"
	timeEllapsed := MessageTally time: [
		ctrl testLoopedGraphProcessingWith: (AAFBreaksAgent new)
		     times: times.
	].

	"Takes less than 10 secs on my 2.2 DualCore."
	self should: [12000 > timeEllapsed].
	self should: [64 = (ctrl graphSize)].
	
	"Now only a single run, since we need to know the additional costs of running the agents during the simulation (per frame)"
	timeEllapsed := MessageTally time: [
		ctrl testLoopedGraphProcessingWith: (AAFBreaksAgent new)
		     times: 1.
	].

	"Takes less than 4 msecs on my 2.2 DualCore."
	self should: [6 > timeEllapsed].
	self should: [64 = (ctrl graphSize)].
	
	AAFControl reset.
	! !
