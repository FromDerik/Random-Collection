import Vapor

struct TVDBLoginResponse: Content {
    struct Data: Content {
        let token: String
    }

    let data: Data
    let status: String
}

struct TVDBListsResponse: Content {
    struct Data: Content {
        let id: Int
        let isOfficial: Bool
    }

    let status: String
    let data: [Data]
}

struct TVDBExtendedListResponse: Content {
    struct Data: Content {
        let id: Int
        let name: String
        let isOfficial: Bool
        let image: String
        let entities: [ListEntity]
    }

    let status: String
    let data: Data
}

struct ListEntity: Content {
    let order: Int
    let seriesId: Int?
    let movieId: Int?
}

struct TVDBMovieSeriesResponse: Content {
    struct Data: Content {
        let id: Int
        let name: String
        let image: String?
    }
    
    let status: String
    let data: Data
}