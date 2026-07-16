# Recognizable Liminal Prop Research

## Finding

The previous artifact set used symbolic silhouettes. In playtests, those forms read as abstract sculpture rather than misplaced everyday infrastructure. Backrooms-style unease works better when the player recognizes an ordinary object immediately and only then notices that its placement, repetition, or condition is wrong.

The original Level 0 vocabulary is deliberately mundane: fluorescent fixtures, continuous damp carpet, office or retail partitions, and architectural repetition. The current Backrooms Wiki description also emphasizes structural aberrations rather than decorative fantasy objects. The web series later gives the fluorescent troffer unusually specific physical construction, reinforcing the importance of recognizable industrial detail. Production coverage of the 2026 film describes drab furniture escalating into impossible clipped piles, including chairs and old televisions. Community Level 1 and Level 2 descriptions repeatedly add warehouse crates, shelves, pipes, valves, wiring, and small machinery.

## Implemented Object Set

The game now uses nine original, procedural low-poly object families:

| Object | Recognition anchors | Liminal displacement |
| --- | --- | --- |
| False window | Four dark panes, metal mullions, sill | Three stairs lead to a window that opens nowhere |
| Water cooler | Inverted bottle, red/blue taps, drip tray, cups | Placed alone in grass or on a dark disc |
| CRT cart | Deep television body, convex-lit screen, knobs, antennae, wheeled AV cart | Powered without a cable or audience |
| Payphone | Handset, coin slot, 3 x 4 keypad, return hatch, hanging cord | No network and no enclosing booth |
| Folding chair | Vinyl seat/back, tubular crossed frame | Repeated as if an event has already ended |
| Vending machine | Glass product grid, controls, coin slot, retrieval hatch | Stocked and lit where there is no service route |
| Fluorescent troffer | Four tubes, galvanized frame, two hanging wires | Detached from the ceiling but still glowing |
| Supply crates | Pallet, slatted boxes, crossed braces | Warehouse stock appears in non-warehouse terrain |
| Pipe manifold | Three pipes, cross-feed, two valve wheels, pressure gauge | Functional plant hardware mounted without a building |

Each family appears twice on floors two and three. Every instance is decorative, non-pickup, and non-interactable. Their positions remain deterministic for visual QA and tests.

## Originality Boundary

No third-party model, game texture, logo, brand shape, or proprietary scene was copied. The models are assembled at runtime from Godot `BoxMesh`, `CylinderMesh`, and original transforms. References informed generic object categories, recognizable real-world proportions, and placement logic only.

## Sources

- [Backrooms Wiki: Level 0, Threshold](https://backrooms-wiki.wikidot.com/level-0) - fluorescent lighting, damp carpet, office/retail architecture, and structural aberrations. The page identifies its own CC BY-SA licensing and the original Level 0 image as CC0.
- [Wikipedia: Backrooms web series](https://en.wikipedia.org/wiki/Backrooms_%28web_series%29) - the removed troffer fixture, four fluorescent tubes, galvanized housing, and 1970s construction details.
- [Wallpaper*: Backrooms and the sinister architecture of liminal spaces](https://www.wallpaper.com/art/film/backrooms-film-liminal-spaces) - ordinary spaces stripped of expected function and production design built through practical sets plus Blender mockups.
- [ELLE Decor: The Sets of A24's Backrooms](https://www.elledecor.com/life-culture/a71413741/backrooms-a24-production-design-sets/) - drab furniture escalating into clipped piles of chairs and other recognizable furnishings.
- [Team Byte Backrooms Wiki: Level 1](https://teambytethebackrooms.wiki.gg/wiki/Level_1) - abandoned warehouse grammar, storage rooms, supply crates, exposed structure, and bright industrial lighting.
- [Team Byte Backrooms Wiki: Level 2](https://teambytethebackrooms.wiki.gg/wiki/Level_2) - maintenance tunnels with pipes, shelves, and machinery.
