extends KinematicBody

signal die
signal hit

export var boxer_health = 100
# how fast the player moves in metres per second
export var speed = 14
# the downward acceleration when in the air, in metres per second square
export var fall_acceleration = 75

var velocity = Vector3.ZERO

# vertical impulse applied to the character upon jumping in metres per second
export var jump_impulse = 20

# vertical impulse applied to the character upon bouncing over a mob in m/s
export var bounce_impulse = 16

func _physics_process(delta):
	# local variable to store the input dir
	var direction = Vector3.ZERO
	
	# check for move input and update the direction accordingly
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_fwd"):
		# Notice how we're working with the vector's x and z axes
		# X-Z plane is the ground plane
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.look_at(translation + direction, Vector3.UP)
	
	# Ground velocity
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	# vertical velocity
	velocity.y -= fall_acceleration * delta
	
	
	# Jumping
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y += jump_impulse
		
	# moving the character
	velocity = move_and_slide(velocity, Vector3.UP)

func lose_health():
	emit_signal("hit")
	boxer_health -= 10
	$AnimationPlayer.play("hit")
	
	if boxer_health <= 0:
		die()
func die():
	emit_signal("die")
	queue_free()
	
func _on_Area_body_entered(body):
	lose_health()
