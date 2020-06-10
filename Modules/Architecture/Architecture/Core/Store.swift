import Foundation
import RxSwift
import RxRelay
import RxCocoa
import Utils

public final class Store<State, Action> {
    
    private var disposeBag: DisposeBag = DisposeBag()
    
    private var state: Driver<State>
    private var internalDispatch: (([Action]) -> Void)?
                
    private init(dispatch: @escaping ([Action]) -> Void, stateObservable: Driver<State>) {
        internalDispatch = dispatch
        state = stateObservable
    }
    
    public init(initialState: State, reducer: Reducer<State, Action>) {
        let behaviorRelay = BehaviorRelay(value: initialState)
        state = behaviorRelay.asDriver()
        
        internalDispatch = { actions in
            
            var tempState = behaviorRelay.value
            let effects = actions.flatMap { reducer.reduce(&tempState, $0) }
            
            behaviorRelay.accept(tempState)
            
            Observable.from(effects.map { $0.single })
                .merge().toArray()
                .observeOn(MainScheduler.instance)
                .subscribe(onSuccess: self.batch)
                .disposed(by: self.disposeBag)
        }
    }
    
    public func view<ViewState, ViewAction>(
        state toLocalState: @escaping (State) -> ViewState,
        action toGlobalAction: @escaping (ViewAction) -> Action?
    ) -> Store<ViewState, ViewAction> {
        
        return Store<ViewState, ViewAction>(
            dispatch: { actions in
                self.batch(
                    actions.compactMap(toGlobalAction)
                )
            },
            stateObservable: state.map(toLocalState)
        )
    }
     
    public func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.internalDispatch?([action])
        }
    }
    
    public func batch(_ actions: [Action]) {
        if actions.isEmpty { return }
        self.internalDispatch?(actions)
    }
}

extension Store {
    public func select<B>(_ selector: @escaping (State) -> B) -> Driver<B> {
        return state.map(selector)
    }
    
    public func select<B>(_ selector: @escaping (State) -> B) -> Driver<B> where B: Equatable {
        return state.map(selector).distinctUntilChanged()
    }

    public func compactSelect<B>(_ selector: @escaping (State) -> B?) -> Driver<B> {
        return state.compactMap(selector)
    }

    func compactSelect<B>(_ selector: @escaping (State) -> B?) -> Driver<B> where B: Equatable {
        return state.compactMap(selector).distinctUntilChanged()
    }
}
