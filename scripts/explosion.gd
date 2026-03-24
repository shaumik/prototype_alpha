extends CPUParticles2D

var sfx_explosion = preload("res://assets/audio/explosion.wav")

func play_audio(stream: AudioStream) -> void:
    var player = AudioStreamPlayer.new()
    player.stream = stream
    player.finished.connect(player.queue_free)
    get_tree().current_scene.call_deferred("add_child", player)
    player.play()

func _ready() -> void:
    emitting = true
    play_audio(sfx_explosion)
    await get_tree().create_timer(lifetime).timeout
    queue_free()
