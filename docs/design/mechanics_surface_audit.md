# Mechanics Surface Audit

## Purpose

The game should expose only values that help the player make a decision. Internal state may remain hidden when it drives language loss, progression, or recovery, but it must not create a second competing HUD.

## Player-Facing Values

| Value | Surface | Reason |
| --- | --- | --- |
| Pollution | Left icon tooltip and corruption events | Sole progression and risk axis. |
| Funds | Left icon tooltip and publish preview | Immediate economy result; frames are never purchased. |
| Actions | Persistent five-pip label | Immediate daily constraint. |
| Tower floor | Social-app secondary page | Narrative progression belongs to the phone, not the world HUD. |

Day remains an internal scheduler and save field, but is not presented as a competing progress metric. Hidden-floor eligibility is deliberately not surfaced as a checklist.

## Internal State Retained

| Value | Verified gameplay role |
| --- | --- |
| Day | Resets the five-action budget and advances authored events. |
| Floor | Selects geography, dialogue, music, and legacy rules. |
| Prerequisite IDs | Stores the three key-NPC reveals and physical pickups for the hidden route. |
| Doll encounter IDs | Prevents one physical doll from granting more than one Meme Frame. |
| Relationship residue | Records reality-dialogue consequences without becoming a player-facing progression bar. |

There is no separate heat, clarity, sanity, trust, danger, Tarot, or threshold-discount progression system. Pollution alone controls floor thresholds and language degradation.

## Removed Surface Debt

- Removed six legacy HUD value bindings that were permanently `null` after the icon-rail redesign.
- Removed the unused `_stats_label` and duplicate `_actions_label` alias.
- Publish results foreground only funds and pollution; propagation remains an internal calculation needed to determine those outcomes.
- Removed active merchant/shop, Arcana/Tarot, clarity relic, and random NPC-frame reward surfaces.

## Bonus Audit

Token tags, fusion bonuses, daily signals, and repeat penalties remain because they change the funds/pollution preview. They do not introduce new persistent meters. Physical floor objects now serve only the authored three-part hidden-route prerequisite flow.
