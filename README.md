# Babel Meme Game

Standalone Godot 4.6 game built from the third-chapter meme prototype. It combines a phone-based urban-legend feed with emotion-slot crafting, Balatro-like propagation scoring, signal-arcana consumables, permanent ascent modifiers, inherited meme rules, and reality dialogue that becomes less understandable as pollution rises.

## Current Loop

1. Browse the social feed and collect language fragments.
2. Buy and edit emotion slots, then craft a complete meme from two core fragments.
3. Build around the day's signal hand for extra propagation base and multiplier.
4. Buy up to two signal-arcana cards, then use them to rewrite a meme, reroll a hand, or amplify one publish.
5. Publish for heat and money while accepting the hand and arcana pollution risks.
6. Ascend the tower, keep one permanent modifier, and carry the previous floor's hottest meme into reality as a legacy rule.

Each day has five effective actions. Navigation, window movement, preview placement, and editing do not spend actions.

The social phone starts with an empty Following channel. Following accounts and liking posts from Discover are free and persist across days; Nearby remains unavailable because the device has no location signal.

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
