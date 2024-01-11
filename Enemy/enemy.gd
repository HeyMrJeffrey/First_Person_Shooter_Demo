extends CharacterBody3D
class_name Enemy

#region Constants & Variables
# Default movement speed
const base_speed = 5.0

# Enemy maximum hitpoints
var max_hitpoints: int = 100

# Area in which the enemy can deal damage
var attack_range: float = 1.5

# How much damage is done to the player upon attack
var attack_damage: int = 20

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Reference to the player
var player

# True if the play is in attack range, or the enemy has been shot
var provoked: bool = false

# How close the player can be before the enemy locks on to attack
var aggro_range: float = 12.0

# Getter/Setter controlling logic for changing enemies hitpoints
var hitpoints: int = max_hitpoints:
#endregion
	set(value):
		hitpoints = value
		hit_by_player_audio.play()
		if hitpoints <= 0:
			player.enemy_killed()
			queue_free()
		provoked = true
			
#region Onready Variables
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var hit_by_player_audio: AudioStreamPlayer = $HitByPlayerAudio
#endregion

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
		velocity.x = direction.x * base_speed
		velocity.z = direction.z * base_speed
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed)
		velocity.z = move_toward(velocity.z, 0, base_speed)

	move_and_slide()
	
func look_at_target(direction: Vector3) -> void:
	var adjusted_direction: Vector3 = direction
	adjusted_direction.y = 0
	look_at(global_position + adjusted_direction, Vector3.UP, true)
	
func attack() -> void:
	player.hitpoints -= attack_damage
