import SwiftUI

// MARK: - Dance Hall Detail

struct DanceHallDetailView: View {
    let hall: DanceHall

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Location header
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(hall.city), \(hall.state) \(hall.zip)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let date = hall.verifiedDate {
                        Label("Verified \(formattedDate(date))", systemImage: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                }

                if !hall.description.isEmpty {
                    GroupBox {
                        Text(hall.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !hall.dances.isEmpty {
                    GroupBox("Dances") {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(hall.dances, id: \.self) { d in
                                Label(d, systemImage: "figure.dance")
                                    .font(.subheadline)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if !hall.lessons.isEmpty {
                    GroupBox("Lessons") {
                        Text(hall.lessons)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                if hall.hours != nil || hall.phone != nil || hall.website != nil {
                    GroupBox("Contact & Hours") {
                        VStack(alignment: .leading, spacing: 10) {
                            if let hours = hall.hours {
                                HStack(alignment: .top, spacing: 8) {
                                    Image(systemName: "clock")
                                        .foregroundStyle(WesternTheme.primary)
                                        .frame(width: 20)
                                    Text(hours)
                                        .font(.subheadline)
                                }
                            }
                            if let phone = hall.phone, let url = hall.phoneURL {
                                Link(destination: url) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "phone")
                                            .foregroundStyle(WesternTheme.primary)
                                            .frame(width: 20)
                                        Text(phone)
                                            .font(.subheadline)
                                    }
                                }
                            }
                            if let website = hall.website, let url = hall.websiteURL {
                                Link(destination: url) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "globe")
                                            .foregroundStyle(WesternTheme.primary)
                                            .frame(width: 20)
                                        Text(website)
                                            .font(.subheadline)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                Button {
                    Haptics.impact(.light)
                    openInMaps(hall)
                } label: {
                    Label("Get Directions in Maps", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .padding(.top, 8)
            }
            .padding()
        }
        .navigationTitle(hall.name)
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAd()
        .onDisappear {
            AdManager.shared.recordDetailReturn()
        }
    }

    private func formattedDate(_ iso: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: iso) else { return iso }
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}
