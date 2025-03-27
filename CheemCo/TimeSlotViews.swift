import SwiftUI

struct TimeSlotItemView: View {
    let time: Date
    let duration: Double
    let isSelected: Bool
    let onSelect: () -> Void
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading) {
                    Text(timeFormatter.string(from: time))
                        .font(.headline)
                    
                    if let endTime = Calendar.current.date(
                        byAdding: .minute,
                        value: Int(duration * 60),
                        to: time
                    ) {
                        Text("Until \(timeFormatter.string(from: endTime))")
                            .font(.subheadline)
                            .foregroundColor(ThemeColors.secondaryText)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ThemeColors.textColor)
                }
            }
            .padding()
            .background(isSelected ? ThemeColors.lightGreen : ThemeColors.darkGreen)
            .foregroundColor(ThemeColors.textColor)
            .cornerRadius(10)
        }
    }
}

struct TimeSlotDaySection: View {
    let daySlots: TimeSlotGroup
    @Binding var selectedTime: Date?
    @ObservedObject var viewModel: HangoutRequestViewModel
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        Section(header: dayHeader) {
            ForEach(daySlots.slots, id: \.self) { slot in
                TimeSlotItemView(
                    time: slot,
                    duration: viewModel.selectedDuration,
                    isSelected: selectedTime == slot,
                    onSelect: { selectedTime = slot }
                )
            }
        }
    }
    
    private var dayHeader: some View {
        Text(dateFormatter.string(from: daySlots.date))
            .font(.headline)
            .foregroundColor(ThemeColors.textColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(ThemeColors.darkGreen)
    }
}

struct TimeSlotListView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    @Binding var selectedTime: Date?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.timeSlots, id: \.id) { daySlots in
                    TimeSlotDaySection(daySlots: daySlots, selectedTime: $selectedTime, viewModel: viewModel)
                }
            }
        }
    }
}

struct TimeSlotLoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: ThemeColors.darkGreen))
    }
}

struct TimeSlotEmptyView: View {
    var body: some View {
        VStack {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.largeTitle)
                .foregroundColor(ThemeColors.secondaryText)
            Text("No available times found")
                .foregroundColor(ThemeColors.secondaryText)
                .padding(.top)
        }
        .padding()
    }
}

struct TimeSlotPickerView: View {
    @ObservedObject var viewModel: HangoutRequestViewModel
    @Binding var selectedTime: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Available Times")
                .font(.title2)
                .foregroundColor(ThemeColors.textColor)
                .padding(.bottom)
            
            if viewModel.isLoadingTimeSlots {
                TimeSlotLoadingView()
            } else if viewModel.timeSlots.isEmpty {
                TimeSlotEmptyView()
            } else {
                TimeSlotListView(viewModel: viewModel, selectedTime: $selectedTime)
            }
        }
    }
} 