import SwiftUI

/// Inline curriculum view — embedded inside BeginnerBootcampView's NavigationStack.
struct CurriculumView: View {
    let store: DanceStore
    @State private var curriculum = CurriculumStore.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            progressHeader
            moduleList
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Learning Path", systemImage: "graduationcap.fill")
                        .font(.headline)
                        .foregroundStyle(WesternTheme.primaryDark)
                    Spacer()
                    Text("\(curriculum.completedCount) of \(curriculum.totalCount)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                ProgressView(value: curriculum.completionFraction)
                    .tint(WesternTheme.primary)

                if curriculum.completedCount == curriculum.totalCount {
                    Label("All modules complete!", systemImage: "star.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                } else if let next = curriculum.nextIncompleteModule {
                    Text("Up next: Module \(next.number) — \(next.title)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Module Cards

    private var moduleList: some View {
        VStack(spacing: 10) {
            ForEach(CurriculumModule.all) { module in
                NavigationLink {
                    ModuleDetailView(module: module, store: store)
                } label: {
                    moduleCard(module)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func moduleCard(_ module: CurriculumModule) -> some View {
        let complete = curriculum.isComplete(module)
        return HStack(spacing: 14) {
            // Number / checkmark badge
            ZStack {
                Circle()
                    .fill(complete ? Color.green : WesternTheme.primary.opacity(0.15))
                    .frame(width: 44, height: 44)
                if complete {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.white)
                } else {
                    Text("\(module.number)")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(WesternTheme.primary)
                }
            }

            // Text
            VStack(alignment: .leading, spacing: 3) {
                Text(module.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(module.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack(spacing: 10) {
                    Label(module.estimatedTimeDisplay, systemImage: "clock")
                    if !module.danceIDs.isEmpty {
                        Label("\(module.danceIDs.count) dance\(module.danceIDs.count == 1 ? "" : "s")", systemImage: "figure.dance")
                    }
                }
                .font(.caption2)
                .foregroundStyle(.tertiary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(complete ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}
