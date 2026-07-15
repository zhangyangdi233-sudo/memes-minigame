#!/usr/bin/env python3
"""Render the original, phase-aligned Babel liminal score stems."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import random
import wave
from pathlib import Path

try:
	import numpy as np
except ImportError as exc:  # pragma: no cover - generation-time dependency
	raise SystemExit("Music generation requires NumPy: python3 -m pip install numpy") from exc


ROOT = Path(__file__).resolve().parent.parent
OUT_DIR = ROOT / "assets" / "generated" / "audio"
METADATA_PATH = OUT_DIR / "babel_liminal_score.json"
SAMPLE_RATE = 22_050
DURATION_SECONDS = 96.0
FRAME_COUNT = int(SAMPLE_RATE * DURATION_SECONDS)
BPM = 80
BARS = 32
BEAT_SECONDS = 60.0 / BPM
BAR_SECONDS = 60.0 / BPM * 4.0
FIELD_SECONDS = BAR_SECONDS * 4.0
CHUNK_FRAMES = 131_072
TAU = math.tau
SEED = 80_199_611
MAX_SEAM_DELTA_PCM = 1_400
MAX_SEAM_RATIO = 2.5
MAX_ADAPTIVE_MIX_PEAK_DBFS = -1.0
STEM_FILENAMES = {
	"reality": "babel_reality_liminal.wav",
	"phone": "babel_phone_signal.wav",
	"pollution": "babel_pollution_rot.wav",
}
ADAPTIVE_MIX_SCENARIOS = {
	"phone_default": {"reality": -26.0, "phone": -8.0, "pollution": -60.0},
	"reality_default": {"reality": -10.0, "phone": -42.0, "pollution": -60.0},
	"reality_intimate": {"reality": -7.0, "phone": -42.0, "pollution": -60.0},
	"phone_max_pollution": {"reality": -26.0, "phone": -8.0, "pollution": -3.0},
	"reality_max_pollution": {"reality": -10.0, "phone": -42.0, "pollution": -3.0},
	"intimate_max_pollution": {"reality": -7.0, "phone": -42.0, "pollution": -3.0},
}

# A project-original five-note cell. Its asymmetrical spacing leaves the final
# note suspended, so the same pitch classes survive very different treatments.
MOTIF_NAME = "cold_window_five"
MOTIF_ROOT_MIDI = 64
MOTIF_INTERVALS = (0, 3, 7, 2, 5)
MOTIF_ONSETS_BEATS = (0.0, 1.5, 2.25, 4.0, 6.5)
MOTIF_DURATIONS_BEATS = (1.1, 0.5, 1.25, 1.8, 1.0)
REALITY_MOTIF_VARIANTS = (
	MOTIF_INTERVALS,
	(0, 3, 7, 2, 4),
	(0, 3, 8, 2, 5),
	MOTIF_INTERVALS,
)
PHONE_MOTIF_INTERVALS = tuple(interval - 12 if interval > 6 else interval for interval in MOTIF_INTERVALS)
POLLUTION_MOTIF_INTERVALS = tuple(-interval for interval in MOTIF_INTERVALS)


def midi(note: int) -> float:
	return 440.0 * 2.0 ** ((note - 69) / 12.0)


def loop_frequency(frequency: float) -> float:
	"""Quantize a frequency to an integer number of cycles per loop."""
	return round(frequency * DURATION_SECONDS) / DURATION_SECONDS


def smoothstep(value: np.ndarray) -> np.ndarray:
	value = np.clip(value, 0.0, 1.0)
	return value * value * (3.0 - 2.0 * value)


def periodic_noise_bank(seed: int, count: int, low_hz: float, high_hz: float) -> list[tuple[float, float, float]]:
	rng = random.Random(seed)
	components: list[tuple[float, float, float]] = []
	for index in range(count):
		frequency = loop_frequency(rng.uniform(low_hz, high_hz))
		phase = rng.uniform(0.0, TAU)
		amplitude = 1.0 / math.sqrt(index + 1.0)
		components.append((frequency, phase, amplitude))
	return components


REALITY_NOISE = periodic_noise_bank(SEED + 1, 14, 16.0, 480.0)
PHONE_NOISE = periodic_noise_bank(SEED + 2, 9, 180.0, 2_600.0)
POLLUTION_NOISE = periodic_noise_bank(SEED + 3, 18, 90.0, 4_800.0)


def periodic_noise(t: np.ndarray, components: list[tuple[float, float, float]], stereo_phase: float) -> np.ndarray:
	result = np.zeros_like(t)
	normalization = sum(component[2] for component in components)
	for frequency, phase, amplitude in components:
		result += amplitude * np.sin(TAU * frequency * t + phase + stereo_phase)
	return result / max(1.0, normalization)


CHORD_FIELDS = (
	(40, 52, 59, 66),
	(40, 48, 55, 59),
	(43, 50, 59, 64),
	(50, 57, 64, 70),
	(40, 47, 55, 62),
	(45, 52, 59, 60),
	(48, 55, 59, 66),
	(47, 52, 58, 65),
)
HARMONY_FIELD_NAMES = (
	"E5(add9)",
	"Cmaj7/E",
	"G6",
	"Dsus2(b6)",
	"Em7(no3)",
	"Am(add9)",
	"Cmaj7(#11)",
	"B7sus4(b5)",
)
REALITY_PHRASE_BARS = (1, 9, 17, 25)
REALITY_HARMONY_OFFSETS = (
	(None, None, None, None, None),
	(None, None, None, -7, -7),
	(None, None, 4, None, 3),
	(12, 12, 12, 12, 12),
)


def chord_pad(t: np.ndarray, stereo_phase: float) -> np.ndarray:
	field_position = np.mod(t, DURATION_SECONDS) / FIELD_SECONDS
	field_index = np.floor(field_position).astype(np.int32)
	field_phase = np.mod(t, FIELD_SECONDS)
	crossfade = smoothstep((field_phase - (FIELD_SECONDS - 1.6)) / 1.6)
	result = np.zeros_like(t)
	for index, notes in enumerate(CHORD_FIELDS):
		current_mask = (field_index == index).astype(np.float64) * (1.0 - crossfade)
		previous_index = (index - 1) % len(CHORD_FIELDS)
		next_mask = (field_index == previous_index).astype(np.float64) * crossfade
		weight = current_mask + next_mask
		if not np.any(weight):
			continue
		for voice_index, note in enumerate(notes):
			frequency = loop_frequency(midi(note))
			phase = stereo_phase * (0.35 + voice_index * 0.17)
			voice = np.sin(TAU * frequency * t + phase)
			voice += 0.16 * np.sin(TAU * loop_frequency(frequency * 2.0) * t + phase * 1.7)
			result += weight * voice * (0.024 / (1.0 + voice_index * 0.18))
	return result


def liminal_note(
	t: np.ndarray,
	onset: float,
	note: int,
	duration: float,
	stereo_phase: float,
	gain: float = 1.0,
) -> np.ndarray:
	delta = t - onset
	mask = (delta >= 0.0) & (delta < duration + 3.0)
	if not np.any(mask):
		return np.zeros_like(t)
	local_t = np.where(mask, delta, 0.0)
	attack = 1.0 - np.exp(-local_t * 10.5)
	body = np.exp(-local_t * 0.24)
	release = np.exp(-np.maximum(local_t - duration, 0.0) * 1.75)
	envelope = np.where(mask, attack * body * release, 0.0)
	frequency = loop_frequency(midi(note))
	wander = 0.045 * np.sin(TAU * 0.31 * local_t + stereo_phase)
	voice = np.sin(TAU * frequency * local_t + stereo_phase + wander)
	voice += 0.22 * np.sin(TAU * frequency * 2.0 * local_t + stereo_phase * 1.6)
	voice += 0.07 * np.sin(TAU * frequency * 3.01 * local_t - stereo_phase)
	return envelope * voice * 0.078 * gain


def reality_melody(t: np.ndarray, stereo_phase: float) -> np.ndarray:
	result = np.zeros_like(t)
	for phrase_index, phrase_bar in enumerate(REALITY_PHRASE_BARS):
		phrase_start = phrase_bar * BAR_SECONDS
		variant = REALITY_MOTIF_VARIANTS[phrase_index]
		for note_index, interval in enumerate(variant):
			onset = phrase_start + MOTIF_ONSETS_BEATS[note_index] * BEAT_SECONDS
			duration = MOTIF_DURATIONS_BEATS[note_index] * BEAT_SECONDS
			note = MOTIF_ROOT_MIDI + interval
			result += liminal_note(t, onset, note, duration, stereo_phase)
			harmony_offset = REALITY_HARMONY_OFFSETS[phrase_index][note_index]
			if harmony_offset is not None:
				result += liminal_note(t, onset + 0.035, note + harmony_offset, duration * 0.92, -stereo_phase, 0.34)
	return result


def render_reality(t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
	breath = 0.72 + 0.13 * np.sin(TAU * t / 24.0) + 0.07 * np.sin(TAU * t / 48.0)
	hum = 0.055 * np.sin(TAU * loop_frequency(60.0) * t)
	hum += 0.018 * np.sin(TAU * loop_frequency(120.0) * t + 0.22)
	hum += 0.008 * np.sin(TAU * loop_frequency(180.0) * t + 0.51)
	pedal = 0.048 * np.sin(TAU * loop_frequency(midi(40)) * t)
	pedal += 0.026 * np.sin(TAU * loop_frequency(midi(47)) * t + 0.18)
	left = (hum + pedal + chord_pad(t, -0.16)) * breath
	right = (hum + pedal + chord_pad(t, 0.16)) * breath
	left += periodic_noise(t, REALITY_NOISE, -0.11) * 0.034
	right += periodic_noise(t, REALITY_NOISE, 0.13) * 0.034
	left += reality_melody(t, -0.21)
	right += reality_melody(t, 0.23)
	return left, right


PHONE_ROOT_MIDI = MOTIF_ROOT_MIDI + 24
PHONE_PACKET_PATTERNS = (
	(0, 1, 2, 3, 4),
	(0, 1, 3, 4),
	(0, 2, 3, 4),
	(0, 1, 2, 4),
)


def fm_chime_note(t: np.ndarray, onset: float, note: int, stereo_phase: float, gain: float) -> np.ndarray:
	delta = t - onset
	mask = (delta >= 0.0) & (delta < 1.2)
	if not np.any(mask):
		return np.zeros_like(t)
	local_t = np.where(mask, delta, 0.0)
	envelope = np.where(mask, np.exp(-local_t * 5.1) * (1.0 - np.exp(-local_t * 72.0)), 0.0)
	frequency = loop_frequency(midi(note))
	mod_frequency = loop_frequency(frequency * 2.01)
	mod_index = 1.12 * np.exp(-local_t * 7.2)
	carrier = np.sin(TAU * frequency * local_t + mod_index * np.sin(TAU * mod_frequency * local_t + stereo_phase))
	carrier += 0.16 * np.sin(TAU * loop_frequency(frequency * 3.0) * local_t - stereo_phase)
	return envelope * carrier * 0.125 * gain


def phone_packet(t: np.ndarray, event_time: float, field_index: int, stereo_phase: float) -> np.ndarray:
	result = np.zeros_like(t)
	pattern = PHONE_PACKET_PATTERNS[field_index % len(PHONE_PACKET_PATTERNS)]
	for packet_index, motif_index in enumerate(pattern):
		onset = event_time + MOTIF_ONSETS_BEATS[motif_index] * BEAT_SECONDS * 0.25
		note = PHONE_ROOT_MIDI + PHONE_MOTIF_INTERVALS[motif_index]
		gain = 1.0 / (1.0 + packet_index * 0.10)
		result += fm_chime_note(t, onset, note, stereo_phase, gain)
	return result


def render_phone(t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
	left = periodic_noise(t, PHONE_NOISE, -0.24) * 0.018
	right = periodic_noise(t, PHONE_NOISE, 0.26) * 0.018
	for field_index in range(len(CHORD_FIELDS)):
		event_time = 3.0 + field_index * FIELD_SECONDS
		left += phone_packet(t, event_time, field_index, -0.32)
		right += phone_packet(t, event_time + 0.014, field_index, 0.34)
	beat_phase = np.mod(t, 24.0)
	echo_order = (0, 1, 2, 3, 4, 3, 1, 0)
	for pulse_index in range(8):
		onset = 12.0 + pulse_index * 0.1875
		delta = beat_phase - onset
		mask = (delta >= 0.0) & (delta < 0.12)
		envelope = np.where(mask, np.exp(-np.maximum(delta, 0.0) * 32.0), 0.0)
		note = PHONE_ROOT_MIDI + 12 + PHONE_MOTIF_INTERVALS[echo_order[pulse_index]]
		frequency = loop_frequency(midi(note))
		pulse = envelope * np.sin(TAU * frequency * np.maximum(delta, 0.0)) * 0.052
		left += pulse
		right_delta = delta - 1.0 / SAMPLE_RATE
		right_mask = (right_delta >= 0.0) & (right_delta < 0.12)
		right_envelope = np.where(right_mask, np.exp(-np.maximum(right_delta, 0.0) * 32.0), 0.0)
		right += right_envelope * np.sin(TAU * frequency * np.maximum(right_delta, 0.0)) * 0.052
	soft_clock = (np.maximum(0.0, np.sin(TAU * t / 3.0)) ** 18) * np.sin(TAU * loop_frequency(418.0) * t) * 0.024
	left += soft_clock
	right += soft_clock
	return left, right


POLLUTION_ROOT_MIDI = MOTIF_ROOT_MIDI - 12
POLLUTION_STEP_ORDER = (0, 1, 2, 3, 4, 3, 2, 1)
POLLUTION_ROOT_SHIFTS = (0, 0, -2, -2, 0, 0, -1, 0)


def pollution_note(t: np.ndarray, onset: float, note: int, stereo_phase: float) -> np.ndarray:
	delta = t - onset
	mask = (delta >= 0.0) & (delta < 1.55)
	if not np.any(mask):
		return np.zeros_like(t)
	local_t = np.where(mask, delta, 0.0)
	envelope = np.where(mask, (1.0 - np.exp(-local_t * 32.0)) * np.exp(-local_t * 2.45), 0.0)
	frequency = loop_frequency(midi(note))
	mod_frequency = loop_frequency(frequency * math.sqrt(2.0))
	drift = 1.85 + 0.42 * np.sin(TAU * 3.7 * local_t + stereo_phase)
	voice = np.sin(TAU * frequency * local_t + drift * np.sin(TAU * mod_frequency * local_t + stereo_phase))
	voice += 0.28 * np.sin(TAU * frequency * 0.5 * local_t - stereo_phase)
	return envelope * voice * 0.092


def pollution_phrase(t: np.ndarray, field_index: int, stereo_phase: float) -> np.ndarray:
	result = np.zeros_like(t)
	phrase_start = field_index * FIELD_SECONDS + 0.5 * BAR_SECONDS
	root = POLLUTION_ROOT_MIDI + POLLUTION_ROOT_SHIFTS[field_index]
	for note_index, interval in enumerate(POLLUTION_MOTIF_INTERVALS):
		onset = phrase_start + MOTIF_ONSETS_BEATS[note_index] * BEAT_SECONDS * 0.65
		result += pollution_note(t, onset, root + interval, stereo_phase)
	return result


def render_pollution(t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
	eighth = BAR_SECONDS / 8.0
	step_phase = np.mod(t, eighth)
	step_index = np.floor(np.mod(t, BAR_SECONDS) / eighth).astype(np.int32)
	accent = np.choose(step_index, [1.0, 0.20, 0.15, 0.92, 0.18, 0.14, 0.86, 0.22])
	gate = accent * (1.0 - np.exp(-step_phase * 58.0)) * np.exp(-step_phase * 9.5)
	step_intervals = np.choose(step_index, [POLLUTION_MOTIF_INTERVALS[index] for index in POLLUTION_STEP_ORDER])
	base_frequency = 440.0 * 2.0 ** ((POLLUTION_ROOT_MIDI + step_intervals - 69.0) / 12.0)
	left_detuned = base_frequency * 2.0 ** (-13.0 / 1200.0)
	right_detuned = base_frequency * 2.0 ** (15.0 / 1200.0)
	left = gate * np.sin(TAU * left_detuned * step_phase) * 0.088
	right = gate * np.sin(TAU * right_detuned * step_phase + 0.24) * 0.088
	mod_frequency = base_frequency * math.sqrt(2.0)
	fm_index = 1.35 + 0.95 * np.sin(TAU * t / 24.0)
	left += gate * np.sin(TAU * base_frequency * step_phase + fm_index * np.sin(TAU * mod_frequency * step_phase)) * 0.076
	right += gate * np.sin(TAU * base_frequency * step_phase + fm_index * np.sin(TAU * mod_frequency * step_phase + 0.4)) * 0.076
	left += periodic_noise(t, POLLUTION_NOISE, -0.37) * (0.041 + gate * 0.050)
	right += periodic_noise(t, POLLUTION_NOISE, 0.41) * (0.041 + gate * 0.050)
	for field_index in range(len(CHORD_FIELDS)):
		left += pollution_phrase(t, field_index, -0.39)
		right += pollution_phrase(t, field_index, 0.43)
	for event_time in range(9, 96, 12):
		delta = t - float(event_time)
		mask = (delta >= 0.0) & (delta < 0.72)
		local_t = np.where(mask, delta, 0.0)
		burst = np.where(mask, np.exp(-local_t * 6.8), 0.0)
		burst *= np.sin(TAU * loop_frequency(1_420.0) * local_t + 3.1 * np.sin(TAU * loop_frequency(93.0) * local_t))
		left += burst * 0.09
		right -= burst * 0.08
	return left, right


RENDERERS = {
	"reality": render_reality,
	"phone": render_phone,
	"pollution": render_pollution,
}


def soft_master(left: np.ndarray, right: np.ndarray) -> np.ndarray:
	stereo = np.column_stack((left, right))
	return np.tanh(stereo * 1.18) * 0.78


def render_stem(name: str, filename: str) -> None:
	path = OUT_DIR / filename
	peak = 0.0
	for start in range(0, FRAME_COUNT, CHUNK_FRAMES):
		end = min(FRAME_COUNT, start + CHUNK_FRAMES)
		t = np.arange(start, end, dtype=np.float64) / SAMPLE_RATE
		left, right = RENDERERS[name](t)
		peak = max(peak, float(np.max(np.abs(soft_master(left, right)))))
	target_peak = 10.0 ** (-3.0 / 20.0)
	normalization = target_peak / max(peak, 1e-9)
	with wave.open(str(path), "wb") as wav_file:
		wav_file.setnchannels(2)
		wav_file.setsampwidth(2)
		wav_file.setframerate(SAMPLE_RATE)
		for start in range(0, FRAME_COUNT, CHUNK_FRAMES):
			end = min(FRAME_COUNT, start + CHUNK_FRAMES)
			t = np.arange(start, end, dtype=np.float64) / SAMPLE_RATE
			left, right = RENDERERS[name](t)
			pcm = (np.clip(soft_master(left, right) * normalization, -0.98, 0.98) * 32767.0).astype("<i2")
			wav_file.writeframesraw(pcm.tobytes())


def sha256(path: Path) -> str:
	digest = hashlib.sha256()
	with path.open("rb") as file_handle:
		for chunk in iter(lambda: file_handle.read(1024 * 1024), b""):
			digest.update(chunk)
	return digest.hexdigest()


def inspect_wav(path: Path) -> dict[str, int | float | str]:
	with wave.open(str(path), "rb") as wav_file:
		if wav_file.getnchannels() != 2 or wav_file.getsampwidth() != 2:
			raise RuntimeError(f"{path.name} must be stereo 16-bit PCM")
		if wav_file.getframerate() != SAMPLE_RATE or wav_file.getnframes() != FRAME_COUNT:
			raise RuntimeError(f"{path.name} has incorrect loop length")
		pcm_frames = np.frombuffer(wav_file.readframes(FRAME_COUNT), dtype="<i2").reshape(-1, 2).astype(np.int32)
		seam_delta = int(np.max(np.abs(pcm_frames[0] - pcm_frames[-1])))
		frame_deltas = np.abs(np.diff(pcm_frames, axis=0))
		seam_reference = max(1, int(round(float(np.percentile(frame_deltas, 99.9)))))
		seam_ratio = seam_delta / seam_reference
		pcm = pcm_frames.astype(np.float64) / 32768.0
		peak_dbfs = 20.0 * math.log10(max(float(np.max(np.abs(pcm))), 1e-9))
		rms_dbfs = 20.0 * math.log10(max(float(np.sqrt(np.mean(pcm * pcm))), 1e-9))
	return {
		"sha256": sha256(path),
		"frames": FRAME_COUNT,
		"sample_rate": SAMPLE_RATE,
		"channels": 2,
		"seam_delta_pcm": seam_delta,
		"seam_reference_pcm": seam_reference,
		"seam_delta_ratio": round(seam_ratio, 3),
		"peak_dbfs": round(peak_dbfs, 3),
		"rms_dbfs": round(rms_dbfs, 3),
	}


def inspect_adaptive_mix() -> dict[str, float]:
	readers = {name: wave.open(str(OUT_DIR / filename), "rb") for name, filename in STEM_FILENAMES.items()}
	peaks = {scenario: 0.0 for scenario in ADAPTIVE_MIX_SCENARIOS}
	try:
		for start in range(0, FRAME_COUNT, CHUNK_FRAMES):
			frame_count = min(CHUNK_FRAMES, FRAME_COUNT - start)
			chunks = {
				name: np.frombuffer(reader.readframes(frame_count), dtype="<i2").reshape(-1, 2).astype(np.float64) / 32768.0
				for name, reader in readers.items()
			}
			for scenario, volumes in ADAPTIVE_MIX_SCENARIOS.items():
				mixed = np.zeros((frame_count, 2), dtype=np.float64)
				for name, volume_db in volumes.items():
					mixed += chunks[name] * 10.0 ** (volume_db / 20.0)
				peaks[scenario] = max(peaks[scenario], float(np.max(np.abs(mixed))))
	finally:
		for reader in readers.values():
			reader.close()
	return {
		scenario: round(20.0 * math.log10(max(peak, 1e-9)), 3)
		for scenario, peak in peaks.items()
	}


def score_contract() -> dict[str, object]:
	return {
		"format_version": 2,
		"title": "Babel Liminal Score",
		"authoring": "Project-original deterministic synthesis; no samples, recordings, or extracted melodies",
		"license": "Project-owned original asset",
		"seed": SEED,
		"bpm": BPM,
		"bars": BARS,
		"duration_seconds": DURATION_SECONDS,
		"loop_begin": 0,
		"loop_end": FRAME_COUNT,
		"creative_direction": {
			"reference_scope": "High-level mood and production traits only",
			"traits": ["hazy", "empty", "dreamlike", "lost", "uncanny", "cold"],
		},
		"originality": {
			"motif_origin": "Composed for this project from the interval and rhythm values declared in the generator",
			"melody_transcribed": False,
			"samples_used": False,
			"recordings_used": False,
			"third_party_audio_used": False,
			"synthesis": "Mathematical oscillators, deterministic envelopes, FM, and seeded periodic noise",
		},
		"composition": {
			"motif": {
				"name": MOTIF_NAME,
				"root_midi": MOTIF_ROOT_MIDI,
				"intervals_semitones": list(MOTIF_INTERVALS),
				"onsets_beats": list(MOTIF_ONSETS_BEATS),
				"durations_beats": list(MOTIF_DURATIONS_BEATS),
				"reality_phrase_bars": list(REALITY_PHRASE_BARS),
				"reality_variants": [list(variant) for variant in REALITY_MOTIF_VARIANTS],
			},
			"harmony": {
				"field_bars": 4,
				"fields": list(HARMONY_FIELD_NAMES),
				"variation_plan": [
					"single-line statement",
					"lower-fifth shadow ending",
					"raised-apex upper-third bloom",
					"octave-memory return",
				],
			},
			"transformations": {
				"reality": {
					"intervals_semitones": list(MOTIF_INTERVALS),
					"method": "slow glass-tone statements with changing harmony voices",
					"time_scale": 1.0,
				},
				"phone": {
					"intervals_semitones": list(PHONE_MOTIF_INTERVALS),
					"method": "octave-folded quarter-time FM packet fragmentation",
					"time_scale": 0.25,
				},
				"pollution": {
					"intervals_semitones": list(POLLUTION_MOTIF_INTERVALS),
					"method": "interval inversion, lower-register displacement, and half-bar offset",
					"time_scale": 0.65,
				},
			},
		},
		"adaptive_mix": {
			"phase_aligned": True,
			"independent_stems": True,
			"shared_start_frame": 0,
			"shared_end_frame": FRAME_COUNT,
			"master_peak_dbfs": -3.0,
			"verified_scenario_peak_dbfs": inspect_adaptive_mix(),
		},
	}


def write_metadata() -> None:
	stems = {name: {"file": filename, **inspect_wav(OUT_DIR / filename)} for name, filename in STEM_FILENAMES.items()}
	metadata = {**score_contract(), "stems": stems}
	METADATA_PATH.write_text(json.dumps(metadata, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")


def verify() -> None:
	if not METADATA_PATH.exists():
		raise FileNotFoundError(METADATA_PATH)
	metadata = json.loads(METADATA_PATH.read_text(encoding="utf-8"))
	for key, expected_value in score_contract().items():
		if metadata.get(key) != expected_value:
			raise RuntimeError(f"metadata contract mismatch: {key}")
	if set(metadata.get("stems", {})) != set(STEM_FILENAMES):
		raise RuntimeError("metadata must describe exactly the three adaptive stems")
	for scenario, peak_dbfs in metadata["adaptive_mix"]["verified_scenario_peak_dbfs"].items():
		if float(peak_dbfs) > MAX_ADAPTIVE_MIX_PEAK_DBFS:
			raise RuntimeError(f"adaptive mix scenario {scenario} can overload the master")
	stem_hashes: set[str] = set()
	for name, filename in STEM_FILENAMES.items():
		path = OUT_DIR / filename
		inspection = inspect_wav(path)
		expected = {"file": filename, **inspection}
		if metadata["stems"][name] != expected:
			raise RuntimeError(f"{filename} differs from its deterministic render metadata")
		if int(inspection["seam_delta_pcm"]) > MAX_SEAM_DELTA_PCM:
			raise RuntimeError(f"{filename} has an audible loop discontinuity")
		if float(inspection["seam_delta_ratio"]) > MAX_SEAM_RATIO:
			raise RuntimeError(f"{filename} has an abnormal boundary step")
		if not -3.1 <= float(inspection["peak_dbfs"]) <= -2.9:
			raise RuntimeError(f"{filename} has an unexpected master peak")
		if not -36.0 <= float(inspection["rms_dbfs"]) <= -9.0:
			raise RuntimeError(f"{filename} has an unexpected average level")
		stem_hashes.add(str(inspection["sha256"]))
	if len(stem_hashes) != len(STEM_FILENAMES):
		raise RuntimeError("adaptive stems must contain distinct audio renders")


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("--verify", action="store_true")
	args = parser.parse_args()
	OUT_DIR.mkdir(parents=True, exist_ok=True)
	if args.verify:
		verify()
		return
	for name, filename in STEM_FILENAMES.items():
		print(f"rendering {name}: {filename}")
		render_stem(name, filename)
	write_metadata()
	verify()
	print(f"rendered {len(STEM_FILENAMES)} synchronized stems at {DURATION_SECONDS:.0f}s")


if __name__ == "__main__":
	main()
