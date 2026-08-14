extends SceneTree

const SCORE_METADATA_PATH := "res://assets/generated/audio/babel_liminal_score.json"
const AUDIO_ROOT := "res://assets/generated/audio/"
const EXPECTED_FLOOR_FILES := {
	"floor_1": "babel_phone_signal_floor_1.wav",
	"floor_2": "babel_phone_signal.wav",
	"floor_3": "babel_phone_signal_floor_3.wav",
	"floor_4": "babel_phone_signal_floor_4.wav",
	"floor_5": "babel_phone_signal_floor_5.wav",
}
const EXPECTED_FIXED_HASHES := {
	"babel_reality_liminal.wav": "39b5bc85c5c62c77af894ce471ff29d5602ab956e48b21064f364d55b6e8071a",
	"babel_phone_signal_floor_1.wav": "e361ea4b487e2ea0ef15a8d970a245429cdbf7fb9cb7fad69192cf6a7b04f698",
	"babel_phone_signal.wav": "be1e497be9cc9131ae1e261c3494e2fcf310e01393c2dfdf3a81b07851c87de3",
}
const FLOOR_1_GIT_BLOB := "f671f7d3fc892e4d216a6f4bb95fd63a1da43127"

var _failures: Array[String] = []


func _init() -> void:
	_run()
	if _failures.is_empty():
		print("phone music asset tests passed")
		quit(0)
	else:
		for failure in _failures:
			push_error(failure)
		quit(1)


func _run() -> void:
	var metadata_text := FileAccess.get_file_as_string(SCORE_METADATA_PATH)
	_assert_true(not metadata_text.is_empty(), "phone music metadata should be readable")
	if metadata_text.is_empty():
		return
	var parsed: Variant = JSON.parse_string(metadata_text)
	_assert_true(parsed is Dictionary, "phone music metadata should contain valid JSON")
	if not parsed is Dictionary:
		return
	var metadata := parsed as Dictionary
	var phone_floors := metadata.get("phone_floors", {}) as Dictionary
	_assert_eq(int(phone_floors.get("contract_version", 0)), 1, "phone floors should use the first asset contract")
	_assert_eq(int(phone_floors.get("shared_end_frame", 0)), 2_116_800, "phone floors should be exact 96-second loops")
	_assert_eq(int(phone_floors.get("sample_rate", 0)), 22_050, "phone floors should use 22.05 kHz audio")
	_assert_eq(int(phone_floors.get("channels", 0)), 2, "phone floors should be stereo")

	var originality := phone_floors.get("originality", {}) as Dictionary
	_assert_true(bool(originality.get("project_original_audio_only", false)), "phone floors should contain project-original audio only")
	_assert_true(not bool(originality.get("commercial_game_music_used", true)), "phone floors should not contain commercial game music")
	_assert_true(not bool(originality.get("samples_used", true)), "phone floor synthesis should not use samples")
	_assert_true(not bool(originality.get("recordings_used", true)), "phone floor synthesis should not use recordings")

	_validate_preserved_assets(phone_floors.get("preservation", {}) as Dictionary)
	_validate_floor_layers(phone_floors.get("layers", {}) as Dictionary)
	_validate_distinctness(phone_floors.get("distinctness", {}) as Dictionary)


func _validate_preserved_assets(preservation: Dictionary) -> void:
	_assert_eq(str(preservation.get("floor_1_git_blob", "")), FLOOR_1_GIT_BLOB, "floor 1 should record its exact historical Git blob")
	_assert_eq(str(preservation.get("reality_sha256", "")), EXPECTED_FIXED_HASHES["babel_reality_liminal.wav"], "reality preservation hash should remain pinned")
	_assert_eq(str(preservation.get("floor_1_sha256", "")), EXPECTED_FIXED_HASHES["babel_phone_signal_floor_1.wav"], "floor 1 preservation hash should remain pinned")
	_assert_eq(str(preservation.get("floor_2_sha256", "")), EXPECTED_FIXED_HASHES["babel_phone_signal.wav"], "floor 2 preservation hash should remain pinned")
	for filename: String in EXPECTED_FIXED_HASHES:
		var path := AUDIO_ROOT + filename
		_assert_true(FileAccess.file_exists(path), "%s should exist" % filename)
		if FileAccess.file_exists(path):
			_assert_eq(FileAccess.get_sha256(path), EXPECTED_FIXED_HASHES[filename], "%s should remain byte-for-byte unchanged" % filename)


func _validate_floor_layers(layers: Dictionary) -> void:
	_assert_eq(layers.size(), 5, "metadata should describe all five phone floors")
	var hashes := {}
	var titles := {}
	var designs := {}
	for floor_index in range(1, 6):
		var floor_name := "floor_%d" % floor_index
		var layer := layers.get(floor_name, {}) as Dictionary
		var expected_filename: String = EXPECTED_FLOOR_FILES[floor_name]
		_assert_eq(int(layer.get("floor", 0)), floor_index, "%s should retain its floor number" % floor_name)
		_assert_eq(str(layer.get("file", "")), expected_filename, "%s should use its canonical filename" % floor_name)
		_assert_true(not str(layer.get("title", "")).is_empty(), "%s should publish a musical identity" % floor_name)
		_assert_true((layer.get("palette", []) as Array).size() == 3, "%s should publish a three-part sound palette" % floor_name)
		var audio_path := AUDIO_ROOT + expected_filename
		_assert_true(FileAccess.file_exists(audio_path), "%s audio should exist" % floor_name)
		if not FileAccess.file_exists(audio_path):
			continue
		var actual_hash := FileAccess.get_sha256(audio_path)
		_assert_eq(actual_hash, str(layer.get("sha256", "")), "%s should match deterministic metadata" % floor_name)
		var wav := _inspect_pcm_wav(audio_path)
		_assert_eq(int(wav.get("frames", 0)), 2_116_800, "%s should contain exactly 96 seconds of frames" % floor_name)
		_assert_eq(int(wav.get("sample_rate", 0)), 22_050, "%s should use a 22.05 kHz sample rate" % floor_name)
		_assert_eq(int(wav.get("channels", 0)), 2, "%s should use stereo PCM" % floor_name)
		_assert_eq(int(wav.get("bits_per_sample", 0)), 16, "%s should use 16-bit PCM" % floor_name)
		_assert_true(int(wav.get("seam_delta_pcm", 99_999)) <= 1_400, "%s should remain pop-free at the loop boundary" % floor_name)
		var stream := load(audio_path) as AudioStreamWAV
		_assert_true(stream != null, "%s should import as an AudioStreamWAV" % floor_name)
		if stream != null:
			_assert_eq(stream.mix_rate, 22_050, "%s imported resource should retain its sample rate" % floor_name)
			_assert_true(stream.stereo, "%s imported resource should remain stereo" % floor_name)
			_assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s imported resource should loop forward" % floor_name)
			_assert_eq(stream.loop_begin, 0, "%s imported loop should start at frame zero" % floor_name)
			_assert_eq(stream.loop_end, 2_116_800, "%s imported loop should end at the exact final frame" % floor_name)
		hashes[actual_hash] = true
		titles[str(layer.get("title", ""))] = true
		designs[str(layer.get("design", ""))] = true
	_assert_eq(hashes.size(), 5, "every phone floor should contain distinct PCM audio")
	_assert_eq(titles.size(), 5, "every phone floor should have a distinct musical identity")
	_assert_eq(designs.size(), 5, "every phone floor should use a distinct arrangement design")


func _validate_distinctness(distinctness: Dictionary) -> void:
	var maximum_allowed := float(distinctness.get("maximum_allowed", 0.0))
	var maximum_measured := float(distinctness.get("maximum_measured", 1.0))
	_assert_near(maximum_allowed, 0.45, 0.000_001, "phone floor correlation limit should stay strict")
	_assert_true(maximum_measured <= maximum_allowed, "phone floors should remain measurably distinct")
	var correlations := distinctness.get("pairwise_abs_correlations", {}) as Dictionary
	_assert_eq(correlations.size(), 10, "all ten phone-floor pairs should have full-loop correlation checks")
	for pair: String in correlations:
		_assert_true(float(correlations[pair]) <= maximum_allowed, "%s should remain below the similarity limit" % pair)


func _inspect_pcm_wav(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var riff := file.get_buffer(4).get_string_from_ascii()
	file.seek(8)
	var wave_signature := file.get_buffer(4).get_string_from_ascii()
	file.seek(20)
	var format := file.get_16()
	var channels := file.get_16()
	var sample_rate := file.get_32()
	file.seek(34)
	var bits_per_sample := file.get_16()
	file.seek(40)
	var data_bytes := file.get_32()
	_assert_eq(riff, "RIFF", "%s should use a RIFF container" % path)
	_assert_eq(wave_signature, "WAVE", "%s should use a WAVE container" % path)
	_assert_eq(format, 1, "%s should use uncompressed PCM" % path)
	var bytes_per_frame: int = channels * bits_per_sample / 8
	var first_frame_offset := 44
	var last_frame_offset := first_frame_offset + data_bytes - bytes_per_frame
	var seam_delta := 0
	for channel in range(channels):
		file.seek(first_frame_offset + channel * 2)
		var first_sample := _signed_pcm16(file.get_16())
		file.seek(last_frame_offset + channel * 2)
		var last_sample := _signed_pcm16(file.get_16())
		seam_delta = maxi(seam_delta, absi(first_sample - last_sample))
	return {
		"frames": data_bytes / bytes_per_frame,
		"sample_rate": sample_rate,
		"channels": channels,
		"bits_per_sample": bits_per_sample,
		"seam_delta_pcm": seam_delta,
	}


func _signed_pcm16(value: int) -> int:
	return value - 65_536 if value >= 32_768 else value


func _assert_true(value: bool, message: String) -> void:
	if not value:
		_failures.append(message)


func _assert_near(actual: float, expected: float, tolerance: float, message: String) -> void:
	if absf(actual - expected) > tolerance:
		_failures.append("%s (expected %.6f, got %.6f)" % [message, expected, actual])


func _assert_eq(actual: Variant, expected: Variant, message: String) -> void:
	if actual != expected:
		_failures.append("%s (expected %s, got %s)" % [message, expected, actual])
