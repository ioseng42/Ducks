import Ducks
import XCTest

/*
 * Classic Redux Example of a simple up / down counter
 * Instead of a webpage with buttons, this is a basic console app.
 */

struct State {
    var counter: Int
}

enum Action {
    case up(_ value: Int)   // Inc by <value>
    case down(_ value: Int) // Dec by <value>
}

extension Action {
    // Inc by 10 after 1 sec :: Async Effect
    static let asyncUp: SideEffect<State> = { _, dispatch in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            dispatch(Action.up(10))
        }
    }
    
    // Dec by 10 after 1 sec :: Async Effect
    static let asyncDown: SideEffect<State> = { _, dispatch in
        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            dispatch(Action.down(10))
        }
    }
}

let reducer: Reducer<State> = { state, action in
    var state = state
    switch (action as? Action) {
    case let .up(value)?:
        state.counter += value
    case let .down(value)?:
        state.counter -= value
    default:
        break
    }
    return state
}

func logActions(_ fetch: @escaping Fetch<State>, dispatch: @escaping Dispatch) -> Dispatch {
    let format = DateFormatter()
    format.timeStyle = .medium
    return { action in
        print("-- Action \(format.string(from: Date())) -- \(action)")
        dispatch(action)
    }
}

func test() {
    let store = Store(State(counter: 0), reducer: reducer, middleware: logActions)
    store.$state.observe(with: store, queue: .global()) { _, state in
        print("New State : \(state)")
    }
    store.$state.observe(\.counter, with: store, queue: .global()) { _, counter in
        print("counter : \(counter)")
    }
    let tooltip = """
-- Options --
1 ⏎ to increment by 1 synchronously
2 ⏎ to decrement by 1 synchronously
3 ⏎ to increment by 10 asynchronously after 1 second
4 ⏎ to decrement by 10 asynchronously after 1 second
** Any other keys ⏎ to exit **
"""
    
    print(tooltip)
    outerLoop: while true {
        switch (Int(readLine() ?? "")) {
        case 1: store.dispatch(Action.up(1))
        case 2: store.dispatch(Action.down(1))
        case 3: store.dispatch(Action.asyncUp)
        case 4: store.dispatch(Action.asyncDown)
        default: break outerLoop
        }
    }
}

final class DucksTests: XCTestCase {
    func testDucks() {
        test()
    }
    
    static var allTests = [
        ("testDucks", testDucks),
    ]
}

