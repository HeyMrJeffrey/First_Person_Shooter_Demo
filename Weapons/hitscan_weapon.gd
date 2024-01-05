extends Node3D

@export var fire_rate: float = 14.0
@export var recoil: float = 0.05
@export var weapon_mesh: Node3D
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_pressed("fire"):
		if cooldown_timer.is_stopped():
			shoot()
	
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta*5.0)
			
func shoot() -> void:
	print(ray_cast_3d.get_collider())
	cooldown_timer.start(1.0/fire_rate)
	weapon_mesh.position.z += recoil
