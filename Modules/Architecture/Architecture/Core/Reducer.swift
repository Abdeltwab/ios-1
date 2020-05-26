import Foundation
import RxSwift

public typealias ReduceFunction<StateType, ActionType> = (inout StateType, ActionType) -> [Effect<ActionType>]

public struct Reducer<StateType, ActionType> {
    public let reduce: ReduceFunction<StateType, ActionType>
    
    public init(_ reduce: @escaping ReduceFunction<StateType, ActionType>) {
        self.reduce = reduce
    }
    
    public func pullback<GlobalState, GlobalAction>(
        state: WritableKeyPath<GlobalState, StateType>,
        action: WritableKeyPath<GlobalAction, ActionType?>
    ) -> Reducer<GlobalState, GlobalAction> {
        return Reducer<GlobalState, GlobalAction> { globalState, globalAction in
            guard let localAction = globalAction[keyPath: action] else { return [] }
            
            let locaEffects = self.reduce(&globalState[keyPath: state], localAction)
            return locaEffects.map { localEffect in
                localEffect
                    .map { localAction -> GlobalAction in
                        var globalAction = globalAction
                        globalAction[keyPath: action] = localAction
                        return globalAction
                    }
                }
        }
    }

    public func pullback<GlobalAction>(
        action: WritableKeyPath<GlobalAction, ActionType?>
    ) -> Reducer<StateType, GlobalAction> {
        return self.pullback(state: \StateType.self, action: action)
    }

    /// Enhances a reducer with some other reducer.
    public func decorate<ReducerState, ReducerAction>(
        with reducer: Reducer<ReducerState, ReducerAction>,
        state: WritableKeyPath<StateType, ReducerState>,
        action: WritableKeyPath<ActionType, ReducerAction?>
    ) -> Reducer {
        combine(
            self,
            reducer.pullback(state: state, action: action)
        )
    }
}

public func combine<State, Action>(
    _ reducers: Reducer<State, Action>...
) -> Reducer<State, Action> {
    combine(reducers)
}

public func combine<State, Action>(
    _ reducers: [Reducer<State, Action>]
) -> Reducer<State, Action> {
    return Reducer { state, action in
        let effects = reducers.flatMap { $0.reduce(&state, action) }
        return effects
    }
}
