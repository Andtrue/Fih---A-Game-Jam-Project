extends AcceptDialog

const SFX: Array[AudioStream] = [
	preload("res://Assets/SFX/Awww.wav"),
	preload("res://Assets/SFX/Cat Laughing At You 4.mp3"),
	preload("res://Assets/SFX/Family Guy Seagull.mp3"),
	preload("res://Assets/SFX/Idiot.wav"),
	preload("res://Assets/SFX/Laugh (genuine) 1.wav"),
	preload("res://Assets/SFX/Laugh (genuine) 2.wav"),
	preload("res://Assets/SFX/Laugh (mocking) 1.wav"),
	preload("res://Assets/SFX/Laugh (mocking) 2.wav"),
	preload("res://Assets/SFX/Sorry 1.wav"),
	preload("res://Assets/SFX/Sorry 2.wav"),
	preload("res://Assets/SFX/Trash 1.wav"),
	preload("res://Assets/SFX/Trash 2.wav"),
	preload("res://Assets/SFX/Trash 3.wav"),
	preload("res://Assets/SFX/Trash 4.wav"),
	preload("res://Assets/SFX/Trash 5.wav"),
	preload("res://Assets/SFX/Whata Bitch 1.wav"),
	preload("res://Assets/SFX/Whata Bitch 2.wav"),
	preload("res://Assets/SFX/Whata Bitch 3.wav"),
	preload("res://Assets/SFX/Fahh - meme sound effect.mp3")
]

@onready var sfx_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	play_random_sfx()

func play_random_sfx() -> void:
	if SFX.is_empty():
		return

	# Select a random sound.
	sfx_player.stream = SFX.pick_random()

	# Play the selected sound.
	sfx_player.play()
	
