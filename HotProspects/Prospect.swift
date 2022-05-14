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
    @Published  private(set) var people: [Prospect]
    let saveKey = "SavedData"
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        }

        people = []
    }
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}

