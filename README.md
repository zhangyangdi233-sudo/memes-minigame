# Babel Meme Game

Standalone Godot 4.6 game built from the third-chapter meme prototype. It combines a phone-based urban-legend feed, language-aware Meme Frames, meme fusion, integer propagation scoring, permanent Tarot ascent choices, inherited meme rules, and pollution-distorted reality dialogue.

## Current Loop

1. Browse image-led social posts and collect one language-aware unit at a time: a Chinese character, a Japanese lexical unit, or an English word.
2. Buy an infrequent Meme Frame and place one collected unit into its only core slot.
3. Fuse two completed memes for higher propagation and higher pollution.
4. Build around the day's signal hand, then publish for heat and money.
5. Put the phone away and explore the current tower floor as a first-person 3D street district.
6. Approach a billboard NPC or the floor merchant, press `F`, and carry every previous floor's hottest meme into reality as a legacy rule.
7. On ascent, choose one of three named Tarot passives; combinations such as Star + Sun + Moon unlock additional effects.

Each day has five effective actions. Navigation, window movement, preview placement, and editing do not spend actions.

After the fifth normal action, the inline action pulse hands off to a 3.6-second internationalist day transition before settlement restores five actions. The one-time 60% pollution flashback keeps its own direct black-screen jump and does not stack this transition.

The phone launcher keeps all four Apps in separate movable windows. The social App uses a tall phone layout with an image-first two-column feed, a separate draggable post-detail companion, and a mobile publish flow ordered as content, propagation preview, and signal hand. Following accounts and liking posts from Discover are free and persist across days; Nearby remains unavailable because the device has no location signal.

The Profile page also contains the optional `BABEL-LINK 98` cache: a square-edged old website with a guestbook, mirrored incidents, broken links, and a four-digit source-code puzzle. Browsing it costs no daily action, and its unlock state is saved locally.

The meme bank is a right-edge radial selector that appears contextually on the social Publish page and beside the notebook. Completed memes sit on the ring and can be selected with the mouse wheel, a Mac trackpad pan, clicking, or drag and drop. The notebook opens at the upper left and separates frame crafting from two-meme fusion with browser-style tabs.

## Reality Controls

- `WASD` or arrow keys: move freely through the shared street and its open lots.
- Mouse: lowering the phone captures the cursor for free look; `Esc` releases it and a left click captures it again.
- Touchscreen: drag across the open reality view to turn and tilt the camera without spending an action.
- Mac trackpad: two-finger pan follows the physical finger direction; sliding left looks left and sliding down looks down.
- `F`: talk to the nearby NPC or merchant.
- `Tab`: raise or lower the phone.

The first floor starts with four open street lots along a continuous street at least 230 meters long, five times the original map length. Its central crossing extends 43.2 meters in both horizontal directions, with repeated light bays, false doors, continuous visible walls, and a cross-shaped twelve-segment collision perimeter. Ordinary NPC population falls by floor from four to zero while one merchant remains. Floor two is a near-black irregular disc shaped by thirteen broad, walkable hill mounds. Nine detached houses scatter across both axes, while only the original six remain gameplay anchors so the extra scenery cannot multiply rewards. Floor three becomes a naturally skylit 341-meter green-gray gallery whose complete ground is covered by one batched meadow. Later floors keep tested collision, fall recovery, fixed-focus distance blur, cold fog, and no jump-scare trigger volumes.

NPCs and the merchant use front-facing faceless source portraits at the player's eye line. A separate animated 56 px black-marker layer redraws over the blank face while preserving the original portrait, color, and billboard transform. Once on every floor, a faceless image watcher briefly appears beside physical cover, plays a 2.45-second non-looping cue, retreats behind the cover when approached, and remains gone on that floor after saving.

## Adaptive Score

The preserved 96-second reality loop is paired with a distinct 96-second phone loop for each tower floor. Floor one restores its pinned historical mix, floor two preserves the later signal mix byte-for-byte, and floors three through five introduce separate original horror arrangements. A five-note `E-G-B-F#-A` motif gives the score a recognizable identity while each floor changes its sound palette and structure. All source audio is deterministic local synthesis with no external samples or transcribed melody.

Regenerate or verify the committed score with NumPy available:

```sh
python3 tools/generate_music_stems.py
python3 tools/generate_music_stems.py --verify
```

Glowing street relics can be collected with `F` without spending an action. `信号筹码` adds eight base points to the next publication, `回声镜片` adds one point to the shared integer multiplier, and `清晰线` immediately restores seven clarity. Publish modifiers are consumed after one successful post, while collected relic IDs remain gone if the floor is rebuilt.

Reality conversations use a cursor-driven three-choice surface. Every ordinary NPC now carries a three-turn arc that adds concrete district history and can be interrupted by failed understanding. Hovering previews the full clean intention; after selecting, any physical key reveals one language-aware unit. Pollution replaces units with red signal glyphs, while legacy phrases are inserted automatically. The first completed sentence costs one action and the remaining turns are free. Finishing the full arc has a pure deterministic 45% chance to leave a free Meme Frame, with no pity or hidden guarantee; the same NPC cannot be farmed twice on one day.

Choosing the merchant's authored trade response reveals one rotating communication aid. `静音贴`, `语义锚`, and `旧词典页` have different prices, bonuses, and limited charges. The strongest owned item is consumed only when pollution would otherwise overwhelm the sentence.

At the empty tower top there is no sage and no ordinary sentence. The final interaction compresses the remaining language to exactly four irreversible choices: blank, blocks, `哈吉米`, or silence. After one choice, the tower gives no reply and only a restart remains.

## Localization and Saves

The first launch opens a native-name language choice for Chinese, Japanese, and English before the main menu. Language can be changed again in Settings without restarting the run. Settings also provides a manual save button; language, master volume, and VHS preference are stored separately from run progress.

Chinese remains the authored source language. English and Japanese use audited catalogs covering UI, feed posts, NPC dialogue, floor events, legacy phrases, ending copy, and formatted runtime messages. English collection and corruption operate on complete words, Japanese collection preserves kanji compounds, kana groups, loanwords, and numbered nouns, and Chinese retains character-level rhythm. `res://tests/test_localization.gd` scans the three gameplay scripts for untranslated Chinese literals in addition to exercising the first-run selector and settings controls.

## Run

Open this folder in Godot 4.6 or newer. The main scene is:

```text
res://scenes/babel_meme_game.tscn
```

On this machine, the project can be launched with:

```sh
/Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --path /Users/zhang/Documents/游戏/babel-meme-game
```

## Tests

Run the headless state tests with:

```sh
HOME=/Users/zhang/Documents/游戏/.godot_home /Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhang/Documents/游戏/babel-meme-game --script res://tests/test_meme_game_state.gd
```

The rendered publish-layout capture tool is `res://tools/capture_publish_scene.gd`.
Set `BABEL_CAPTURE_FLOOR=1`, `2`, or `3` and run `res://tools/capture_reality_district.gd` from a rendered Godot session to capture each district. Add `BABEL_CAPTURE_OVERVIEW=1` on floor two for the elevated structural QA view that proves the irregular clearing and sparse house spread. Run `res://tools/capture_meme_bank_motion.gd` to save closed, opening, and open frames plus the measured scale/alpha trace. The generated-floor regression test is `res://tests/test_reality_world.gd`, and the transition/context test is `res://tests/test_day_transition.gd`. Capture tools cover walking, dialogue, merchant inventory, observer retreat, and the next-day frame under `res://tools/`.

Run the localization audit with `res://tests/test_localization.gd`. It verifies catalog parity, dynamic format strings, language-specific text units, first-run language selection, settings language switching, and source-literal coverage.

Run `res://tests/test_oldweb_archive.gd` for the optional archive puzzle and `res://tests/test_reality_world.gd` for continuous architecture, descending NPC population, suspense lighting, walkable clearance, and zero jump-scare trigger volumes.

Reality floors two through five also use a deterministic, floor/day-authored horror table. Movement and camera observation drive a finite light failure, a one-letter EXIT-sign absence, and a transparent distant mirage scheduled only on days four and nine. `res://tests/test_authored_horror_events.gd` verifies the state sequences and confirms that no event is an `Area3D` jump-scare trigger.

The full requirement-to-evidence audit, including all 18 automated tests and rendered capture paths, is recorded in `docs/goal_completion_matrix.md`.

## Third-party Addon

`addons/richtext2/` contains RichTextLabel2 v1.14 by chairfull under the MIT license. Its license is preserved at `addons/richtext2/LICENSE`.
