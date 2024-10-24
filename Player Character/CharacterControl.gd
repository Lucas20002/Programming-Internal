extends CharacterBody2D

#how fast the player will slide down a wall
const WALL_SPEED_GRAVITY = 50.0

#how fast the player moves left to right
const SPEED = 400.0

#how high the player jumps in the air
const JUMP_VELOCITY = -500.0
const FLOAT_UP_VELOCITY = -200.0
const MAX_FLOAT_TIME = 0.5

var float_up_time = 0
var can_jump = true
var wall_sliding = false
var direction_true = true
var float_upwards = false

func jump():
	velocity.y = -JUMP_VELOCITY
	can_jump = false

#when the coyote timer ends can_jump is set to false which disables the players ability to jump
#until they are touching the ground or a wall
func _on_coyote_timer_timeout():
	can_jump = false

func jump_cut():
	if velocity.y < -500:
		velocity.y = -500

func _on_wall_jump_timer_timeout():
	direction_true = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	
	#When the player initially jumps it changes the variable can_jump to false, this disables the players ability to jump until
	#the player is either touching the floor or is touching a wall, in which then the variable will then be set back to true
	#allowing the player to jump again
	if can_jump == false and is_on_floor() or is_on_wall_only():
		can_jump = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# When the player presses the jump key and variable can_jump is equal to true, the player will jump and set can_jump to false
	if Input.is_action_just_released("jump") and can_jump:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump"):
		jump_cut()
		can_jump = false
	
	#if the player runs off of a ledge but hasn't jumped this starts CoyoteTime, CoyoteTime briefly allows the player to jump
	#even if they aren't touching the ground
	if (is_on_floor_only() == false) and can_jump and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	
	#(Lines 57-70) When the player is only on a wall they are able to jump again to the opposite wall, alternatively if the player were
	#to hold Left or Right depending on which side the wall is on, they will slowly slide down the wall, this can be used to
	#figure out where to jump to next or scale down a wall safely 
	if Input.is_action_just_released("jump") and is_on_wall_only():
		can_jump = false
	
	if is_on_wall_only():
		if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
			wall_sliding = true
		else:
			wall_sliding = false
		if wall_sliding:
			velocity.y += (WALL_SPEED_GRAVITY * delta)
			velocity.y = min(velocity.y, WALL_SPEED_GRAVITY)
	
	if wall_sliding and Input.is_action_pressed("jump") and direction_true:
		if Input.is_action_pressed("move_left"):
			velocity.x = 400
		if Input.is_action_pressed("move_right"):
			velocity.x = -400
	
	var direction = Input.get_axis("move_left", "move_right")
	if is_on_wall_only() and Input.is_action_just_pressed("jump"):
		velocity.x = -400 * direction
		velocity.y = 400 * direction
		direction_true = false
		float_upwards = true
		$wallJumpTimer.start()
	
	if Input.is_action_pressed("jump") and float_up_time < MAX_FLOAT_TIME:
		velocity.y = -400
		float_up_time * delta
	else:
		float_up_time = MAX_FLOAT_TIME
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction_true:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		move_and_slide()
#when the character falls out of the map it will reload the level and respawn the character
func respawn():
	get_tree().reload_current_scene()

func _on_boundary_body_entered(body):
	if body.is_in_group("Player"):
		print("Respawn")
		body.respawn()

func _on_goal_body_entered(body):
	if body.is_in_group("Player"):
		get_tree().change_scene_to_file("res://level_complete.tscn")
		print("Level Complete")
		print(Menu.finalTime)
