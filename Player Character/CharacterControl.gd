extends CharacterBody2D

@onready var level_completed = $"CanvasLayer/Level Complete"
func _ready():
	Global.level_completed.connect(show_level_completed)
#how fast the player will slide down a wall
const WALL_SPEED_GRAVITY = 50.0

const SPEED = 400.0
const JUMP_VELOCITY = -400.0
var can_jump = true

func jump():
	velocity.y = -JUMP_VELOCITY
	can_jump = false

func jump_cut():
	if velocity.y < -400:
		velocity.y = -400
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):
	if can_jump == false and is_on_floor():
		can_jump = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_released("ui_up") and can_jump == true:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("ui_up"):
		jump_cut()
		can_jump = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	if direction_true:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
	
func write_score_to_file():
		var file = FileAccess.open("res://LeaderBoard.txt", FileAccess.WRITE)
		print($end_level_score) #(end level time.score)
		file.seek_end()
		file.store_string("player name here: ")

func read_high_score():
		var content = ""
		if FileAccess.file_exists("res://LeaderBoard.txt"):
			var file = FileAccess.open("res://LeaderBoard.txt", FileAccess.READ)
			content = "high score: 0"
#when the character falls out of the map it will reload the level and respawn the character
func respawn():
	get_tree().reload_current_scene()

func _on_boundary_body_entered(body):
	if body.is_in_group("Player"):
		print("Respawn")
		body.respawn()

func _on_goal_body_entered(body):
	if body.is_in_group("Player"):
		Global.Timeractive == false
		Global.Level_Completed.emit()
		print("Level Complete")

func show_level_completed():
	level_completed.show()
	get_tree().paused = true
