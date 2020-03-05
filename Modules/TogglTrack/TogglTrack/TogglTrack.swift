//
//  TogglTrack.swift
//  TogglTrack
//
//  Created by Ricardo Sánchez Sotres on 27/02/2020.
//  Copyright © 2020 Ricardo Sánchez Sotres. All rights reserved.
//

import UIKit
import Architecture
import RxSwift
import Onboarding
import API
import Repository
import Networking
import Models

public class TogglTrack
{
    private let store: Store<AppState, AppAction>!
    private let appCoordinator: AppCoordinator
    private let router: Router
    private var disposeBag = DisposeBag()

    public init(window: UIWindow)
    {
        let appFeature = AppFeature()
                
        store = Store(
            initialState: AppState(),
            reducer: logging(appFeature.reducer),
            environment: AppEnvironment()
        )
        
        appCoordinator = appFeature.mainCoordinator(store: store) as! AppCoordinator
        router = Router(initialRoute: "root", initialCoordinator: appCoordinator)
                
        store
            .select({ $0.route })
            .do(onNext: { print("Route: \($0.path)") })
            .distinctUntilChanged()
            .drive(onNext: router.navigate)
            .disposed(by: disposeBag)
        
        appCoordinator.start(window: window)
        store.dispatch(.start)
    }
}
