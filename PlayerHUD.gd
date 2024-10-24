extends Node2D

var level_time = 0.0
var start_level_msec = 0.0
@onready var level_time_label = %LevelTimeLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	start_level_msec = Time.get_ticks_msec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	level_time = Time.get_ticks_msec() - start_level_msec
	level_time_label.text = str(level_time / 1000.0)
	Menu.finalTime = str(level_time / 1000.0)

func write_score_to_file():
	var file = FileAccess.open("score file here", FileAccess.WRITE)
	print() #(end level time.score)
	file.seek_end()
	file.store_string("player name here: " + str()) #str(end level time.score)

func read_high_score():
	var content = ""
	if FileAccess.file_exists("score file here"):
		var file = FileAccess.open("score file here", FileAccess.READ)
		content = "high score: 0"
		#timer_scores.txt = content
