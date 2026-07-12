# Generated Asset Provenance

The game keeps four composition-defining raster assets as curated OpenAI imagegen outputs. They are loaded directly at runtime and are not recreated by the procedural fallback generator.

## Curated imagegen assets

| Runtime asset | Original generation | Size | SHA-256 | Role |
| --- | --- | --- | --- | --- |
| `world/phone_down_backdrop.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbc5187dc81918176aff7c3059317.png` | 1672 x 941 | `b47f8772e40da13dada074bc3518be9fef4368ff9941dca35826bd576a49e6fe` | Low-view road, hand, and phone composition |
| `world/npc_signal_portrait.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-36e50e5c-760a-4fce-a1da-769248b49ed5.png` | 1024 x 1536 | `440d89e06cbb96b63570885939d02e08382d4464fbe24b9874a08907716517fa` | Chroma-keyed reality-dialogue classmate portrait |
| `social/poster_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbcafe3c08191937224629c9b05eb.png` | 1448 x 1086 | `76ae2647761ba61c4923f161f49d9e09f142042d26088b37b267a9db1d059594` | Twelve-cell social urban-legend poster atlas |
| `ui/arcana_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/exec-479815ca-02a7-4a9d-b2c9-382b2dc7f426.png` | 1536 x 1024 | `ca52ccc5d003c7a7786fd8f3157fc134a1f7426cf488ef78fc3eb98ece10e7bc` | Six-cell signal-arcana consumable atlas |

All four images use the established five-color International Style direction: deep green, ink black, warm cream, yellow green, and fluorescent pollution green. Their subjects combine an empty road, telecommunications towers, analog signal noise, a detached classmate, occult broadcast symbols, and editorial poster grids.

## User-supplied visual references

`world/reference_districts/` contains the three scene references supplied by the project owner for the sunlit brick street, night white-block neighborhood, and overgrown gallery. They are mounted as distant continuation planes inside newly modeled 3D districts; they are not redistributed as standalone stock content.

`1/` contains eight dithered green/blue photographs supplied by the project owner. The floor generator rotates them across in-world memory panels to support the fragmented, low-signal atmosphere.

## Procedural local assets

`tools/generate_visual_assets.py` may recreate only the small HUD icons and player portrait. It intentionally does not regenerate curated imagegen art or retired road, hand-phone, NPC, or split social-poster files.

`tools/generate_audio_assets.py` deterministically synthesizes four mono 22.05 kHz WAV files from oscillators and seeded noise: the phone-road loop, reality-room loop, pollution flashback burst, and action tick. No external recordings are used.

Run the non-writing integrity check with:

```bash
python3 tools/generate_visual_assets.py --verify
python3 tools/generate_audio_assets.py --verify
```
