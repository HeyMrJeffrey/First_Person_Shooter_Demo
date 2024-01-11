extends Node
class_name AmmoHandler

#region Onready Variables
@onready var pickup_sound_effect: AudioStreamPlayer = $PickupSoundEffect
@export var ammo_label: Label
@onready var weapon_handler: Node3D = %WeaponHandler
#endregion

# Stores the various ammo types
enum ammo_type {
	BULLET,
	SMALL_BULLET 
}

# Dictionary stores current ammo amount relative to its type
var ammo_storage: Dictionary = {
	ammo_type.BULLET: 10,
	ammo_type.SMALL_BULLET: 60
}

# Returns true if the given ammo type has any ammo, false otherwise
func has_ammo(type: ammo_type) -> bool:
	return ammo_storage[type] > 0

# Removes ammo of the ammo type used and updates the appropriate label
func use_ammo(type: ammo_type) -> void:
	if has_ammo(type):
		ammo_storage[type] -= 1
		update_ammo_label(weapon_handler.get_active_weapon_ammo())

# Adds ammo of the ammo type used and updates the appropriate label
func add_ammo(type: ammo_type, amount: int) -> void:
	pickup_sound_effect.play()
	ammo_storage[type] += amount
	update_ammo_label(weapon_handler.get_active_weapon_ammo())

# Updates the ammo for the given ammo type
func update_ammo_label(type: ammo_type) -> void:
	ammo_label.text = str(ammo_storage[type])
