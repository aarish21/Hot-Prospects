//
//  Prospect.swift
//  HotProspects
//
//  Created by Aarish on 14/05/22.
//

import Foundation
class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = "aarish.rahman21@gmail.com"
    fileprivate(set) var isContacted = false
}

@MainActor class Prospects: ObservableObject{
    @Published var people: [Prospect]

        init() {
            self.people = []
        }
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
    }
}

