extends Node3D

var voice_id

func _ready():
	# Get a list of English voices and select the first available one
	var voices = DisplayServer.tts_get_voices_for_language("en")
	if voices.size() > 0:
		voice_id = voices[0]  # Choose the first English voice
	else:
		print("No voices found! Ensure TTS is enabled in Project Settings.")
	
	# Connect button signal (assuming the button is named "Button")
	$Button.pressed.connect(_on_button_pressed)

# Function to trigger TTS and mouth animation
func _on_button_pressed():
	var text = $LineEdit.text  # Get text from input
	DisplayServer.tts_speak(text, voice_id)  # Speak the text with TTS
	animate_mouth(text)  # Animate the mouth while speaking

# Function to animate the mouth (basic open-close)
func animate_mouth(text):
	var audio_duration = text.length() * 0.1  # Estimate duration based on text length
	$AnimationPlayer.play("mouth_open_close")  # Play looped animation

	# Wait for the estimated duration before stopping the animation
	await get_tree().create_timer(audio_duration).timeout
	$AnimationPlayer.stop()
