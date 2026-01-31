import NIOSSL
import Fluent
import FluentPostgresDriver
import Leaf
import Vapor
import QueuesFluentDriver

extension DatabaseID {
    static var queues: Self { .init(string: "my_queues_db") }
}

// configures your application
public func configure(_ app: Application) async throws {
    app.http.server.configuration.hostname = Environment.get("HOSTNAME") ?? "localhost"
    app.http.server.configuration.port = Environment.get("PORT").flatMap { Int.init($0) } ?? 6666
    // serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // guard let _ = Environment.get("DATABASE_HOST"),
        // guard let db_username = Environment.get("DATABASE_USERNAME"),
        // let db_password = Environment.get("DATABASE_PASSWORD"),
        // let db_name = Environment.get("DATABASE_NAME") else {
        //     throw Abort(.internalServerError, reason: "Failed to get database environment values")
        // }

    let databaseURL = Environment.get("DATABASE_URI") ?? "postgresql://vapor:vapor@localhost:5432/vapor"
    
    try app.databases.use(.postgres(url: databaseURL), as: .psql)

//    app.migrations.add(CreateTodo())
    app.migrations.add(CreateList())
    app.migrations.add(CreateEntry())

    try await app.autoMigrate()

    app.views.use(.leaf)
    app.caches.use(.memory)
    
    switch app.environment {
    case .development:
        app.logger.logLevel = .debug
        app.middleware.use(CORSMiddleware(), at: .beginning)
    default:
        break
    }

    // fetch data
    try await checkCache(app)
    
    // register scheduled job
//    app.queues.schedule()
//        .minutely()

    // register routes
    try routes(app)
}
