extends Node3D

@export var fire_rate: float = 14.0
@export var recoil: float = 0.05
@export var weapon_mesh: Node3D
@export var weapon_damage: int = 15
@export var muzzle_flash: GPUParticles3D
@export var sparks: PackedScene
@export var automatic: bool
@export var ammo_handler: AmmoHandler
@export var ammo_type: AmmoHandler.ammo_type

@onready var cooldown_timer: Timer = $CooldownTimer
@onready var weapon_position: Vector3 = weapon_mesh.position
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if automatic:
		if Input.is_action_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	else:
		if Input.is_action_just_pressed("fire"):
			if cooldown_timer.is_stopped():
				shoot()
	weapon_mesh.position = weapon_mesh.position.lerp(weapon_position, delta*5.0)
			
func shoot() -> void:
	if ammo_handler.has_ammo(ammo_type):
		ammo_handler.use_ammo(ammo_type)
		muzzle_flash.restart()
		var collider = ray_cast_3d.get_collider()
		cooldown_timer.start(1.0/fire_rate)
		weapon_mesh.position.z += recoil
		
		if collider is Enemy:
			collider.hitpoints -= weapon_damage
		
		if collider != null:
			var spark = sparks.instantiate()
			add_child(spark)
			spark.global_position = ray_cast_3d.get_collision_point()
