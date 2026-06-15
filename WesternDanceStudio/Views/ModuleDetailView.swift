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
                if !moduleErrors.isEmpty { commonMistakesSection }
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
            VStack(alignment: .leading, spacing: 12) {
                Label("Terms to Know", systemImage: "book.closed.fill")
                    .font(.headline)
                    .foregroundStyle(WesternTheme.primaryDark)

                ForEach(module.glossaryTerms, id: \.self) { termName in
                    let term = DanceTerm.allTerms.first { $0.term == termName }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(termName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(WesternTheme.primaryDark)
                        if let def = term?.definition {
                            Text(def)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if termName != module.glossaryTerms.last {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Common Mistakes (Phase 5)

    private var moduleErrors: [CommonError] {
        CommonError.all.filter { $0.moduleIDs.contains(module.id) }
    }

    private var commonMistakesSection: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Label("Watch Out For", systemImage: "exclamationmark.triangle.fill")
                        .font(.headline)
                        .foregroundStyle(.orange)
                    Spacer()
                    NavigationLink {
                        CommonErrorsView()
                    } label: {
                        Text("See all")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(WesternTheme.primary)
                    }
                }

                ForEach(moduleErrors) { error in
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: error.category.icon)
                            .font(.caption)
                            .foregroundStyle(WesternTheme.primary.opacity(0.7))
                            .frame(width: 16)
                            .padding(.top, 2)
                        VStack(alignment: .leading, spacing: 3) {
                            Text(error.title)
                                .font(.subheadline.weight(.semibold))
                            Text(error.fix)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    if error.id != moduleErrors.last?.id {
                        Divider()
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
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

