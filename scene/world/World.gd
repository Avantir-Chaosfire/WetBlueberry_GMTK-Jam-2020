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
var entitiesToRender = []
	
func startGame():
	inGame = true
	currentLevel = levelClasses[currentLevelIndex].instance()
	add_child(currentLevel)
	
func _ready():
	startGame()

func _physics_process(_delta):
	if inGame:
		if not gameComplete and not victorious:
			var satisfiesVictoryCondition = false
			if satisfiesVictoryCondition:
				victory()
		var entitiesToRender = currentLevel.GetEntitiesToRender()
		renderSortEntities(entitiesToRender)
		
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
	
func renderSortEntities(entities):
	entities.sort_custom(self, "depthComparison")
	var z = 0
	for entity in entities:
		entity.z_index = z
		entity.z_as_relative = false
		z += 1

func depthComparison(a, b):
	return a.getGlobalPosition().y < b.getGlobalPosition().y
