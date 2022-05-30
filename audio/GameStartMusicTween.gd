class_name GameStartMusicTween
extends Tween

# https://godotengine.org/qa/27939/how-to-fade-in-out-an-audio-stream

func fade_music_out(stream_player: AudioStreamPlayer):
	# tween music volume down to 0
	self.interpolate_property(stream_player, "volume_db", stream_player.volume_db, -80, 4, 1, Tween.EASE_IN, 0)
	self.start()


func _on_GameStartMusicTween_tween_completed(object, key):
	# stop the music -- otherwise it continues to run at silent volume
	object.stop()
