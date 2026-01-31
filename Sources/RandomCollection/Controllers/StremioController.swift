import Vapor
import Fluent

struct StremioController: RouteCollection {
    func boot(routes: any RoutesBuilder) throws {
        routes.get("manifest.json", use: self.manifest)
        routes.get("catalog", ":type", "**", use: self.catalog)
    }

    @Sendable
    func manifest(req: Request) async throws -> Manifest {
        return Manifest(
            id: "com.satanSm0kes.random-collection-addon",
            version: "1.0.0",
            name: "Weekly Franchise",
            description: "Adds a catalog that randomly selects a franchise, rotates weekly",
            resources: [
                "catalog",
            ],
            types: [
                "movie",
                "series"
            ],
            catalogs: [
                CatalogItem(
                    type: "collection",
                    id: "franchise-list",
                    name: "Weekly Selection",
                    extra: [
                        
                    ]
                )
            ],
            idPrefixes: [
                "tvdb:"
            ],
            background: nil,
            logo: nil,
            contactEmail: nil
        )
    }

    func catalog(req: Request) async throws -> CatalogResponse {
        try await checkCache(req.application)
        
        guard let selectedListId = try await req.cache.get("selectedList", as: UUID.self) else {
            throw Abort(.notFound, reason: "No list currently selected")
        }
        
        let entries = try await Entry.query(on: req.db)
            .filter(\.$list.$id == selectedListId)
            .with(\.$list)
            .sort(\.$order)
            .all()
            .map { Meta(id: "tvdb:\($0.tvdbID)", type: $0.type, name: "\($0.title) - \($0.list.tvdbID)", poster: $0.poster) }
        
        return CatalogResponse(metas: entries)
    }
}
