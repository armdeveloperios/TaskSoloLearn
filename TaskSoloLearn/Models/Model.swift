//
//  Model.swift
//  TaskSoloLearn
//
//  Created by Armen Alikhanyan on 4/20/19.
//  Copyright © 2019 ArmenAlikhanyan. All rights reserved.
//

import Foundation

struct DataJson: Codable {
    var response: Results!
}

struct Results: Codable {
    var results: [News]!
}

struct News: Codable {
    var sectionName: String!
    var webPublicationDate: String!
    var webTitle: String!
    var fields: Fields!
}

struct Fields: Codable {
    var bodyText: String!
    var thumbnail: String?
}
