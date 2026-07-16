# Psychological Horror Event Direction

## Research Finding

The strongest reusable principle is not a specific hallway, monster, or line of dialogue. It is the player's growing confidence in a repeated routine, followed by one restrained contradiction.

- `P.T.` confines the player to a small repeated route. Progress comes from observing changes in a familiar corridor, so the player's memory becomes part of the interaction rather than a passive record.
- `Sentient` makes ordinary compliance uncomfortable. The player continues performing legible tasks while the institution around those tasks becomes harder to trust.
- `Milk outside a bag of milk outside a bag of milk` treats subjective perception as presentation structure. The local Ren'Py installation was inspected only at package and runtime-structure level; its archive, dialogue, art, and audio were not extracted or copied.

## Implemented Event Grammar

The reality world now has a deterministic authored event table for floors two through five. The selected event or pair depends on floor and day. No random timer is used.

1. **Light memory**: after the player walks away from the spawn point, a familiar suspended fluorescent fixture follows a fixed five-beat failure pattern and settles into a dim afterimage. It never flickers forever.
2. **Dead sign**: an ordinary `EXIT` sign changes to `EX_T` only after the player has looked at it and then moved their view away. The absence is visible on the next glance.
3. **Distant mirage**: on only days four and nine, a transparent image billboard can enter the schedule after floor one. Layered copies drift by a few pixels, and the image dissolves as the player approaches. It has no modeled body, collision, pursuit, or close-up reveal.

Every event root is non-interactable, deterministic, and explicitly marked `non_jumpscare`. No `Area3D` trigger volume is created. Event progress uses movement distance, camera direction, and short authored timing only.

## Pacing Rules

- Floor one remains calm so later contradictions have contrast.
- Floors two through four alternate between one restrained event and a two-event day.
- The image mirage can appear at most twice in a twelve-day run, independent of the repeating light/sign rotation.
- Floor five continues to use the light and sign events; the mirage is added only on its two authored days.
- Looking at an event never causes it to lunge, teleport toward the player, or seize input.
- Day changes rotate the event combination without rebuilding the whole floor or resetting the player's position.

## Originality Boundary

The system borrows only high-level craft principles: spatial repetition, delayed recognition, procedural compliance, and subjective uncertainty. All event geometry, timing, text, placement, state logic, and audiovisual treatment are original to this project. No reference game's map, puzzle, script, model, image, sound, or scene order is reproduced.

## Sources

- [Game Developer: P.T. game analysis](https://www.gamedeveloper.com/design/p-t-silent-hills-teaser-game-analysis) - constrained sightlines, immersion, and the hallway as a psychological system.
- [GameSpot: In Memory of the Unbearable Enigma, P.T.](https://www.gamespot.com/articles/in-memory-of-the-unbearable-enigma-p-t/1100-6426967/) - extreme spatial confinement generating a much larger imagined story space.
- [BFI: P.T. ten years on](https://www.bfi.org.uk/features/pt-10-years-hideo-kojima-guillermo-del-toros-horror-micro-masterpiece) - a familiar domestic place becoming alien through repeated spatial mutation.
- [PC Gamer: Sentient](https://www.pcgamer.com/do-what-youre-told-or-else-in-freaky-free-horror-game-sentient/) - unease generated through instruction, compliance, and institutional atmosphere.
- [Milk series reference](https://milk.wiki.gg/wiki/Milk_outside_a_bag_of_milk_outside_a_bag_of_milk) - release and authorship reference for the locally installed work.
