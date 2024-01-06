extends CharacterBody3D
class_name Enemy

const SPEED = 5.0

@export var max_hitpoints: int = 100
@export var attack_range: float = 1.5
@export var attack_damage: int = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var player
var provoked: bool = false
var aggro_range: float = 12.0
var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value
		if hitpoints <= 0:
			queue_free()
		provoked = true
			
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

func _process(_delta: float) -> void:
	if provoked:
		navigation_agent_3d.target_position = player.global_position

func _physics_process(delta: float) -> void:	
	var next_position = navigation_agent_3d.get_next_path_position()
	
	var direction: Vector3 = global_position.direction_to(next_position)
	var distance: float = global_position.distance_to(player.global_position)
	
	if distance <= aggro_range:
		provoked = true
	else:
		provoked = false
	
	if provoked:
		if distance <= attack_range:
			playback.travel("Attack")
	
	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
func look_at_target(direction: Vector3) -> void:
	var adjusted_direction: Vector3 = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)
	
func attack() -> void:
	player.hitpoints -= attack_damage
