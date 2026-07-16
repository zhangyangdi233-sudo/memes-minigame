# Generated Asset Provenance

The game keeps nine composition-defining raster assets as curated OpenAI imagegen outputs. They are loaded directly at runtime and are not recreated by the procedural fallback generator.

## Curated imagegen assets

| Runtime asset | Original generation | Size | SHA-256 | Role |
| --- | --- | --- | --- | --- |
| `world/phone_down_backdrop.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbc5187dc81918176aff7c3059317.png` | 1672 x 941 | `b47f8772e40da13dada074bc3518be9fef4368ff9941dca35826bd576a49e6fe` | Low-view road, hand, and phone composition |
| `world/npc_signal_portrait.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-36e50e5c-760a-4fce-a1da-769248b49ed5.png` | 1024 x 1536 | `440d89e06cbb96b63570885939d02e08382d4464fbe24b9874a08907716517fa` | Chroma-keyed reality-dialogue classmate portrait |
| `social/poster_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbcafe3c08191937224629c9b05eb.png` | 1448 x 1086 | `76ae2647761ba61c4923f161f49d9e09f142042d26088b37b267a9db1d059594` | Twelve-cell social urban-legend poster atlas |
| `ui/arcana_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-479815ca-02a7-4a9d-b2c9-382b2dc7f426.png` | 1536 x 1024 | `ca52ccc5d003c7a7786fd8f3157fc134a1f7426cf488ef78fc3eb98ece10e7bc` | Six-cell signal-arcana consumable atlas |
| `characters/protagonist_operator.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-4ff17ce4-2fbc-41ea-bf9f-6335ec884086.png` | 1024 x 1536 | `d5c0f85474b7f7f59d7e031d81e751eb7e928fe7f105329372d4951fe7d0a1cd` | Identity-preserving protagonist based on the project owner's drawings |
| `characters/merchant_frame_vendor.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-8da1abae-e72f-4812-894d-00f1b0f803ce.png` | 1024 x 1536 | `25086b7a615cb7db29fd8c1a64df8f9d5e641f5bff0c394b41e0ee2cd65ba9c3` | Empty-frame merchant billboard |
| `characters/npc_late_arrival.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-587c81ff-ceac-4ae4-91fb-8c0450427659.png` | 1024 x 1536 | `ac04e563a31f32e4b08a45d0f781d12fdd6eb6c9ce00f80cd2918ce3b163a3ff` | Late-arrival commuter billboard |
| `characters/npc_echo_tenant.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-54bba57d-4581-414a-bc65-221c74fdcb6e.png` | 1024 x 1536 | `97b3f5c47efe59dc72cc7d639405a6bbc44f1dd9d3fd612225b9a527923bbf36` | Echo-tenant billboard |
| `characters/npc_archive_witness.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-0f825ce3-8410-4444-85a8-025c84561426.png` | 1024 x 1536 | `48cd98bc9b808fcb0b7678f371208dc10be70ba4a15af4c87ce760bfb6215866` | Archive-witness billboard |

The curated images use the established five-color International Style direction: deep green, ink black, warm cream, yellow green, and fluorescent pollution green. The character set shares flat cartoon proportions, limited moss-green values, pixel-stepped contours, and offset white signal outlines.

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
