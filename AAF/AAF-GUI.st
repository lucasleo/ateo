SimpleButtonMorph subclass: #AAFButton
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFButton methodsFor: 'override' stamp: 'HM 7/24/2009 01:59'!
doButtonAction
	"Restore label's font size. Ugly, but meh ..."
	AAFWidgetUtils applyDefaultFontSize:self.
		
	super doButtonAction! !


Object subclass: #AAFListModel
	instanceVariableNames: 'list primary selection'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:48'!
initialize
	super initialize.

	list := nil.
	selection := nil.
	primary := 0.! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:20'!
list
	^ (list collect: [:t1 | t1 asString])! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:47'!
list: aCollection
	list := aCollection.! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:46'!
listMorph
	| view |
	
	(nil = list or: [nil = selection])
		ifTrue: [^nil].

	view := PluggableListMorphOfMany new.
	view on: self
	     list: #list
	     primarySelection: #primarySelection
	     changePrimarySelection: #primarySelection:
	     listSelection: #listSelectionAt:
	     changeListSelection: #listSelectionAt:put:
	     menu: nil
	     keystroke: #arrowKey:from:.
	
	AAFWidgetUtils applyDefaultMorphProperties: view.
	
	^view! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:22'!
listSelectionAt: index
	^(selection at: index ifAbsent: [^ false])! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 21:47'!
listSelectionAt: index put: object
	selection at: index put: object.
	self listSelectionChanged.! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 22:10'!
listSelectionChanged
	self changed: #listSelectionChanged.
	
	"#allSelections is just a stupid event name which is much too generic for my taste. That is why I trigger 2 events here ..."
	self changed: #allSelections.! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:20'!
primarySelection
	^primary! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:21'!
primarySelection: selection
	primary := selection! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:49'!
selection
	^selection! !

!AAFListModel methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:47'!
selection: aCollection
	selection := aCollection.! !


SimpleSwitchMorph subclass: #AAFToggleButton
	instanceVariableNames: 'enabledLabel disabledLabel'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFToggleButton methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 23:26'!
disabledLabel: aString
	disabledLabel := aString.! !

!AAFToggleButton methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 14:27'!
enabledLabel: aString
	enabledLabel := aString.
	self label: aString.! !

!AAFToggleButton methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 13:35'!
updateLabel
	(self isOn)
		ifTrue: [self label: enabledLabel]
		ifFalse: [self label: disabledLabel].
		
	"Restore label's font size. Ugly, but meh ..."
	AAFWidgetUtils applyDefaultFontSize:self.! !


!AAFToggleButton methodsFor: 'override' stamp: 'HM 7/24/2009 13:35'!
doButtonAction
	self updateLabel.
	super doButtonAction.! !


AlignmentMorph subclass: #AAFWidget
	instanceVariableNames: 'target action arguments'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 00:46'!
action
	^action! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 00:57'!
actionSelector
	"Its neither action nor selector. It's a slot, or a callback, but actionSelector?!! How about actionSelectorOfTargetThatMapsToAMethod? Anyway, we need a common introspection interface for AAFWidgets and Morphs."
	^action! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:48'!
addWidget: aWidget frame: aRectangle
	"Feels ugly to wrap the addMorph functionality. But with proportional layouts this is just too much typing, and it makes GUI-building code nearly unreadable."
	self addMorph: aWidget
	     fullFrame: (LayoutFrame fractions: (aRectangle)).! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 03:05'!
arguments: aCollection
	arguments := aCollection asArray copy.! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 03:04'!
doWidgetAction
	(nil ~= target and: [nil ~= action])
		ifTrue: [
			target perform: action withArguments: arguments.
		].! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:15'!
initialize
	super initialize.

	self layoutPolicy: (ProportionalLayout new);
	     borderWidth:0;
	     color: Color transparent.

! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 00:39'!
submorphs
	^submorphs! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 00:44'!
target
	^target! !

!AAFWidget methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 03:00'!
target: anObject action: aMethodSymbol
	target := anObject.
	action := (aMethodSymbol asSymbol).! !


AAFWidget subclass: #AAFDialog
	instanceVariableNames: 'viewport title buttonBox'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFDialog methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:32'!
buttonBox
	^buttonBox! !

!AAFDialog methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:39'!
initialize
	super initialize.
	
	AAFWidgetUtils applyDefaultMorphProperties: self.
	self extent: (AAFDialog defaultWidth)@(AAFDialog defaultHeight).

	"I have no idea why size doesn't translate directly to a fontsize. It seems you have to use higher values than 36 in case you want a font at that size. Well, I couldn't care less - we already knew before how borken Squeak is."
	title := StringMorph new.
	title contents: nil;
	      fontName: (AAFWidgetUtils defaultFont) size: 50.
	
	self addMorph: title
	     fullFrame: (LayoutFrame fractions: (0@0 extent: 1@0.1));
	     addMorph: (AAFWidgetUtils separatorNew: (AAFDialog defaultWidth))
	     fullFrame: (LayoutFrame fractions: (0@0.1 extent: 1@0.11)).

	viewport := AAFWidget new.

	self addMorph: viewport
	     fullFrame: (LayoutFrame fractions: (0@0.12 extent: 1@0.7)).

	buttonBox := AAFWidget new.

	self addMorph: buttonBox
	     fullFrame: (LayoutFrame fractions: (0@0.9 extent:1@0.1)).! !

!AAFDialog methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:31'!
title
	^(title contents)! !

!AAFDialog methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:30'!
title: aString
	title contents: aString.! !

!AAFDialog methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:32'!
viewport
	^viewport! !

"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFDialog class
	instanceVariableNames: ''!

!AAFDialog class methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:18'!
defaultHeight
	^600! !

!AAFDialog class methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 02:51'!
defaultWidth
	^600! !


AAFWidget subclass: #AAFInputDistribution
	instanceVariableNames: 'mwb1Value mwb1Button mwb2Value mwb2Button label climbRate'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 03:06'!
incDecValues: anInteger
	| newVal |
	
	newVal := mwb1Value + anInteger.

	(0 <= newVal and: [100 >= newVal])
		ifTrue: [
			mwb1Value := newVal.
			mwb2Value := 100 - newVal.
		].

	self updateLabels.
	self arguments: (self values).
	self doWidgetAction.! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:58'!
initialize
	super initialize.

	self extent: (AAFDialog defaultWidth * 0.67)@50.
	
	climbRate := 5.
	mwb1Value := 50.
	mwb1Button := AAFWidgetUtils buttonNew: self action: #onMwb1Clicked label: nil.
	self addWidget: mwb1Button frame: (0.0@0 extent: 0.49@1).
		
	mwb2Value := (100 - mwb1Value). 
	mwb2Button := AAFWidgetUtils buttonNew: self action: #onMwb2Clicked label: nil.
	self addWidget: mwb2Button frame: (0.51@0 extent: 0.49@1).
	self updateLabels.

	! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 02:53'!
mwb1: mwb1 mwb2: mwb2
	(100 == (mwb1 + mwb2) and: [0 <= mwb1]
	                      and: [0 <= mwb2])
		ifTrue: [
			mwb1Value := mwb1.
			mwb2Value := mwb2.
		].
	
	self updateLabels.! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:58'!
onMwb1Clicked
	self incDecValues: climbRate.
! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:58'!
onMwb2Clicked
	self incDecValues: (climbRate negated).
! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 02:45'!
updateLabels
	mwb1Button label: ('MWB 1: ', mwb1Value asString, '%').
	mwb2Button label: ('MWB 2: ', mwb2Value asString, '%').

	AAFWidgetUtils applyDefaultFontSize: mwb1Button.
	AAFWidgetUtils applyDefaultFontSize: mwb2Button.! !

!AAFInputDistribution methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 02:38'!
values
	^(Array with: (mwb1Value asFloat / 100.0)
	        with: (mwb2Value asFloat / 100.0))! !


AAFWidget subclass: #AAFSpinButton
	instanceVariableNames: 'value range climbRate incButton decButton textInput valueStr editButton'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:17'!
climbRate
	^climbRate! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 12:47'!
climbRate: aNumber
	((range at: 1) <= aNumber and: [(range at: 2) >= aNumber])
		ifTrue: [climbRate := aNumber].! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 11:25'!
inRange: aNumber
	^((range at: 1) <= aNumber and: [(range at: 2) >= aNumber])! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 12:15'!
incDecValues: aNumber
	| newVal |
	
	newVal := value + aNumber.

	(self inRange: newVal)
		ifTrue: [
			value := newVal.
			self updateTextInput.
		].

	self arguments: (self value).
	self doWidgetAction.! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 11:01'!
initialize
	super initialize.
	self extent: (100@40).
	
	AAFWidgetUtils applyDefaultMorphProperties: self.

	range := Array with: 0 with: 100.
	value := 0.
	climbRate := 5.
	
	"Just a simple label because Morphics have no simple line input. Instead, I will use good old ST80 MVC to get the user input."
	textInput := StringMorph new.
	self updateTextInput.
	self addWidget: textInput frame: (0.05@0.15 extent: 0.55@0.7).
	
	editButton := AAFWidgetUtils buttonNew: self
	                             action: #onEditButtonClicked
	                             label: 'E'.
	editButton cornerStyle: #squared.
	self addWidget: editButton frame: (0.61@0 extent: 0.18@1).
	
	incButton := AAFWidgetUtils buttonNew: self
	                            action: #onIncButtonClicked
	                            label: '+'.
	incButton cornerStyle: #squared.
	self addWidget: incButton frame: (0.81@0 extent: 0.19@0.48).

	decButton := AAFWidgetUtils buttonNew: self
	                            action: #onDecButtonClicked
	                            label: '-'.
	decButton cornerStyle: #squared.
	self addWidget: decButton frame: (0.81@0.52 extent: 0.19@0.48).! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:49'!
onDecButtonClicked
	self incDecValues: (climbRate negated).! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 13:18'!
onEditButtonClicked
	| fitbTitle newValue |
	
	fitbTitle := ('Please enter a number between [', (range at: 1) asString, ', ', (range at: 2) asString, ']:').
	newValue := (FillInTheBlank request: fitbTitle
	                            initialAnswer: (value asString)) asNumber.
	
	(newValue isKindOf: Number)
		ifTrue: [self value: newValue].

	self arguments: (self value).
	self doWidgetAction.! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:18'!
onIncButtonClicked
	self incDecValues: climbRate.! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:15'!
range
	^range! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 12:45'!
range: aRange
	"a range is an interval, here: an array of size 2 where the second element has to be bigger than the first."
	range := aRange.
	climbRate := (((range at: 2) - (range at: 1)) / 20.0) rounded.! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 10:57'!
updateTextInput
	textInput contents: (value asString).
	textInput fontName: (AAFWidgetUtils defaultFont) size: 24.! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 01:36'!
value
	^(Array with: value)! !

!AAFSpinButton methodsFor: 'as yet unclassified' stamp: 'HM 8/2/2009 13:17'!
value: aNumber
	(self inRange: aNumber)
		ifTrue: [value := aNumber].

	self updateTextInput.! !


Object subclass: #AAFWidgetUtils
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AAF-GUI'!
!AAFWidgetUtils commentStamp: 'HM 7/26/2009 20:14' prior: 0!
I cannot believe there is no ListModel for PluggableListMorphs. And there is no API doc to telling how to impl. it either. Squeak devs, you really making it hard for no goog reason.
!


"-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- "!

AAFWidgetUtils class
	instanceVariableNames: ''!

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 00:41'!
applyDefaultButtonProperties: aButton
	aButton borderWidth: (AAFWidgetUtils defaultBorderWidth);
           cornerStyle: #rounded;
           color: Color veryLightGray.

	"This feels so stupid. Descend the object hierarchy, grab the first StringMorhp, hope it is the button label, and set the font size. For the lack of a Morph>>fontSize property."
	AAFWidgetUtils applyDefaultFontSize: aButton.! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 00:41'!
applyDefaultFontSize: aWidget
	(aWidget findA: StringMorph) fontName: (AAFWidgetUtils defaultFont)
                                size: 30.! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/26/2009 20:39'!
applyDefaultMorphProperties: morph
	morph borderWidth:2;
	      cornerStyle: #rounded;
	      color: Color white.

	^morph.! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 02:01'!
buttonNew: target action: action label: label
	| button |
	
	button := AAFButton new.
	
	button target: target;
          actionSelector: action;
          label: label.

	"Properties like font size can only be set after labels have been set. Don't ask ..."
	AAFWidgetUtils applyDefaultButtonProperties: button.
	
	^button! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 00:28'!
defaultBorderWidth
	^2! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 21:53'!
defaultFont
	^#BitstreamVeraSans! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/21/2009 22:55'!
dialogNewWithCloseButtonAndTitle: title
	| dialog |

	dialog := AAFDialog new.
	dialog openCenteredInWorld.
	dialog title: title.

	(dialog buttonBox) addWidget: (AAFWidgetUtils buttonNew: dialog action: #delete label: 'Close')
	                   frame: (0@0 extent: 1@1).

	^dialog! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/22/2009 00:23'!
separatorNew: aNumber
	^(LineMorph from: (0@0) to: (aNumber@0) color: (Color black) width: (AAFWidgetUtils defaultBorderWidth)).! !

!AAFWidgetUtils class methodsFor: 'as yet unclassified' stamp: 'HM 7/24/2009 14:33'!
toggleButtonNew: target action: action label: label disabledLabel: disabledLabel
	| button |
	
	button := AAFToggleButton new.
	button target: target;
	       actionSelector: action;
          enabledLabel: label;
          disabledLabel: disabledLabel.

	"Properties like font size can only be set after labels have been set. Don't ask ..."
	AAFWidgetUtils applyDefaultButtonProperties: button.
	button turnOn.
	
	^button! !
