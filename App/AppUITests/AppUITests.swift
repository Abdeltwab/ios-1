//
//  AppUITests.swift
//  AppUITests
//
//  Created by Juan Laube on 6/1/20.
//  Copyright © 2020 Ricardo Sánchez Sotres. All rights reserved.
//

import XCTest

class AppUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLogin() throws {
        app.buttons["Login with Email"].tap()

        let emailTextField = app.textFields["email"]
        emailTextField.tap()
        emailTextField.typeText("user@toggl.com")

        let passwordTextField = app.secureTextFields["password"]
        passwordTextField.tap()
        passwordTextField.typeText("s3cr3tz!")

        app.buttons["Login"].tap()
    }

    func testSignUp() throws {
        app.buttons["Login with Email"].tap()
        app.buttons["SignUp"].tap()

        let emailTextField = app.textFields["email"]
        emailTextField.tap()
        emailTextField.typeText("user@toggl.com")

        let passwordTextField = app.secureTextFields["password"]
        passwordTextField.tap()
        passwordTextField.typeText("s3cr3tz!")

        app.buttons["Signup"].tap()
        _ = app.textViews["loading"].waitForExistence(timeout: 1)
    }
}

class AppPerformanceTests: XCTestCase {
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTOSSignpostMetric.applicationLaunch]) {
                XCUIApplication().launch()
            }
        }
    }
}
