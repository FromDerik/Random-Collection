//
//  List.swift
//  RandomCollection
//
//  Created by Derik Malcolm on 1/17/26.
//

import Fluent
import struct Foundation.UUID

//enum EntryType: String, Codable {
//    case movie, series, unknown
//}

final class List: Model, @unchecked Sendable {
    static let schema = "lists"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "tvdb_id")
    var tvdbID: Int
    
    @Field(key: "name")
    var name: String
    
    @Field(key: "poster_url")
    var poster: String
    
    init(id: UUID? = nil, tvdbID: Int, name: String, poster: String) {
        self.id = id
        self.tvdbID = tvdbID
        self.name = name
        self.poster = poster
    }
    
    init() { }
}

final class Entry: Model, @unchecked Sendable {
    static let schema = "entries"
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "tvdb_id")
    var tvdbID: Int
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "poster_url")
    var poster: String
    
    @Field(key: "list_order")
    var order: Int
    
    @Field(key: "type")
    var type: String
    
    @Parent(key: "list_id")
    var list: List
    
    init(id: UUID? = nil, tvdbID: Int, title: String, poster: String, order: Int, type: String, listId: List.IDValue) {
        self.id = id
        self.tvdbID = tvdbID
        self.title = title
        self.poster = poster
        self.type = type
        self.order = order
        self.$list.id = listId
    }
    
    init() {}
}
