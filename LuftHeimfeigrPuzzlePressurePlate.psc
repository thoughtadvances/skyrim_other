Scriptname LuftHeimfeigrPuzzlePressurePlate extends PressurePlate

; How to use
; 1. Attach this script to every trigger in the puzzle
; 2. In CK, create the GlobalVariables shown below and attach them to each GlobalVariable in this script in CK
; 3. In CK, set the variable "puzzlePosition" to a different value on each trigger.  
;	This is the value that locates it in the puzzle.  These should be values 1-5.  I assigned them in a clockwise
;	fashion such that the trigger at the top is 1, the one to the right is 2, and so forth around the circle.
; 4. Go down to the bottom of this script in the "OnInit" Event and set the arrays that are valid paths to unlock the puzzle.  
;	Currently, there are two example paths: [1,3,5,2,4,1] and [4,1,2,5,3,1]
; 5. Go down to the line that says "TODO: Make something interesting happen when the puzzle is solved" and put in your code

; This script was written to handle 6 selected plates.  If you need add one, do this:
; 1. Add a GlobalVariable "LuftSelectedPlate7" in the fashion shown below
; 2. Add a LuftSelectedPlate.SetValueInt(0) in the reset section
; 3. Add a line to the UpdateUserPath() Function:
; elseif LuftNumberOfSelectedPlates.GetValueInt() == 5
;		LuftSelectedPlate6.SetValueInt(puzzlePosition)
; 4. In the UserPath() Function, increase the total number of slots in the array: new int[6] and set that new slot: userPath[5] = LuftSelectedPlate6.GetValueInt()
; 5. Define the new slot on every validUserPath that is defined in the OnInit() Function

; Adding a validUserPath
; 1. Add the variable: int[] validPath3
; 2. Define it in the OnInit() function in the same fashion as the others
; 3. Add an OR statement to the if statement in UserPathIsValid() like this: || UserPathIsValidForPath(validPath3)

; Valid paths that unlock the puzzle, set automatically on init.  See the OnInit() event below
int[] validPath1
int[] validPath2

int Property puzzlePosition	Auto 	; The int that identifies where this piece lies in the puzzle

; Arrays can not be GlobalVariables, so each item in the array is stored globally rather than the array itself
GlobalVariable Property LuftSelectedPlate1 Auto 	; The puzzlePosition number of the first plate selected by the user
GlobalVariable Property LuftSelectedPlate2 Auto 	; The second plate number selected by the user...
GlobalVariable Property LuftSelectedPlate3 Auto
GlobalVariable Property LuftSelectedPlate4 Auto
GlobalVariable Property LuftSelectedPlate5 Auto
GlobalVariable Property LuftSelectedPlate6 Auto
GlobalVariable Property LuftNumberOfSelectedPlates Auto ; counter telling me how many plates have been selected
GlobalVariable Property HasFinished	Auto				; Prevent anything from happening if the player has already completed the puzzle

ObjectReference Property StairPillar Auto 				; The object to be activated when the puzzle is completed
GlobalVariable Property StairPillarActivated Auto 		; Keep track of whether the stairwell has been activated
String Property StairPillarAnimation Auto
ObjectReference Property DustEffect Auto 				; Dust to show on puzzle success
Sound Property RumbleSound Auto 				; Sound to play on puzzle success
Sound Property DoorSound Auto

Event OnActivate(ObjectReference akActivator)
	if (HasFinished.GetValueInt() != 1)
		Debug.Trace("OnActivate called")
		UpdateUserPath() ; Take into account which plate the user just activated
		Debug.Trace("I am getting through UpdateUserPath")

		bool validPath = UserPathIsValid()
		Debug.Trace("I am getting through UserPathIsValid")

		Debug.Trace(validPath)

		if validPath
			Debug.Trace("User path is valid")
			if LuftNumberOfSelectedPlates.GetValueInt() == 6
				PuzzleFinished()
			endif
		else
			ResetPuzzle()
		endif
		GoToState("Inactive")
		playAnimation("Up")
	endif
EndEvent

Function PuzzleFinished()	; What happens when the user solves the puzzle
	; TODO: Make something interesting happen when the puzzle is solved
	HasFinished.SetValueInt(1)
	if StairPillarActivated.GetValueInt() != 1
		Game.ShakeCamera(afStrength = 0.2, afDuration = 1)
		DustEffect.Activate(self)
		RumbleSound.Play(Game.GetPlayer())
		DoorSound.Play(StairPillar)
		StairPillar.PlayAnimationAndWait("256Up", "done")
		StairPillarActivated.SetValueInt(1)
	endIf
	Debug.Notification("Success!  You unlocked the puzzle!")
	Debug.Trace("Success! You unlocked the puzzle!")
	ResetPuzzle()	; Reset the puzzle so that it could be used again
EndFunction

Function ResetPuzzle()
	Debug.Notification("Reset")
	Debug.Trace("Reset")
	LuftSelectedPlate1.SetValueInt(0)
	LuftSelectedPlate2.SetValueInt(0)
	LuftSelectedPlate3.SetValueInt(0)
	LuftSelectedPlate4.SetValueInt(0)
	LuftSelectedPlate5.SetValueInt(0)
	LuftSelectedPlate6.SetValueInt(0)
	LuftNumberOfSelectedPlates.SetValueInt(0)
EndFunction

; TODO: There must be some way to reduce this hard-codedness
Function UpdateUserPath()
	Debug.Trace("puzzlePosition = " + puzzlePosition)
	LuftNumberOfSelectedPlates.SetValueInt(LuftNumberOfSelectedPlates.GetValueInt() + 1)
	if LuftNumberOfSelectedPlates.GetValueInt() == 1
		LuftSelectedPlate1.SetValueInt(puzzlePosition)
	elseif LuftNumberOfSelectedPlates.GetValueInt() == 2
		LuftSelectedPlate2.SetValueInt(puzzlePosition)
	elseif LuftNumberOfSelectedPlates.GetValueInt() == 3
		LuftSelectedPlate3.SetValueInt(puzzlePosition)
	elseif LuftNumberOfSelectedPlates.GetValueInt() == 4
		LuftSelectedPlate4.SetValueInt(puzzlePosition)
	elseif LuftNumberOfSelectedPlates.GetValueInt() == 5
		LuftSelectedPlate5.SetValueInt(puzzlePosition)
	elseif LuftNumberOfSelectedPlates.GetValueInt() == 6
		LuftSelectedPlate6.SetValueInt(puzzlePosition)
	endif
	Debug.Notification("LuftNumberOfSelectedPlates = " + LuftNumberOfSelectedPlates.GetValueInt())
EndFunction

bool Function UserPathIsValidForPath(int[] validArray)
	int[] userPath = UserPath() ; Turn the user's selections into a array to easily check it below
	Debug.Trace("userPath = " + userPath)
	int counter = 0
	while counter < LuftNumberOfSelectedPlates.GetValueInt()
		Debug.Trace("Testing if item selected at position " + counter + "is correct")
		if userPath[counter] != validArray[counter]
			return false
		endif
		counter += 1
	endWhile
	return true
EndFunction

int[] Function UserPath()
	int[] userPath = new int[6]
	userPath[0] = LuftSelectedPlate1.GetValueInt()
	userPath[1] = LuftSelectedPlate2.GetValueInt()
	userPath[2] = LuftSelectedPlate3.GetValueInt()
	userPath[3] = LuftSelectedPlate4.GetValueInt()
	userPath[4] = LuftSelectedPlate5.GetValueInt()
	userPath[5] = LuftSelectedPlate6.GetValueInt()
	return userPath
EndFunction

bool Function UserPathIsValid()
	Debug.Trace("UserPathIsValid called")
	if (UserPathIsValidForPath(validPath1) || UserPathIsValidForPath(validPath2))
		return true
	else
		return false
	endif
EndFunction

; Set the valid path arrays so that they don't need to be manually set on every object in CK
Event OnInit()
	validPath1 = new int[6]
	validPath1[0] = 1
	validPath1[1] = 3
	validPath1[2] = 5
	validPath1[3] = 2
	validPath1[4] = 4
	validPath1[5] = 1

	validPath2 = new int[6]
	validPath2[0] = 1
	validPath2[1] = 4
	validPath2[2] = 2
	validPath2[3] = 5
	validPath2[4] = 3
	validPath2[5] = 1
EndEvent
