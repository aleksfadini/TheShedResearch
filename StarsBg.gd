extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var star_speed=0.2
var base_star_speed=3

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func speed_bump():
	$StarSpeed.play("speed_bump")


func _on_StarSpeedTimer_timeout():
	$ParallaxBg.scroll_offset+=Vector2(0,-star_speed*base_star_speed)
	pass # Replace with function body.
