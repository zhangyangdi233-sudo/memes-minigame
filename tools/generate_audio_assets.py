#!/usr/bin/env python3
"""Generate deterministic lo-fi audio for the standalone Babel game."""

from __future__ import annotations

import argparse
import hashlib
import math
import os
import random
import struct
import wave
from collections.abc import Callable


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT_DIR = os.path.join(ROOT, "assets", "generated", "audio")
SAMPLE_RATE = 22_050
TAU = math.tau
EXPECTED_SHA256 = {
	"action_tick.wav": "776a93f470b53d5691d4ab338ddcab6a8eaf3a85f88e54df42666ddbefd4a2e0",
	"pollution_flashback.wav": "26c3b12f4479b3b01c3bede896e9dcf08e834493fef44ca4dd84da840f089cd2",
	"reality_room_loop.wav": "c13f97fee2ae5c35efb51d4f3425d370922966c51f26ab683b2787d995403c9c",
	"phone_road_loop.wav": "e19219a86670f9f41b9af12501a005146d983da2e0fb0bb60ca3e3f874e692b7",
}


def clamp(value: float, low: float = -1.0, high: float = 1.0) -> float:
	return max(low, min(high, value))


def write_wav(filename: str, duration: float, sample_fn: Callable[[float, int], float]) -> None:
	frame_count = round(duration * SAMPLE_RATE)
	samples = [sample_fn(index / SAMPLE_RATE, index) for index in range(frame_count)]
	peak = max(0.001, max(abs(sample) for sample in samples))
	normalization = 0.82 / peak
	pcm = bytearray()
	for sample in samples:
		pcm.extend(struct.pack("<h", round(clamp(sample * normalization) * 32767)))
	os.makedirs(OUT_DIR, exist_ok=True)
	with wave.open(os.path.join(OUT_DIR, filename), "wb") as wav_file:
		wav_file.setnchannels(1)
		wav_file.setsampwidth(2)
		wav_file.setframerate(SAMPLE_RATE)
		wav_file.writeframes(bytes(pcm))


def phone_road_sample(t: float, _index: int) -> float:
	breath = 0.78 + 0.12 * math.sin(TAU * 0.25 * t)
	hum = 0.34 * math.sin(TAU * 45.0 * t) + 0.12 * math.sin(TAU * 90.0 * t)
	road = 0.055 * math.sin(TAU * 713.0 * t + 0.7 * math.sin(TAU * 0.5 * t))
	road += 0.035 * math.sin(TAU * 1193.0 * t + 0.3 * math.sin(TAU * 0.25 * t))
	pulse_gate = max(0.0, math.sin(TAU * 0.5 * t)) ** 12
	pulse = pulse_gate * 0.10 * math.sin(TAU * 238.0 * t)
	return hum * breath + road + pulse


def reality_room_sample(t: float, _index: int) -> float:
	room = 0.28 * math.sin(TAU * 50.0 * t) + 0.08 * math.sin(TAU * 100.0 * t)
	electric = 0.025 * math.sin(TAU * 799.0 * t + math.sin(TAU * 0.125 * t))
	breathing = (0.68 + 0.18 * math.sin(TAU * 0.125 * t)) * room
	return breathing + electric


def build_flashback_samples(duration: float) -> list[float]:
	rng = random.Random(60013)
	frame_count = round(duration * SAMPLE_RATE)
	result: list[float] = []
	for index in range(frame_count):
		t = index / SAMPLE_RATE
		gate = 1.0 if int(t * 22.0) % 5 not in (1, 4) else 0.16
		carrier = 0.36 * math.sin(TAU * (83.0 + int(t * 7.0) * 19.0) * t)
		signal = 0.22 * math.sin(TAU * 1700.0 * t + 4.0 * math.sin(TAU * 11.0 * t))
		noise = rng.uniform(-0.42, 0.42)
		fade = min(1.0, t / 0.025, (duration - t) / 0.05)
		result.append((carrier + signal + noise) * gate * max(0.0, fade))
	return result


def write_samples(filename: str, samples: list[float]) -> None:
	peak = max(0.001, max(abs(sample) for sample in samples))
	pcm = bytearray()
	for sample in samples:
		pcm.extend(struct.pack("<h", round(clamp(sample * 0.88 / peak) * 32767)))
	os.makedirs(OUT_DIR, exist_ok=True)
	with wave.open(os.path.join(OUT_DIR, filename), "wb") as wav_file:
		wav_file.setnchannels(1)
		wav_file.setsampwidth(2)
		wav_file.setframerate(SAMPLE_RATE)
		wav_file.writeframes(bytes(pcm))


def action_tick_sample(t: float, _index: int) -> float:
	envelope = math.exp(-t * 28.0)
	return envelope * (0.42 * math.sin(TAU * 620.0 * t) + 0.16 * math.sin(TAU * 82.0 * t))


def verify_audio_assets() -> None:
	for filename, expected_hash in EXPECTED_SHA256.items():
		path = os.path.join(OUT_DIR, filename)
		if not os.path.exists(path):
			raise FileNotFoundError(f"Missing generated audio asset: {filename}")
		with open(path, "rb") as audio_file:
			actual_hash = hashlib.sha256(audio_file.read()).hexdigest()
		if actual_hash != expected_hash:
			raise RuntimeError(f"Generated audio changed unexpectedly: {filename}")


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("--verify", action="store_true", help="verify generated audio without writing files")
	args = parser.parse_args()
	if args.verify:
		verify_audio_assets()
		return
	write_wav("phone_road_loop.wav", 8.0, phone_road_sample)
	write_wav("reality_room_loop.wav", 8.0, reality_room_sample)
	write_samples("pollution_flashback.wav", build_flashback_samples(1.6))
	write_wav("action_tick.wav", 0.18, action_tick_sample)
	verify_audio_assets()


if __name__ == "__main__":
	main()
