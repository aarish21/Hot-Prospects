//
//  ProspectsView.swift
//  HotProspects
//
//  Created by Aarish on 14/05/22.
//

import SwiftUI
import CodeScanner
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none, contacted, uncontacted
    }
    
    @State private var sort: Int = 0
    @State private var isShowingScanner = false
    let filter: FilterType
    @EnvironmentObject var prospects: Prospects
    @State private var isSortedByName = false
    
    var body: some View {
        NavigationView{
            List{
                ForEach(sortedFilteredProspects){ prospect in
                    
                    VStack(alignment: .leading){
                        if prospect.isContacted{
                            HStack{
                                VStack(alignment: .leading){
                                    Text(prospect.name)
                                        .font(.headline)
                                    Text(prospect.emailAddress)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Label("", systemImage: "person.fill.checkmark")
                            }
                        }else{
                            HStack{
                                VStack(alignment: .leading){
                                    Text(prospect.name)
                                        .font(.headline)
                                    Text(prospect.emailAddress)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Label("", systemImage: "person.fill.xmark")
                            }
                        }
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            
                            Button {
                                prospects.toggle(prospect)
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind Me", systemImage: "bell")
                            }
                            .tint(.orange)
                            
                        }
                    }
                }
            }
            
            .toolbar{
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Picker("sort", selection: $sort) {
                            Text("By Name").tag(0)
                            Text("Most Recent").tag(1)
                           
                        }.onChange(of: sort) { s in
                            if s == 0{
                                isSortedByName = true
                            }else{
                                isSortedByName = false
                            }
                        }
                    } label: {
                        Label("sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }                }
               
                
            }
            
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(codeTypes: [.qr], simulatedData: "Aarish\naarish.rahman21@gmail.com", completion: handleScan)
            }
            .navigationTitle(title)
        }
        
    }
    var sortedFilteredProspects: [Prospect] {
        if isSortedByName {
            // by name
            return filteredProspects.sorted(by: { $0.name < $1.name })
        } else {
            // by most recent
            return filteredProspects.reversed()
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    var filteredProspects: [Prospect] {
        switch filter {
        case .none:
            return prospects.people
        case .contacted:
            return prospects.people.filter { $0.isContacted }
        case .uncontacted:
            return prospects.people.filter { !$0.isContacted }
        }
    }

    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            
            prospects.add(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default

            var dateComponents = DateComponents()
            dateComponents.hour = 9
//            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else {
                        print("D'oh")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none)
            .environmentObject(Prospects())
    }
}
