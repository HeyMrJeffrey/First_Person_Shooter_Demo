extends Camera3D

@export var smooth_speed: float = 50.0

func _physics_process(delta: float) -> void:
	var weight: float = clamp(delta * smooth_speed, 0.0, 1.0)
	global_transform = global_transform.interpolate_with(get_parent().global_transform, weight)
	global_position = get_parent().global_position
