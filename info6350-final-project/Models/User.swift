//
//  User.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/16/21.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var uid:String
    var firstName: String
    var lastName: String
    var email: String
}
