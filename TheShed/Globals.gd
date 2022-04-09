extends Node

var score:= 0
var timer_tot:= 0
const max_hearts:=10
var hearts_halfs:=20
var next_stage:=1

var game_version=SilentWolf.config.game_version

func _ready():
	reset_score()

func reset_score():
	score = 0
	timer_tot= 0
	hearts_halfs = max_hearts*2
#	hearts_halfs = 100000
