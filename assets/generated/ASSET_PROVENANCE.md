# Generated Asset Provenance

The game keeps two composition-defining raster assets as curated OpenAI imagegen outputs. They are loaded directly at runtime and are not recreated by the procedural fallback generator.

## Curated imagegen assets

| Runtime asset | Original generation | Size | SHA-256 | Role |
| --- | --- | --- | --- | --- |
| `world/phone_down_backdrop.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbc5187dc81918176aff7c3059317.png` | 1672 x 941 | `b47f8772e40da13dada074bc3518be9fef4368ff9941dca35826bd576a49e6fe` | Low-view road, hand, and phone composition |
| `social/poster_sheet.png` | `/Users/zhang/.codex/generated_images/019f3588-2c22-7b91-914e-587404e05fbc/ig_076d677daea12b9f016a4cbcafe3c08191937224629c9b05eb.png` | 1448 x 1086 | `76ae2647761ba61c4923f161f49d9e09f142042d26088b37b267a9db1d059594` | Twelve-cell social urban-legend poster atlas |

Both images use the established five-color International Style direction: deep green, ink black, warm cream, yellow green, and fluorescent pollution green. Their subjects combine an empty road, telecommunications towers, analog signal noise, and editorial poster grids.

## Procedural local assets

`tools/generate_visual_assets.py` may recreate only the small HUD icons and player portrait. It intentionally does not regenerate retired road, hand-phone, NPC, or split social-poster files.

Run the non-writing integrity check with:

```bash
python3 tools/generate_visual_assets.py --verify
```
