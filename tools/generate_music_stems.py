#!/usr/bin/env python3
"""Render the original, phase-aligned Babel liminal score stems."""

from __future__ import annotations

import argparse
import hashlib
import json
import math
import os
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
BAR_SECONDS = 60.0 / BPM * 4.0
FIELD_SECONDS = BAR_SECONDS * 4.0
CHUNK_FRAMES = 131_072
TAU = math.tau
SEED = 80_199_611
STEM_FILENAMES = {
	"reality": "babel_reality_liminal.wav",
	"phone": "babel_phone_signal.wav",
	"pollution": "babel_pollution_rot.wav",
}


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


CHORD_FIELDS = [
	[52, 59, 64, 66],
	[48, 52, 59, 66],
	[50, 55, 59, 64],
	[47, 52, 59, 65],
	[47, 52, 59, 64],
	[45, 52, 59, 60],
	[50, 52, 59, 66],
	[47, 52, 58, 65],
]


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
			result += weight * np.sin(TAU * frequency * t + phase) * (0.026 / (1.0 + voice_index * 0.18))
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
	return left, right


PHONE_SCALE = [76, 78, 79, 83, 84]


def fm_chime(t: np.ndarray, event_time: float, notes: list[int], stereo_phase: float) -> np.ndarray:
	result = np.zeros_like(t)
	for note_index, note in enumerate(notes):
		onset = event_time + note_index * 0.1875
		delta = t - onset
		mask = (delta >= 0.0) & (delta < 1.35)
		if not np.any(mask):
			continue
		local_t = np.where(mask, delta, 0.0)
		envelope = np.where(mask, np.exp(-local_t * 5.4) * (1.0 - np.exp(-local_t * 70.0)), 0.0)
		frequency = loop_frequency(midi(note))
		mod_frequency = loop_frequency(frequency * 2.01)
		mod_index = 1.05 * np.exp(-local_t * 7.5)
		carrier = np.sin(TAU * frequency * local_t + mod_index * np.sin(TAU * mod_frequency * local_t + stereo_phase))
		result += envelope * carrier * (0.14 / (1.0 + note_index * 0.12))
	return result


def render_phone(t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
	left = periodic_noise(t, PHONE_NOISE, -0.24) * 0.018
	right = periodic_noise(t, PHONE_NOISE, 0.26) * 0.018
	for event_index in range(16):
		event_time = 3.0 + event_index * 6.0
		cell_length = 2 + event_index % 3
		notes = [PHONE_SCALE[(event_index * 2 + offset * (1 + event_index % 2)) % len(PHONE_SCALE)] for offset in range(cell_length)]
		left += fm_chime(t, event_time, notes, -0.32)
		right += fm_chime(t, event_time + 0.014, notes, 0.34)
	beat_phase = np.mod(t, 24.0)
	for pulse_index in range(8):
		onset = 12.0 + pulse_index * 0.1875
		delta = beat_phase - onset
		mask = (delta >= 0.0) & (delta < 0.12)
		envelope = np.where(mask, np.exp(-np.maximum(delta, 0.0) * 32.0), 0.0)
		frequency = loop_frequency(midi(PHONE_SCALE[pulse_index % len(PHONE_SCALE)] + 12))
		pulse = envelope * np.sin(TAU * frequency * np.maximum(delta, 0.0)) * 0.055
		left += pulse
		right_delta = delta - 1.0 / SAMPLE_RATE
		right_mask = (right_delta >= 0.0) & (right_delta < 0.12)
		right_envelope = np.where(right_mask, np.exp(-np.maximum(right_delta, 0.0) * 32.0), 0.0)
		right += right_envelope * np.sin(TAU * frequency * np.maximum(right_delta, 0.0)) * 0.055
	soft_clock = (np.maximum(0.0, np.sin(TAU * t / 3.0)) ** 18) * np.sin(TAU * loop_frequency(418.0) * t) * 0.024
	left += soft_clock
	right += soft_clock
	return left, right


def render_pollution(t: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
	eighth = BAR_SECONDS / 8.0
	step_phase = np.mod(t, eighth)
	step_index = np.floor(np.mod(t, BAR_SECONDS) / eighth).astype(np.int32)
	accent = np.choose(step_index, [1.0, 0.20, 0.15, 0.92, 0.18, 0.14, 0.86, 0.22])
	gate = accent * (1.0 - np.exp(-step_phase * 58.0)) * np.exp(-step_phase * 9.5)
	base_frequency = loop_frequency(midi(64))
	left_detuned = loop_frequency(base_frequency * 2.0 ** (-13.0 / 1200.0))
	right_detuned = loop_frequency(base_frequency * 2.0 ** (15.0 / 1200.0))
	left = gate * np.sin(TAU * left_detuned * t) * 0.095
	right = gate * np.sin(TAU * right_detuned * t + 0.24) * 0.095
	mod_frequency = loop_frequency(base_frequency * math.sqrt(2.0))
	fm_index = 1.35 + 0.95 * np.sin(TAU * t / 24.0)
	left += gate * np.sin(TAU * base_frequency * t + fm_index * np.sin(TAU * mod_frequency * t)) * 0.082
	right += gate * np.sin(TAU * base_frequency * t + fm_index * np.sin(TAU * mod_frequency * t + 0.4)) * 0.082
	left += periodic_noise(t, POLLUTION_NOISE, -0.37) * (0.045 + gate * 0.055)
	right += periodic_noise(t, POLLUTION_NOISE, 0.41) * (0.045 + gate * 0.055)
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
		first = np.frombuffer(wav_file.readframes(1), dtype="<i2").astype(np.int32)
		wav_file.setpos(FRAME_COUNT - 1)
		last = np.frombuffer(wav_file.readframes(1), dtype="<i2").astype(np.int32)
		seam_delta = int(np.max(np.abs(first - last)))
		wav_file.rewind()
		pcm = np.frombuffer(wav_file.readframes(FRAME_COUNT), dtype="<i2").astype(np.float64) / 32768.0
		peak_dbfs = 20.0 * math.log10(max(float(np.max(np.abs(pcm))), 1e-9))
		rms_dbfs = 20.0 * math.log10(max(float(np.sqrt(np.mean(pcm * pcm))), 1e-9))
	return {
		"sha256": sha256(path),
		"frames": FRAME_COUNT,
		"sample_rate": SAMPLE_RATE,
		"channels": 2,
		"seam_delta_pcm": seam_delta,
		"peak_dbfs": round(peak_dbfs, 3),
		"rms_dbfs": round(rms_dbfs, 3),
	}


def write_metadata() -> None:
	stems = {name: {"file": filename, **inspect_wav(OUT_DIR / filename)} for name, filename in STEM_FILENAMES.items()}
	metadata = {
		"title": "Babel Liminal Score",
		"authoring": "Original deterministic synthesis; no samples, recordings, or extracted melodies",
		"license": "Project-owned original asset",
		"seed": SEED,
		"bpm": BPM,
		"bars": BARS,
		"duration_seconds": DURATION_SECONDS,
		"loop_begin": 0,
		"loop_end": FRAME_COUNT,
		"stems": stems,
	}
	METADATA_PATH.write_text(json.dumps(metadata, ensure_ascii=True, indent=2) + "\n", encoding="utf-8")


def verify() -> None:
	if not METADATA_PATH.exists():
		raise FileNotFoundError(METADATA_PATH)
	metadata = json.loads(METADATA_PATH.read_text(encoding="utf-8"))
	for name, filename in STEM_FILENAMES.items():
		path = OUT_DIR / filename
		inspection = inspect_wav(path)
		expected = metadata["stems"][name]
		if inspection["sha256"] != expected["sha256"]:
			raise RuntimeError(f"{filename} differs from the committed deterministic render")
		if int(inspection["seam_delta_pcm"]) > 1_400:
			raise RuntimeError(f"{filename} has an audible loop discontinuity")
		if not -3.1 <= float(inspection["peak_dbfs"]) <= -2.9:
			raise RuntimeError(f"{filename} has an unexpected master peak")


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
