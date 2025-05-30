//
//  MovieCardView.swift
//  WhichMovieTonight
//
//  Created by Maxime Tanter on 25/04/2025.
//

import SwiftUI

struct MovieCardView: View {
    @Environment(\.colorScheme) var colorScheme

    let movie: Movie

    @State var counter: Int = 0
    @State var origin: CGPoint = .zero

    var body: some View {
        VStack(spacing: 16) {
            if let url = movie.posterURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case let .success(image):
                        ZStack {
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 350)
                                .cornerRadius(16)
                                .shadow(color: .primary.opacity(0.2), radius: 10)
                                .onPressingChanged { point in
                                    if let point {
                                        origin = point
                                        counter += 1
                                    }
                                }
                                .modifier(RippleEffect(at: origin, trigger: counter))
                        }
                    case .failure:
                        placeHolderPoster
                    @unknown default:
                        placeHolderPoster
                    }
                }
            } else {
                placeHolderPoster
            }

            VStack(spacing: 12) {
                Text(movie.title)
                    .font(.title2.bold())
                    .multilineTextAlignment(.center)

                // Informations OMDB
                if let year = movie.year, let rated = movie.rated {
                    HStack(spacing: 16) {
                        Text(year)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text("•")
                            .foregroundStyle(.secondary)

                        Text(rated)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let runtime = movie.runtime {
                            Text("•")
                                .foregroundStyle(.secondary)

                            Text(runtime)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Note IMDB
                if let imdbRating = movie.imdbRating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)

                        Text(imdbRating)
                            .font(.subheadline)
                            .fontWeight(.semibold)

                        Text("IMDb")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                // Réalisateur et acteurs
                if let director = movie.director {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Directed by \(director)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if let actors = movie.actors {
                    Text(actors)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }

                // Synopsis
                if let overview = movie.overview {
                    Text(overview)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .padding(.top, 4)
                }
            }

            genreTags
        }
        .padding()
        .cornerRadius(24)
        .padding(.horizontal)
        .onAppear {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }

    private var placeHolderPoster: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.2))
            .frame(height: 300)
            .overlay {
                Image(systemName: "film")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.secondary)
            }
    }

    private var genreTags: some View {
        HStack(spacing: 8) {
            ForEach(movie.genres, id: \.self) { genre in
                Text(genre)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    .overlay {
                        Capsule()
                            .stroke(.primary.opacity(0.1))
                    }

                    .shadow(color: .cyan.opacity(0.3), radius: 2, x: 2, y: 2)
            }
        }
    }
}

#Preview {
    MovieCardView(movie: MockMovie.sample)
}

struct StreamingPlatformLogoView: View {
    let platform: StreamingPlatform

    var body: some View {
        Image(platform.icon)
            .resizable()
            .scaledToFit()
            .frame(width: 32, height: 32)
            .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

struct WrapHStack<Content: View>: View {
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: () -> Content

    init(spacing: CGFloat = 8, alignment: HorizontalAlignment = .leading, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        /// Flow layout from SwiftUI-Introspect or custom
        /// Using a LazyVgrid for now
        FlowLayout(spacing: spacing, alignment: alignment, content: content)
    }
}
