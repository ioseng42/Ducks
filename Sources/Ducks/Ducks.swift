import Dispatch
import Ufos

public typealias Dispatch = (Any) -> Void
public typealias Fetch<State> = () -> State
public typealias Middleware<State> = (@escaping Fetch<State>, @escaping Dispatch) -> Dispatch
public typealias Reducer<State> = (State, Any) -> State
public typealias SideEffect<State> = (@escaping Fetch<State>, @escaping Dispatch) -> Void

public final class Store<State> {
    @Observed
    public private(set) var state: State
    public private(set) var dispatch: Dispatch!
    
    public init(_ initial: State,
                reducer: @escaping Reducer<State>,
                middleware: @escaping Middleware<State> = { _, dispatch in dispatch },
                queue: DispatchQueue = DispatchQueue(label: "ducks-\(DispatchTime.now().uptimeNanoseconds)", qos: .userInteractive)) {
        state = initial
        let sideEffectMiddleware: Middleware<State> = { fetch, dispatch in
            return { action in
                (action as? SideEffect<State>).map { $0(fetch, dispatch) } ?? dispatch(action)
            }
        }
        let middleware = combineMiddleware(middleware, sideEffectMiddleware)
        let fetch: Fetch<State> = {
            queue.sync { [unowned self] in state }
        }
        dispatch = middleware(fetch) { action in
            queue.async { [unowned self] in state = reducer(state, action) }
        }
    }
}

public func combineReducers<State>(_ reducers: Reducer<State>...) -> Reducer<State> {
    return { prevState, action in
        reducers.reduce(prevState) { state, reducer in reducer(state, action) }
    }
}

public func combineMiddleware<State>(_ fst: @escaping Middleware<State>, _ rest: Middleware<State>...) -> Middleware<State> {
    let middlewares = rest.reversed() + [fst]
    let m1 = middlewares.last ?? fst
    let m = middlewares.dropLast()
    return { fetch, dispatch in m.reduce(m1(fetch, dispatch)) { $1(fetch, $0) } }
}
