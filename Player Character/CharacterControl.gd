extends CharacterBody2D

const WALL_SPEED_GRAVITY = 100.0
const SPEED = 400.0
const JUMP_VELOCITY = -600.0
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

func _on_coyote_timer_timeout():
	can_jump = false

func jump_cut():
	if velocity.y < -600:
		velocity.y = -600

func _on_wall_jump_timer_timeout():
	direction_true = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")



func _physics_process(delta):
	if can_jump == false and is_on_floor() or is_on_wall_only():
		can_jump = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Handle jump.
	if Input.is_action_just_released("jump") and can_jump:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_just_released("jump") and is_on_wall_only():
		can_jump = false
	
	if Input.is_action_just_released("jump"):
		jump_cut()
		can_jump = false
	
	if (is_on_floor_only() == false) and can_jump and $CoyoteTimer.is_stopped():
		$CoyoteTimer.start()
	
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



