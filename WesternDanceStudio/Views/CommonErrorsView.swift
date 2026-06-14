import SwiftUI

struct CommonErrorsView: View {
    @State private var selectedCategory: CommonError.ErrorCategory? = nil

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                categoryPicker
                ForEach(visibleCategories, id: \.self) { category in
                    categorySection(category)
                }
                Spacer(minLength: 24)
            }
            .padding()
            .frame(maxWidth: 800)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .navigationTitle("Common Mistakes")
        .navigationBarTitleDisplayMode(.inline)
        .withBannerAd()
    }

    // MARK: - Category Filter

    private var visibleCategories: [CommonError.ErrorCategory] {
        if let cat = selectedCategory { return [cat] }
        return CommonError.ErrorCategory.allCases
    }

    private var categoryPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                filterChip(label: "All", icon: "list.bullet", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }
                ForEach(CommonError.ErrorCategory.allCases) { cat in
                    filterChip(label: cat.rawValue, icon: cat.icon, isSelected: selectedCategory == cat) {
                        selectedCategory = selectedCategory == cat ? nil : cat
                    }
                }
            }
            .padding(.horizontal, 2)
            .padding(.vertical, 4)
        }
    }

    private func filterChip(label: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.selection()
            action()
        } label: {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                isSelected ? WesternTheme.primary : Color(.secondarySystemGroupedBackground),
                in: Capsule()
            )
            .foregroundStyle(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Section

    private func categorySection(_ category: CommonError.ErrorCategory) -> some View {
        let errors = CommonError.all.filter { $0.category == category }
        return VStack(alignment: .leading, spacing: 12) {
            Label(category.rawValue, systemImage: category.icon)
                .font(.headline)
                .foregroundStyle(WesternTheme.primaryDark)

            ForEach(errors) { error in
                errorCard(error)
            }
        }
    }

    // MARK: - Error Card

    private func errorCard(_ error: CommonError) -> some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Text(error.title)
                    .font(.subheadline.weight(.semibold))

                Divider()

                errorRow(
                    icon: "eye",
                    label: "What it looks like",
                    text: error.symptom
                )

                errorRow(
                    icon: "arrow.triangle.2.circlepath",
                    label: "The fix",
                    text: error.fix,
                    accent: true
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func errorRow(icon: String, label: String, text: String, accent: Bool = false) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(accent ? WesternTheme.primary : .secondary)
                .frame(width: 16)
                .padding(.top, 2)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.caption)
                    .foregroundStyle(accent ? .primary : .secondary)
            }
        }
    }
}
