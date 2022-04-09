extends Node2D

onready var textInst=load("res://UI/SmallMsg.tscn")
var playNoteTrack=Assets.playNoteTrack1
var yeah_points:=10
var miss_points:=-2
var early_points:=-2
var wut_points:=-4
var streak_points_5:=20
var streak_points_10:=50
var streak_points_20:=100
var streak_points_50:=500
var streak_points_100:=1500
var streak_points_200:=5000
var streak_points_300:=10000
var streak_points_400:=20000
var streak_points_1000:=100000
var score_tot:=0
var timer_tot:=0
var countdown:=0
var play_note := true
var streak:=0
var delta_sum_ := 0.0
var left := []

var stage:=1
var stage_finished:=false

var spacebar_active:=false
var next_level_test=true

onready var stuff := {
	36: {
		"color": Color.purple,
		"key": "left",
		"node": get_node("buttons/left"),
		"queue": []
	},
	38: {
		"color": Color.aqua,
		"key": "up",
		"node": get_node("buttons/up"),
		"queue": []
	},
	41: {
		"color": Color.blue,
		"key": "down",
		"node": get_node("buttons/down"),
		"queue": []
	},
	42: {
		"color": Color.red,
		"key": "right",
		"node": get_node("buttons/right"),
		"queue": []
	}
}

var animation := {
	36: {
		"call": "kick",
	},
	38: {
		"call": "snare",
	},
	41: {
		"call": "kick",
	},
	42: {
		"call": "snare",
	}
}

var animation_queue := []

func _ready() -> void:
	setup_stage()
	for s in stuff.values():
		s.node.color = s.color
#	if play_note:
#	$music.stream=playNoteTrack
	mute_all()
	if stage==1:
		Globals.reset_score()
	else:
		score_tot=Globals.score
		timer_tot=Globals.timer_tot
	update_score()
	$crt/UI/Health.update_health()
#	if stage ==1:
#		countdown=1

func _process(delta):
	delta_sum_ += delta
	for s in stuff.values():
		if Input.is_action_just_pressed(s.key):
			if not s.queue.empty():
				if s.queue.front().test_hit(delta_sum_):
#					s.node.perfect()
					s.queue.pop_front().hit(s.node.global_position)
					perfect(s.node.global_position,s.color)
#					print("hit")
					if play_note:
						var node_nr=1
						match s.key:
							"left": node_nr=1
							"up": node_nr=2
							"down": node_nr=4
							"right": node_nr=3
						$Timers.get_node("Exp"+str(node_nr)).start_expiration()
						update_score(yeah_points)
						update_streak(1)
				else:
					play_random_clink()
					update_score(early_points)
					update_streak(0)
					early(s.node.global_position)
#					print("TOO EARLY")
			else:
				play_random_clink()
				update_streak(0)
				update_score(wut_points)
#				print("WUT??")
		if not s.queue.empty():
			if s.queue.front().test_miss(delta_sum_):
#				play_random_clink()
				s.queue.pop_front().miss()
				miss(s.node.global_position)
				update_score(miss_points)
				update_streak(0)
#				print("miss")
	for s in stuff.values():
		s.node.pressed = Input.is_action_pressed(s.key)
#	if delta_sum_ >= 0.1 and not $midi1.playing:
	if delta_sum_ >= 0.1 and not $midi1.playing and not stage_finished:
#		$Timers/CountdownTimer.start()
		$midi1.play()
#	if delta_sum_ >= 1.0 and not $midi2.playing:
	if delta_sum_ >= 1.1 and not $midi2.playing and not stage_finished:
		$midi2.play()
#	if delta_sum_ >= 1.0 and not $music.playing:
	if delta_sum_ >= 1.1 and not $music.playing and not stage_finished:
		spacebar_active=true
		$music.play()
#	if delta_sum_ >= 1.04 and not $Sample1.playing:
		if play_note:
			$Sample1.play()
			$Sample2.play()
			$Sample3.play()
			$Sample4.play()
			
	# Uncomment the two lines below to autowin after 10 secs
#	if delta_sum_ >= 2:
#		show_score_gained("+1000")
#		_on_music_finished()
#		win()
#	if delta_sum_ >= 20 and next_level_test:
#		next_level_test=false
#		_on_music_finished()
		
		
#	if (Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_accept")) and not stage_finished:
#		if spacebar_active:
#			get_tree().change_scene("res://Exit.tscn")
#	if $music.get_playback_position()>=5 and test_stage_finished:
#		test_stage_finished=false
#		_on_music_finished()

func _on_midi_event(channel, event):
#	print("event: ", event)
#	print("channel: ", channel)
#	print("note: ", event.note)
	print("track name: ", channel.track_name)
#	print("event type: ", event.type)
#	print("------------------")
	if channel.track_name == "Falcon" or channel.track_name == "Falcon 2":
		print("note: ", str(event.note))
		var s = stuff.get(event.note)
		if s and event.type == 1:
			var i = preload("res://note.tscn").instance()
			add_child(i)
			if stage == 1:
				i.expected_time = delta_sum_ + 0.95
			elif stage == 2:
				i.expected_time = delta_sum_ + 0.95
			elif stage == 3:
				i.expected_time = delta_sum_ + 0.95
			i.global_rotation   = s.node.global_rotation
			i.global_position.y = -400
			i.global_position.x = s.node.global_position.x
			i.color             = s.color
			s.queue.push_back(i)

func _on_midi2_event(channel, event):
	if channel.track_name == "Falcon" or channel.track_name == "Falcon 2":
		var a = animation.get(event.note)
		if a and event.type == 1:
			$drum.call(a.call)

func perfect(glo_pos,color):
	show_text(glo_pos,"YEAH!",color)

func early(glo_pos):
	show_text(glo_pos,"early")

func miss(glo_pos):
	show_text(glo_pos,"miss")
	
func show_text(glo_pos,text,color:=Color(1,1,1)):
	var i = textInst.instance()
	$Notifications/HitNotifications.add_child(i)
	i.global_position=glo_pos
	if text=="YEAH!":
		i.modulate=color
	i.show_text(text)
	
func mute_all():
	$Sample1.volume_db=-80
	$Sample2.volume_db=-80
	$Sample3.volume_db=-80
	$Sample4.volume_db=-80

func update_score(score:=0):
	score_tot+=score
	if score >0:
		$crt/UI/Score.modulate=Color(0.5,1,0.5)
	else:
		$crt/UI/Score.modulate=Color(1,0,0)
		
	Globals.score=score_tot
	print("global score", Globals.score)
	$crt/UI/Score/Points.text=str(score_tot)
	if score==miss_points or score==early_points:
		Globals.hearts_halfs-=1
		$crt/UI/Health.update_health()
	if score==wut_points:
		Globals.hearts_halfs-=2
		$crt/UI/Health.update_health()
	if score==streak_points_5:
		fly_heart(1)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+1,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_10:
		fly_heart(2)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+2,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_20:
		fly_heart(3)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+4,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_50:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_100:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_200:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_300:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_400:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if score==streak_points_1000:
		fly_heart(4)
		Globals.hearts_halfs=clamp(Globals.hearts_halfs+8,0,20)
		$crt/UI/Health.update_health()
	if Globals.hearts_halfs<=0:
		lose()
	if score>=streak_points_5:
		show_score_gained("+"+str(score))

func _on_PlayTimer_timeout():
	timer_tot+=1
	Globals.timer_tot=timer_tot
	$crt/UI/Time/Points.text=str(timer_tot)

func update_streak(nr=0):
	if nr==0:
		streak=0
	else:
		streak+=nr
	if streak==3:
		show_msg("Streak\n3x!!!",1)
		update_score(10)
	if streak==5:
		show_msg("Streak\n5x!!!",2)
		update_score(streak_points_5)
#		$applause.play()
	if streak==10:
		show_msg("Streak\n10x!!!",3)
		update_score(streak_points_10)
#		$applause.play()
	if streak==20:
		$applause.play()
		show_msg("Streak\n20x!!!",4)
		update_score(streak_points_20)
	if streak==50:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_50)
	if streak==100:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_100)
	if streak==200:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_200)
	if streak==300:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_300)
	if streak==400:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_400)
	if streak==1000:
		$applause.play()
		show_msg("Streak\n50x!!!",5)
		update_score(streak_points_1000)

func show_msg(text_msg,lvl=1):
	$Msg/Cont/Label.text=text_msg
	$Msg/Cont/MegaParticles.modulate=Color(1,1,1)
	match lvl:
		1:
			$Msg/Cont/BecomeBig.play("Lev1")
		2:
			$Msg/Cont/MiniParticles.emitting=true
			$Msg/Cont/BecomeBig.play("Lev2")
		3:
			$Msg/Cont/MegaParticles.emitting=true
			$Msg/Cont/BecomeBig.play("Lev3")
		4:
			$Msg/Cont/MegaParticles.emitting=true
			$Msg/Cont/BecomeBig.play("Lev4")
		5:
			$Msg/Cont/MegaParticles.modulate=Color(1,0,1)
			$Msg/Cont/MegaParticles.emitting=true
			$Msg/Cont/BecomeBig.play("Lev5")

func show_lvl_msg(text:=""):
	$Notifications/LvlMessage.show_lvl_msg(text)

func _on_CountdownTimer_timeout():
	var first_countdown=1.7
	var second_countdown=1.0
	var inter_countdowns=0.65
	if stage == 2:
		first_countdown=1.2
		second_countdown=0.9
		inter_countdowns=0.6
	if stage == 3:
		first_countdown=1.05
		second_countdown=0.85
		inter_countdowns=0.55
	if countdown == 0:
		countdown_msg("1...")
		$Timers/CountdownTimer.wait_time=first_countdown
	if countdown == 1:
		countdown_msg("2...")
		$Timers/CountdownTimer.wait_time=second_countdown
	if countdown == 2:
		countdown_msg("1,")
		$Timers/CountdownTimer.wait_time=inter_countdowns
	if countdown == 3:
		countdown_msg("2,")
		$Timers/CountdownTimer.wait_time=inter_countdowns
	if countdown == 4:
		countdown_msg("3,")
		$Timers/CountdownTimer.wait_time=inter_countdowns
	if countdown == 5:
		countdown_msg("4!")	
		$Timers/CountdownTimer.wait_time=inter_countdowns
	countdown+=1
	$Timers/CountdownTimer.start()

func countdown_msg(text:=""):
	$Notifications/BeginMsg.show_begin_msg(text)

func play_random_clink():
#	print("clinks: ", Assets.clinks)
	$Wrong.stream=Assets.clinks[randi() % Assets.clinks.size()]
#	$Wrong.stream=Assets.clinks[1]
	$Wrong.play()

func setup_stage():
	stage=Globals.next_stage
	if stage==1:
		$midi1.file=Assets.midiTrack1
		$midi2.file=Assets.midiTrack1
		$Sample1.stream=Assets.kickTrack1
		$Sample2.stream=Assets.snareTrack1
		$Sample3.stream=Assets.hatsTrack1
		$Sample4.stream=Assets.tomTrack1
		$music.stream=Assets.playNoteTrack1
	elif stage==2:
		$midi1.file=Assets.midiTrack2
		$midi2.file=Assets.midiTrack2
		$Sample1.stream=Assets.kickTrack2
		$Sample2.stream=Assets.snareTrack2
		$Sample3.stream=Assets.hatsTrack2
		$Sample4.stream=Assets.tomTrack2
		$music.stream=Assets.playNoteTrack2
		$Bg/Sprite.texture=Assets.bgStage2
		$Musicians/Bassist/Body.texture=Assets.BassistBodyLvl2
		$Musicians/Bassist/Legs.texture=Assets.BassistLegs
		$Musicians/Bassist/Clothes.texture=Assets.BassistClothesLvl2
		$Musicians/Bassist/Clothes.show()
		$Musicians/Bassist/Hair.texture=Assets.BassistHairLvl2
		$Musicians/Bassist/Hair.show()
		$Musicians/Bassist/Instrument.texture=Assets.BassistInstrumentLvl2
		$Musicians/Harmonist/Instrument.texture=Assets.HarmonistInstrumentLvl2
		$Musicians/Harmonist/Body.texture=Assets.HarmonistBodyLvl2
		$Musicians/Harmonist/Legs.texture=Assets.HarmonistLegs
		$Musicians/Harmonist/Clothes.texture=Assets.HarmonistClothesLvl2
		$Musicians/Harmonist/Clothes.show()
		$Musicians/Harmonist/Hair.texture=Assets.HarmonistHairLvl2
		$Musicians/Harmonist/Hair.show()
		$Musicians/Harmonist/Instrument.texture=Assets.HarmonistInstrumentLvl2
	elif stage==3:
		$midi1.file=Assets.midiTrack3
		$midi2.file=Assets.midiTrack3
		$Sample1.stream=Assets.kickTrack3
		$Sample2.stream=Assets.snareTrack3
		$Sample3.stream=Assets.hatsTrack3
		$Sample4.stream=Assets.tomTrack3
		$music.stream=Assets.playNoteTrack3
		$Bg/Sprite.texture=Assets.bgStage3
		$Musicians/Bassist/Body.texture=Assets.BassistBodyLvl3
		$Musicians/Bassist/Legs.texture=Assets.BassistLegsLvl3
		$Musicians/Bassist/Clothes.texture=Assets.BassistClothesLvl3
		$Musicians/Bassist/Clothes.show()
		$Musicians/Bassist/Hair.texture=Assets.BassistHairLvl3
		$Musicians/Bassist/Hair.show()
		$Musicians/Bassist/Instrument.texture=Assets.BassistInstrumentLvl3
		$Musicians/Harmonist/Instrument.texture=Assets.HarmonistInstrumentLvl3
		$Musicians/Harmonist/Body.texture=Assets.HarmonistBodyLvl3
		$Musicians/Harmonist/Legs.texture=Assets.HarmonistLegs
		$Musicians/Harmonist/Clothes.texture=Assets.HarmonistClothesLvl3
		$Musicians/Harmonist/Clothes.show()
		$Musicians/Harmonist/Hair.texture=Assets.HarmonistHairLvl3
		$Musicians/Harmonist/Hair.show()
		$Musicians/Harmonist/Instrument.texture=Assets.HarmonistInstrumentLvl3

func _on_music_finished():
	$music.stop()
	stage_finished = true
	hide_behind_game_over()
	$Notifications.show()
	$Notifications/LvlMessage.show()
	if stage==1:
		Globals.next_stage=2
		show_lvl_msg("Stage 1 completed!\nGet ready for\nStage 2!!!")
	if stage==2:
		Globals.next_stage=3
		show_lvl_msg("Stage 2 completed!\nGet ready for\nStage 3!!!")
	if stage==3:
		Globals.next_stage=4
		win()
#		show_lvl_msg("Stage 3 completed!\nYou are not human!")
		pass # Replace with function body.

func load_next_stage():
	$Notifications/LvlMessage.hide()
	if not Globals.next_stage==4:
		get_tree().change_scene("res://Main.tscn")
	else:
		get_tree().change_scene("res://Exit.tscn")

func fly_heart(halfs:=1):
	$Notifications/FlyHeart.fly_heart(halfs)

func lose():
	get_tree().paused=true
	hide_behind_game_over()
	$GameOver.show()
	$Notifications/BeginMsg.hide()
#	$Notifications.hide()
	if stage ==1:
		$GameOver/GameOverSound.stream=Assets.game_over_stage1
	elif stage ==2:
		$GameOver/GameOverSound.stream=Assets.game_over_stage2
	elif stage ==3:
		$GameOver/GameOverSound.stream=Assets.game_over_stage3
	$GameOver/pressSpace/flicker.play("flicker")
	$GameOver/Anim.play("show")
	$GameOver/GameOverSound.play()

func win():
	get_tree().paused=true
	hide_behind_game_over()
	$Win.show()
	$Notifications/BeginMsg.hide()
	$Win/applause2.play()
#	$Notifications.hide()
	$Win/pressSpace/flicker.play("flicker")
	$Win/Anim.play("show")
	$Win/WinSound.play()
	$Win/Confetti.emitting=true
	pass
	
func hide_behind_game_over():
	for each_node in get_tree().get_nodes_in_group("arrows"):
		each_node.hide()
	for each_node in get_tree().get_nodes_in_group("floating"):
		each_node.hide()
	$Notifications.hide()
	$Notifications.modulate.a=0

func show_score_gained(score_text):
	$Notifications/ScoreTooltip.show_begin_msg(score_text)
