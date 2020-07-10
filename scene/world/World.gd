extends Node2D

#var victoryMenuClass = preload("res://scene/ui/Victory/Victory.tscn")
#var finalVictoryMenuClass = preload("res://scene/ui/FinalVictory/FinalVictory.tscn")

var levelClasses = [
	preload("res://scene/level/1/Level1.tscn")
]

onready var gui = get_node("GUI")
onready var victorySoundEffect = get_node("VictorySoundEffect")
onready var finalVictorySoundEffect = get_node("FinalVictorySoundEffect")

var currentLevel = null
var currentLevelIndex = 0
var victorious = false
var gameComplete = false
var inGame = false
	
func startGame():
	inGame = true
	currentLevel = levelClasses[currentLevelIndex].instance()
	add_child(currentLevel)
	
func _ready():
	startGame()

func _physics_process(_delta):
	if inGame and not gameComplete:
		if not victorious:
			var satisfiesVictoryCondition = false
			if satisfiesVictoryCondition:
				victory()
		
func victory():
	victorious = true
	if currentLevelIndex < len(levelClasses) - 1:
		victorySoundEffect.play()
		#gui.add_child(victoryMenuClass.instance())
	else:
		finalVictorySoundEffect.play()
		advanceLevel()
		
func advanceLevel():
	if not gameComplete:
		remove_child(currentLevel)
		currentLevel.queue_free()
		currentLevelIndex += 1
		if currentLevelIndex >= len(levelClasses):
			completeGame()
		else:
			victorious = false
			currentLevel = levelClasses[currentLevelIndex].instance()
			add_child(currentLevel)
	
func restartLevel():
	if not gameComplete:
		victorious = false
		remove_child(currentLevel)
		currentLevel.queue_free()
		currentLevel = levelClasses[currentLevelIndex].instance()
		add_child(currentLevel)
		
func restartGame():
	victorious = false
	gameComplete = false
	currentLevelIndex = 0
	startGame()
		
func completeGame():
	victorious = true
	gameComplete = true
	#gui.add_child(finalVictoryMenuClass.instance())
	
func getCharacter():
	return currentLevel.get_node("Character")
