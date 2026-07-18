# Goal Completion Matrix

Date: 2026-07-18

This matrix is the handoff contract for independent review. A row is complete only when implementation, automated evidence, and observable runtime evidence agree.

## Verification Baseline

- Godot: `4.6.3.stable`
- Automated suite: all 18 scripts under `res://tests/` pass headlessly.
- Deterministic asset checks pass for visual assets, UI/audio assets, the cover-watcher stinger, and all five phone-music stems.
- Rendered captures completed with exit code 0 for the Japanese feed, floors two and three, NPC dialogue, merchant dialogue, authored horror events, and the cover watcher.
- Short-lived capture scripts still produce Godot shutdown-time RID/resource warnings after a successful saved frame. No GDScript error, scene-load failure, or rendering failure occurs; this is recorded as a harness limitation rather than hidden.

## Requirement Evidence

| # | Requirement | Implementation evidence | Automated evidence | Runtime evidence |
| --- | --- | --- | --- | --- |
| 1 | Japanese social cards have equal width; heights may differ; cards open. | `babel_meme_game.gd` builds one two-column `SocialFeedMasonry` grid with clipped card contents and poster click targets. | `test_social_feed_layout.gd` compares every rendered width within 0.5 px, requires staggered heights, then injects a real pointer click and verifies the detail page. | `tools/current_social_japanese.png`, `tools/current_social_japanese_detail.png` |
| 2 | Floor three uses full-map grass and brighter natural light; floor two returns to near-black. | `reality_floor_generator.gd` creates one 50,000+ instance grass MultiMesh over the complete map bounds. Floor 2 ambient/key energy are 0.14/0.30; floor 3 uses 0.68/1.18 with cleaner fog and skylights. | `test_reality_world.gd` checks full culling bounds, coverage ratio 1.0, density, natural-light metadata, and the floor 2/3 energy separation. | `tools/current_reality_floor_2.png`, `tools/current_reality_floor_3.png` |
| 3 | Preserve phone-down music; restore the earlier phone-up track on floor one; keep the current floor-two track; create distinct tracks for every later floor. | Five deterministic 96-second stereo phone loops plus the preserved reality loop are selected by tower floor in `babel_meme_game.gd`. Metadata pins the historic floor-one Git blob and the unchanged floor-two/reality hashes. | `test_phone_music_assets.gd` verifies exact hashes, formats, loop points, five distinct designs, and all ten pairwise correlations; `test_audio_runtime.gd` verifies floor routing and crossfade behavior. | Runtime audio players load and play in `test_audio_runtime.gd`; metadata is in `assets/generated/audio/babel_liminal_score.json`. |
| 4 | Successful ordinary-NPC dialogue awards a Meme Frame at roughly 40-50%. | `NPC_MEME_FRAME_REWARD_CHANCE_PERCENT` is 45, with deterministic actor/day rolls, daily deduplication, third-eligible-success pity, and merchant exclusion. | `test_meme_game_state.gd` covers chance, pity, duplicate attempts, merchant exclusion, action cost, and old/new save compatibility. | Reward feedback is rendered by the normal reality-dialogue result flow. |
| 5 | Add recognizable low-poly horror/dreamcore objects, place them logically, and make them non-pickup. | Nine original procedural families: false window, water cooler, CRT cart, payphone, folding chair, vending machine, fluorescent troffer, supply crates, and pipe manifold. | `test_reality_world.gd` requires every family, at least 18 instances, defining silhouette parts, original procedural metadata, and zero pickup/interactable paths. | `tools/current_floor_2_*.png` and `tools/current_floor_3_*.png`; rationale in `docs/design/backrooms_prop_research.md`. |
| 6 | Floor two is a large uneven irregular circle with sparse scattered houses. | A 96 by 16 segment unequal-radius ArrayMesh disc uses deterministic height variation, matching trimesh collision, six houses spread across both axes, and a 16% maximum building-coverage ratio. | `test_reality_world.gd` checks dimensions comparable to floor one, center fill, boundary clamping, collision, elevation, six physical houses, and two-axis spread. | `tools/current_reality_floor_2.png` plus floor-two artifact captures. |
| 7 | Fixed focal depth keeps nearby content clear and distant content soft. | The reality camera uses far DOF beginning at 18 m over a 12 m transition; near blur is disabled. | `test_reality_world.gd` checks all camera attributes and the `near_clear_far_soft` profile. | Distance falloff is visible in floor and object captures. |
| 8 | Simplify the meme bank and use `easeOutQuint` for contextual motion. | Meme bank is contextual to notebook/publish only; its radial selector supports wheel, trackpad, touch, and clicks. Godot `TRANS_QUINT + EASE_OUT` implements the requested GSAP `power5.out` curve without a web dependency. | `test_day_transition.gd` checks contextual visibility, interrupted open/close tweens, curve metadata, and no action cost; `test_drag_controls.gd` checks ring movement and the same curve. | `tools/current_notebook_view.png`, `tools/current_publish_view.png`; contract in `docs/design/meme_bank_motion.md`. |
| 9 | Learn from the local Milk installation's atmosphere and writing without weakening originality. | Presentation uses short observation/correction beats, viewpoint-bound UI, selective disruptions, and ordinary-object anchors. No archive, dialogue, image, or audio was copied into the project. | `test_localization.gd`, `test_richtext_effects.gd`, and dialogue/state tests protect authored cadence and playable flow. | Direction and originality boundary: `docs/design/character_and_narrative_direction.md`, `docs/design/denpa_cartoon_horror_direction.md`. |
| 10 | Improve English/Japanese localization as localization rather than literal substitution. | Parallel catalogs cover UI, feed, NPCs, events, endings, dynamic formats, and language-specific tokenization. | `test_localization.gd` checks catalog-key parity, ordered placeholder parity, terminology, native sample lines, source-literal coverage, and Chinese/English/Japanese text-unit rules. | `tools/current_social_english.png`, `tools/current_social_japanese.png`, `tools/current_language_selection.png`; audit in `docs/research/localization_voice_audit.md`. |
| 11 | NPC/merchant face obstruction is animated, opaque black handwriting on a separate layer. | Untouched character `Billboard` and independent `FaceScribbleOverlay` are unshaded camera-facing sprites; the overlay uses a four-frame atlas, 56 px black strokes, higher render priority, and no multiply/dark rectangle. | `test_reality_world.gd` checks source preservation, transform registration, shader path/parameters, billboard behavior, opacity, width, and priority. | `tools/current_npc_character_view.png`, `tools/current_npc_character_view_phase_b.png`, `tools/current_merchant_view.png`. |
| 12 | Remove redundant values/bonuses while retaining mechanics that materially affect play. | Global HUD exposes only Day, Pollution, Money, and Actions; tower floor lives in a social secondary page. Redundant multiplier mirrors and six dead HUD bindings were removed; Heat, Clarity, and threshold discount remain hidden because they affect progression. | `test_main_scene.gd` guards the reduced HUD/profile surface and secondary tower location; state/playthrough tests retain pressure, pollution, ascent, and recovery behavior. | `docs/design/mechanics_surface_audit.md` records every retained and removed value. |
| 12A | NPC and merchant art should feel more unsettling, indie, and less cute/mature-realistic. | Four curated 1024 x 1536 portraits share faceless cream heads, restrained green/black print grain, front-facing compact proportions, and role-specific props. | `test_character_assets.gd` pins the curated sources, transparent canvas, palette, and featureless face region; `test_reality_world.gd` verifies floor-independent colors. | Source assets under `assets/generated/characters/`; latest NPC and merchant captures above. |
| 13 | Overall presentation should use restrained psychological-horror craft inspired by repeated-space, compliance, and subjective-perception references. | Deterministic light-memory, failed-sign, rare mirage, language-pollution flashback, inherited-language pressure, and non-jumpscare spatial repetition form one authored system. | `test_authored_horror_events.gd`, `test_oldweb_archive.gd`, `test_playthrough_flow.gd`, and `test_main_scene.gd` cover scheduling, state transitions, progression, and the empty-tower ending. | `tools/current_horror_*.png`; research synthesis in `docs/design/psychological_horror_event_research.md`. |
| A | NPCs and merchant are eye-level, slightly cartoon, and have no facial details. | All four source images are featureless. Runtime normalizes portraits to 1.90 m, grounds their feet, places face centers within 0.08 m of the 1.56 m first-person eye line, and keeps both image layers billboarding together. | `test_character_assets.gd` and `_assert_actor_face_veil()` in `test_reality_world.gd`. | Latest NPC/merchant captures above. |
| B | A faceless watcher appears once per floor behind nearby cover, retreats on approach, vanishes, and plays a 2-3 second cue. | Per-floor persistent seen state, cropped image billboard, physical cover, 0.72 s reveal, 6.4 m approach threshold, quint retreat, and 2.45 s non-looping generated stinger. | `test_cover_watcher.gd`, `test_audio_runtime.gd`, and `test_save_progress.gd`. | `tools/current_horror_cover_watcher.png`. |

## Test Command

Each test is a standalone SceneTree script. Example:

```bash
HOME=/Users/zhang/Documents/游戏/.godot_home \
  /Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot \
  --headless --path /Users/zhang/Documents/游戏/babel-meme-game \
  --script res://tests/test_reality_world.gd
```

## Asset Integrity Commands

```bash
python3 tools/generate_visual_assets.py --verify
python3 tools/generate_audio_assets.py --verify
python3 tools/generate_cover_watcher_stinger.py --verify
/Users/zhang/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 tools/generate_music_stems.py --verify
```
