extends Node2D

onready var entities = get_node("Entities")
onready var walls = get_node("Walls")

var ready = false

func _ready():
	ready = true

func GetEntitiesToRender():
	if ready:
		var entitiesToRender = entities.get_children()
		var bodiesToRender = []
		for entity in entitiesToRender:
			bodiesToRender.append(entity.get_node("Body"))
		return bodiesToRender + walls.get_children()
	return []
