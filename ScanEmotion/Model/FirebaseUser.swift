//
//  FirebaseUser.swift
//  ScanEmotion
//
//  Created by Engin Bolat on 16.06.2025.
//

import FirebaseAuth
import Foundation

struct FirebaseUser {
    let uid: String?
    let displayName: String?
    let email: String?
    let phoneNumber: String?
    let photoURL: URL?

    init(user: User) {
        uid = user.uid
        displayName = user.displayName
        email = user.email
        phoneNumber = user.phoneNumber
        photoURL = user.photoURL
    }
}

extension FirebaseUser {
    init(uid: String?, displayName: String?, email: String?, phoneNumber: String? = nil, photoURL: URL? = nil) {
        self.uid = uid
        self.displayName = displayName
        self.email = email
        self.phoneNumber = phoneNumber
        self.photoURL = photoURL
    }
}
