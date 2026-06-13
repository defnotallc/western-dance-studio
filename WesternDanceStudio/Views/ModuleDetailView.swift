import SwiftUI

struct ModuleDetailView: View {
    let module: CurriculumModule
    let store: DanceStore

    @State private var curriculum = CurriculumStore.shared
    private var isComplete: Bool { curriculum.isComplete(module) }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                moduleHeader
                skillsSection
                if !module.concepts.isEmpty { conceptsSection }
                if !module.danceIDs.isEmpty { dancesSection }
                if !module.glossaryTerms.isEmpty { glossarySection }
                completeButton
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle(module.numberDisplay)
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAd()
    }

    // MARK: - Header

    private var moduleHeader: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(isComplete ? Color.green : WesternTheme.primary)
                        .frame(width: 52, height: 52)
                    if isComplete {
                        Image(systemName: "checkmark")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(module.number)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(module.title)
                        .font(WesternTheme.displayFont(size: 22))
                        .foregroundStyle(WesternTheme.primaryDark)
                    Text(module.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            WesternDivider()

            Text(module.overview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                Label(module.estimatedTimeDisplay, systemImage: "clock")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !module.danceIDs.isEmpty {
                    Label("\(module.danceIDs.count) dance\(module.danceIDs.count == 1 ? "" : "s")", systemImage: "figure.dance")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Label("\(module.skills.count) skills", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Skills

    private var skillsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 8) {
                Label("What You'll Learn", systemImage: "list.bullet.clipboard.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)
                    .padding(.bottom, 2)

                ForEach(module.skills, id: \.self) { skill in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline)
                            .foregroundStyle(isComplete ? .green : WesternTheme.primary.opacity(0.5))
                        Text(skill)
                            .font(.subheadline)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Key Concepts

    private var conceptsSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 20) {
                Label("Key Concepts", systemImage: "book.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                ForEach(module.concepts) { concept in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(concept.heading)
                            .font(.subheadline.weight(.semibold))
                        Text(concept.body)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if concept.id != module.concepts.last?.id {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Practice Dances

    private var dancesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                Label("Practice Dances", systemImage: "figure.dance")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                ForEach(moduleDances) { dance in
                    NavigationLink(value: dance) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(dance.name)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(dance.summary)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            DifficultyStars(difficulty: dance.difficulty, size: 9)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }

                    if dance.id != moduleDances.last?.id {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationDestination(for: Dance.self) { dance in
            DanceDetailView(dance: dance, store: store)
        }
    }

    private var moduleDances: [Dance] {
        let all = Dance.sampleDances
        return module.danceIDs.compactMap { id in all.first { $0.id == id } }
    }

    // MARK: - Glossary Terms

    private var glossarySection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("Terms to Know", systemImage: "book.closed.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                FlowLayout(spacing: 8) {
                    ForEach(module.glossaryTerms, id: \.self) { termName in
                        termChip(termName)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func termChip(_ name: String) -> some View {
        let term = DanceTerm.allTerms.first { $0.term == name }
        return VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption.weight(.semibold))
                .foregroundStyle(WesternTheme.primaryDark)
            if let def = term?.definition {
                Text(def)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(WesternTheme.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Complete Button

    private var completeButton: some View {
        Button {
            Haptics.impact(.medium)
            curriculum.toggleComplete(module)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isComplete ? "checkmark.circle.fill" : "circle")
                Text(isComplete ? "Marked Complete" : "Mark as Complete")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isComplete ? Color.green : WesternTheme.primary, in: RoundedRectangle(cornerRadius: 14))
            .foregroundStyle(.white)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isComplete)
    }
}

// MARK: - Flow Layout

/// Simple wrapping HStack for variable-width chips.
private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        let height = rows.map(\.height).reduce(0, +) + CGFloat(max(rows.count - 1, 0)) * spacing
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let rows = computeRows(proposal: ProposedViewSize(width: bounds.width, height: nil), subviews: subviews)
        var y = bounds.minY
        for row in rows {
            var x = bounds.minX
            for item in row.items {
                item.view.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
                x += item.width + spacing
            }
            y += row.height + spacing
        }
    }

    private struct Row {
        var items: [(view: LayoutSubview, width: CGFloat)] = []
        var height: CGFloat = 0
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [Row] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [Row] = []
        var currentRow = Row()
        var rowWidth: CGFloat = 0

        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if rowWidth + size.width > maxWidth, !currentRow.items.isEmpty {
                rows.append(currentRow)
                currentRow = Row()
                rowWidth = 0
            }
            currentRow.items.append((view, size.width))
            currentRow.height = max(currentRow.height, size.height)
            rowWidth += size.width + spacing
        }
        if !currentRow.items.isEmpty { rows.append(currentRow) }
        return rows
    }
}
