# Babel Meme Game

Standalone Godot 4.6 game built from the third-chapter meme prototype. It combines a phone-based urban-legend feed with emotion-slot crafting, Balatro-like propagation scoring, signal-arcana consumables, permanent ascent modifiers, inherited meme rules, and reality dialogue that becomes less understandable as pollution rises.

## Current Loop

1. Browse the social feed and collect language fragments.
2. Buy and edit emotion slots, then craft a complete meme from two core fragments.
3. Build around the day's signal hand for extra propagation base and multiplier.
4. Buy up to two signal-arcana cards, then use them to rewrite a meme, reroll a hand, or amplify one publish.
5. Publish for heat and money while accepting the hand and arcana pollution risks.
6. Put the phone away and explore the current tower floor as a first-person 3D space.
7. Approach a billboard NPC or the floor merchant, press `F`, and carry the previous floor's hottest meme into reality as a legacy rule.

Each day has five effective actions. Navigation, window movement, preview placement, and editing do not spend actions.

The social phone starts with an empty Following channel. Following accounts and liking posts from Discover are free and persist across days; Nearby remains unavailable because the device has no location signal.

## Reality Controls

- `WASD` or arrow keys: move through the generated rooms.
- Mouse: click the world to capture the cursor and look around; `Esc` releases it.
- `F`: talk to the nearby NPC or merchant.
- `Tab`: raise or lower the phone.

The first floor starts with four rooms. Each ascent adds two or three rooms, reduces the ordinary NPC population from five toward two, and always keeps one merchant. Some rooms contain signal items while others are deliberately empty. The cinematic bars stay fixed, while phone and App windows render above them.

Reality conversations use a cursor-driven three-choice surface. Each choice is a three-to-five-character summary; hovering previews the full clean intention without covering the NPC subtitle. After selecting, any physical key reveals exactly one character. Unspoken characters remain gray, clean characters turn cream-white, and pollution successes replace that position with red signal glyphs or fragments from the meme bank. Legacy phrases are inserted automatically. Completing the whole sentence costs one action; partial typing is free. Ordinary NPCs make one understanding check, merchants make three, and three failed attempts close the conversation until the player presses `F` again.

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
The generated-floor regression test is `res://tests/test_reality_world.gd`. `res://tools/capture_reality_scene.gd` captures the walking view, while `res://tools/capture_dialogue_scene.gd` captures the subtitle and response layout.
