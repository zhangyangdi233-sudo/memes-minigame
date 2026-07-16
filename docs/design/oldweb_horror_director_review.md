# Old-Web Horror Director Review

## Direction

The game should feel like a useful device that slowly proves it has been useful for the wrong reason. Horror comes from reliable systems producing impossible continuity, not from constant visual noise or frequent jump scares.

Three pillars govern new work:

1. **Confidence on the phone, uncertainty in reality.** The phone has orderly feeds, explicit costs, and visible rewards. Reality uses distance, silence, incomplete replies, and inherited phrases that no longer fit.
2. **Absence before interruption.** A missing window, shortened street population, dead link, or NPC who stops answering should arrive before any strong glitch event.
3. **Evidence across surfaces.** A feed post, street prop, NPC conversation, and cached website should describe the same event from incompatible dates. The player assembles the contradiction without an exposition screen.

## Implemented Director Pass

- The social feed uses stable image cards and language-aware word collection so browsing remains readable in all three languages.
- Ordinary NPCs now carry three-turn conversations. Each turn reveals one concrete fragment of the district, while misunderstanding can interrupt the exchange before the explanation is complete.
- Completing an NPC conversation can award a Meme Frame. The deterministic 45% roll and third-attempt guarantee make conversation mechanically valuable without turning NPCs into vending machines.
- Floor two onward removes people, extends connected architecture, darkens the environmental hierarchy, and reserves stronger suspense cues for deeper floors.
- Floors two through five now rotate a deterministic authored event table: a light remembers the wrong brightness, an EXIT sign loses one letter after the player looks away, and a transparent distant mirage appears on only two authored days. These events never use collision-triggered jump scares.
- The profile now contains an in-world `BABEL-LINK 98` cache. Its guestbook, mirrors, broken link, and source-code cache puzzle are optional, cost no action, and reveal original lore through investigation.
- The adaptive score now shares a recognizable five-note motif across reality, phone, and pollution stems. Each layer transforms the motif instead of replacing it with unrelated ambience.

## Player Review

### What works

- The central loop has a clear temptation: phone actions produce heat, money, words, and frames; reality produces fragile context and occasional free frames.
- Longer conversations make pollution legible as a loss. The player first understands the person, then watches later units overwrite that understanding.
- The old website rewards curiosity without stealing one of five daily actions. A player can leave immediately, while an ARG-minded player has a concrete code and a persistent unlock.
- Fewer NPCs on later floors increases the value of each surviving voice and makes traversal feel less like checking icons off a map.

### Risks to monitor

- Three-turn conversations must not repeat the same information. Every turn needs a new object, date, location, or contradiction.
- The source-code puzzle needs at least two discoverable clues before future codes are added. Mystery is welcome; arbitrary guessing is not.
- Visual filters must remain optional and threshold-driven. Constant VHS distortion makes text tiring and removes contrast from the 60% flashback.
- Frame rewards should be announced clearly but briefly. The emotional end of a conversation should remain louder than the inventory change.

## Developer Review

### Durable choices

- Conversation rewards are deterministic from day and actor ID, deduplicated per actor per day, and serialized with existing save data. This prevents reload farming and keeps tests reproducible.
- The three music stems are synchronized, locally synthesized, and generated from one script. No runtime streaming, external sample license, or beat-alignment system is required.
- Old-web pages reuse the social App hierarchy and theme tokens. New cache pages can be data-driven later without adding a browser or network dependency.
- Generated floors remain collision-tested and recover from falls. Atmosphere changes should continue through materials, spacing, light, and population before adding expensive effects.

### Next production priorities

1. Add one clue to the street and one clue to an NPC for each future cache code.
2. Record conversation callbacks so a later NPC can quote the player's earlier clean intention incorrectly.
3. Expand the authored event table only after playtesting whether players notice the current light, dead-sign, and rare image-mirage events without explicit prompts.
4. Add reduced-motion and reduced-noise options before expanding the VHS and pollution effects.
5. Profile frame acquisition and floor generation on the lowest target hardware before increasing image or shader resolution.

## Originality Boundary

Reference works inform broad craft only: short-form retro horror, optional filters, subjective text presentation, and websites that become fragmented evidence. All dialogue, lore, site copy, puzzles, music, characters, locations, and assets in this project must remain original. No external game's script, melody, image, interface frame, or recognizable scene composition is copied.

## Reference Notes

- Puppet Combo's public material supports short retro horror, story-dependent presentation, and optional visual filters: <https://www.puppetcombo.com/faq/>
- `I Love Bees` is useful as a structural example of an ordinary website becoming fragmented evidence: <https://en.wikipedia.org/wiki/I_Love_Bees>
- `No Players Online` demonstrates investigation across a simulated old computer and linked artifacts: <https://en.wikipedia.org/wiki/No_Players_Online>
- The music reference was used only for high-level qualities such as coldness, liminality, and melodic suspension; no melody or audio was copied: <https://www.bilibili.com/video/BV19VB7YrEmg/>
