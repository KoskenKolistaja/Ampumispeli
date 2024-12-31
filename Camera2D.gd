extends Camera2D

export var random_strength: float = 100.0
export var shake_fade: float = 5.0

var rng = RandomNumberGenerator.new()

var shake_strength: float = 0

func _ready():
	MetaData.camera = self

func _process(delta):
	
	if shake_strength > 0:
		shake_strength = lerp(shake_strength,0,shake_fade * delta)
		offset = randomOffset()

func apply_shake():
	shake_strength = random_strength

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))
