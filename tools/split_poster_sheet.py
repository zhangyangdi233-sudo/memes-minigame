#!/usr/bin/env python3
"""Split the generated social poster sheet into project-local poster PNGs."""

from __future__ import annotations

import os
import struct
import zlib


ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SHEET_PATH = os.path.join(ROOT, "assets/generated/social/poster_sheet.png")
OUT_DIR = os.path.join(ROOT, "assets/generated/social")


def _read_chunks(data: bytes):
	offset = 8
	while offset < len(data):
		length = struct.unpack(">I", data[offset : offset + 4])[0]
		name = data[offset + 4 : offset + 8]
		payload = data[offset + 8 : offset + 8 + length]
		yield name, payload
		offset += 12 + length


def load_rgba_png(path: str) -> tuple[int, int, list[tuple[int, int, int, int]]]:
	with open(path, "rb") as f:
		data = f.read()
	if not data.startswith(b"\x89PNG\r\n\x1a\n"):
		raise ValueError("not a PNG")
	width = height = color_type = 0
	idat = bytearray()
	for name, payload in _read_chunks(data):
		if name == b"IHDR":
			width, height, bit_depth, color_type, compression, filter_method, interlace = struct.unpack(">IIBBBBB", payload)
			if bit_depth != 8 or color_type not in [2, 6] or compression != 0 or filter_method != 0 or interlace != 0:
				raise ValueError("expected non-interlaced 8-bit RGB/RGBA PNG")
		elif name == b"IDAT":
			idat.extend(payload)
	raw = zlib.decompress(bytes(idat))
	channels = 4 if color_type == 6 else 3
	stride = width * channels
	rows: list[bytearray] = []
	pos = 0
	for _y in range(height):
		filter_type = raw[pos]
		pos += 1
		row = bytearray(raw[pos : pos + stride])
		pos += stride
		prev = rows[-1] if rows else bytearray(stride)
		for i in range(stride):
			left = row[i - channels] if i >= channels else 0
			up = prev[i]
			up_left = prev[i - channels] if i >= channels else 0
			if filter_type == 1:
				row[i] = (row[i] + left) & 0xFF
			elif filter_type == 2:
				row[i] = (row[i] + up) & 0xFF
			elif filter_type == 3:
				row[i] = (row[i] + ((left + up) // 2)) & 0xFF
			elif filter_type == 4:
				row[i] = (row[i] + _paeth(left, up, up_left)) & 0xFF
			elif filter_type != 0:
				raise ValueError(f"unsupported PNG filter {filter_type}")
		rows.append(row)
	pixels: list[tuple[int, int, int, int]] = []
	for row in rows:
		for x in range(width):
			i = x * channels
			alpha = row[i + 3] if channels == 4 else 255
			pixels.append((row[i], row[i + 1], row[i + 2], alpha))
	return width, height, pixels


def _paeth(a: int, b: int, c: int) -> int:
	p = a + b - c
	pa = abs(p - a)
	pb = abs(p - b)
	pc = abs(p - c)
	if pa <= pb and pa <= pc:
		return a
	if pb <= pc:
		return b
	return c


def save_rgba_png(path: str, width: int, height: int, pixels: list[tuple[int, int, int, int]]) -> None:
	def chunk(name: bytes, payload: bytes) -> bytes:
		return struct.pack(">I", len(payload)) + name + payload + struct.pack(">I", zlib.crc32(name + payload) & 0xFFFFFFFF)

	raw = bytearray()
	for y in range(height):
		raw.append(0)
		for x in range(width):
			raw.extend(pixels[y * width + x])
	data = b"\x89PNG\r\n\x1a\n"
	data += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0))
	data += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
	data += chunk(b"IEND", b"")
	with open(path, "wb") as f:
		f.write(data)


def crop(pixels: list[tuple[int, int, int, int]], sheet_w: int, x: int, y: int, size: int) -> list[tuple[int, int, int, int]]:
	out: list[tuple[int, int, int, int]] = []
	for yy in range(y, y + size):
		start = yy * sheet_w + x
		out.extend(pixels[start : start + size])
	return out


def main() -> None:
	width, height, pixels = load_rgba_png(SHEET_PATH)
	cell = min(width // 4, height // 3)
	for index in range(12):
		col = index % 4
		row = index // 4
		tile = crop(pixels, width, col * cell, row * cell, cell)
		save_rgba_png(os.path.join(OUT_DIR, f"poster_{index:02d}.png"), cell, cell, tile)
	print(f"split {SHEET_PATH} into 12 poster tiles of {cell}px")


if __name__ == "__main__":
	main()
