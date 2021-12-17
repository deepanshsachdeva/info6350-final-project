//
//  Post.swift
//  info6350-final-project
//
//  Created by Deepansh Sachdeva on 12/16/21.
//

import Foundation
import FirebaseFirestoreSwift

struct Post: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var body: String
    var createdByUID: String
    var createdByFullName:String
    @ServerTimestamp var lastUpdated:Date? = nil
}
