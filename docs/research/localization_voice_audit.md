# Localization and Horror Voice Audit

Date: 2026-07-17

## Scope

This pass audits the Chinese source, Japanese localization, and English localization as three authored voices. It does not copy dialogue, images, scripts, or assets from another game.

The locally installed `Milk outside a bag of milk outside a bag of milk` package was inspected only for its shipping structure and presentation context. Its authored content remains inside `archive.rpa` and was not extracted into this project.

## Sources

- [Microsoft: Display text within a user interface](https://learn.microsoft.com/en-us/globalization/fonts-layout/displaying-text) distinguishes control labels, static instructions, and user input, and treats line breaking, fonts, resource authoring, and message formatting as localization concerns rather than translation afterthoughts.
- [Microsoft Localization Style Guides](https://learn.microsoft.com/en-us/globalization/reference/microsoft-style-guides) defines locale-specific terminology and style conventions as part of localization quality.
- [W3C Requirements for Japanese Text Layout](https://www.w3.org/TR/jlreq/) documents Japanese character classes, line-start and line-end prohibitions, and the need to treat Japanese line breaking differently from space-delimited English.
- The developer-authored [Steam page for Milk outside a bag of milk outside a bag of milk](https://store.steampowered.com/app/1604000/Milk_outside_a_bag_of_milk_outside_a_bag_of_milk/) describes a text-led psychological-horror presentation built from recursive verbal structures, distorted perception, rare scenes, and oppressive sound. This pass uses those broad presentation principles, not its wording.

## Voice Rules

### System UI

- Prefer compact control labels over translated instructions.
- Keep navigation terms identical wherever the same destination is referenced.
- Translate product concepts by function: `App` becomes `アプリ` in prose and disappears when a short Japanese window title is clearer.
- Keep placeholders in the same order because Godot format strings do not use positional localization arguments here.

### Social Horror

- Begin with an ordinary object or record: a school, entry log, bus, window, or message.
- Put the impossible fact in a short independent clause.
- Do not add explanatory adjectives such as “creepy” or “mysterious.” The contradiction carries the horror.
- Preserve the cadence rather than the Chinese word order. English favors short subject-verb clauses; Japanese may omit the subject and delay the contradiction.

### Reality Dialogue

- Keep a human intention legible beneath the surreal rule.
- Preserve metaphors such as fares, inventory, and forms, but make the surrounding grammar native.
- Repetition should alter a phrase or its authority, not merely repeat the same translated sentence.

## Automated Contract

`tests/test_localization.gd` now enforces:

- identical source-key sets for English and Japanese catalogs;
- identical ordered `%s`, `%d`, `%02d`, and `%%` signatures in every translation;
- word-level pickup and dialogue units for English and Japanese;
- audited terminology for high-frequency navigation and mechanic text;
- selected native horror lines whose ordinary-to-impossible pivot must remain intact.

This contract protects technical completeness. Native-speaker editorial review is still recommended before release, especially for long late-floor conversations.
