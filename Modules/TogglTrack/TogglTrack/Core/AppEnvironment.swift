//
//  AppEnvironment.swift
//  Toggl-iOS
//
//  Created by Ricardo Sánchez Sotres on 15/02/2020.
//  Copyright © 2020 Ricardo Sánchez Sotres. All rights reserved.
//

import Foundation
import API
import Repository

public struct AppEnvironment
{
    public let api: API
    public let repository: Repository
    
    public init(api: API, repository: Repository)
    {
        self.api = api
        self.repository = repository
    }
}

extension AppEnvironment
{
    var userAPI: UserAPI
    {
        return api
    }
}