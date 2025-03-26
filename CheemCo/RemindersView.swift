import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct Reminder: Identifiable {
    var id: String
    var title: String
    var dueDate: Date
    var completed: Bool
    var createdBy: String
}

class ReminderManager: ObservableObject {
    @Published var reminders: [Reminder] = []
    private var db = Firestore.firestore()
    
    init() {
        loadReminders()
    }
    
    func loadReminders() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        db.collection("reminders")
            .whereField("createdBy", in: [userId])
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No reminders found")
                    return
                }
                
                self.reminders = documents.compactMap { document -> Reminder? in
                    let data = document.data()
                    return Reminder(
                        id: document.documentID,
                        title: data["title"] as? String ?? "",
                        dueDate: (data["dueDate"] as? Timestamp)?.dateValue() ?? Date(),
                        completed: data["completed"] as? Bool ?? false,
                        createdBy: data["createdBy"] as? String ?? ""
                    )
                }
            }
    }
    
    func addReminder(_ title: String, dueDate: Date) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let newReminder = [
            "title": title,
            "dueDate": Timestamp(date: dueDate),
            "completed": false,
            "createdBy": userId
        ] as [String : Any]
        
        db.collection("reminders").addDocument(data: newReminder) { error in
            if let error = error {
                print("Error adding reminder: \(error)")
            }
        }
    }
    
    func toggleReminder(_ id: String, completed: Bool) {
        db.collection("reminders").document(id).updateData([
            "completed": completed
        ]) { error in
            if let error = error {
                print("Error updating reminder: \(error)")
            }
        }
    }
    
    func deleteReminder(_ id: String) {
        db.collection("reminders").document(id).delete() { error in
            if let error = error {
                print("Error removing reminder: \(error)")
            }
        }
    }
}

struct RemindersView: View {
    @StateObject private var reminderManager = ReminderManager()
    @State private var showingAddReminder = false
    @State private var newReminderTitle = ""
    @State private var newReminderDate = Date()
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active")) {
                    ForEach(reminderManager.reminders.filter { !$0.completed }) { reminder in
                        ReminderRow(reminder: reminder, reminderManager: reminderManager)
                    }
                }
                
                Section(header: Text("Completed")) {
                    ForEach(reminderManager.reminders.filter { $0.completed }) { reminder in
                        ReminderRow(reminder: reminder, reminderManager: reminderManager)
                    }
                }
            }
            .navigationTitle("Reminders")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddReminder = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddReminder) {
            NavigationView {
                Form {
                    TextField("Reminder Title", text: $newReminderTitle)
                    DatePicker("Due Date", selection: $newReminderDate)
                }
                .navigationTitle("New Reminder")
                .navigationBarItems(
                    leading: Button("Cancel") {
                        showingAddReminder = false
                    },
                    trailing: Button("Add") {
                        reminderManager.addReminder(newReminderTitle, dueDate: newReminderDate)
                        newReminderTitle = ""
                        newReminderDate = Date()
                        showingAddReminder = false
                    }
                    .disabled(newReminderTitle.isEmpty)
                )
            }
        }
    }
}

struct ReminderRow: View {
    let reminder: Reminder
    let reminderManager: ReminderManager
    
    var body: some View {
        HStack {
            Button(action: {
                reminderManager.toggleReminder(reminder.id, completed: !reminder.completed)
            }) {
                Image(systemName: reminder.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(reminder.completed ? .green : .gray)
            }
            
            VStack(alignment: .leading) {
                Text(reminder.title)
                    .strikethrough(reminder.completed)
                Text(reminder.dueDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .swipeActions {
            Button(role: .destructive) {
                reminderManager.deleteReminder(reminder.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct RemindersView_Previews: PreviewProvider {
    static var previews: some View {
        RemindersView()
    }
}


