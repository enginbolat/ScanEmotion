//
//  UserSession.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 16.06.2025.
//

import Observation

@Observable
class UserSession {
    var isLoggedIn: Bool = false
    var name: String = ""
    var surname: String = ""
    var email: String = ""
    var image: String = ""

    func login(name: String, surname: String, email: String, image: String) {
        self.name = name
        self.surname = surname
        self.email = email
        self.image = image
        isLoggedIn = true
    }

    func logout() {
        name = ""
        surname = ""
        email = ""
        image = ""
        isLoggedIn = false
    }
}
