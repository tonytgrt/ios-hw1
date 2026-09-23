# Castle Escape

*For instructions, consult the HW1 Assignment on the [CIS 1951 website](https://www.seas.upenn.edu/~cis1951/26fa/assignments/).*

**Xcode version:** 27.0

## Explanations

**What locations/rooms does your game have?**

1. Dungeon Cell (starting location)
2. Hallway
3. Library
4. Courtyard
5. Gatehouse

**What items does your game have?**

1. Rusty Key: found in the Library. You need it to unlock the gate in the Gatehouse and escape.

**Explain how your code is designed. In particular, describe how you used structs or enums, as well as protocols.**

The game uses three enums:

- `Direction` holds the four directions. It has `String` raw values, so a typed command like `"north"` converts straight to `.north`.
- `Location` holds the five rooms. Each case has a `name`, a `description`, and an `exits` dictionary that maps each `Direction` to the `Location` it leads to.
- `Item` holds the items that can be picked up (just the key).

`Location` and `Item` both conform to the `Describable` protocol, which requires a `name` and a `description`. The generic `describe(_ thing: some Describable)` function formats them the same way when printing a room or an item in it. If either conformance is removed, the calls to `describe` no longer compile.

All game state is stored in the `CastleEscape` struct: the player's current `location`, an `items` dictionary of items still lying in each location, and an `inventory` array of items picked up. `handle(input:context:)` reads the command and hands it to `move(_:context:)` or `take(context:)`. `move` checks for the two endings first (the moat east of the Courtyard, and the gate north of the Gatehouse). Otherwise it follows the current location's exits.

**How do you use optionals in your program?**

- `Direction(rawValue: command)` returns `nil` when the input isn't a direction, so `if let` tells movement commands apart from other commands.
- `location.exits[direction]` returns `nil` when there's no exit that way. A `guard let` then prints "You can't go ... from here" instead of moving.
- `items.removeValue(forKey: location)` returns `nil` when there's nothing to pick up. `guard let` handles that case for the `take` command.
- `items[location]` is unwrapped with `if let` to show an item's description only when one is in the room.

**Did you implement any extra features you're proud of and want to show off?**

- None

## Endings

### Ending 1

Good ending: pick up the key, then unlock the gate and escape.

```text
north
west
take
east
north
north
north
```

### Ending 2

Bad ending: walk into the moat.

```text
north
north
east
```
