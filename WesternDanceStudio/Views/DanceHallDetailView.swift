import SwiftUI

// MARK: - Dance Hall Detail

struct DanceHallDetailView: View {
    let hall: DanceHall

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(hall.city), \(hall.state) \(hall.zip)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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
}
