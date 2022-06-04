extends KinematicBody2D


const WALK_FORCE = 200
const WALK_MAX_SPEED = 100
const FALL_MAX_SPEED = 100
const STOP_FORCE = 270
const JUMP_SPEED = 170
const MASS = 8

const DASH_FORCE = 1200
const DASH_MAX_SPEED = 200
const DASH_SPEED = 120

enum {CONTROL, DASH}
var State = CONTROL

var velocity = Vector2(0,0)
var was_on_floor = false

var last_key_pressed = Vector2.RIGHT

var nb_jump := 0
export(int,1,2) var player_number:=1
var nb=""

onready var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	if player_number == 2:
		nb="_2"
	
func change_state(new_state)->void:
	if new_state == CONTROL:
		$CollisionShape2D.disabled = false
	elif new_state == DASH:
		velocity= last_key_pressed*DASH_SPEED
		$Timer_dash.start()
		$CollisionShape2D.disabled = true
		
	State = new_state

func _physics_process(delta):

	if State == CONTROL:
		
		manage_looking_dir()
		var walk = 0.0
		
		if is_on_floor():
			walk = WALK_FORCE *(Input.get_action_strength("ui_right"+nb) - Input.get_action_strength("ui_left"+nb))
		else:
			walk = WALK_FORCE *(Input.get_action_strength("ui_right"+nb) - Input.get_action_strength("ui_left"+nb))
		# Slow down the player if they're not trying to move.
		if abs(walk) < WALK_FORCE * 0.2:
			if is_on_floor():
				# The velocity, slowed down a bit, and then reassigned.
				velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
			else:
				velocity.x = move_toward(velocity.x, 0, STOP_FORCE * delta)
		else:
			velocity.x += walk * delta
		# Clamp to the maximum horizontal movement speed.
		velocity.x = clamp(velocity.x, -WALK_MAX_SPEED, WALK_MAX_SPEED)

		# Vertical movement code. Apply gravity.
		if not is_on_floor():
			velocity.y += gravity * delta * MASS
		
		velocity.y = clamp(velocity.y, -2*FALL_MAX_SPEED, FALL_MAX_SPEED)
		
		var snap = Vector2.DOWN
		if (is_on_floor() or nb_jump>0) and Input.is_action_just_pressed("ui_up"+nb):
			velocity.y = -JUMP_SPEED
			nb_jump -= 1
			snap = Vector2.ZERO
			#create_jump_particles()
		
		# Move based on the velocity and snap to the ground.
		velocity = move_and_slide_with_snap(velocity, snap, Vector2.UP,true,4,0.9,false)
		
		if is_on_floor():
			nb_jump = 1
		
		if Input.is_action_just_pressed("ui_dash"):
			change_state(DASH)
		
	elif State == DASH:
		
		velocity = velocity.move_toward(last_key_pressed*DASH_FORCE, DASH_FORCE * delta)
		
		velocity = move_and_slide(velocity)
	
	
	

func _process(delta):
	
	# animation
	
	# jumping particules
	if is_on_floor():
		if not(was_on_floor):
			#_land()
			was_on_floor= true 
	else:
		was_on_floor = false
	
	if State == CONTROL:
		if Input.is_action_pressed("ui_right"+nb):
			$AnimatedSprite.flip_h = false
			$AnimatedSprite.play("run")
		elif Input.is_action_pressed("ui_left"+nb):
			$AnimatedSprite.flip_h = true
			$AnimatedSprite.play("run")
		else:
			$AnimatedSprite.play("idle")
	elif State == DASH:
		$AnimatedSprite.play("run")
		if last_key_pressed == Vector2.RIGHT:
			$AnimatedSprite.flip_h = false
		else:
			$AnimatedSprite.flip_h = true
		



func manage_looking_dir():
	if Input.is_action_pressed("ui_left"+nb):
		last_key_pressed = Vector2.LEFT
	else: #Input.is_action_just_pressed("ui_right"):
		last_key_pressed = Vector2.RIGHT
	
#	if Input.is_action_just_pressed("ui_up"):
#		last_key_pressed = Vector2.UP
#	elif Input.is_action_just_pressed("ui_down"):
#		last_key_pressed = Vector2.DOWN
		

func _on_Timer_dash_timeout():
	change_state(CONTROL)
