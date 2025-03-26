import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST_Calendar

struct CalendarView: View {
    @EnvironmentObject var eventManager: EventManager
    @State private var showingAddEvent = false
    @State private var selectedDate = Date()
    @State private var showingGoogleSignIn = false
    
    var body: some View {
        NavigationStack {
            VStack {
                if !eventManager.isGoogleSignedIn {
                    Button(action: {
                        showingGoogleSignIn = true
                    }) {
                        HStack {
                            Image(systemName: "calendar")
                            Text("Connect Google Calendar")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                
                List {
                    Section(header: Text("Local Events")) {
                        ForEach(eventManager.events.filter {
                            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
                        }) { event in
                            EventRow(event: event)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        eventManager.deleteEvent(event.id)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    
                    if eventManager.isGoogleSignedIn {
                        Section(header: Text("Google Calendar Events")) {
                            ForEach(eventManager.googleEvents, id: \.identifier) { event in
                                if let start = event.start?.dateTime?.date ?? event.start?.date?.date,
                                   Calendar.current.isDate(start, inSameDayAs: selectedDate) {
                                    GoogleEventRow(event: event)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddEvent = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddEvent) {
            AddEventView(isPresented: $showingAddEvent, selectedDate: selectedDate)
                .environmentObject(eventManager)
        }
        .alert("Sign in to Google Calendar", isPresented: $showingGoogleSignIn) {
            Button("Sign In") {
                eventManager.signInToGoogleCalendar { success in
                    if success {
                        print("Successfully connected to Google Calendar")
                    }
                }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

struct EventRow: View {
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.title)
                .font(.headline)
            HStack {
                Text(event.type)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatTimeRange(start: event.date, duration: event.duration))
                    .font(.subheadline)
            }
        }
    }
    
    private func formatTimeRange(start: Date, duration: Double) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        
        let endDate = Calendar.current.date(byAdding: .minute, value: Int(duration * 60), to: start) ?? start
        
        return "\(formatter.string(from: start)) - \(formatter.string(from: endDate))"
    }
}

struct GoogleEventRow: View {
    let event: GTLRCalendar_Event
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(event.summary ?? "Untitled Event")
                .font(.headline)
            HStack {
                Text("Google Calendar")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                if let startTime = event.start?.dateTime?.date,
                   let endTime = event.end?.dateTime?.date {
                    Text("\(formatTime(startTime)) - \(formatTime(endTime))")
                        .font(.subheadline)
                }
            }
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct AddEventView: View {
    @EnvironmentObject var eventManager: EventManager
    @Binding var isPresented: Bool
    let selectedDate: Date
    
    @State private var eventTitle = ""
    @State private var eventStartTime = Date()
    @State private var duration: Double = 1.0
    @State private var selectedEventType = "Meeting"
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $eventTitle)
                    
                    DatePicker("Start Time", selection: $eventStartTime, displayedComponents: [.hourAndMinute])
                    
                    Picker("Duration", selection: $duration) {
                        Text("30 minutes").tag(0.5)
                        Text("1 hour").tag(1.0)
                        Text("1.5 hours").tag(1.5)
                        Text("2 hours").tag(2.0)
                        Text("3 hours").tag(3.0)
                    }
                    
                    Picker("Event Type", selection: $selectedEventType) {
                        Text("Meeting").tag("Meeting")
                        Text("Family Event").tag("Family Event")
                        Text("Personal").tag("Personal")
                        Text("Other").tag("Other")
                    }
                }
                
                Section(header: Text("Conflicts")) {
                    let conflicts = eventManager.checkConflicts(for: eventStartTime, duration: duration)
                    if conflicts.isEmpty {
                        Text("No scheduling conflicts")
                            .foregroundColor(.green)
                    } else {
                        ForEach(conflicts, id: \.1) { conflict in
                            VStack(alignment: .leading) {
                                Text("Conflict with: \(conflict.0)")
                                    .foregroundColor(.red)
                                if conflict.2 == "Google Calendar",
                                   let event = eventManager.googleEvents.first(where: { $0.summary == conflict.0 }),
                                   let start = event.start?.dateTime?.date,
                                   let end = event.end?.dateTime?.date {
                                    Text("\(formatTime(start)) - \(formatTime(end))")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                } else {
                                    let endTime = Calendar.current.date(byAdding: .minute, value: Int(duration * 60), to: conflict.1) ?? conflict.1
                                    Text("\(formatTime(conflict.1)) - \(formatTime(endTime))")
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Event")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                },
                trailing: Button("Add") {
                    let combinedDate = Calendar.current.date(
                        bySettingHour: Calendar.current.component(.hour, from: eventStartTime),
                        minute: Calendar.current.component(.minute, from: eventStartTime),
                        second: 0,
                        of: selectedDate) ?? selectedDate
                    
                    eventManager.addEvent(eventTitle,
                                        date: combinedDate,
                                        duration: duration,
                                        type: selectedEventType)
                    isPresented = false
                }
                .disabled(eventTitle.isEmpty)
            )
        }
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}


