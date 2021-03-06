Object subclass: #AAFAgentUi
	instanceVariableNames: 'agent title dialog viewportX viewportY inactiveSelectionModel inactiveSelection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-AgentUis'!

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 00:58'!
agent
	^agent! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 13:29'!
agent: anAAFAgent
	agent := anAAFAgent.
	"Hum, what happens with the old dialogs that were already connected? Should I use breakDeps?"
	agent addDependent: self.! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 12:51'!
dialog
	^dialog! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 20:40'!
dialogNew: anAAFAgent
	"Create a new dialog instance and populate it with properties that are valid for all agents. Returns nil if no agent was specified yet."
	(anAAFAgent isKindOf: AAFAgent)
		ifFalse: [^nil].
	
	self agent: anAAFAgent.
	viewportX := 0.
	viewportY := 0.

	dialog := AAFWidgetUtils dialogNewWithCloseButtonAndTitle: title.
	
	(dialog viewport) addWidget: (self inactiveSelectionNew)
	                  frame: (viewportX @ viewportY extent: 1@0.29).
	viewportY := 0.3.

	^dialog! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 20:40'!
inactiveSelectionNew
	| list selection size label |

	size := 32.
	list := Array new: size.
	selection := Array new: size.
	(1 to: size)
		do: [:idx |

			list at: idx put: ('Track section ', idx asString).
			selection at: idx put: false.
		].
	
	inactiveSelectionModel := AAFListModel new.
	inactiveSelectionModel addDependent: self.
	inactiveSelectionModel list: list;
	                       selection: selection.

	label := 'Track sections with inactive agent' asStringMorph.
	label fontName: AAFWidgetUtils defaultFont
	      size: 16. "Really, I don't understand how Squeak handles font sizes. All I know is that this does not show as a 16pt font."

	inactiveSelection := AAFWidget new.
	inactiveSelection addWidget: label
	                  frame: (0@0 extent: 1@0.18).
	
	inactiveSelection  addWidget:	(inactiveSelectionModel listMorph)
	                   frame: (0@0.2 extent: 1@0.8).

	^inactiveSelection! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:08'!
initialize
	super initialize.

	"The subclasses have to choose a proper agent as its model."
	agent := nil.
	
	"This is the title used in self>>showProperties"
	title := 'An Agent'.

	"This member stores the properties dialog, as long as it stays open (since we 'close' it by deleting the dialog atm)."
	dialog := nil.
	
	"Use these coordinates pointing to the dialog viewport's proportional layout to find the next suitable space for your widget to add."
	viewportX := 0.
	viewportY := 0.! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/29/2009 18:06'!
show
	"Opens a dialog with the pre-initialized model agent."
	self dialogNew: agent.
		
	"Forces the dialog to show current data."
	self updateFromAgent.
	self updateFromListSelection.
	
	(nil ~= dialog)
		ifTrue: [dialog openCenteredInWorld].! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 22:03'!
update: event
	"Filter by event which also tells us which model sent a changed message: #modelAspectChanged."
	(#agentPropertyChanged = event)
		ifTrue: [self updateFromAgent].
	(#listSelectionChanged = event)
		ifTrue: [self updateFromListSelection].
	! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:45'!
updateFromAgent
	"Empty for now"

! !

!AAFAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 17:45'!
updateFromListSelection
	agent inactiveSelection: (inactiveSelectionModel selection).! !


AAFAgentUi subclass: #AAFBreaksAgentUi
	instanceVariableNames: 'pointerVisibleButton'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-AgentUis'!

!AAFBreaksAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 21:35'!
dialogNew: anAAFAgent
	super dialogNew: anAAFAgent.

	(nil = dialog)
		ifTrue: [self return].

	pointerVisibleButton := AAFWidgetUtils toggleButtonNew: agent
	                                       action: #pointerVisible:
	                                       label: 'Visible pointer' 
	                                       disabledLabel: 'Invisible pointer'.

	(dialog viewport) addWidget: pointerVisibleButton
	                  frame: (viewportX @ viewportY extent: 0.3@0.1).
	viewportX := 0.33.
		
	^dialog! !

!AAFBreaksAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:08'!
initialize
	super initialize.

	"Set the model for this view, and we have to use the setter here."
	self agent: (AAFBreaksAgent new).

	title := 'Breaks agent'.! !

!AAFBreaksAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 22:04'!
updateFromAgent
	super updateFromAgent.

	(agent isKindOf: AAFBreaksAgent)
		ifFalse: [self return].

	"Update pointer status."
	(agent isPointerVisible)
		ifTrue: [pointerVisibleButton  turnOn.]
		ifFalse: [pointerVisibleButton turnOff.].
	pointerVisibleButton updateLabel.! !


AAFAgentUi subclass: #AAFInputDistributionAgentUi
	instanceVariableNames: 'inputDistribution'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-AgentUis'!

!AAFInputDistributionAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:11'!
dialogNew: anAAFAgent
	super dialogNew: anAAFAgent.

	(nil = dialog)
		ifTrue: [self return].

	inputDistribution := AAFInputDistribution new.
	inputDistribution target: agent
	                  action: #inputDistribution:with:.
	
	viewportX := 0.0.
	(dialog viewport) addWidget: inputDistribution
	                  frame: (viewportX @ viewportY extent: 0.49@0.1).
	
	viewportX := 0.5.
		
	^dialog! !

!AAFInputDistributionAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:08'!
initialize
	super initialize.

	"Set the model for this view, and we have to use the setter here."
	self agent: (AAFInputDistributionAgent new).

	title := 'Input distribution agent'.! !

!AAFInputDistributionAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 7/31/2009 18:05'!
updateFromAgent
	| inputDistInc |

	super updateFromAgent.

	(agent isKindOf: AAFInputDistributionAgent)
		ifFalse: [self return].

	"Update input distribution."
	inputDistInc := ((agent inputDistribution at: 1) * 100) asInteger.
	inputDistribution mwb1: inputDistInc
	                  mwb2: (100 - inputDistInc).! !


AAFAgentUi subclass: #AAFSteeringAgentUi
	instanceVariableNames: 'thresholdInput adjustmentRateInput lookAheadInput'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-AgentUis'!

!AAFSteeringAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 12:47'!
dialogNew: anAAFAgent
	| thresholdTitle adjustmentRateTitle lookAheadTitle |
	
	super dialogNew: anAAFAgent.

	(nil = dialog)
		ifTrue: [self return].

	"Threshold"
	thresholdTitle := 'Threshold' asStringMorph.
	(dialog viewport) addWidget: thresholdTitle
	                  frame: (viewportX @ viewportY extent: 0.30@0.05).
	viewportY := viewportY + 0.06.
	
	thresholdInput := AAFSpinButton new.
	thresholdInput target: agent action: #threshold:.

	(dialog viewport) addWidget: thresholdInput
	                  frame: (viewportX @ viewportY extent: 0.30@0.1).
	viewportX := 0.33.
	viewportY := viewportY - 0.06.

	"AdjustmentRate"
	adjustmentRateTitle := 'Adjustment rate' asStringMorph.
	(dialog viewport) addWidget: adjustmentRateTitle
	                  frame: (viewportX @ viewportY extent: 0.30@0.05).
	viewportY := viewportY + 0.06.
	
	adjustmentRateInput := AAFSpinButton new.
	adjustmentRateInput target: agent action: #adjustmentRate:.
	adjustmentRateInput range: (Array with: 32 with: 2048).
	adjustmentRateInput climbRate: 64.

	(dialog viewport) addWidget: adjustmentRateInput
	                  frame: (viewportX @ viewportY extent: 0.30@0.1).
	viewportX := 0.66.
	viewportY := viewportY - 0.06.

	"LookAhead"
	lookAheadTitle := 'Look-ahead' asStringMorph.
	(dialog viewport) addWidget: lookAheadTitle
	                  frame: (viewportX @ viewportY extent: 0.30@0.05).
	viewportY := viewportY + 0.06.
	
	lookAheadInput := AAFSpinButton new.
	lookAheadInput target: agent action: #lookAhead:.
	lookAheadInput range: (Array with: -400 with: 0).

	(dialog viewport) addWidget: lookAheadInput
	                  frame: (viewportX @ viewportY extent: 0.30@0.1).
	viewportX := 0.
	viewportY := viewportY + 0.17.
		
	^dialog! !

!AAFSteeringAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 00:58'!
initialize
	super initialize.

	"Set the model for this view, and we have to use the setter here."
	self agent: (AAFSteeringAgent new).

	title := 'Steering agent'.! !

!AAFSteeringAgentUi methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 13:20'!
updateFromAgent
	super updateFromAgent.

	(agent isKindOf: AAFSteeringAgent)
		ifFalse: [self return].

	thresholdInput value: (agent threshold).
	adjustmentRateInput value: (agent adjustmentRate).
	lookAheadInput value: (agent lookAhead).! !
