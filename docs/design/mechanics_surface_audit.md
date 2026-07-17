# Mechanics Surface Audit

## Purpose

The game should expose only values that help the player make a decision. Internal state may remain hidden when it drives language loss, progression, or recovery, but it must not create a second competing HUD.

## Player-Facing Values

| Value | Surface | Reason |
| --- | --- | --- |
| Day | Left icon tooltip | Establishes run pacing. |
| Pollution | Left icon tooltip and corruption events | Primary risk/reward axis. |
| Money | Left icon tooltip and shop | Supports purchasing decisions. |
| Actions | Persistent five-pip label | Immediate daily constraint. |
| Tower floor | Social-app secondary page | Narrative progression belongs to the phone, not the world HUD. |

## Hidden Values Retained

| Value | Verified gameplay role |
| --- | --- |
| Heat | Enters ascent pressure, settlement decay, and the final run pressure calculation. |
| Clarity | Falls after publishing and reality dialogue, changes communication quality, and contributes to final pressure. |
| Threshold discount | Softens the next ascent after failure and prevents a hard run lock. |

These values are not permanently displayed, but removing them would change progression or the language-collapse arc. They are therefore mechanics, not abandoned HUD data.

## Removed Surface Debt

- Removed six legacy HUD value bindings that were permanently `null` after the icon-rail redesign.
- Removed the unused `_stats_label` and duplicate `_actions_label` alias.
- Reduced publish results to one additive base, named integer bonuses and penalties, one final multiplier, and one score.
- Removed the redundant `synergy_multiplier`, `pollution_multiplier`, `repeat_multiplier`, `contract_multiplier`, `world_item_multiplier`, and `modifier_base_bonus` mirrors. None had a runtime consumer.

## Bonus Audit

Daily contracts, source-card passives, world-item effects, fusion bonuses, Arcana modifiers, and repeat penalties remain because each changes the visible publish preview or a later dialogue outcome. Their contribution is named in the preview instead of being exposed as parallel multiplier totals.
