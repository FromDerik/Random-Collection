import Vapor

struct CatalogResponse: Content {
    let metas: [Meta]
}

struct Meta: Content {
    let id: String
    let type: String
    let name: String
    let poster: String?
    let posterShape: String?
    let background: String?
    let logo: String?
    let description: String?
    let releaseInfo: String?
    let imdbRating: String?
    let director: [String]?
    let cast: [String]?
    let genres: [String]?
    let videos: [Video]?
    let runtime: String?
    let website: String?
    let language: String?
    let country: String?
    
    init(id: String, type: String, name: String, poster: String? = nil, posterShape: String? = nil, background: String? = nil, logo: String? = nil, description: String? = nil, releaseInfo: String? = nil, imdbRating: String? = nil, director: [String]? = nil, cast: [String]? = nil, genres: [String]? = nil, videos: [Video]? = nil, runtime: String? = nil, website: String? = nil, language: String? = nil, country: String? = nil) {
        self.id = id
        self.type = type
        self.name = name
        self.poster = poster
        self.posterShape = posterShape
        self.background = background
        self.logo = logo
        self.description = description
        self.releaseInfo = releaseInfo
        self.imdbRating = imdbRating
        self.director = director
        self.cast = cast
        self.genres = genres
        self.videos = videos
        self.runtime = runtime
        self.website = website
        self.language = language
        self.country = country
    }
}

struct Video: Content {
    let id: String
    let title: String
    let released: String
    let thumbnail: String
}

