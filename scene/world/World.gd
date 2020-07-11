extends Node2D

var titleMenuClass = preload("res://scene/menu/title/Title.tscn")
var victoryMenuClass = preload("res://scene/menu/victory/Victory.tscn")
var finalVictoryMenuClass = preload("res://scene/menu/final_victory/FinalVictory.tscn")

var levelClasses = [
	preload("res://scene/level/1/Level1.tscn"),
	preload("res://scene/level/2/Level2.tscn")
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
	gui.add_child(titleMenuClass.instance())
	inGame = true
	currentLevel = levelClasses[currentLevelIndex].instance()
	add_child(currentLevel)
	entitiesToRender = currentLevel.GetEntitiesToRender()
	
func _ready():
	startGame()

func _physics_process(_delta):
	if inGame:
		if not gameComplete and not victorious:
			var satisfiesVictoryCondition = false
			if satisfiesVictoryCondition:
				victory()
		renderSortEntities(entitiesToRender)
		
func victory():
	victorious = true
	if currentLevelIndex < len(levelClasses) - 1:
		victorySoundEffect.play()
		gui.add_child(victoryMenuClass.instance())
	else:
		finalVictorySoundEffect.play()
		completeGame()
		
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
			entitiesToRender = currentLevel.GetEntitiesToRender()
	
func restartLevel():
	if not gameComplete:
		victorious = false
		call_deferred("unloadNode", currentLevel)
		currentLevel = levelClasses[currentLevelIndex].instance()
		call_deferred("loadNode", currentLevel)
		
func restartGame():
	victorious = false
	gameComplete = false
	inGame = true
	currentLevelIndex = 0
	startGame()
		
func completeGame():
	victorious = true
	gameComplete = true
	inGame = false
	gui.add_child(finalVictoryMenuClass.instance())
	
func CheckVictory():
	print("CheckVictory")
	var isVictorious = true
	for entity in entitiesToRender:
		if entity.IsEnemy() and not entity.dead:
			isVictorious = false
			break
	if isVictorious:
		victory()
	print("Done")
		
func unloadNode(node):
	remove_child(node)
	node.queue_free()
	
func loadNode(node):
	add_child(node)
	entitiesToRender = currentLevel.GetEntitiesToRender()
	
func renderSortEntities(entities):
	entities.sort_custom(self, "depthComparison")
	var z = 0
	for entity in entities:
		entity.z_index = z
		entity.z_as_relative = false
		z += 1

func depthComparison(a, b):
	return a.getGlobalPosition().y < b.getGlobalPosition().y
	
func FailLevel():
	restartLevel()
