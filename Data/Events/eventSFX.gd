extends AcceptDialog

const CAT_LAUGH_SFX: AudioStream = preload("res://Assets/SFX/Cat Laughing At You 4.mp3")

const SFX: Array[AudioStream] = [
	CAT_LAUGH_SFX,
	preload("res://Assets/SFX/Awww.wav"),
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

const CAT_TEXTURE: Texture2D = preload("res://Assets/Event Textures/cat-laughing-4.webp")

func _ready():
	play_random_sfx()

func play_random_sfx() -> void:
	if SFX.is_empty():
		return

	# Select a random sound.
	var selected_sfx: AudioStream = SFX.pick_random()
	sfx_player.stream = selected_sfx
	
	if selected_sfx == CAT_LAUGH_SFX:
		apply_cat_texture()
	
	# Play the selected sound.
	sfx_player.play()
	
func apply_cat_texture():
		var background := StyleBoxTexture.new()
		background.texture = CAT_TEXTURE
		add_theme_stylebox_override("panel", background)	# apply background texture	
		
		var image_size: Vector2i = Vector2i(CAT_TEXTURE.get_size() * 0.25)
		size = image_size
