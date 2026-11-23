# Echo Escape: Ten New Puzzle Chambers

Implemented chamber guide, 15 November 2026.

These chambers are implemented as campaign chambers 11 to 20, after the ten teaching chambers. Choose CHAMBERS in the game header to try any of them directly. The maps below remain schematic; the editable Godot scenes contain the finished collision geometry. Each new chamber has passed an input-driven solution test twice from a reset, using real recording, commitment, and playback. This verifies a working solution, not difficulty balance or a unique minimum echo count.

## What this game is about

Echo Escape is a puzzle platformer about arranging several versions of one person's actions in a shared room. A recording preserves inputs, including aim, rather than a route through space. An unchanged recording can therefore produce a different result when somebody opens a floor, moves a crate, or removes an obstruction.

The player is effectively both performer and stage manager. Sometimes the right action is to improve a recording. Sometimes the recording is already correct and the room must change around it. The best puzzles should let the player distinguish those two cases.

The current ten chambers introduce movement, plates, echoes, carrying, physical cooperation, enemies, shooting, turret timing, replacement recordings, and combinations of those systems. This set develops their consequences: delayed cooperation, reuse of an object, useful obstruction, deliberate destruction, and removing a recording that has outlived its purpose.

### The ten ideas at a glance

1. **Same Walk, Different Floor:** open a hatch beneath an unchanged walking recording.
2. **Repossession:** reclaim a crate after its first doorway has served its purpose.
3. **A Shot into Tomorrow:** give a previously blocked shot a useful destination.
4. **Burn After Use:** demolish the staircase after the echo has finished climbing it.
5. **Right of Way:** choreograph a passing place for two solid recordings.
6. **Enemy on Payroll:** use a turret to operate unreachable machinery.
7. **Appointment for a Parcel:** deliver an object to a pickup recorded in an empty room.
8. **The Door That Must Close:** stop holding an opening so it becomes protective cover.
9. **Delete the Ladder:** replace a temporary helper with a crate and reuse its memory slot.
10. **The Last Rehearsal:** turn one crate into three successive tools while the echoes change roles around it.

## Rules these designs use

- There are three memory slots in the current game. After committing, a live player can act alongside all three echoes without recording into another slot.
- Each attempt restores the room. Only recordings carry forward; dropped crates and destroyed targets do not.
- Echoes replay movement, jumps, interaction, throws, shots, and recorded aim. They do not correct their routes when the world changes.
- After its input ends, an echo remains in the room and continues being affected by physics. A settled echo can hold a plate or provide a step indefinitely. A recording is not a loop.
- Actors are solid after they separate from the shared spawn. The current spawn grace ends once a pair is at least 40 pixels apart.
- A player, echo, or released crate can press an ordinary plate. There are no echo-only or crate-only plate types in these proposals.
- Plates control doors while occupied. A door can also be arranged horizontally as a hatch, with corresponding collision and visual dimensions.
- A held crate has its collisions disabled. It is not a shield or a reliable plate weight while being carried. Released crates regain their collisions.
- Pickup selects the nearest available rigid body within reach. A recording can press interact when nothing is there, then succeed on a later attempt when a crate arrives.
- Projectiles have no friendly-fire exemption. Safe firing lanes must account for both the player and every echo.
- Fragile targets are physical objects that break when hit. They are not already implemented as universal remote switches. Where these designs need a lasting change, the target physically supports a crate or an actor.
- Only the live player clears a chamber. An echo death already observed in the attempt prevents clearing. The current game freezes the room when the live player clears; it does not evaluate the rest of every recording. These designs aim to leave everyone safe rather than reward a last-second escape before an echo dies.
- Re-recording a committed slot leaves its old echo playing until the replacement is committed. Clearing that slot first removes the old echo, but also removes the old recording. Plans below account for that difference.

No new movement ability, rewind, inventory key, damage type, conveyor, teleport, or automatic echo correction is assumed. The scenes, ordinary plate-to-door connections, chamber sequence, titles, hints, and direct chamber selection are now included in the game.

### Physical scale and resolved physics issues

A headless probe of the controller measured a flat-ground jump of about **142 pixels vertically** and **260 pixels horizontally** at full movement speed. The player body is 20 by 32 pixels; a standard crate is 44 by 44. Actors can stand on one another. Corners and ceilings still affect the available jump, so the full solution tests exercise the actual geometry rather than relying only on those measurements.

The projectile issue identified during design is fixed. Projectiles now check their travel segment against physical bodies, including thin walls, and retain body-contact detection. Plate and exit detectors no longer absorb bullets. Friendly fire remains part of the rules.

Crates now remain awake, so removing their support makes them fall. Released crates are explicitly awakened, and a throw starts from the actor's current position and aim rather than the previous frame's carrying position. Turret projectiles belong to their chamber, so resetting or freezing that chamber also removes or freezes its shots.

Regression tests cover a travelling shot breaking a static support, a settled crate falling onto a plate, a fast shot stopping at a thin wall, friendly fire through a plate detector, current-aim throwing, and turret-shot cleanup. A separate safety check verifies that the shutter in chamber 18 protects its echo when closed and exposes it when open.

## Reading the maps

All maps are side views or side-view route diagrams. Vertical separation matters. A line of `=` represents a floor or ledge, `|` a wall, and arrows indicate movement or fire. Lettered connections are described in each chamber, so no color distinction is required.

- `S`: common player and echo spawn.
- `X`: exit for the live player.
- `A`, `B`, `C`, `F`, `Q`: pressure plates, as defined locally.
- `G_A`: a door opened by plate A; the same notation applies to other letters.
- `H`: a horizontal door used as a hatch.
- `K`: the room's crate.
- `f`: a fragile support.
- `T<`: a turret firing left.
- `R`: a safe resting pocket or a solid end stop, defined locally.

Doors must seal their intended openings. Extend adjacent solid geometry to the ceiling or another wall; a standard freestanding door is not enough to establish a puzzle boundary. Seal exits behind the relevant gates, rather than relying on an instruction not to take a shortcut.

## 01. Same Walk, Different Floor

**The idea:** The echo does exactly what it did before, but ends up one floor lower.

**Intended cast:** One echo and the live player. Medium difficulty; a good opening for this set.

```text
                     recorded walking route
              =================[ H ]================ R
             /                       v
          steps               lower catch lane === B | R
         /
S ======+==== A
        |
        +========= separate lower exit route ===== G_B ==== X
```

**Layout.** Build a long upper corridor reached by two easy steps. Put a roughly 120-pixel hatch in its floor, with a lower catch lane about 120 pixels beneath it. Both lanes end against a solid wall at approximately the same horizontal position. Plate B fills the last part of the lower lane. Plate A sits near the spawn on a separate branch, far enough from the hatch that one actor cannot hold it and walk over the hatch. The live player's exit route stays below both lanes.

**Connections.** A opens H. B opens G_B. There is no timer or permanent latch.

**Recording and solution.**

1. Record slot 1 climbing to the upper corridor, walking across the closed hatch, and continuing against the far end stop for a short settling interval. Commit while safely stopped on the upper floor. Do not record a jump over the hatch.
2. On the next attempt, the live player holds A before the echo reaches H.
3. The echo falls through the open hatch and keeps applying its recorded rightward movement. The lower corridor catches it and the end stop places it on B.
4. Once the echo is settled on B, leave A. The hatch closes above it. Take the separate lower route through G_B to X.

**The discovery.** A recording can contain the correct instructions before it has ever reached its useful destination.

**Safe ending.** The echo finishes against the lower end stop on B. No hazard threatens either its original upper resting place or its final lower one.

**Blockout checks.** The hatch must be wide enough for the moving actor to fall clear before reaching its far lip. Give the lower lane room for the horizontal travel during the fall. Check that closing H cannot catch the echo's head. An extra echo simply holding A is a legitimate alternative, but the one-echo solution should be conspicuously simpler.

**Hint:** “Change the floor, keep the footsteps.”

## 02. Repossession

**The idea:** A crate has finished its first job even though it still looks indispensable.

**Intended cast:** One echo, one crate, and the live player. Medium difficulty.

```text
                        observation room
              G_A ===== easy steps ===== B | R
             /
S ==== K === A
       |
       +====== outside return route ===== F
                                      
                                       ===== G_B == G_F ==== X
```

**Layout.** The crate begins near A in a shared entry bay. G_A leads into an observation room containing B. The separate outside route remains accessible from the entry bay even when G_A closes. Put F near the end of that outside route, then place both exit gates farther on. B, F, and the exit must be far enough apart that a stationary body cannot overlap two of them.

**Connections.** A opens the observation-room entrance G_A. B opens the first exit gate G_B. F opens the second exit gate G_F. Two doors in series avoid needing a new combined switch rule.

**Recording and solution.**

1. In slot 1, carry K onto A, release it, pass through G_A, climb to B, and commit while standing there.
2. On the next attempt, let the echo repeat the entire delivery and enter the observation room. Wait until B visibly activates.
3. Pick K back up from A. G_A closes behind the echo, which no longer needs that doorway.
4. Carry K along the outside route and release it on F. The echo holds G_B open; the crate holds G_F open. Walk to X.

**The discovery.** Maintaining every earlier solution is unnecessary. A resource can be borrowed back once its consequence is safely established.

**Safe ending.** The echo remains on B inside the observation room. The crate settles on F. Neither depends on A staying active.

**Blockout checks.** Make the closed observation-room door visible from the crate pickup point, so the player can see that the echo is safely beyond it. Taking the crate too early should strand the echo in a harmless place rather than kill it. Avoid a route from F to X short enough to cross its gate while still overlapping F.

**Hint:** “It opened the way. It does not have to keep it open.”

## 03. A Shot into Tomorrow

**The idea:** Record a useful shot while its line of fire is still blocked.

**Intended cast:** One echo and the live player. Medium difficulty. Projectile and support behavior are covered by regression checks.

```text
S ====+==== long upper route ===== A
      |
      v        sealed firing lane          K
   gun well   echo > > > [shutter] > > >    f
   ===== R     |                           v
               |                        [ B ]
               +========== outer route == G_B ==== X
```

**Layout.** The spawn splits between a firing well and an upper control route. The well has a descent of about 220 pixels and no loose object, so its occupant cannot simply jump back out. Its shot slit is too short for the actor to pass through. Across the room, a fragile support holds K over a broad receiving basin containing B. A shutter interrupts the shot lane. Put A on the upper route, with solid stone blocking any direct shot from A to the support.

The shot must hit the support below the crate, rather than pushing the crate. Keep the receiving plate below the shot lane.

**Connections.** A opens the shutter. B opens G_B. Breaking f drops K; there is no target-to-door signal.

**Recording and solution.**

1. Record slot 1 dropping into the firing well, waiting long enough for a later player to reach A, firing once at the closed shutter, then ending safely in the well.
2. On the next attempt, take the upper route and hold A before the recorded shot.
3. The same shot now travels through the open shutter and breaks f. K drops onto B and opens G_B.
4. Leave A and follow the outside route to X. The shooter stays in its safe well.

**The discovery.** The failed shot was not a failed recording. It was an appointment that the rest of the room had not yet kept.

**Safe ending.** One shot only, a permanent back wall beyond the support, an empty firing lane afterward, and a settled crate on B.

**Blockout checks.** Start with a generous four-second arrival allowance, then tune from the actual route. Make the firing slit much thinner than an actor but comfortably larger than the projectile. The well's lip must remain above a normal jump. Keep A out of pickup reach of K and out of sight of f. Check that the projectile is consumed by the shutter during the original recording.

**Hint:** “Record the shot. Supply the opening.”

## 04. Burn After Use

**The idea:** The staircase becomes the key only after somebody has finished climbing it.

**Intended cast:** One echo, one crate, and the live player. Medium to hard. Uses the corrected projectile behavior.

```text
                                   permanent high ledge
                                     ===== A | R
                                    /
S ==== approach ledge ====   K     /
                           [f]          temporary boost
                     wide open shaft
          firing nook > >   f
                             v
                         [ B ] ===== G_A == G_B ==== X
```

The repeated `f` labels refer to the same support, shown both as a stepping surface and as a firing target.

**Layout.** Put the approach surface around y = 500 and the permanent high ledge around y = 340. K rests on a small fragile support with its top level with the approach surface. The crate supplies the extra height for the 160-pixel ascent. Beneath it is a receiving basin at roughly y = 640. A side firing nook gives a horizontal view of the support's center while keeping the shot below K and well below the high ledge.

Leave a hole at least 70 pixels wide around the 44-pixel crate. A crate cannot drop through a hole only as wide as the standard 38-pixel support. Short approach gaps can be jumped; the support does not need to form a continuous solid bridge.

**Connections.** A and B open separate gates in series before X.

**Recording and solution.**

1. In slot 1, use K as a step, jump onto the permanent high ledge, walk onto A, and commit.
2. On the next attempt, let the echo complete the climb. Wait until it is entirely on the permanent ledge.
3. From the lower firing nook, destroy the fragile support. K falls into B's receiving basin.
4. Pass through both gates to X.

**The discovery.** Destruction can be progress even when it removes the route that made progress possible.

**Safe ending.** The echo is on permanent ground, not on the demolished support. The crate is captured on B. The firing lane ends in a solid wall.

**Blockout checks.** Shooting too early should leave the echo on a safe lower floor with an obviously failed climb. Test that K does not get wedged on the shaft edges, and that its movement during the climb is small enough for repeatable playback. The implemented climb, support break, crate landing, and final escape all pass together in the replay solution test.

**Hint:** “Use the staircase before you dismantle it.”

## 05. Right of Way

**The idea:** The recordings have the correct destinations, but their routes disagree about who owns a doorway.

**Intended cast:** Two echoes, one crate, and the live player. Hard, primarily spatial rather than hazardous.

```text
storage room       shared single-file passage          east control
 K === G_A ====+==============================+========== A
              |       raised passing bay     |
              |           === R              |
              +===============+==============+
                              |
S ==== B                      +==== delivery pocket C
       |
       +========================== G_B == G_C ==== X
```

**Layout.** Place A to the east and the crate storeroom to the west. Returning from A to B uses the same narrow passage that a courier must use to bring K east. The passage has a low ceiling except for one raised passing bay. Its ordinary vertical clearance should admit one standing actor, but prevent one from jumping over another outside that bay. The bay's upper ledge should be roughly 50 to 70 pixels above the corridor floor.

Provide a loop from the spawn to A that does not require opening the storeroom. B is at the west end of the passage, outside the storeroom. C is at the east delivery end, near the spawn. The live player drops from the far right and follows the lower exit corridor leftward.

**Connections.** A opens the storeroom gate G_A. B and C open separate exit gates.

**Recording and solution.**

1. Record slot 1 going to A, holding it long enough for a courier to fetch K, then returning toward B. On the return, jump into the raised passing bay, pause, and continue to B. Commit there.
2. Record slot 2 using that opening to enter storage, pick up K, and carry it east. Pass beneath slot 1 during its pause, then release K in C's delivery pocket. End in a safe recess away from the crate.
3. On the final attempt, let the crossing happen and take the outside exit route after B and C are active.

**The discovery.** An empty pause in an early recording can be a piece of architecture for a later one. The bodies themselves are part of the map.

**Safe ending.** Slot 1 stops on B; slot 2 rests beside the delivery pocket. No enemy or fatal floor is needed. A collision produces a readable traffic jam and a retry.

**Blockout checks.** Start with a pause of at least 1.5 seconds in the bay. Tune the route lengths so the courier reaches the crossing during that pause. Do not rely on a carried crate making its carrier wider: it has no collision. If editing slot 1 after recording slot 2, remember that the old slot 1 also replays during the edit; separating the opening routes helps prevent interference.

**Hint:** “Leave room for someone who has not arrived yet.”

## 06. Enemy on Payroll

**The idea:** The turret is the only worker who can reach the machinery.

**Intended cast:** One echo and the live player. Medium to hard. Uses projectile impacts and shutter collision.

```text
         sealed upper machinery gallery
     stop | B        K < < < [shutter] < < < T
          |===================================

S ===== A
        |
        +========== lower route ===== G_A == G_B ==== X
```

**Layout.** Suspend a closed machinery gallery with its floor at y = 300, well above the lower playfield floor at y = 640. Put the turret at the right, K in the middle, and B inside a receiving stop at the left. The turret shoots left through a shutter. Enclose the gallery so actors cannot climb into it or throw a lower object inside. There are no other crates.

Use a solid stop immediately beyond B so repeated shots push K into a stable resting position. Aim through the upper half of the crate, above B's detector. The implemented floor is at y = 300, the crate center is near y = 278, and the shot line is at y = 266. Bullets travel through the upper part of the crate.

**Connections.** A opens both the shutter and G_A. B opens G_B.

**Recording and solution.**

1. Record slot 1 going to A and ending there.
2. On the next attempt, wait for the echo to open the shutter. The turret's shots push K left until the receiving stop holds it on B.
3. Use the lower route through G_A and G_B to X. Keep all actors below the machinery lane.

**The discovery.** An enemy's action can be useful without acquiring a new allegiance or special interaction.

**Safe ending.** The echo holds A. K is pinned against a solid stop on B. Continued fire remains enclosed above the player route.

**Blockout checks.** Confirm that multiple impacts advance K consistently and cannot bounce it out of the plate pocket. The player should be able to watch the motion before committing to the exit. Destroying the turret too early should make the missing service obvious; it must not secretly complete the puzzle through a death trigger. Do not make the turret invulnerable. If a player finds a legal shot that pushes K instead, treat that as an alternative solution to evaluate, not an invisible rule violation.

**Hint:** “For once, let it shoot.”

## 07. Appointment for a Parcel

**The idea:** Record a pickup before there is anything to pick up.

**Intended cast:** Two echoes, one crate, and the live player. Hard; the challenge is supplying a recorded action at the right time.

```text
S ==== upper route ===== receiving dock R ==== C
       |                       ^                \ easy steps
       |                       |                 ==== B
       |                    throw arc
       v                       |
   deep source well: K ======== A
   =============================

outside route ================= G_A == G_B == G_C ==== X
```

**Layout.** Split the spawn between an upper receiving route and a deep source well. Put K and A on the well floor. The lip should rise about 220 pixels above that floor, beyond a normal jump even from the crate. The upper dock should sit close enough horizontally for a jumping throw from the well to reach it. Begin with a horizontal separation around 120 to 170 pixels and tune the throw in the actual engine.

Make the dock a broad, shallow trough with a back wall. It catches the crate and brings it to rest within interaction reach of a clearly marked standing position. C is farther along the upper corridor, behind a dogleg so K cannot simply be thrown straight onto it. B is beyond C on a short stair route. The final exit route is separate from all three plates.

**Connections.** A, B, and C each open one of three doors in series.

**Recording and solution.**

1. Record slot 1 as the receiver. Reach the empty dock, wait, press interact, walk to C, press interact again, then climb to B and commit. During this recording both interaction presses do nothing. That is intentional.
2. Record slot 2 dropping into the source well, collecting K, and making a jumping throw into the receiver's trough before slot 1's scheduled pickup. Then stand on A and commit.
3. On playback, slot 1 now finds K at its appointment. Its second interaction releases K onto C, and it finishes on B. Slot 2 remains on A.
4. The live player takes the outside route through all three gates.

**The discovery.** A recording can describe a responsibility before its required object exists at that location.

**Safe ending.** The sender rests on A in the well. The receiver rests on B. K is released and settled on C.

**Blockout checks.** Make the first version forgiving: target a settled delivery at least one second before pickup, not a midair catch. The verified recording places pickup at about ten seconds. The sender delivers well before that appointment. The throw inherits actor velocity and is affected by crate mass, so do not use the player's jump range as the throw range. Keep all other rigid bodies out of the pickup radius. Test late deliveries and duplicate interaction attempts so failure is clear. Escaping the well with additional echo scaffolding is a legitimate alternative to investigate; no invisible carrying restriction is assumed.

**Hint:** “Someone can be waiting before there is a delivery.”

## 08. The Door That Must Close

**The idea:** An open door is first helpful and then dangerous.

**Intended cast:** One moving echo and the live player. Hard. Bullets stop on closed doors and solid cover.

```text
                         upper danger lane
       safe echo route ==== Q < < [shutter] < < T in stone hood
                          |
S ==== A                  |
       |                  |
       +==== G_A ==== sheltered waiting bay ==== G_Q ==== X
```

**Layout.** A controls both the lower transit door and an upper gun shutter. The player uses the lower passage, which is outside the shot lane. The echo can reach Q by a separate route behind permanent cover. Q opens the final gate but lies in the turret's line of fire whenever the shutter is open.

Protect the turret's body with ordinary stone, leaving its existing muzzle outside the cover and pointing through the shutter. The source of the shots must remain visible. This uses geometry, not an invulnerability rule. Check the muzzle's actual position rather than assuming rotating the firing direction moves it.

Aim at the upper part of an actor standing on Q, above the plate's detector. Give the echo a protected waiting corner before Q so existing bullets can pass before it takes its final position.

**Connections.** A opens G_A and the gun shutter. Q opens G_Q. Leaving A closes both of its doors.

**Recording and solution.**

1. Record slot 1 holding A for a comfortable transit window, then leaving it, pausing behind cover, and ending on Q. Begin with roughly a three-second opening and at least a one-second sheltered pause; tune these against projectile travel and the actual route.
2. On the final attempt, cross G_A while the echo holds A. Wait in the sheltered bay.
3. The echo leaves A. The shutter closes and cuts off future shots. After existing shots have passed, the echo steps onto Q.
4. Pass G_Q and reach X.

**The discovery.** A useful recording must sometimes stop helping one part of the room so it can safely help another. Leaving a permanent holder on A creates the wrong world state.

**Safe ending.** The echo remains on Q behind a closed shutter. The live player is beyond G_Q. The turret continues firing into the closed shutter.

**Blockout checks.** Two stationary holders should visibly leave Q exposed, but do not claim this proves there is no timing-based alternative. Ensure a still-travelling bullet cannot hit Q immediately after the shutter closes. Neither door should close around an actor. The lower waiting bay needs permanent cover independent of A. Check that the stone hood actually blocks countershots without blocking the turret's own outgoing projectile.

**Hint:** “Opening it is only half the job.”

## 09. Delete the Ladder

**The idea:** One recording teaches another how to climb, then must be removed to make room for the final team.

**Intended cast:** Three final echoes, one crate, and the live player. Expert. No shooting required.

```text
                            upper station
                         ======== B | R
                        /
           launch mark R          rise about 160 px
           helper here first
S ==== K == crate here later
       |
       +====== left branch A
       |
       +====== right branch C

exit route ================= G_A == G_B == G_C ==== X
```

**Layout.** Use a shared launch floor at y = 640 and a high ledge at y = 480, close enough horizontally for a boosted jump. The temporary helper stands at a marked point on the lower floor. Its head is about 32 pixels above that floor; a crate in the same place supplies about 44 pixels. Both can support the intended climb, but an unaided jump cannot reach the 160-pixel rise.

Plate B is on the permanent high ledge. A and C sit in distant lower branches. All three control separate gates in the live player's exit route. Keep the launch position off every plate. There is only one crate, initially beside the spawn.

**Connections.** A, B, and C each control their own exit gate.

**Recording and solution.**

1. Record slot 1 as a temporary helper standing at the launch mark. Commit there.
2. Record slot 2 as the climber. Wait at the spawn for several seconds, jump onto the helper's head, settle briefly, then jump to the high ledge and end on B. Include the initial wait so a future courier has time to prepare the launch mark.
3. Clear slot 1. This explicitly removes the helper and frees its slot. Keep slot 2 unchanged.
4. Record slot 3 carrying K to the old helper's position before slot 2 arrives. Release K, get clear of the climbing route, and finish on A. Slot 2 now climbs using the crate. The two boosts differ by 12 pixels, so both jumps must land on the same forgiving ledge without depending on an exact apex.
5. Record the now-empty slot 1 going to C. Slots 2 and 3 continue replaying.
6. With all three committed, take the live player along the exit route. Slot 3 holds A, slot 2 holds B, and the new slot 1 holds C.

**The discovery.** A recording can be useful during construction of a solution without belonging in the finished solution. Deletion can be progress.

**Safe ending.** The three echoes hold three separate plates. K remains under the unused launch mark. There is no fourth echo and no requirement for another recording slot during the final live run.

**Blockout checks.** The first helper and the climber must separate from spawn before using each other as solid bodies. Test the original climber recording on both the 32-pixel helper and the 44-pixel crate. Give its first landing a settling pause and use a broad permanent ledge. Clear the helper before recording the courier so the crate and helper do not compete for the same space. A slow delivery should make the climber miss safely onto the floor. Carrying K to a plate after the climb may produce another valid solution; evaluate it rather than imposing a new crate restriction.

**Hint:** “Keep the lesson. Replace the teacher.”

## 10. The Last Rehearsal

**The idea:** Build a solution in layers, then reuse its first object after the rest of the room has taken over.

**Intended cast:** Three echoes, one crate, and the live player. Expert finale. Uses the corrected projectile behavior.

```text
                    fragile perch with end stop
                   ===== [ f + actor ] | R
                  /           v
S ==== Q ==== K == launch      landing pad B
                    |               ^
                    |               | fall from f
                    +==== A == G_A ==== service room
                    |                  shooter > [shutter] > f
                    |
                    +==== steps to upper escape route
                          ===== G_B ===== F == G_F ==== X
```

**Layout.** Divide the chamber into four visibly connected regions: the launch and supply bay, the high fragile perch, the lower control pad and service room, and an upper escape route. The high perch sits directly above B on the permanent ground floor. Its final standing position is directly over the fragile support, against an end stop.

K initially provides a boost for reaching the perch. A lies in the supply bay and opens the service room containing the firing position. Q is a lower control pad near the spawn and opens the shutter in the dividing wall. The shooter aims below the perched actor at the fragile support. The escape route climbs above the service room, so it remains usable after G_A closes. A tall dividing wall prevents those escape steps from replacing the initial crate boost.

**Connections.** A opens the gun-well entrance G_A. Q opens the firing shutter. B opens G_B on the outside route. F opens the final gate G_F. No mechanism remembers a previous press; every useful persistent state is represented by an actor or a released crate.

**Recording and solution.**

1. **Slot 1, the climber:** use K to reach the fragile perch, walk against its end stop, and commit there. Leave the shot lane below the actor's feet.
2. **Slot 2, the stagehand:** wait until the climber has left K, move K onto A, release it, then return to the lower control pad and finish on Q. K opens the gun-well entrance; slot 2 opens the firing shutter.
3. **Slot 3, the shooter:** wait for those arrangements, enter the service room, and fire once into the exposed fragile support. The shot removes the climber's floor. Slot 1, already out of recorded movement, falls onto the ground-floor pad B. Finish slot 3 safely in the service room.
4. **The live escape:** let the three recordings establish B. Only then reclaim K from A. Closing G_A is harmless because the shooter is already inside the service room.
5. Carry K along the outside route, through G_B, and release it onto F. Walk through G_F to X.

**The discovery.** The crate has been a staircase, an admission weight, and an exit key. Meanwhile, one unchanged echo has been a climber, a waiting passenger, and finally a switch holder.

**Safe ending.** Slot 1 stands on B directly beneath its old perch. Slot 2 stands on Q near the spawn. Slot 3 has fired its only shot and rests in the service room. K holds F. G_A can remain closed forever.

**Blockout checks.** Record the climber ending still on the fragile support; continued rightward input after the fall would complicate the landing. The perch has an end stop, and B covers the landing area below. Wait for that landing rather than a temporary activation by an actor walking past B. Allow at least one second between the climb and crate collection, and another visible settling interval between the support breaking and the final crate pickup. Verify that the shooter cannot accidentally hit the perched actor, that the falling actor does not enter the shot lane before the shot is spent, and that removing K from A does not block the outside route. During recording, nobody should enter the portal accidentally and clear the chamber before the team is complete.

**Hint:** “Every job ends. Every object can have another.”

## Starting points and implementation adjustments

For an introduction to the new set, start with **11**, **12**, and **19** in the chamber picker. Together they explore spatial reinterpretation, reuse of a shared object, and editing the team itself. **13** introduces delayed firing. **20** combines the interactions after they have been learned separately.

The intended emotional progression is curiosity in 11, confidence in 12, anticipation in 13, irreversible commitment in 14, social choreography in 15, reversal in 16, trust in 17, restraint in 18, subtraction in 19, and authorship in 20. These are design intentions. The automated solutions do not measure how human players experience the difficulty.

The original paper layouts were adjusted where physical testing required it:

- The shooting apertures are aligned to the actual recorded aim and remain too small for an actor. Crate landings and boost jumps use stable stops and forgiving floors.
- In chamber 15, the escape route is below the shared passage. Drop from its right end, then travel left through the two gates. The passing bay remains above the corridor.
- In chamber 17, use the upper stepping platform to reach the dock. The source well is below it. The verified receiver records its empty pickup at roughly ten seconds, then carries the future parcel over the dock's stop to C and finishes on B. The final player drops from the far right to the lower exit route.
- In chamber 20, Q is a lower control pad rather than a deep well. The shooter enters a closed service room through A's door rather than through a one-way drop. The outside escape route climbs above that room. These changes preserve the three roles and the crate's three jobs.
- In the finale, wait for the fragile support to disappear and the climber to land on B before reclaiming the crate. A passing actor can briefly light B earlier; that is not the final handoff.

The original teaching chambers also received repairs: a clearable shooting barrier, reachable stepping routes and exit landings, a stable crate catch, a threshold plate that stays active through its door, and taller final gates that cannot be bypassed from their elevated approach.

## Validation record

All twenty chambers have scripted solutions driven through ordinary movement, jump, pickup, release, throw, and shooting inputs. The tests create recordings through the real memory system and then replay them from a reset. They do not teleport actors, open gates directly, or inject a solved world state in order to clear a chamber.

Each new chamber is replayed twice with its committed recordings. The checks require the live player to reach the exit, every committed echo to remain alive, and the new chamber's echoes to finish their inputs before completion. They include pauses in the final arrangement to expose unstable crate placements and unsafe resting positions.

Additional checks cover memory behavior, spawn separation, chamber loading and progression, the pause and chamber picker controls, projectile impacts, crate support removal, turret cleanup, and both outcomes of the dangerous shutter arrangement.

Run the complete suite from this directory:

```sh
python3 tests/run_all.py
```

The runner also treats Godot script errors as failures, including cases where the engine reports them with a successful process exit status. Rendered views were inspected for layout and legibility. Difficulty, discovery, and unintended alternative solutions still benefit from human playtesting.
