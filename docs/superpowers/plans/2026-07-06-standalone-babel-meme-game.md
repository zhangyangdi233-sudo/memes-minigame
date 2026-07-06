# Standalone Babel Meme Game Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone Godot game from the Babel meme pollution prototype, separate from `X.-WHEEL`.

**Architecture:** The project uses one pure gameplay state script for rules and one Control scene script for UI. The rules can be tested headlessly with Godot `--script`; the UI only calls the state API and rebuilds itself from state.

**Tech Stack:** Godot 4.6.3, GDScript, native Control UI, no network, no WebView, no dependency on `X.-WHEEL`.

---

### Task 1: Project Skeleton and Logic Tests

**Files:**
- Create: `project.godot`
- Create: `tests/test_meme_game_state.gd`
- Later create: `scripts/meme_game_state.gd`

- [x] **Step 1: Create the standalone project directory**

Run: `mkdir -p babel-meme-game/docs/superpowers/plans babel-meme-game/tests babel-meme-game/scripts babel-meme-game/scenes`

- [x] **Step 2: Add `project.godot`**

The main scene is `res://scenes/babel_meme_game.tscn`.

- [ ] **Step 3: Write failing logic tests**

Tests assert: five effective actions auto-mark day settlement, picking tokens costs action, navigation is free, placing tokens/placing memes is free, crafting and dialogue confirmation cost action.

- [ ] **Step 4: Run tests and confirm RED**

Run: `/Users/zhang/Documents/游戏/Godot_4.6.3/Godot.app/Contents/MacOS/Godot --headless --path /Users/zhang/Documents/游戏/babel-meme-game --script res://tests/test_meme_game_state.gd`

Expected: FAIL because `res://scripts/meme_game_state.gd` does not exist yet.

### Task 2: Pure Gameplay State

**Files:**
- Create: `scripts/meme_game_state.gd`
- Modify: `tests/test_meme_game_state.gd`

- [ ] **Step 1: Implement minimal state API**

Implement `new_run`, `set_phone_open`, `set_active_app`, `pick_token`, `buy_slot`, `place_token_in_slot`, `confirm_craft`, `place_meme_in_blank`, `confirm_dialogue`, `settle_day_if_needed`.

- [ ] **Step 2: Run tests and confirm GREEN**

Run the same Godot headless command. Expected: PASS with zero failed assertions.

### Task 3: Playable Native UI

**Files:**
- Create: `scenes/babel_meme_game.tscn`
- Create: `scripts/babel_meme_game.gd`

- [ ] **Step 1: Create one Control scene**

The scene is a `Control` root with a script that constructs the interface at runtime: status bar, desktop/dialogue, right phone, bottom meme bank.

- [ ] **Step 2: Wire UI to state**

Buttons call the state API. Navigation does not spend actions. Effective actions call `settle_day_if_needed` and refresh the UI.

- [ ] **Step 3: Provide click fallback for drag interactions**

Click token then slot, click meme then dialogue blank. This keeps the first standalone build playable on trackpad and mouse.

### Task 4: Verification

**Files:**
- Read: `project.godot`
- Read: `tests/test_meme_game_state.gd`
- Read: `scripts/meme_game_state.gd`

- [ ] **Step 1: Run headless tests**

Expected: all assertions pass.

- [ ] **Step 2: Run Godot once headlessly against the main scene**

Expected: project loads and exits without script errors.

- [ ] **Step 3: Optionally launch GUI**

Use the local Godot binary to launch `/Users/zhang/Documents/游戏/babel-meme-game` if GUI verification is permitted.
