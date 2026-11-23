# Echo Escape: Master Game Design

## Purpose

This document is the shared source of truth for the game concept and the first mechanics prototype. It is intended to give future contributors enough context to make technical decisions without treating undecided presentation and campaign details as requirements.

## Game premise

Echo Escape is a 2D puzzle platformer built around editable recordings of previous attempts. The player escapes a connected sequence of abstract chambers by recording actions into memory slots, then playing alongside those recorded selves.

The central challenge is planning a sequence of overlapping runs. A player can record an action in one slot, add more recordings, discover that an early recording is wrong, and overwrite only that recording before continuing. Puzzles should reward understanding of timing, physical space, and shared world state.

The game is mechanics-led. The memory and escape framing exists to explain the system, but story should remain sparse and must not carry the experience.

## Player objective

Each chamber has an exit. The player clears it when the current run reaches that exit and all committed echoes survive. The campaign is a continuous escape route through connected chambers. A map will eventually reveal discovered rooms, progression state, and optional discoveries, but it is outside the first prototype.

## Memory recording system

### Memory slots

- The player owns a set of memory slots.
- Each slot is independently empty, selected, or committed.
- The player may select any slot to record, regardless of when other slots were recorded.
- Committing a recording writes it to the selected slot.
- Re-recording a committed slot overwrites only that slot, after confirmation.
- The player may clear a committed slot.
- The design does not set a final maximum number of slots. Levels are designed around the number they need.
- Major progression moments may grant additional slots in the final game, but the exact progression is undecided.

### Recording lifecycle

1. The player selects a memory slot through a small in-game overlay in the upper-right corner.
2. A new attempt starts from the chamber's initial state.
3. The player performs actions using the normal controls.
4. The player can restart the uncommitted attempt at any time. This discards only that in-progress recording.
5. The player can commit the attempt to the selected slot, including an incomplete attempt.
6. On later attempts, selected committed slots replay as echoes alongside the current player.

The game must communicate this state clearly at all times. The overlay should make it immediately apparent which slot is selected, committed, recording, or empty. No separate slot-management menu is required.

### Echoes

- An echo is a translucent, coloured copy of the player character.
- Individual echoes do not need unique visual identities beyond their colour treatment.
- Echoes replay the player inputs recorded on every physics frame, including movement, jumping, pickup, throwing, and shooting.
- Echoes replay those inputs into the live world. They are not scripted animations and do not own a separate copy of the level state.
- World conditions can therefore change an echo's outcome. It can be blocked by a crate, fail to pick up an object that moved, or fire into a changed layout.
- When blocked, an echo continues applying its recorded input rather than passing through new obstacles.
- An echo stops receiving input once its recorded run ends.
- Echoes have ordinary physical presence. They may carry objects, press controls, change shared world state, and serve as temporary platforms for other players or echoes.
- Echoes can die. A recording that died will replay that death in later attempts.
- A chamber cannot be cleared if any committed echo dies.

This deliberate input-replay model enables emergent solutions. For example, a later recording can jump over a future player in a narrow space, preserving room for another run.

## World rules

- Each new recording attempt begins from the chamber's original state.
- Committed echoes reproduce their actions to recreate the state needed by the current run.
- Objects and mechanisms are shared by the current player and every active echo.
- Committed echoes should never be silently corrected to preserve an old outcome. Changed state producing a changed outcome is part of the puzzle.
- Death, hazards, enemies, and physics are permitted, but interactions should remain predictable and readable.
- The current attempt has no rewind. Restart begins it again from the chamber's starting state.

## Core prototype mechanics

The first prototype must include:

1. Running and jumping.
2. A chamber exit and clear condition.
3. Selectable, overwriteable, clearable memory slots.
4. Per-physics-frame input recording and live echo replay.
5. Carrying and throwing physics objects.
6. Pressure plates and doors.
7. Breakable targets or blocks.
8. Shooting that can push objects, activate remote targets, destroy fragile targets, and defeat enemies.
9. Moving geometric enemies.
10. Turret enemies.
11. Death and restart behaviour.

Actions and hazards are unlimited rather than governed by ammunition, object durability, or player health resources. The challenge comes from sequence planning and execution.

## Controls for the prototype

| Action | Input |
| --- | --- |
| Move | A / D |
| Jump | Space |
| Interact or pick up | E |
| Shoot | Left mouse button |
| Throw | Right mouse button |
| Restart current attempt | R |

## Prototype level structure

Build a compact teaching set rather than the complete campaign:

1. Movement, jumping, and exit.
2. Pressure plate and door.
3. Record and replay one echo.
4. Carrying and throwing an object.
5. Using echoes as physical platforms or simultaneous switch holders.
6. Moving hazard or moving enemy.
7. Shooting and breakable or remote targets.
8. Turret enemy and safe recorded timing.
9. Re-recording one early slot while retaining later recordings.
10. A final combined chamber using multiple core systems.

These are teaching targets, not final level layouts. Individual chambers may use more or fewer slots as needed.

## Visual direction

- The final game should be minimalist and abstract, using bold coloured geometric spaces.
- It should feel visually striking through glow, particles, distortion, and animated backgrounds.
- Placeholder art should be simple and clearly readable.
- Final character and sprite design will be made later by an artist. The prototype should not assume a particular character appearance.
- Enemies should initially be abstract moving shapes and turrets.
- All placeholder scenes, sprites, scripts, and resources must be normal Godot project assets that remain visible and editable in the Godot editor.

## Deferred decisions

The following are intentionally not part of the first mechanics prototype:

- Final player appearance and hand-drawn art direction.
- Final UI appearance beyond a readable memory-slot overlay.
- Music and sound direction.
- Narrative details and exact memory framing.
- Exact memory-slot unlock schedule and final slot count.
- World map implementation.
- Full campaign layout beyond the prototype teaching chambers.
- Optional collectible design and secret-room rules.

## Technical implications for later design

- The recording data needs to store player controls per physics frame, not high-level actions or object positions.
- Replay must use the same player controller as the current player so that live collisions and shared physics affect it naturally.
- Chamber reset must reliably restore the initial scene state before instantiating selected echoes and beginning a new current attempt.
- Interactable objects, doors, plates, projectiles, hazards, enemies, and exits must work identically for a live player and an echo unless a level explicitly designs around their physical difference.
- The project structure should favour reusable Godot scenes and scripts for player, echo, level objects, and chambers.

## Prototype acceptance criteria

The prototype is ready for playtesting when a player can:

1. Choose a memory slot, create an incomplete recording, commit it, and see it replay on the next attempt.
2. Re-record or clear one slot without changing other committed slots.
3. Observe a replay behave differently when the shared world changes, such as being blocked from a pickup or by geometry.
4. Solve at least one chamber requiring an echo to press a switch or act as a platform.
5. Solve at least one chamber requiring a thrown object and a shot that affects it or a remote target.
6. See deaths prevent a clear when any committed echo dies.
7. Restart an uncommitted run without losing committed recordings.
8. Understand the current recording and memory-slot state from the in-game overlay.


## Implemented campaign expansion

The campaign now contains twenty chambers. The original ten remain the teaching set; chambers 11 to 20 implement the designs in NEW_PUZZLE_LEVELS.md. The CHAMBERS control in the header can start any chamber and clears the previous chamber's recordings. Opening the picker pauses simulation and the elapsed timer.

The new set covers redirecting a recording through a hatch, reclaiming a crate, a delayed shot, dismantling a used staircase, sharing a narrow passage, useful turret fire, a future pickup, closing a protective shutter, replacing a temporary helper, and a combined finale.

Projectiles collide with physical bodies and ignore sensor areas. Friendly fire remains enabled. Crates remain awake so they react when supporting geometry disappears. Turret shots reset and freeze with their chamber. Existing teaching layouts have been adjusted where collision testing exposed blocked routes or gate bypasses.

The input-driven solution checks exercise all twenty chambers. Each new puzzle repeats its final solution from reset with the same saved inputs. This establishes working solutions without establishing unique solutions or human difficulty ratings.
