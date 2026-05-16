import SwiftUI

// MARK: - Step direction parsing

/// Best-effort direction inference from a step instruction string.
/// Used to render a visual footprint diagram alongside the text.
enum StepDirection: String {
    case forward, backward, left, right, crossOver, inPlace, diagonal, unknown

    var icon: String {
        switch self {
        case .forward:   return "arrow.up"
        case .backward:  return "arrow.down"
        case .left:      return "arrow.left"
        case .right:     return "arrow.right"
        case .crossOver: return "arrow.up.right"
        case .inPlace:   return "circle"
        case .diagonal:  return "arrow.up.right.circle"
        case .unknown:   return "figure.walk"
        }
    }

    var color: Color {
        switch self {
        case .forward, .crossOver: return .green
        case .backward:            return .orange
        case .left, .right, .diagonal: return .blue
        case .inPlace:             return .gray
        case .unknown:             return .secondary.opacity(0.6)
        }
    }
}

enum StepFoot: String {
    case left, right, both, unknown

    var label: String {
        switch self {
        case .left: return "L"
        case .right: return "R"
        case .both: return "L+R"
        case .unknown: return "•"
        }
    }

    var color: Color {
        switch self {
        case .left: return .blue
        case .right: return .red
        case .both: return .purple
        case .unknown: return .gray
        }
    }
}

/// Parses a natural-language step instruction into a visual (foot, direction) pair.
/// The parsing is heuristic — it looks for keywords like "forward", "left foot", etc.
enum StepParser {
    static func parse(_ text: String) -> (foot: StepFoot, direction: StepDirection) {
        let lower = text.lowercased()

        // Foot detection
        let foot: StepFoot = {
            let hasLeft = lower.contains("left foot") || lower.contains("left (")
                || lower.range(of: #"\bleft\b"#, options: .regularExpression) != nil
            let hasRight = lower.contains("right foot") || lower.contains("right (")
                || lower.range(of: #"\bright\b"#, options: .regularExpression) != nil
            if hasLeft && hasRight { return .both }
            if hasLeft { return .left }
            if hasRight { return .right }
            return .unknown
        }()

        // Direction detection (priority order matters — check specific before general)
        let direction: StepDirection = {
            if lower.contains("cross") { return .crossOver }
            if lower.contains("diagonal") { return .diagonal }
            if lower.contains("forward") { return .forward }
            if lower.contains("back") { return .backward }
            if lower.contains("side") || lower.contains("to the right") || lower.contains("slide right") { return .right }
            if lower.contains("to the left") || lower.contains("slide left") { return .left }
            if lower.contains("in place") || lower.contains("bounce") || lower.contains("wobble") { return .inPlace }
            return .unknown
        }()

        return (foot, direction)
    }
}

// MARK: - Step diagram view

/// Renders a sequence of steps as a row of footprint indicators with directional arrows.
/// Each step shows a circle with the foot label (L/R) and an arrow for direction.
struct StepDiagram: View {
    let steps: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 14) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, text in
                    stepCell(index: index + 1, text: text)
                }
            }
            .padding(.vertical, 4)
        }
    }

    private func stepCell(index: Int, text: String) -> some View {
        let parsed = StepParser.parse(text)
        return VStack(spacing: 6) {
            Text("\(index)")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)

            ZStack {
                Circle()
                    .fill(parsed.foot.color.opacity(0.15))
                    .frame(width: 44, height: 44)

                Circle()
                    .stroke(parsed.foot.color, lineWidth: 2)
                    .frame(width: 44, height: 44)

                // Foot label (L/R)
                Text(parsed.foot.label)
                    .font(.subheadline.bold())
                    .foregroundStyle(parsed.foot.color)
            }
            .overlay(alignment: .bottomTrailing) {
                // Direction arrow badge
                Image(systemName: parsed.direction.icon)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(4)
                    .background(Circle().fill(parsed.direction.color))
                    .offset(x: 4, y: 4)
            }
        }
        .frame(width: 54)
        .accessibilityLabel(Text("Step \(index): \(text)"))
    }
}

// MARK: - Legend

struct StepDiagramLegend: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("How to read the diagram")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                legendItem(label: "L", color: .blue, text: "Left foot")
                legendItem(label: "R", color: .red, text: "Right foot")
            }

            HStack(spacing: 10) {
                directionItem(icon: "arrow.up", color: .green, label: "Fwd")
                directionItem(icon: "arrow.down", color: .orange, label: "Back")
                directionItem(icon: "arrow.left", color: .blue, label: "L/R")
                directionItem(icon: "arrow.up.right", color: .green, label: "Cross")
                directionItem(icon: "circle", color: .gray, label: "In place")
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func legendItem(label: String, color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 20, height: 20)
                Circle().stroke(color, lineWidth: 1.5).frame(width: 20, height: 20)
                Text(label).font(.caption2.bold()).foregroundStyle(color)
            }
            Text(text).font(.caption2).foregroundStyle(.secondary)
        }
    }

    private func directionItem(icon: String, color: Color, label: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.caption2.bold())
                .foregroundStyle(.white)
                .padding(3)
                .background(Circle().fill(color))
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}
