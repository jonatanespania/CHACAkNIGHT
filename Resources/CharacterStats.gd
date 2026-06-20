extends Resource
class_name CharacterStats

signal level_up_notification()
signal update_stats()

class Ability:
	var min_modifier: float
	var max_modifier: float
	
	var ability_score: int = 25:
		set(value):
			ability_score = clamp(value, 0, 100)

	func _init(min:float, max:float) -> void:
		min_modifier = min
		max_modifier = max
	
	func percentile_lerp(min_boundary:float, max_boundary:float) -> float:
		return lerp(min_boundary, max_boundary, ability_score / 100.0)
		
	func get_modifier() -> float:
		return percentile_lerp(min_modifier, max_modifier)

	#BORRAR SUBIDA DEL LVL RANDOM
	func increase() -> void:
		ability_score += randi_range(2,5)
		
var level := 1
var xp := 0:
	set(value):
		xp = value
		var boundary = percentage_level_up_boundary()
		
		while xp > boundary:
			xp -= boundary
			level_up()
			boundary = percentage_level_up_boundary()
		update_stats.emit()
		
const MIN_DASH_COOLDOWN := 1.5
const MAX_DASH_COOLDOWN := 0.5

#Bonus de daño en attack
var strength := Ability.new(2.0, 12.0)
# Velocidad de movimiento
var speed := Ability.new(3.0, 7.0)
# HP Bonus
var endurance := Ability.new(5.0, 25.0)
# Crit Chance
var agility := Ability.new(0.05, 0.25)



func get_base_speed() -> float:
	return speed.get_modifier()

func get_damage_modifier() -> float:
	return strength.get_modifier()

func get_crit_change() -> float:
	return agility.get_modifier()
	
func get_max_hp() -> int:
	return 20 + int(level * endurance.get_modifier())
	
func get_dash_cooldown() -> float:
	return agility.percentile_lerp(MIN_DASH_COOLDOWN,MAX_DASH_COOLDOWN)

func level_up() -> void:
	level += 1
	strength.increase()
	agility.increase()
	speed.increase()
	endurance.increase()
	level_up_notification.emit()
#	printt(strength.ability_score,
#		agility.ability_score,
#		endurance.ability_score,
#		speed.ability_score
#		)

# METODO RPG
func percentage_level_up_boundary() -> int:
	return int(50 * pow(1.2, level))

# METODO POKEMON	
func cubic_level_up_boundary() -> int:
	return int(50 + pow(level, 3))
