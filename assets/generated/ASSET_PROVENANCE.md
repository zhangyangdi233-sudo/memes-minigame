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

`tools/generate_visual_assets.py` may recreate only the small HUD icons and player portrait. It intentionally does not regenerate curated imagegen art or retired road, hand-phone, NPC, or split social-poster files.

`tools/generate_audio_assets.py` deterministically synthesizes four mono 22.05 kHz WAV files from oscillators and seeded noise: the phone-road loop, reality-room loop, pollution flashback burst, and action tick. No external recordings are used.

Run the non-writing integrity check with:

```bash
python3 tools/generate_visual_assets.py --verify
python3 tools/generate_audio_assets.py --verify
```
