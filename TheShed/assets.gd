extends Node

var clinks=[]
# audio assets
var playNoteTrack1=load("res://samples/Stage1/Stage1_100_Backing Track.ogg")
var playNoteTrack2=load("res://samples/Stage2/Stage2_115_Backing Track.ogg")
var playNoteTrack3=load("res://samples/Stage3/Stage3_130_Backing Track.ogg")
var kickTrack1=load("res://samples/Stage1/Stage1_100_Kick.ogg")
var kickTrack2=load("res://samples/Stage2/Stage2_115_Kick.ogg")
var kickTrack3=load("res://samples/Stage3/Stage3_130_Kick.ogg")
var snareTrack1=load("res://samples/Stage1/Stage1_100_Snare.ogg")
var snareTrack2=load("res://samples/Stage2/Stage2_115_Snare.ogg")
var snareTrack3=load("res://samples/Stage3/Stage3_130_Snare.ogg")
var hatsTrack1=load("res://samples/Stage1/Stage1_100_Hats.ogg")
var hatsTrack2=load("res://samples/Stage2/Stage2_115_Hats.ogg")
var hatsTrack3=load("res://samples/Stage3/Stage3_130_Hats.ogg")
var tomTrack1=load("res://samples/Stage1/Stage1_100_Toms.ogg")
var tomTrack2=load("res://samples/Stage2/Stage2_115_Toms.ogg")
var tomTrack3=load("res://samples/Stage3/Stage3_130_Toms.ogg")
var midiTrack1="res://samples/Stage1/Stage1_100.mid"
var midiTrack2="res://samples/Stage2/Stage2_115.mid"
var midiTrack3="res://samples/Stage3/Stage3_130.mid"

var game_over_stage1=load("res://audio/Stage1Loss.ogg")
var game_over_stage2=load("res://audio/Stage2Loss.ogg")
var game_over_stage3=load("res://audio/Stage3Loss.ogg")
# visual assets
var bgStage2=load("res://graphics/BgNibiruCraters.png")
var bgStage3=load("res://graphics/BgBlackRunCastle.png")
#Bassist
var BassistBodyLvl2=load("res://graphics/BassistBodyDarkBrown.png")
var BassistBodyLvl3=load("res://graphics/BassistBodySkeletonT3.png")
var BassistClothesLvl2=load("res://graphics/BassistClothesPrinceJacket.png")
var BassistClothesLvl3=load("res://graphics/BassistClothesTank.png")
var BassistHairLvl2=load("res://graphics/BassistHairBlondGlasses.png")
var BassistHairLvl3=load("res://graphics/BassistHairGrandpaPipe.png")
var BassistInstrumentLvl2=load("res://graphics/BassistInstrumentBassMandolinT3.png")
var BassistInstrumentLvl3=load("res://graphics/BassistInstrumentBWFenderBass.png")
var BassistLegsLvl3=load("res://graphics/BassistLegsBone.png")
var BassistLegs=load("res://graphics/BassistLegs.png")
#Harmonist
var HarmonistBodyLvl2=load("res://graphics/HarmonistBody02.png")
var HarmonistBodyLvl3=load("res://graphics/HarmonistBodyZombieT2.png")
var HarmonistClothesLvl2=load("res://graphics/HarmonistClothesBlueGirlDress.png")
var HarmonistClothesLvl3=load("res://graphics/HarmonistClothesCappottoScuro.png")
var HarmonistHairLvl2=load("res://graphics/HarmonistHairBrownPieces.png")
var HarmonistHairLvl3=load("res://graphics/HarmonistHairMetal.png")
var HarmonistInstrumentLvl2=load("res://graphics/HarmonistInstrumentSpaceOrganT4.png")
var HarmonistInstrumentLvl3=load("res://graphics/HarmonistInstrumentOldPianoT3.png")
var HarmonistLegsLvl3=load("res://graphics/BassistLegsBone.png")
var HarmonistLegs=load("res://graphics/HarmonistLegs.png")

func _ready():
	randomize()
	load_clinks()

func load_clinks():
	for each in 16:
		clinks.append(load("res://samples/DrumClinks/DrumClink_"+str(each)+".ogg"))
