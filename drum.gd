extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var sticks_up=load("res://graphics/DrummerStickHigh.png")
var sticks_med=load("res://graphics/DrummerStickMid.png")
var sticks_low=load("res://graphics/DrummerStickLow.png")
var eyesOpened=load("res://graphics/DrummerEyes01.png")
var eyesClosed=load("res://graphics/DrummerEyes02.png")

var stick_counter=0

var eyes_open=true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func kick() -> void:
#	$kick.scale = Vector2(1.2, 1.2)
	$Drummer/Instrument.scale = Vector2(1.05, 1.05)
#	$Drummer/Body.position.y+=1

func snare() -> void:
	$Drummer/Body.position.y+=1
	$Drummer/Clothes.position.y+=1
	$Drummer/Eyes.position.y+=1
	$Drummer/Hair.position.y+=1
	$Drummer/Sticks.position.y+=1
	$snare.position.y = 40
	sticks_up()
	stick_counter=2
	
func hat_closed() -> void:
	$hat.position.y = 20

func hat_open() -> void:
	$hat.position.y = 40

func _process(delta) -> void:
	$Drummer/Body.position.y = lerp($Drummer/Body.position.y, 0, delta * 10.0)
	$Drummer/Clothes.position.y = lerp($Drummer/Body.position.y, 0, delta * 10.0)
	$Drummer/Eyes.position.y = lerp($Drummer/Body.position.y, 0, delta * 10.0)
	$Drummer/Hair.position.y = lerp($Drummer/Body.position.y, 0, delta * 10.0)
	$Drummer/Sticks.position.y = lerp($Drummer/Body.position.y, 0, delta * 10.0)
	$Drummer/Instrument.scale = lerp($Drummer/Instrument.scale, Vector2(1, 1), delta * 10.0)
#	$kick.scale = lerp($kick.scale, Vector2(1, 1), delta * 10.0)
	$snare.position.y = lerp($snare.position.y, 0, delta * 10.0)
	$hat.position.y = lerp($hat.position.y, 0, delta * 10.0)

func sticks_up():
	$Drummer/Sticks.texture=sticks_up

func sticks_med():
	$Drummer/Sticks.texture=sticks_med

func sticks_low():
	$Drummer/Sticks.texture=sticks_low


func _on_SticksTimer_timeout():
	match stick_counter:
		2:
			sticks_low()
		1:
			sticks_med()
		0:
			sticks_up()
	if stick_counter >0:
		stick_counter-=1
	pass # Replace with function body.


func _on_EyesTimer_timeout():
	if eyes_open:
		eyes_open=false
		$Drummer/Eyes.texture=eyesOpened
		$EyesTimer.wait_time=rand_range(0.5,2)
	else:
		$EyesTimer.wait_time=rand_range(0.2,0.4)
		$Drummer/Eyes.texture=eyesClosed
		eyes_open=true
	$EyesTimer.start()
	pass # Replace with function body.
