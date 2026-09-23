import Foundation

/// Something in the game that has a name and a description the player can read.
protocol Describable {
    var name: String { get }
    var description: String { get }
}

/// The directions the player can move in.
enum Direction: String {
    case north, south, east, west
}

/// Items that can be picked up.
enum Item: Describable {
    case key

    var name: String {
        switch self {
        case .key: return "Rusty Key"
        }
    }

    var description: String {
        switch self {
        case .key: return "A rusty iron key lies on one of the shelves."
        }
    }
}

/// The locations in the castle.
enum Location: Describable {
    case cell, hallway, library, courtyard, gatehouse

    var name: String {
        switch self {
        case .cell: return "Dungeon Cell"
        case .hallway: return "Hallway"
        case .library: return "Library"
        case .courtyard: return "Courtyard"
        case .gatehouse: return "Gatehouse"
        }
    }

    var description: String {
        switch self {
        case .cell:
            return "You are in a cold, damp dungeon cell. The cell door hangs open to the north."
        case .hallway:
            return "A torch-lit hallway. A library lies to the west, a courtyard to the north, and your cell to the south."
        case .library:
            return "Dusty bookshelves line the walls. The hallway is to the east."
        case .courtyard:
            return "An open courtyard under the night sky. A gatehouse stands to the north, a dark moat lies to the east, and the hallway is to the south."
        case .gatehouse:
            return "A huge iron gate blocks the way north to freedom. The courtyard is to the south."
        }
    }

    /// Where each direction leads from this location.
    var exits: [Direction: Location] {
        switch self {
        case .cell: return [.north: .hallway]
        case .hallway: return [.south: .cell, .west: .library, .north: .courtyard]
        case .library: return [.east: .hallway]
        case .courtyard: return [.south: .hallway, .north: .gatehouse]
        case .gatehouse: return [.south: .courtyard]
        }
    }
}

/// Declare your game's behavior and state in this struct.
///
/// This struct will be re-created when the game resets. All game state should
/// be stored in this struct.
struct CastleEscape: AdventureGame {
    /// Where the player currently is.
    var location = Location.cell

    /// Items that are still lying around, keyed by the location they're in.
    var items: [Location: Item] = [.library: .key]

    /// Items the player has picked up.
    var inventory: [Item] = []

    /// Returns a title to be displayed at the top of the game.
    var title: String {
        return "Castle Escape"
    }

    /// Runs at the start of every game.
    ///
    /// - Parameter context: The object you use to write output and end the game.
    mutating func start(context: AdventureGameContext) {
        context.write("Welcome to Castle Escape! Find a way out of the castle. Type \"help\" to see the available commands.")
        context.write(describeLocation())
    }

    /// Runs when the user enters a line of input.
    ///
    /// - Parameters:
    ///   - input: The line the user typed.
    ///   - context: The object you use to write output and end the game.
    mutating func handle(input: String, context: AdventureGameContext) {
        let command = input.lowercased().trimmingCharacters(in: .whitespaces)

        if let direction = Direction(rawValue: command) {
            move(direction, context: context)
        } else if command == "take" {
            take(context: context)
        } else if command == "help" {
            context.write("Commands: north, south, east, west, take, help")
        } else {
            context.write("I don't understand \"\(input)\". Type \"help\" to see the available commands.")
        }
    }

    /// Moves the player in the given direction, ending the game if they reach an ending.
    mutating func move(_ direction: Direction, context: AdventureGameContext) {
        if location == .courtyard && direction == .east {
            context.write("You step into the dark moat and something with a lot of teeth drags you under. THE END (Bad Ending)")
            context.endGame()
            return
        }

        if location == .gatehouse && direction == .north {
            if inventory.contains(.key) {
                context.write("The rusty key turns in the lock and the gate creaks open. You escape into the night. THE END (Good Ending)")
                context.endGame()
            } else {
                context.write("The gate is locked. Maybe there's a key somewhere in the castle.")
            }
            return
        }

        guard let next = location.exits[direction] else {
            context.write("You can't go \(direction.rawValue) from here.")
            return
        }

        location = next
        context.write(describeLocation())
    }

    /// Picks up the item in the current location, if there is one.
    mutating func take(context: AdventureGameContext) {
        guard let item = items.removeValue(forKey: location) else {
            context.write("There's nothing here to take.")
            return
        }

        inventory.append(item)
        context.write("You picked up the \(item.name).")
    }

    /// Describes the current location, including any item lying in it.
    func describeLocation() -> String {
        var text = describe(location)
        if let item = items[location] {
            text += "\n" + describe(item)
        }
        return text
    }

    /// Formats anything with a name and description for display.
    func describe(_ thing: some Describable) -> String {
        return "\(thing.name): \(thing.description)"
    }
}

// Leave this line in - this line sets up the UI you see on the right.
// Update this if you rename your AdventureGame implementation.
CastleEscape.run()
