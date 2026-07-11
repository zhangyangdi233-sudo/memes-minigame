#!/usr/bin/env python3
"""Generate fallback UI art and verify curated imagegen assets.

The two composition-defining images are curated imagegen outputs and must not
be overwritten by the procedural fallback generator. This script intentionally
uses only the Python standard library.
"""

from __future__ import annotations

import argparse
import hashlib
import math
import os
import random
import struct
import zlib
from typing import Iterable, Sequence


Color = tuple[int, int, int, int]
Point = tuple[int, int]

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

CURATED_IMAGEGEN_ASSETS = {
	"assets/generated/world/phone_down_backdrop.png": "b47f8772e40da13dada074bc3518be9fef4368ff9941dca35826bd576a49e6fe",
	"assets/generated/world/npc_signal_portrait.png": "440d89e06cbb96b63570885939d02e08382d4464fbe24b9874a08907716517fa",
	"assets/generated/social/poster_sheet.png": "76ae2647761ba61c4923f161f49d9e09f142042d26088b37b267a9db1d059594",
}

INK: Color = (16, 20, 15, 255)
BG: Color = (54, 91, 45, 255)
LIME: Color = (183, 217, 87, 255)
PALE: Color = (221, 235, 138, 255)
CREAM: Color = (255, 241, 201, 255)
POLLUTION: Color = (156, 255, 36, 255)
TRANSPARENT: Color = (0, 0, 0, 0)


class Canvas:
	def __init__(self, width: int, height: int, bg: Color = TRANSPARENT):
		self.width = width
		self.height = height
		self.pixels = [bg for _ in range(width * height)]

	def save(self, relative_path: str) -> None:
		path = os.path.join(ROOT, relative_path)
		os.makedirs(os.path.dirname(path), exist_ok=True)
		save_png(path, self.width, self.height, self.pixels)

	def set(self, x: int, y: int, color: Color) -> None:
		if 0 <= x < self.width and 0 <= y < self.height:
			self.pixels[y * self.width + x] = blend(self.pixels[y * self.width + x], color)

	def rect(self, x: int, y: int, w: int, h: int, color: Color) -> None:
		for yy in range(max(0, y), min(self.height, y + h)):
			row = yy * self.width
			for xx in range(max(0, x), min(self.width, x + w)):
				self.pixels[row + xx] = blend(self.pixels[row + xx], color)

	def rounded_rect(self, x: int, y: int, w: int, h: int, r: int, color: Color) -> None:
		for yy in range(y, y + h):
			for xx in range(x, x + w):
				dx = max(x - xx + r, 0, xx - (x + w - r - 1))
				dy = max(y - yy + r, 0, yy - (y + h - r - 1))
				if dx * dx + dy * dy <= r * r:
					self.set(xx, yy, color)

	def line(self, x1: int, y1: int, x2: int, y2: int, color: Color, thickness: int = 1) -> None:
		dx = x2 - x1
		dy = y2 - y1
		steps = max(abs(dx), abs(dy), 1)
		for i in range(steps + 1):
			t = i / steps
			x = round(x1 + dx * t)
			y = round(y1 + dy * t)
			half = max(0, thickness // 2)
			self.rect(x - half, y - half, thickness, thickness, color)

	def polygon(self, points: Sequence[Point], color: Color) -> None:
		if not points:
			return
		min_y = max(0, min(y for _, y in points))
		max_y = min(self.height - 1, max(y for _, y in points))
		for y in range(min_y, max_y + 1):
			nodes: list[int] = []
			j = len(points) - 1
			for i, (xi, yi) in enumerate(points):
				xj, yj = points[j]
				if (yi < y and yj >= y) or (yj < y and yi >= y):
					nodes.append(int(xi + (y - yi) / max(1, yj - yi) * (xj - xi)))
				j = i
			nodes.sort()
			for i in range(0, len(nodes), 2):
				if i + 1 >= len(nodes):
					break
				self.rect(nodes[i], y, nodes[i + 1] - nodes[i] + 1, 1, color)

	def circle(self, cx: int, cy: int, r: int, color: Color) -> None:
		for y in range(cy - r, cy + r + 1):
			for x in range(cx - r, cx + r + 1):
				if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r * r:
					self.set(x, y, color)


def blend(dst: Color, src: Color) -> Color:
	sa = src[3] / 255.0
	if sa <= 0:
		return dst
	if sa >= 1:
		return src
	da = dst[3] / 255.0
	out_a = sa + da * (1.0 - sa)
	if out_a <= 0:
		return TRANSPARENT
	out = []
	for i in range(3):
		out.append(round((src[i] * sa + dst[i] * da * (1.0 - sa)) / out_a))
	return (out[0], out[1], out[2], round(out_a * 255))


def save_png(path: str, width: int, height: int, pixels: Iterable[Color]) -> None:
	def chunk(name: bytes, data: bytes) -> bytes:
		return struct.pack(">I", len(data)) + name + data + struct.pack(">I", zlib.crc32(name + data) & 0xFFFFFFFF)

	raw = bytearray()
	pixel_list = list(pixels)
	for y in range(height):
		raw.append(0)
		for x in range(width):
			raw.extend(pixel_list[y * width + x])
	data = b"\x89PNG\r\n\x1a\n"
	data += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
	data += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
	data += chunk(b"IEND", b"")
	with open(path, "wb") as f:
		f.write(data)


def noise_color(base: Color, amount: int) -> Color:
	return (
		max(0, min(255, base[0] + random.randint(-amount, amount))),
		max(0, min(255, base[1] + random.randint(-amount, amount))),
		max(0, min(255, base[2] + random.randint(-amount, amount))),
		base[3],
	)


def circle_outline(c: Canvas, cx: int, cy: int, r: int, color: Color, thickness: int = 3) -> None:
	for degree in range(0, 360, 2):
		x = cx + int(math.cos(math.radians(degree)) * r)
		y = cy + int(math.sin(math.radians(degree)) * r)
		c.rect(x - thickness // 2, y - thickness // 2, thickness, thickness, color)


def generate_road() -> None:
	random.seed(101)
	c = Canvas(1024, 1024, BG)
	for y in range(c.height):
		for x in range(c.width):
			shade = int(24 * y / c.height)
			c.set(x, y, noise_color((42 + shade, 70 + shade, 37 + shade // 2, 255), 10))
	for offset in [-320, -160, 0, 160, 320]:
		c.polygon([(496 + offset // 4, 0), (532 + offset // 4, 0), (900 + offset, 1024), (795 + offset, 1024)], (221, 235, 138, 70))
	for y in range(90, 1024, 128):
		c.polygon([(0, y), (1024, y + 52), (1024, y + 72), (0, y + 22)], (16, 20, 15, 42))
	for y in range(120, 1024, 160):
		c.polygon([(448, y), (574, y + 8), (590, y + 42), (428, y + 32)], (255, 241, 201, 84))
	for x in range(0, 1024, 28):
		c.line(x, 0, min(1024, x + 300), 1024, (16, 20, 15, 28), 2)
	c.save("assets/generated/world/road_loop_green.png")


def generate_hand_phone() -> None:
	c = Canvas(1280, 720)

	# Left hand, drawn as flat poster shapes so it can sit over the road layer.
	c.polygon([(356, 720), (408, 604), (548, 512), (638, 548), (640, 720)], (255, 241, 201, 235))
	c.polygon([(480, 594), (566, 432), (614, 442), (580, 628)], (255, 241, 201, 246))
	c.polygon([(560, 572), (686, 438), (728, 468), (624, 632)], (255, 241, 201, 240))
	c.polygon([(626, 610), (784, 520), (812, 556), (674, 682)], (255, 241, 201, 232))
	c.line(430, 704, 562, 476, (54, 91, 45, 150), 5)
	c.line(584, 558, 696, 454, (54, 91, 45, 126), 4)
	c.line(656, 624, 786, 538, (54, 91, 45, 120), 4)

	# A full, readable phone silhouette similar to the reference composition.
	c.polygon([(688, 76), (1018, 52), (1066, 660), (648, 692)], (10, 12, 10, 255))
	c.polygon([(722, 114), (984, 94), (1028, 610), (684, 640)], (24, 29, 22, 255))
	c.line(748, 142, 930, 128, (183, 217, 87, 112), 3)
	for y in [204, 278, 352]:
		c.line(744, y, 948, y - 16, (54, 91, 45, 96), 2)
	c.circle(850, 654, 19, (54, 91, 45, 230))
	c.rounded_rect(814, 72, 90, 9, 5, (54, 91, 45, 255))

	# Bottom black edge: keeps the hand grounded like a first-person UI plate.
	c.polygon([(0, 646), (1280, 642), (1280, 720), (0, 720)], (16, 20, 15, 224))
	c.save("assets/generated/world/hand_phone_down.png")


def draw_person(c: Canvas, x: int, y: int, scale: float, accent: Color) -> None:
	c.polygon([(x - int(80 * scale), y + int(200 * scale)), (x + int(80 * scale), y + int(200 * scale)), (x + int(128 * scale), y + int(420 * scale)), (x - int(132 * scale), y + int(420 * scale))], (16, 20, 15, 245))
	c.polygon([(x - int(58 * scale), y + int(218 * scale)), (x + int(58 * scale), y + int(218 * scale)), (x + int(82 * scale), y + int(404 * scale)), (x - int(86 * scale), y + int(404 * scale))], (255, 241, 201, 235))
	c.circle(x, y + int(105 * scale), int(68 * scale), (255, 241, 201, 255))
	for dx in [-24, 24]:
		c.line(x + int(dx * scale), y + int(102 * scale), x + int(dx * scale), y + int(118 * scale), INK, max(2, int(4 * scale)))
	c.line(x - int(18 * scale), y + int(148 * scale), x + int(26 * scale), y + int(148 * scale), INK, max(2, int(4 * scale)))
	for i in range(8):
		c.polygon([
			(x - int(86 * scale) + int(i * 25 * scale), y + int(48 * scale)),
			(x - int(52 * scale) + int(i * 18 * scale), y - int(12 * scale)),
			(x - int(20 * scale) + int(i * 14 * scale), y + int(78 * scale)),
		], accent)
	c.line(x - int(102 * scale), y + int(190 * scale), x + int(104 * scale), y + int(190 * scale), accent, max(2, int(6 * scale)))


def generate_npc() -> None:
	c = Canvas(512, 768)
	draw_person(c, 256, 95, 1.35, (47, 107, 31, 255))
	for i in range(16):
		c.line(70 + i * 24, 730, 430 - i * 10, 590, (183, 217, 87, 60), 2)
	c.save("assets/generated/world/npc_front.png")


def generate_player_portrait() -> None:
	random.seed(404)
	c = Canvas(360, 420, (6, 22, 30, 0))
	dark: Color = (6, 22, 30, 255)
	green: Color = (0, 172, 70, 255)
	shadow: Color = (2, 54, 39, 255)
	c.rounded_rect(18, 8, 324, 404, 4, dark)
	for _ in range(720):
		c.set(random.randrange(18, 342), random.randrange(8, 412), (0, 172, 70, random.randint(8, 24)))

	# Jacket and shoulders.
	c.polygon([(84, 306), (146, 262), (214, 262), (292, 318), (326, 420), (42, 420)], green)
	c.polygon([(138, 302), (180, 344), (222, 302), (234, 420), (126, 420)], dark)
	c.line(122, 324, 88, 410, dark, 4)
	c.line(244, 324, 284, 410, dark, 4)
	c.line(154, 322, 184, 420, dark, 3)
	c.line(206, 322, 176, 420, dark, 3)
	for y in range(348, 412, 14):
		c.line(150, y, 210, y + 4, shadow, 2)

	# Head base and heavy hair silhouette.
	c.circle(180, 190, 92, green)
	c.polygon([(74, 158), (118, 64), (196, 38), (278, 70), (322, 156), (286, 284), (214, 294), (144, 282), (88, 236)], green)
	c.polygon([(126, 56), (170, 0), (210, 58)], green)
	c.polygon([(60, 214), (100, 124), (122, 290), (82, 342)], green)
	c.polygon([(286, 142), (326, 226), (302, 332), (264, 288)], green)

	# Hair strand cut lines.
	for points in [
		[(118, 126), (104, 202), (118, 250)],
		[(150, 96), (136, 186), (148, 246)],
		[(178, 82), (178, 174), (166, 238)],
		[(204, 88), (222, 178), (210, 256)],
		[(234, 104), (268, 178), (250, 258)],
		[(92, 230), (112, 284), (86, 360)],
		[(284, 228), (270, 300), (300, 374)],
	]:
		for a, b in zip(points, points[1:]):
			c.line(a[0], a[1], b[0], b[1], dark, 4)

	# Face and expression, kept minimal and readable at small size.
	c.line(138, 194, 154, 198, dark, 4)
	c.line(214, 198, 232, 194, dark, 4)
	c.line(164, 236, 196, 238, dark, 4)
	c.line(154, 252, 210, 252, dark, 3)
	c.line(128, 214, 118, 246, dark, 3)
	c.line(244, 212, 252, 246, dark, 3)

	# Pixel-art edge treatment.
	for x in range(32, 330, 18):
		if x % 36 == 0:
			c.rect(x, 24, 8, 8, green)
	for y in range(44, 400, 22):
		if y % 44 == 0:
			c.rect(28, y, 6, 12, green)
	c.save("assets/generated/ui/player_portrait.png")


def generate_icons() -> None:
	icon_specs = {
		"hud_day_icon.png": "day",
		"hud_pollution_icon.png": "pollution",
		"hud_money_icon.png": "money",
		"hud_settings_icon.png": "settings",
		"no_signal_icon.png": "no_signal",
	}
	for filename, kind in icon_specs.items():
		c = Canvas(96, 96)
		if kind == "day":
			c.rounded_rect(17, 24, 62, 52, 3, (0, 0, 0, 0))
			c.line(18, 31, 78, 31, PALE, 5)
			c.line(18, 75, 78, 75, PALE, 5)
			c.line(18, 31, 18, 75, PALE, 5)
			c.line(78, 31, 78, 75, PALE, 5)
			c.line(32, 17, 32, 33, PALE, 5)
			c.line(64, 17, 64, 33, PALE, 5)
			for y in [45, 59]:
				for x in [32, 48, 64]:
					c.rect(x - 4, y - 4, 8, 8, PALE)
		elif kind == "pollution":
			circle_outline(c, 48, 48, 34, PALE, 4)
			c.line(79, 39, 87, 39, PALE, 4)
			c.line(79, 49, 87, 49, PALE, 4)
			c.line(79, 59, 87, 59, PALE, 4)
			c.line(18, 52, 32, 52, PALE, 4)
			c.line(32, 52, 40, 34, PALE, 4)
			c.line(40, 34, 54, 68, PALE, 4)
			c.line(54, 68, 63, 42, PALE, 4)
			c.line(63, 42, 78, 42, PALE, 4)
		elif kind == "money":
			circle_outline(c, 48, 48, 34, PALE, 4)
			circle_outline(c, 48, 48, 25, PALE, 3)
			c.line(34, 32, 48, 48, PALE, 5)
			c.line(62, 32, 48, 48, PALE, 5)
			c.line(48, 48, 48, 70, PALE, 5)
			c.line(34, 49, 62, 49, PALE, 4)
			c.line(36, 58, 60, 58, PALE, 4)
		elif kind == "settings":
			circle_outline(c, 48, 48, 28, PALE, 4)
			circle_outline(c, 48, 48, 11, PALE, 4)
			for degree in range(0, 360, 45):
				x1 = 48 + int(math.cos(math.radians(degree)) * 30)
				y1 = 48 + int(math.sin(math.radians(degree)) * 30)
				x2 = 48 + int(math.cos(math.radians(degree)) * 39)
				y2 = 48 + int(math.sin(math.radians(degree)) * 39)
				c.line(x1, y1, x2, y2, PALE, 6)
		else:
			circle_outline(c, 48, 48, 28, INK, 4)
			c.line(36, 36, 60, 60, INK, 4)
			c.line(60, 36, 36, 60, INK, 4)
		c.save(f"assets/generated/ui/{filename}")


def generate_poster(index: int) -> None:
	random.seed(500 + index)
	h = 520 + (index % 4) * 74
	c = Canvas(420, h, CREAM if index % 2 else (221, 235, 138, 255))
	for _ in range(4500):
		x = random.randrange(c.width)
		y = random.randrange(c.height)
		c.set(x, y, noise_color((54, 91, 45, 60), 60))
	if index % 3 == 0:
		c.rect(0, 0, 420, 150, (16, 20, 15, 235))
		c.rect(22, 26, 130, 18, LIME)
		c.rect(22, 58, 228, 10, (221, 235, 138, 190))
		c.rect(22, 78, 174, 10, (221, 235, 138, 150))
		c.polygon([(240, 112), (310, 40), (356, 390), (190, 392)], (47, 107, 31, 210))
		for y in range(420, h - 24, 22):
			c.rect(28, y, random.randint(80, 250), 7, INK if y % 44 == 0 else (54, 91, 45, 180))
	elif index % 3 == 1:
		c.rect(0, 0, 420, h, (16, 20, 15, 242))
		for y in range(20, h, 42):
			c.rect(random.randint(8, 100), y, random.randint(120, 300), random.randint(4, 12), (221, 235, 138, random.randint(80, 220)))
		c.circle(275, h // 2, 88, (183, 217, 87, 160))
		c.line(64, h - 80, 364, h - 248, POLLUTION, 4)
	else:
		c.rect(26, 22, 366, h - 44, (255, 241, 201, 220))
		for i in range(10):
			c.rect(48, 56 + i * 30, random.randint(80, 280), 12, INK if i % 3 == 0 else (54, 91, 45, 180))
		c.polygon([(230, 140), (308, 80), (348, h - 80), (182, h - 88)], (16, 20, 15, 170))
		for x in range(42, 380, 48):
			c.line(x, h - 138, x + 26, h - 62, (183, 217, 87, 120), 3)
	c.save(f"assets/generated/social/poster_{index:02d}.png")


def verify_curated_assets() -> None:
	for relative_path, expected_hash in CURATED_IMAGEGEN_ASSETS.items():
		path = os.path.join(ROOT, relative_path)
		if not os.path.exists(path):
			raise FileNotFoundError(f"Missing curated imagegen asset: {relative_path}")
		with open(path, "rb") as asset_file:
			actual_hash = hashlib.sha256(asset_file.read()).hexdigest()
		if actual_hash != expected_hash:
			raise RuntimeError(f"Curated asset changed unexpectedly: {relative_path}")


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("--verify", action="store_true", help="verify curated imagegen assets without writing files")
	args = parser.parse_args()
	verify_curated_assets()
	if args.verify:
		return
	# These small UI pieces are intentionally reproducible locally. Retired road,
	# phone, NPC, and split-poster placeholders are no longer generated.
	generate_player_portrait()
	generate_icons()


if __name__ == "__main__":
	main()
