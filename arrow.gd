tool
extends Sprite

var reg_scale=Vector2(5,5)
var passed_scale=Vector2(7,7)

export(bool)  var pressed setget set_pressed
export(Color) var color

func set_pressed(value:bool) -> void:
	pressed = value

func _ready():
	pass

func _process(delta:float) -> void:
	if pressed:
		modulate = lerp(modulate, color, 1.0)
		scale.y  = lerp(scale.y, passed_scale.y, 1.0)
		scale.x  = lerp(scale.x, passed_scale.y, 1.0)
	else:
		modulate = lerp(modulate, Color.gray, delta * 10.0)
		scale.y  = lerp(scale.y, reg_scale.y, delta * 10.0)
		scale.x  = lerp(scale.x, reg_scale.x, delta * 10.0)
