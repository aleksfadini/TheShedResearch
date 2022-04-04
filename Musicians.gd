extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#var bass_eyes_open=true 
var harm_eyes_open=true
var bounce_down=false

var BassisteyesOpened=load("res://graphics/BassistEyes01.png")
var BassisteyesClosed=load("res://graphics/BassistEyes02.png")
var HarmonisteyesOpened=load("res://graphics/HarmonistEyes01.png")
var HarmonisteyesClosed=load("res://graphics/HarmonistEyes02.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_BandAnim_timeout():
#	var d1=randf()
#	if d1 >= 0.5:
#	else:
	var down=2
	if bounce_down:
		bounce_down=false
		$Harmonist/Body.position.y=down
		$Harmonist/Eyes.position.y=down
		$Harmonist/Hair.position.y=down
		$Harmonist/Clothes.position.y=down
		$Bassist/Body.position.y=down
		$Bassist/Eyes.position.y=down
		$Bassist/Hair.position.y=down
		$Bassist/Clothes.position.y=down
		$Bassist/Instrument.position.y=down
		$BandAnim.wait_time=0.2
	else:
		$BandAnim.wait_time=0.8
		$Harmonist/Body.position.y=0
		$Harmonist/Eyes.position.y=0
		$Harmonist/Hair.position.y=0
		$Harmonist/Clothes.position.y=0
		$Bassist/Body.position.y=0
		$Bassist/Eyes.position.y=0
		$Bassist/Hair.position.y=0
		$Bassist/Clothes.position.y=0
		$Bassist/Instrument.position.y=0
		bounce_down=true
#	if bass_eyes_open:
#		bass_eyes_open=false
#		$Bassist/Eyes.texture=BassisteyesOpened
#		$EyesAnim.wait_time=rand_range(1,4)
#	else:
#		$EyesAnim.wait_time=rand_range(0.2,0.4)
#		$Bassist/Eyes.texture=BassisteyesClosed
#		bass_eyes_open=true
	$BandAnim.start()
	pass # Replace with function body.


func _on_EyesAnim_timeout():
	if harm_eyes_open:
		harm_eyes_open=false
		$Harmonist/Eyes.texture=HarmonisteyesOpened
		$Bassist/Eyes.texture=BassisteyesOpened
		$EyesAnim.wait_time=rand_range(0.5,2)
	else:
		$EyesAnim.wait_time=rand_range(0.2,0.4)
		$Harmonist/Eyes.texture=HarmonisteyesClosed
		$Bassist/Eyes.texture=BassisteyesClosed
		harm_eyes_open=true
	$EyesAnim.start()
	pass # Replace with function body.
