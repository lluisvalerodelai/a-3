# Echo Escape

The campaign has 20 chambers. The ten new puzzles are chambers 11 to 20.

Restart any game session that was already running before these changes. Use **Chambers** in the top right to start a particular puzzle. Choosing a chamber clears the current recordings; opening the picker pauses the game and timer.

## Controls

- A and D: move.
- Space: jump.
- E: pick up or release a crate.
- Left mouse: shoot toward the pointer.
- Right mouse: throw toward the pointer.
- 1, 2, 3: select a recording slot. Press a committed slot twice to begin replacing it.
- C: commit the current recording and restart with its echo.
- X: clear the selected slot.
- R: restart the attempt, keeping committed recordings.
- Escape: pause or resume.
- M: toggle sound.
- Enter after clearing a chamber: continue.

After committing all three slots, the live player can still act without making a fourth recording. Finished echoes stay physical. Replacing a slot leaves the old recording active until the replacement is committed; clear the slot first when that old body would interfere.

## New chambers

Select chambers 11 to 20 from the chamber picker. Levels are identified by number.

The level guide contains maps, recording sequences, and solutions. Difficulty ratings describe design intent rather than human playtest results.

## Verification

Run the checks from this directory:

```sh
python3 tests/run_all.py
```

The suite includes complete input-driven solutions for all 20 chambers. Each new chamber replays its solution twice from reset and checks that its echoes survive and finish their recordings.

The chamber scenes remain normal, editable Godot assets. The checks use the existing controller, interactions, memory bank, and chamber runner.
