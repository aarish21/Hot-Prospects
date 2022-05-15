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
    
    let savePath = FileManager.documentsDirectory.appendingPathComponent("SavedPlaces")
    init() {
        
        do {
            let data = try Data(contentsOf: savePath)
            
            people = try JSONDecoder().decode([Prospect].self, from: data)
             
        } catch {
            people = []
        }

    }
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    private func save() {
        
        do {
            
            let data = try JSONEncoder().encode(people)
            try data.write(to: savePath, options: [.atomic, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
