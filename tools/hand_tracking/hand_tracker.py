#!/usr/bin/env python3
"""MediaPipe dual-hand tracker that streams normalized landmarks to Godot over UDP."""

from __future__ import annotations

import argparse
import json
import os
import signal
import socket
import subprocess
import sys
import tempfile
import time
from pathlib import Path
from typing import Any


SCHEMA_VERSION = 1
RUNNING = True

_mpl_cache = Path(tempfile.gettempdir()) / "babel-mediapipe-matplotlib"
_mpl_cache.mkdir(parents=True, exist_ok=True)
os.environ.setdefault("MPLCONFIGDIR", str(_mpl_cache))


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--model", type=Path)
    parser.add_argument("--host", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=7001)
    parser.add_argument("--camera-index", type=int, default=0)
    parser.add_argument("--camera-source", choices=("computer", "phone"), default="computer")
    parser.add_argument("--width", type=int, default=960)
    parser.add_argument("--height", type=int, default=540)
    parser.add_argument("--fps", type=float, default=30.0)
    parser.add_argument("--preview", action="store_true")
    parser.add_argument("--probe", action="store_true")
    parser.add_argument("--self-test", action="store_true")
    parser.add_argument("--simulate", action="store_true")
    parser.add_argument("--max-frames", type=int, default=0)
    return parser.parse_args()


def _stop(_signum: int, _frame: Any) -> None:
    global RUNNING
    RUNNING = False


def _load_cv2() -> Any:
    try:
        import cv2
    except ImportError as exc:
        raise RuntimeError(
            "OpenCV is unavailable. Run tools/hand_tracking/setup_macos.sh first."
        ) from exc
    return cv2


def _load_runtime() -> tuple[Any, Any, Any, Any]:
    try:
        import mediapipe as mp
        from mediapipe.tasks import python as mp_python
        from mediapipe.tasks.python import vision
    except ImportError as exc:
        raise RuntimeError(
            "MediaPipe/OpenCV are unavailable. Run tools/hand_tracking/setup_macos.sh first."
        ) from exc
    return _load_cv2(), mp, mp_python, vision


def _macos_camera_devices() -> list[dict[str, Any]]:
    if sys.platform != "darwin":
        return []
    try:
        completed = subprocess.run(
            ["system_profiler", "SPCameraDataType", "-json"],
            check=True,
            capture_output=True,
            text=True,
            timeout=8,
        )
        payload = json.loads(completed.stdout)
        devices = payload.get("SPCameraDataType", [])
        return devices if isinstance(devices, list) else []
    except (OSError, subprocess.SubprocessError, json.JSONDecodeError):
        return []


def _is_phone_camera(device: dict[str, Any]) -> bool:
    identity = " ".join(
        str(device.get(key, ""))
        for key in ("_name", "spcamera_model-id", "spcamera_unique-id")
    ).lower()
    return any(marker in identity for marker in ("iphone", "ipad", "continuity"))


def _camera_candidates(source: str, requested_index: int) -> list[int]:
    devices = _macos_camera_devices()
    if sys.platform == "darwin":
        if devices:
            matching = [
                index
                for index, device in enumerate(devices)
                if _is_phone_camera(device) == (source == "phone")
            ]
            return matching
        return [requested_index] if source == "computer" else []
    if source == "phone":
        return [index for index in (1, 2, 3, 4, 0) if index >= 0]
    return [requested_index]


def _open_camera(cv2: Any, source: str, index: int, width: int, height: int, fps: float) -> tuple[Any, int]:
    backend = cv2.CAP_AVFOUNDATION if sys.platform == "darwin" else cv2.CAP_ANY
    for candidate in _camera_candidates(source, index):
        capture = cv2.VideoCapture(candidate, backend)
        capture.set(cv2.CAP_PROP_FRAME_WIDTH, width)
        capture.set(cv2.CAP_PROP_FRAME_HEIGHT, height)
        capture.set(cv2.CAP_PROP_FPS, fps)
        if capture.isOpened():
            return capture, candidate
        capture.release()
    raise RuntimeError(f"Unable to open {source} camera (requested index {index}).")


def _make_packet(result: Any, frame_id: int, timestamp_ms: int, width: int, height: int) -> dict[str, Any]:
    hands: list[dict[str, Any]] = []
    for index, landmarks in enumerate(result.hand_landmarks):
        handedness = result.handedness[index][0] if index < len(result.handedness) else None
        hands.append(
            {
                "handedness": handedness.category_name if handedness else "Unknown",
                "score": float(handedness.score) if handedness else 0.0,
                "landmarks": [
                    {"x": float(point.x), "y": float(point.y), "z": float(point.z)}
                    for point in landmarks
                ],
            }
        )
    return {
        "schema_version": SCHEMA_VERSION,
        "frame_id": frame_id,
        "timestamp_ms": timestamp_ms,
        "image_size": [width, height],
        "mirrored": True,
        "hands": hands,
    }


def _send_status_packet(args: argparse.Namespace, status_code: str, message: str) -> None:
    packet = {
        "schema_version": SCHEMA_VERSION,
        "frame_id": -1,
        "timestamp_ms": int(time.monotonic() * 1000),
        "image_size": [0, 0],
        "mirrored": True,
        "status_code": status_code,
        "message": message,
        "hands": [],
    }
    try:
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as udp:
            udp.sendto(json.dumps(packet, separators=(",", ":")).encode("utf-8"), (args.host, args.port))
    except OSError:
        pass


def _synthetic_hand(handedness: str, thumb: tuple[float, float], index: tuple[float, float]) -> dict[str, Any]:
    landmarks = [{"x": (thumb[0] + index[0]) * 0.5, "y": (thumb[1] + index[1]) * 0.5, "z": 0.0} for _ in range(21)]
    landmarks[4] = {"x": thumb[0], "y": thumb[1], "z": 0.0}
    landmarks[8] = {"x": index[0], "y": index[1], "z": 0.0}
    return {"handedness": handedness, "score": 0.99, "landmarks": landmarks}


def run_simulator(args: argparse.Namespace) -> int:
    target = (args.host, args.port)
    frame_interval = 1.0 / max(args.fps, 1.0)
    started = time.monotonic()
    frame_id = 0
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as udp:
        while RUNNING and (args.max_frames <= 0 or frame_id < args.max_frames):
            phase = (time.monotonic() - started) * 1.2
            drift = 0.018 * __import__("math").sin(phase)
            packet = {
                "schema_version": SCHEMA_VERSION,
                "frame_id": frame_id,
                "timestamp_ms": int(time.monotonic() * 1000),
                "image_size": [args.width, args.height],
                "mirrored": True,
                "hands": [
                    _synthetic_hand("Left", (0.24 + drift, 0.64), (0.29 + drift, 0.28)),
                    _synthetic_hand("Right", (0.76 + drift, 0.64), (0.71 + drift, 0.28)),
                ],
            }
            udp.sendto(json.dumps(packet, separators=(",", ":")).encode("utf-8"), target)
            frame_id += 1
            time.sleep(frame_interval)
    return 0


def run_probe(args: argparse.Namespace) -> int:
    cv2 = _load_cv2()
    try:
        capture, selected_index = _open_camera(cv2, args.camera_source, args.camera_index, args.width, args.height, args.fps)
    except RuntimeError as exc:
        print(json.dumps({"camera_source": args.camera_source, "camera_index": args.camera_index, "available": False, "error": str(exc)}))
        return 2
    ok, frame = capture.read()
    capture.release()
    print(
        json.dumps(
            {
                "camera_index": args.camera_index,
                "camera_source": args.camera_source,
                "selected_index": selected_index,
                "available": bool(ok),
                "frame_size": [int(frame.shape[1]), int(frame.shape[0])] if ok else [0, 0],
            }
        )
    )
    return 0 if ok else 2


def run_self_test(args: argparse.Namespace) -> int:
    if args.model is None or not args.model.is_file():
        raise RuntimeError("--model must point to hand_landmarker.task")
    _, _, mp_python, vision = _load_runtime()
    options = vision.HandLandmarkerOptions(
        base_options=mp_python.BaseOptions(model_asset_path=str(args.model)),
        running_mode=vision.RunningMode.VIDEO,
        num_hands=2,
    )
    with vision.HandLandmarker.create_from_options(options):
        pass
    print(json.dumps({"mediapipe": "ok", "model": str(args.model), "num_hands": 2}))
    return 0


def run_tracker(args: argparse.Namespace) -> int:
    if args.model is None or not args.model.is_file():
        raise RuntimeError("--model must point to hand_landmarker.task")
    cv2, mp, mp_python, vision = _load_runtime()
    capture, selected_index = _open_camera(cv2, args.camera_source, args.camera_index, args.width, args.height, args.fps)
    options = vision.HandLandmarkerOptions(
        base_options=mp_python.BaseOptions(model_asset_path=str(args.model)),
        running_mode=vision.RunningMode.VIDEO,
        num_hands=2,
        min_hand_detection_confidence=0.55,
        min_hand_presence_confidence=0.55,
        min_tracking_confidence=0.55,
    )
    target = (args.host, args.port)
    frame_id = 0
    max_hands = 0
    two_hand_frames = 0
    started = time.monotonic()
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as udp, vision.HandLandmarker.create_from_options(options) as landmarker:
        while RUNNING and (args.max_frames <= 0 or frame_id < args.max_frames):
            ok, frame = capture.read()
            if not ok:
                time.sleep(0.02)
                continue
            frame = cv2.flip(frame, 1)
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            timestamp_ms = int((time.monotonic() - started) * 1000)
            mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
            result = landmarker.detect_for_video(mp_image, timestamp_ms)
            packet = _make_packet(result, frame_id, timestamp_ms, frame.shape[1], frame.shape[0])
            hand_count = len(packet["hands"])
            max_hands = max(max_hands, hand_count)
            if hand_count >= 2:
                two_hand_frames += 1
            udp.sendto(json.dumps(packet, separators=(",", ":")).encode("utf-8"), target)
            if args.preview:
                cv2.imshow("Babel Hand Tracker", frame)
                if cv2.waitKey(1) & 0xFF in (27, ord("q")):
                    break
            frame_id += 1
    capture.release()
    if args.preview:
        cv2.destroyAllWindows()
    print(json.dumps({"frames": frame_id, "camera_source": args.camera_source, "selected_index": selected_index, "max_hands": max_hands, "two_hand_frames": two_hand_frames}))
    return 0


def main() -> int:
    args = parse_args()
    signal.signal(signal.SIGINT, _stop)
    signal.signal(signal.SIGTERM, _stop)
    try:
        if args.simulate:
            return run_simulator(args)
        if args.probe:
            return run_probe(args)
        if args.self_test:
            return run_self_test(args)
        return run_tracker(args)
    except Exception as exc:  # Sidecar errors must be visible to Godot/editor logs.
        status_code = "camera_open_failed" if "camera" in str(exc).lower() else "tracker_error"
        _send_status_packet(args, status_code, str(exc))
        print(json.dumps({"error": str(exc), "type": type(exc).__name__}), file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
