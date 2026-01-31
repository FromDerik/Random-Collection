import Vapor

let tvdbBaseURL = "https://api4.thetvdb.com/v4"

public func checkCache(_ app: Application) async throws {
    let env = Environment.get("FETCH_DATA") ?? "0"
    let fetch = Bool(env) ?? false

    if !fetch { return }
    
    if try await List.query(on: app.db).count() == 0 {
        try await fetchData(app)
    }
    
    if try await app.cache.get("selectedList", as: UUID.self) == nil {
        try await selectRandomList(app: app)
    }
}

func fetchData(_ app: Application) async throws {
    
    var token = try await app.cache.get("authToken", as: String.self)

    if token == nil {
        try await getAuthToken(app)
        token = try await app.cache.get("authToken", as: String.self)
    }

    guard let token = token else {
        throw Abort(.internalServerError, reason: "Error getting Auth Token")
    }

    for page in 0...50 {
        let listResponse = try await app.client.get("\(tvdbBaseURL)/lists") { req in
            try req.query.encode(["page": page])
            req.headers.contentType = .json
            req.headers.bearerAuthorization = BearerAuthorization(token: token)
        }

        let lists = try listResponse.content.decode(TVDBListsResponse.self)
        let filtered = lists.data.filter { $0.isOfficial }
        
        for list in filtered {
            let extendedResponse = try await app.client.get("\(tvdbBaseURL)/lists/\(list.id)/extended") { req in
                req.headers.contentType = .json
                req.headers.bearerAuthorization = BearerAuthorization(token: token)
            }

            let extended = try extendedResponse.content.decode(TVDBExtendedListResponse.self)
            app.logger.debug("status: \(extended.status)")
            app.logger.debug("Got list \(extended.data.id)")
            
//            if let savedList = try await List.query(on: app.db).filter(\.$tvdbID, .equal, extended.data.id).first() {
//                savedList.name = extended.data.name
//                savedList.poster = extended.data.image
//                savedList.tvdbID = extended.data.id
//                
//                try await savedList.update(on: app.db)
//            } else {
                let listModel = List(tvdbID: extended.data.id, name: extended.data.name, poster: extended.data.image)
                try await listModel.save(on: app.db)
                app.logger.debug("Saved list \(listModel.tvdbID) to db")
//            }
            
            let sortedEntities = extended.data.entities.sorted { $0.order < $1.order }
            
            for entity in sortedEntities {
                var urlString = ""
                var type = ""
                
                if let movieId = entity.movieId {
                    urlString = "/movies/\(movieId)"
                    type = "movie"
                } else if let seriesId = entity.seriesId {
                    urlString = "/series/\(seriesId)"
                    type = "series"
                }
                
                let movieSeriesResponse = try await app.client.get(URI(string: tvdbBaseURL + urlString)) { req in
                    req.headers.contentType = .json
                    req.headers.bearerAuthorization = BearerAuthorization(token: token)
                }
                
                let response = try movieSeriesResponse.content.decode(TVDBMovieSeriesResponse.self).data
                
                let entry = Entry(tvdbID: response.id, title: response.name, poster: response.image ?? "", order: entity.order, type: type, listId: try listModel.requireID())
                try await entry.save(on: app.db)
                
                app.logger.debug("Saved list entry for list \(listModel.tvdbID)")
                
                try await app.cache.set("cacheUpdated", to: true)
            }
        }
    }
    
    try await selectRandomList(app: app)
}

public func selectRandomList(app: Application) async throws {
    let lists = try await List.query(on: app.db).all()
    guard let random = lists.randomElement() else {
        throw Abort(.internalServerError, reason: "Could not get random list")
    }

    let expiresAfter = Environment.get("REFRESH_AFTER") ?? "604800"
    let int = Int(expiresAfter) ?? 604800
    
    try await app.cache.set("selectedList", to: random.id, expiresIn: .seconds(int))
}

private func getAuthToken(_ app: Application) async throws {
    guard let apiKey = Environment.get("TVDB_API_KEY") else { 
        throw Abort(.notFound, reason: "No API key provided")
    }

    app.logger.debug("API key retreived from env")

    let loginResponse = try await app.client.post("\(tvdbBaseURL)/login") { req in
        req.headers.contentType = .json
        req.headers.add(name: "accept", value: "application/json")
        try req.content.encode(["apiKey": apiKey])
    }

    let token = try loginResponse.content.decode(TVDBLoginResponse.self).data.token

    app.logger.debug("Auth Token retrieved")

    try await app.cache.set("authToken", to: token, expiresIn: .days(30))
}
