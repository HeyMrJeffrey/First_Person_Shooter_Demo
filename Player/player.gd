extends CharacterBody3D
class_name Player

#region Constants & Variables
# Default movement speed
const walking_speed: float = 7.5

# Default sprint speed
const sprinting_speed: float = 10

# Default crouch speed
const crouching_speed: float = 5

# Current movement speed
var current_speed: float = 0.0

# How far down the camera moves when the player enters the crouch position
var crouching_depth: float = -0.5

# True if crouching, false otherwise
var is_crouching: bool = false

# True if sprinting, false otherwise
var is_sprinting: bool = false

# True if sliding, false otherwise
var is_sliding: bool = false

# How high the player can jump in meters
var jump_height: float = 1.0

# How fast the player falls (from ledge, jumping, etc...)
var fall_multiplier: float = 2.5

# Players maximum hitpoints
var max_hitpoints: int = 100

# How far the player zooms in when aiming
var aim_multiplier: float = 0.7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Stores the mouses position change as difference between vector2's in screen space
var mouse_motion: Vector2 = Vector2.ZERO

# Getter/Setter controlling logic for changing player hitpoints
var hitpoints: int = max_hitpoints:
	set(value):
		if value < hitpoints:
			hit_by_enemy_audio.play()
			damage_animation_player.stop(false)
			damage_animation_player.play("TakeDamage")
		hitpoints = value
		if hitpoints <= 0:
			game_over_menu.game_over()
			

#endregion

#region Onready Variables

@onready var camera_pivot: Node3D = $CameraPivot
@onready var damage_animation_player: AnimationPlayer = $DamageTexture/DamageAnimationPlayer
@onready var game_over_menu: Control = $GameOverMenu
@onready var win_menu: Control = $WinMenu
@onready var ammo_handler: AmmoHandler = %AmmoHandler
@onready var smooth_camera: Camera3D = %SmoothCamera
@onready var smooth_camera_fov: float = smooth_camera.fov
@onready var weapon_camera: Camera3D = %WeaponCamera
@onready var weapon_camera_fov: float = weapon_camera.fov
@onready var hit_by_enemy_audio: AudioStreamPlayer = $HitByEnemyAudio
@onready var enemy_killed_audio: AudioStreamPlayer = $EnemyKilledAudio
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
@onready var crouch_to_stand_ray_cast: RayCast3D = $CrouchToStandRayCast
@onready var standing_mesh: MeshInstance3D = $StandingMesh
@onready var crouching_mesh: MeshInstance3D = $CrouchingMesh
#endregion

# Called once wyhen this node enters the scene tree
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called once every frame. 
# delta: float represents time between frames
# Used for framerate-dependent actions (like mouse movement / camera)
func _process(delta: float) -> void:
	handle_aiming_sprinting(delta)

# Called once every "physics" frame; which is locked to 60FPS
# delta: float represents time between frames
# Used for framerate-Independent actions/Physics Bodies (like our player character
func _physics_process(delta: float) -> void:
	handle_camera_rotation()
	
	if Input.is_action_pressed("crouch"):
		set_crouching(delta)
	elif can_standup(): #If there is nothing obstructing us standing up
		set_walking(delta)
		if Input.is_action_pressed("sprint"):
			set_sprinting(delta)

	# Add the gravity.
	if not is_on_floor():
		# is the player still going up?
		if velocity.y >= 0:
			velocity.y -= gravity * delta
		else:
			velocity.y -= gravity * delta * fall_multiplier
	
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = sqrt(jump_height * 2.0 * gravity)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction: Vector3 = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
		if Input.is_action_pressed("aim"):
			velocity.x *= aim_multiplier
			velocity.z *= aim_multiplier
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()

# Only called when the Operating System tells the Engine to handle input
# Useful for things like menu presses or mouse input:
#     (since this will happen every frame anyway if the player is playing)_
# Saves on _process calls
#     (things that lerp() must use one of the process functions)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.002 # = sensitivity for the mouse | use negative because positive is inverted for some reason???
			if Input.is_action_pressed("aim"):
				mouse_motion *= aim_multiplier
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE	

# True if the player can stand, False if the player is crouching and is obstructed from standing
func can_standup() -> bool:
	return !crouch_to_stand_ray_cast.is_colliding()

# Modifies the players (speed) (collision_shape_3d) (camera_position)
func set_crouching(delta: float) -> void:
	is_crouching = true
	is_sprinting = false
	current_speed = crouching_speed
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	standing_mesh.visible = false
	crouching_mesh.visible = true
	camera_pivot.position.y = lerp(camera_pivot.position.y, crouching_depth, delta*20)

# Modifies the players (speed) (collision_shape_3d) (camera_position)
func set_walking(delta: float) -> void:
	is_crouching = false
	is_sprinting = false
	current_speed = walking_speed
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	standing_mesh.visible = true
	crouching_mesh.visible = false
	camera_pivot.position.y = lerp(camera_pivot.position.y, 0.0, delta*20)

# Modifies the players (speed) (collision_shape_3d) (camera_position)
func set_sprinting(delta: float) -> void:
	is_crouching = false
	is_sprinting = true
	current_speed = sprinting_speed
	standing_collision_shape.disabled = true
	crouching_collision_shape.disabled = false
	standing_mesh.visible = true
	crouching_mesh.visible = false
	camera_pivot.position.y = lerp(camera_pivot.position.y, 0.0, delta*20)

# Modifies camera rotation and prevents "flipping"
func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO

# Modifies camera field of view for aiming and sprinting
func handle_aiming_sprinting(delta: float) -> void:		
	if Input.is_action_pressed("aim"):
		smooth_camera.fov = lerp(smooth_camera.fov, smooth_camera_fov*aim_multiplier, delta * 20)
		weapon_camera.fov = lerp(weapon_camera.fov, weapon_camera_fov*aim_multiplier, delta * 20)
	else:
		if is_sprinting and !is_crouching:
			smooth_camera.fov = lerp(smooth_camera.fov, smooth_camera_fov*1.2, delta * 30)
			weapon_camera.fov = lerp(weapon_camera.fov, weapon_camera_fov*1.2, delta * 30)
		else:
			smooth_camera.fov = lerp(smooth_camera.fov, smooth_camera_fov, delta * 30)
			weapon_camera.fov = lerp(weapon_camera.fov, weapon_camera_fov, delta * 30)

# Kludge function. Audio cant be attached to enemy since it is queue_free() upon death
func enemy_killed() -> void:
	enemy_killed_audio.play()

# Kludge function. No game manager so win condition is put on player for now.
func win_game() -> void:
	win_menu.win_game()
