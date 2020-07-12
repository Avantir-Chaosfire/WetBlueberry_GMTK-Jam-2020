extends Control

onready var killCountBar = get_node("MarginContainer/KillCount")

func SetKillCount(killCount):
	killCountBar.value = killCount
