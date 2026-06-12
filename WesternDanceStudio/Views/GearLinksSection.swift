import SwiftUI

/// Amazon-affiliate gear links shown in the Start Here tab and at the
/// bottom of the Favorites tab. Curated keywords, reputable western
/// brands (same ones Cavender's and Boot Barn stock), 4-star minimum,
/// and price floors filter out knockoffs.
struct GearLinksSection: View {
    /// Amazon Associates tracking tag.
    private let amazonAffiliateTag = "defnota-20"

    /// 4-star-and-up filter code in Amazon's URL format.
    private let amazonFourStarsAndUpFilter = "p_72%3A1248879011"

    /// Curated brand allowlists, keyed by gear category.
    /// The same reputable western brands stocked by Cavender's and Boot Barn.
    private enum GearBrands {
        static let boots  = ["Ariat", "Justin", "Tony Lama", "Dan Post", "Dingo", "Durango", "Lucchese", "Corral", "Old West", "Laredo", "Twisted X", "Roper"]
        static let hats   = ["Stetson", "Resistol", "Charlie 1 Horse", "Bailey", "Dorfman Pacific", "Justin", "American Hat Company", "Atwood", "Scala"]
        static let shirts = ["Wrangler", "Cinch", "Ariat", "Panhandle", "Roper", "Rock and Roll Denim", "Cruel Girl", "Cody James", "Ely Cattleman"]
        static let belts  = ["Ariat", "Nocona", "Justin", "Tony Lama", "Wrangler", "Montana Silversmiths"]
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 10) {
                Label("Dance Gear", systemImage: "bag.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)

                Text("Quality country dance essentials from trusted western brands.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                gearLink(
                    "Men's Leather Western Boots",
                    keywords: "mens western boots leather sole",
                    brands: GearBrands.boots,
                    minPriceDollars: 80
                )
                gearLink(
                    "Women's Leather Dance Boots",
                    keywords: "womens cowboy boots leather sole",
                    brands: GearBrands.boots,
                    minPriceDollars: 70
                )
                gearLink(
                    "Cowboy & Cowgirl Hats",
                    keywords: "cowboy hat wool felt",
                    brands: GearBrands.hats,
                    minPriceDollars: 40
                )
                gearLink(
                    "Men's Western Shirts",
                    keywords: "mens pearl snap western shirt long sleeve",
                    brands: GearBrands.shirts,
                    minPriceDollars: 30
                )
                gearLink(
                    "Women's Western Tops",
                    keywords: "womens western shirt cowgirl",
                    brands: GearBrands.shirts,
                    minPriceDollars: 30
                )
                gearLink(
                    "Leather Belts & Buckles",
                    keywords: "western leather belt full grain",
                    brands: GearBrands.belts,
                    minPriceDollars: 25
                )

                Text("As an Amazon Associate, we earn from qualifying purchases.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func gearLink(
        _ label: String,
        keywords: String,
        brands: [String],
        minPriceDollars: Int
    ) -> some View {
        let url = buildAmazonURL(keywords: keywords, brands: brands, minPriceDollars: minPriceDollars)

        Link(destination: url) {
            HStack {
                Image(systemName: "link")
                    .font(.caption2)
                    .foregroundStyle(WesternTheme.primary)
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }

    /// Builds a curated Amazon search URL with:
    /// keyword + brand allowlist + 4-star filter + price floor + affiliate tag.
    private func buildAmazonURL(keywords: String, brands: [String], minPriceDollars: Int) -> URL {
        let minPriceParam = "p_36%3A\(minPriceDollars * 100)-"

        let brandParam: String
        if brands.isEmpty {
            brandParam = ""
        } else {
            let encoded = brands
                .map { $0.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? $0 }
                .joined(separator: "%7C")
            brandParam = ",p_89%3A\(encoded)"
        }

        let rhFilter = "\(amazonFourStarsAndUpFilter),\(minPriceParam)\(brandParam)"

        var components = URLComponents(string: "https://www.amazon.com/s")!
        components.queryItems = [
            URLQueryItem(name: "k", value: keywords),
            URLQueryItem(name: "rh", value: rhFilter),
            URLQueryItem(name: "s", value: "review-rank"),
            URLQueryItem(name: "tag", value: amazonAffiliateTag)
        ]
        return components.url!
    }
}
