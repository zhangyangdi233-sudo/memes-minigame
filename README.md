# Babel Meme Game

Standalone Godot 4.6 game built from the third-chapter meme prototype. It combines a phone-based urban-legend feed with emotion-slot crafting, integer propagation scoring, signal-arcana consumables, permanent ascent modifiers, inherited meme rules, and reality dialogue that becomes less understandable as pollution rises.

## Current Loop

1. Browse the social feed and collect language fragments.
2. Buy and edit emotion slots, then craft a complete meme from two core fragments.
3. Build around the day's signal hand for additive propagation base and one shared integer multiplier.
4. Buy up to two signal-arcana cards, then use them to rewrite a meme, reroll a hand, or amplify one publish.
5. Publish for heat and money while accepting the hand and arcana pollution risks.
6. Put the phone away and explore the current tower floor as a first-person 3D street district.
7. Approach a billboard NPC or the floor merchant, press `F`, and carry the previous floor's hottest meme into reality as a legacy rule.

Each day has five effective actions. Navigation, window movement, preview placement, and editing do not spend actions.

After the fifth normal action, the inline action pulse hands off to a 3.6-second internationalist day transition before settlement restores five actions. The one-time 60% pollution flashback keeps its own direct black-screen jump and does not stack this transition.

The phone launcher keeps all four Apps in separate movable windows. The social App uses a tall phone layout with an image-first two-column feed, a separate draggable post-detail companion, and a mobile publish flow ordered as content, propagation preview, signal hand, and arcana. Following accounts and liking posts from Discover are free and persist across days; Nearby remains unavailable because the device has no location signal.

The meme bank is hidden globally. It appears only as a small attached file window on the social Publish page, where it can still be expanded and dragged; feed browsing, notebook crafting, phone home, and reality walking expose no corner tab.

## Reality Controls

- `WASD` or arrow keys: move freely through the shared street and its open lots.
- Mouse: lowering the phone captures the cursor for free look; `Esc` releases it and a left click captures it again.
- Touchscreen: drag across the open reality view to turn and tilt the camera without spending an action.
- `F`: talk to the nearby NPC or merchant.
- `Tab`: raise or lower the phone.

The first floor starts with four open street lots around a continuous 34 x 46 meter ground plane. Each ascent adds two or three lots and lengthens the shared street, reduces the ordinary NPC population from five toward two, and always keeps one merchant. The floors rotate through three distinct 3D districts: a sunlit brick road and crossing, a night neighborhood of white cubic homes and warm lamps, and an overgrown white colonnade. Generated memory photographs are mounted inside each district as environmental fragments. Four invisible perimeter walls and a fall-recovery safeguard keep the player inside the walkable district. The cinematic bars stay fixed, while phone and App windows render above them.

Glowing street relics can be collected with `F` without spending an action. `信号筹码` adds eight base points to the next publication, `回声镜片` adds one point to the shared integer multiplier, and `清晰线` immediately restores seven clarity. Publish modifiers are consumed after one successful post, while collected relic IDs remain gone if the floor is rebuilt.

Reality conversations use a cursor-driven three-choice surface. Each choice is a three-to-five-character summary; hovering previews the full clean intention without covering the NPC subtitle. After selecting, any physical key reveals exactly one character. Unspoken characters remain gray, clean characters turn cream-white, and pollution successes replace that position with red signal glyphs or fragments from the meme bank. All dialogue uses RichTextLabel2's `curspull` effect, while polluted red glyphs additionally use `cuss`. Legacy phrases are inserted automatically. Completing the whole sentence costs one action; partial typing is free. Ordinary NPCs make one understanding check, merchants make three, and three failed attempts close the conversation until the player presses `F` again.

If the merchant understands `询问商品`, they reveal one rotating communication item. `静音贴`, `语义锚`, and `旧词典页` have different prices, bonuses, and limited charges. The strongest owned item is consumed only when the listener's base understanding roll would fail, so an already clear sentence never wastes a charge.

At the empty tower top there is no sage and no ordinary sentence. The final interaction compresses the remaining language to exactly four irreversible choices: blank, blocks, `哈吉米`, or silence. After one choice, the tower gives no reply and only a restart remains.

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
Set `BABEL_CAPTURE_FLOOR=1`, `2`, or `3` and run `res://tools/capture_reality_district.gd` from a rendered Godot session to capture each district. The generated-floor regression test is `res://tests/test_reality_world.gd`, and the transition/context test is `res://tests/test_day_transition.gd`. Capture tools cover walking, dialogue, merchant inventory, and the next-day frame under `res://tools/`.

## Third-party Addon

`addons/richtext2/` contains RichTextLabel2 v1.14 by chairfull under the MIT license. Its license is preserved at `addons/richtext2/LICENSE`.
