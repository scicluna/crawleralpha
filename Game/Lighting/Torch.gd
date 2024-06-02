extends OmniLight3D

@export var min_intensity: float = 1.25
@export var max_intensity: float = 1.75
@export var flicker_speed: float = .25
@export var color_variation: float = .001

var base_color: Color

func _ready():
	base_color = self.light_color
	randomize()
	flicker()

func flicker():
	var new_intensity = randf_range(min_intensity, max_intensity)
	self.light_energy = new_intensity

	var new_color = base_color
	new_color.r = clamp(base_color.r + randf_range(-color_variation, color_variation), 0, 1)
	new_color.g = clamp(base_color.g + randf_range(-color_variation, color_variation), 0, 1)
	new_color.b = clamp(base_color.b + randf_range(-color_variation, color_variation), 0, 1)
	self.light_color = new_color

	await get_tree().create_timer(flicker_speed).timeout
	flicker()

func randf_range(min_value: float, max_value: float) -> float:
	return randf() * (max_value - min_value) + min_value
