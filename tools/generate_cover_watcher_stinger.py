#!/usr/bin/env python3
"""Generate the original one-shot used by the cover watcher event."""

from __future__ import annotations

import argparse
import hashlib
import math
import os
import random
import struct
import wave


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUTPUT_PATH = os.path.join(ROOT, "assets", "generated", "audio", "cover_watcher_stinger.wav")
SAMPLE_RATE = 22_050
DURATION_SECONDS = 2.45
EXPECTED_SHA256 = "2f22e21ecb8c217d3115e0dfed55cbc9314ec7248872dd9dfcc180f572024cc1"


def _clamp(value: float) -> float:
	return max(-1.0, min(1.0, value))


def _render_samples() -> list[float]:
	rng = random.Random(0xC0A3)
	frame_count = round(SAMPLE_RATE * DURATION_SECONDS)
	low_noise = 0.0
	samples: list[float] = []
	for index in range(frame_count):
		t = index / SAMPLE_RATE
		progress = t / DURATION_SECONDS
		low_noise = low_noise * 0.972 + rng.uniform(-1.0, 1.0) * 0.028
		fade_in = min(1.0, t / 0.055)
		fade_out = min(1.0, (DURATION_SECONDS - t) / 0.34)
		envelope = max(0.0, fade_in * fade_out)
		rising_sub = math.sin(math.tau * (38.0 + progress * 17.0) * t + progress * progress * 9.0)
		bowed_tone = math.sin(math.tau * 113.0 * t + 2.7 * math.sin(math.tau * 0.61 * t))
		unstable_sideband = math.sin(math.tau * 287.0 * t + 6.0 * low_noise)
		scratch_gate = max(0.0, math.sin(math.tau * 6.5 * t + 0.8)) ** 18
		scratch = scratch_gate * rng.uniform(-0.42, 0.42)
		withdrawal = max(0.0, (progress - 0.58) / 0.42)
		reverse_drag = withdrawal * math.sin(math.tau * (760.0 - 410.0 * withdrawal) * t)
		sample = (
			0.38 * rising_sub
			+ 0.20 * bowed_tone
			+ 0.08 * unstable_sideband
			+ 0.24 * low_noise
			+ scratch
			+ 0.13 * reverse_drag
		) * envelope
		samples.append(sample)
	return samples


def _write() -> None:
	samples = _render_samples()
	peak = max(abs(sample) for sample in samples)
	pcm = bytearray()
	for sample in samples:
		pcm.extend(struct.pack("<h", round(_clamp(sample * 0.84 / peak) * 32767)))
	os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
	with wave.open(OUTPUT_PATH, "wb") as wav_file:
		wav_file.setnchannels(1)
		wav_file.setsampwidth(2)
		wav_file.setframerate(SAMPLE_RATE)
		wav_file.writeframes(bytes(pcm))


def _verify() -> None:
	if not os.path.exists(OUTPUT_PATH):
		raise FileNotFoundError(OUTPUT_PATH)
	with wave.open(OUTPUT_PATH, "rb") as wav_file:
		assert wav_file.getnchannels() == 1
		assert wav_file.getsampwidth() == 2
		assert wav_file.getframerate() == SAMPLE_RATE
		assert wav_file.getnframes() == round(SAMPLE_RATE * DURATION_SECONDS)
	if EXPECTED_SHA256:
		with open(OUTPUT_PATH, "rb") as audio_file:
			actual_hash = hashlib.sha256(audio_file.read()).hexdigest()
		if actual_hash != EXPECTED_SHA256:
			raise RuntimeError(f"cover watcher stinger hash mismatch: {actual_hash}")


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("--verify", action="store_true")
	args = parser.parse_args()
	if not args.verify:
		_write()
	_verify()


if __name__ == "__main__":
	main()
