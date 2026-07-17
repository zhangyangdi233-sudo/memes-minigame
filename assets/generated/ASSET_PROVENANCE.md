# Generated Asset Provenance

The game keeps ten composition-defining raster assets as curated OpenAI imagegen outputs. They are loaded directly at runtime and are not recreated by the procedural fallback generator.

## Curated imagegen assets

| Runtime asset | Original generation | Size | SHA-256 | Role |
| --- | --- | --- | --- | --- |
| `world/phone_down_backdrop.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbc5187dc81918176aff7c3059317.png` | 1672 x 941 | `b47f8772e40da13dada074bc3518be9fef4368ff9941dca35826bd576a49e6fe` | Low-view road, hand, and phone composition |
| `world/npc_signal_portrait.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-36e50e5c-760a-4fce-a1da-769248b49ed5.png` | 1024 x 1536 | `440d89e06cbb96b63570885939d02e08382d4464fbe24b9874a08907716517fa` | Chroma-keyed reality-dialogue classmate portrait |
| `social/poster_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbcafe3c08191937224629c9b05eb.png` | 1448 x 1086 | `76ae2647761ba61c4923f161f49d9e09f142042d26088b37b267a9db1d059594` | Twelve-cell social urban-legend poster atlas |
| `ui/arcana_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-479815ca-02a7-4a9d-b2c9-382b2dc7f426.png` | 1536 x 1024 | `ca52ccc5d003c7a7786fd8f3157fc134a1f7426cf488ef78fc3eb98ece10e7bc` | Six-cell signal-arcana consumable atlas |
| `characters/protagonist_operator.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-4ff17ce4-2fbc-41ea-bf9f-6335ec884086.png` | 1024 x 1536 | `d5c0f85474b7f7f59d7e031d81e751eb7e928fe7f105329372d4951fe7d0a1cd` | Identity-preserving protagonist based on the project owner's drawings |
| `characters/merchant_frame_vendor.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-babad000-53d2-4006-9576-6654cd08f271.png` | 1029 x 1528 | `3b6df2b26873108bb700b52e4ed0f7f5e5eaaac5f9c84e5e3981a3545277966c` | Cartoon frame vendor whose two eyes disagree through the inspection lens |
| `characters/npc_late_arrival.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-1382dc4a-b761-4d0b-a441-25425982458a.png` | 1024 x 1536 | `2d5e0b3d4dfce39e5e5f255c06e28d5af92aaa665d420c20ac5c21332cb5cb79` | Cartoon late arrival with duplicated watches and a directionally wrong shoelace |
| `characters/npc_echo_tenant.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-1710614f-6564-4cfc-ac52-0232c15fe033.png` | 1024 x 1536 | `f8d01e19b89862e61f64c5149b7b96493a6938fbb650cc40dc0d844a28a8abaa` | Cartoon echo tenant with split-focus pupils and visible signal rings |
| `characters/npc_archive_witness.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-7d16abdc-e9db-450c-ab94-e07a605b6076.png` | 1024 x 1536 | `9f8442907de0e31d689d75b4653bd3c6005f1bdeac2d1e8738600d1ebfb4a1e5` | Cartoon archive witness surrounded by an almost-correct orbit of blank cards |
| `effects/face_scribble_atlas.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-f1114544-6ff0-49d0-9e6d-53c39cda981b.png` | 1672 x 941 | `781fafe1c5868ca4807cb12a20f6231a9354f1fbd4a09ec725a1ba575631d36a` | Four-frame 40-60 px black marker atlas rendered by a separate transparent face-overlay sprite; source portraits remain untouched |

The curated images use the established five-color International Style direction: deep green, ink black, warm cream, yellow green, and fluorescent pollution green. The character set keeps flat cartoon proportions, limited moss-green values, halftone texture, pixel-stepped contours, and restrained channel offsets. Horror comes from one readable rule error per character rather than realistic distress or grotesque anatomy; the full direction is documented in `docs/design/denpa_cartoon_horror_direction.md`.

## User-supplied visual references

`world/reference_districts/` contains the three scene references supplied by the project owner for the sunlit brick street, night white-block neighborhood, and overgrown gallery. They are mounted as distant continuation planes inside newly modeled 3D districts; they are not redistributed as standalone stock content.

`1/` contains eight dithered green/blue photographs supplied by the project owner. The floor generator rotates them across in-world memory panels to support the fragmented, low-signal atmosphere.

The protagonist identity is based on the project owner's `IMG_3060.PNG`, `未命名作品 2.PNG`, and `未命名作品 3.PNG`. External game screenshots were used only to discuss broad rendering traits; no reference character or source asset is included in these generated designs.

## Procedural local assets

`scripts/reality_floor_generator.gd` builds nine recognizable liminal prop families entirely from Godot primitive meshes: false window, water cooler, CRT cart, payphone, folding chair, vending machine, fluorescent troffer, supply crates, and pipe manifold. No external model or texture is bundled. The research and originality boundary are documented in `docs/design/backrooms_prop_research.md`.

`tools/generate_visual_assets.py` may recreate only the small HUD icons and player portrait. It intentionally does not regenerate curated imagegen art or retired road, hand-phone, NPC, or split social-poster files.

`tools/generate_audio_assets.py` deterministically synthesizes the short utility sounds and the two retired eight-second ambience beds from oscillators and seeded noise.

`tools/generate_music_stems.py` maintains the active original score, `Babel Liminal Score`, and the five-layer phone-floor music set. Every file is a 96-second, 22.05 kHz, 16-bit stereo WAV. The generated compositions use only mathematical oscillators, integer-cycle periodic noise, FM synthesis, and deterministic envelopes. They contain no samples, recordings, extracted melodies, modelled voices, third-party impulse responses, or commercial game music. Reproducibility metadata, exact frame counts, loop-seam measurements, full-loop pairwise correlations, and SHA-256 hashes are stored in `audio/babel_liminal_score.json`.

### Phone-floor music

| Floor | Runtime asset | Origin | SHA-256 | Musical identity |
| --- | --- | --- | --- | --- |
| 1 | `audio/babel_phone_signal_floor_1.wav` | Project-original historical asset restored byte-for-byte from Git blob `f671f7d3fc892e4d216a6f4bb95fd63a1da43127` | `e361ea4b487e2ea0ef15a8d970a245429cdbf7fb9cb7fad69192cf6a7b04f698` | Recovered narrowband carrier and packet chimes |
| 2 | `audio/babel_phone_signal.wav` | Existing project-original phone signal, preserved byte-for-byte | `be1e497be9cc9131ae1e261c3494e2fcf310e01393c2dfdf3a81b07851c87de3` | FM packet fragments, soft clock, and signal dust |
| 3 | `audio/babel_phone_signal_floor_3.wav` | Deterministic project-original synthesis | `658dc19d12850fd94fd5c150a77f741d2a07b0b28f153b8b1889e0354bc31d3f` | Beatless exchange hum, descending tolls, and electromagnetic fog |
| 4 | `audio/babel_phone_signal_floor_4.wav` | Deterministic project-original synthesis | `73e0374907d6e9fbe10fbb4be951d9415ab2b210883664e0e0d81263b5f2b011` | Five-step relay motion, motor pulses, and inharmonic metal decay |
| 5 | `audio/babel_phone_signal_floor_5.wav` | Deterministic project-original synthesis | `0d79332034563d58489b248688988712a977bb0f7088a929864fe1bbeb30138f` | Synthetic formant clusters, reverse-breath swells, and a subharmonic void |

`audio/babel_reality_liminal.wav` is deliberately preserved at SHA-256 `39b5bc85c5c62c77af894ce471ff29d5602ab956e48b21064f364d55b6e8071a`. A normal generator run renders only floors 3 through 5 and leaves the established reality, phone, and pollution stems untouched. `--include-core-stems` is an explicit opt-in for rebuilding those older deterministic stems.

Run the non-writing integrity check with:

```bash
python3 tools/generate_visual_assets.py --verify
python3 tools/generate_audio_assets.py --verify
python3 tools/generate_music_stems.py --verify
```

Render the three new phone-floor loops with `python3 tools/generate_music_stems.py`.
