//
//  CreateList.swift
//  RandomCollection
//
//  Created by Derik Malcolm on 1/17/26.
//

import Fluent

struct CreateList: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("lists")
            .id()
            .field("tvdb_id", .int, .required)
            .field("name", .string, .required)
            .field("poster_url", .string, .required)
            .unique(on: "tvdb_id")
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("lists").delete()
    }
}

struct CreateEntry: Migration {
    func prepare(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("entries")
            .id()
            .field("tvdb_id", .int, .required)
            .field("title", .string, .required)
            .field("poster_url", .string, .required)
            .field("type", .string, .required)
            .field("list_order", .int, .required)
            .field("list_id", .uuid, .required)
            .create()
    }
    
    func revert(on database: any Database) -> EventLoopFuture<Void> {
        database.schema("entries").delete()
    }
}
