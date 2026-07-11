# Signal Arcana System

## Design intent

The signal-arcana layer gives the player a small consumable hand between crafting and publishing. Cards are purchased in the phone shop, held in two slots, and used from the social publish page. Purchasing costs one daily action; using an already purchased card is free.

This borrows the structural lesson from Balatro rather than its content: a readable scoring hand sits at the center, while consumables either tune the deck or create a one-publish spike. Balatro's official materials describe poker hands, Jokers, Tarot cards, Planet cards, and other tools as interlocking build layers. The Babel version translates those layers into meme tags, signal hands, permanent ascent permits, and one-shot broadcast rituals.

References:

- [Balatro official site](https://www.playbalatro.com/)
- [Balatro on Steam](https://store.steampowered.com/app/2379780/Balatro/)
- [Milk outside a bag of milk outside a bag of milk on Steam](https://store.steampowered.com/app/1604000/)
- [Cosmic Ultramarine on Steam](https://store.steampowered.com/app/3296760/Cosmic_Ultramarine/)

## Current cards

| Card | Role | Effect |
| --- | --- | --- |
| XVIII 月亮 | risky multiplier | Next publish total multiplier x1.40, plus 4 pollution |
| XVI 高塔 | hand override | Force the current signal hand to count as complete, plus 7 pollution |
| IX 隐者 | repeat control | Ignore one repeat-decay step on the next publish |
| XII 倒吊人 | sacrifice | Lose 8 clarity now, gain 24 propagation base on the next publish |
| XVII 星星 | permanent tuning | Add one missing current-trend tag to a selected completed meme |
| XX 审判 | hand control | Reroll the current day's signal hand |

## Presentation rules

- Card art uses the same five-color International Style palette and analog print texture as the social poster atlas.
- Art contains no generated words. Godot lays out numerals, names, effects, prices, and disabled states so Chinese text stays exact and responsive.
- The shop reveals one daily card and a `held 0/2` count. The publish page shows the held cards beside the daily signal hand.
- Every score-changing effect appears in the preview as its own base, multiplier, repeat relief, or pollution-risk line.
- Targeted effects require a completed meme in the publish blank; other cards can be used immediately.

## Research synthesis

The atmosphere references two different strengths. Milk outside emphasizes distorted perception, oppressive sound, and verbal structures; Cosmic Ultramarine frames movement between virtual and real space through a terminal. The implementation therefore keeps the occult layer inside the phone, but lets its consequences leak into pollution, clarity, and later reality dialogue rather than creating a separate fantasy world.
