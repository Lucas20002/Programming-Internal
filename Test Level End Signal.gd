extends Node2D
@onready var level_completed = $"CanvasLayer/Level Complete"
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.level_completed.connect(show_level_completed)

func show_level_completed():
	level_completed.show()
	get_tree().paused = true
