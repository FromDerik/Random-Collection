import Vapor

struct Manifest: Content {
    let id: String
    let version: String
    let name: String
    let description: String
    let resources: [String]
    let types: [String]
    let catalogs: [CatalogItem]
    let idPrefixes: [String]?
    let background: String?
    let logo: String?
    let contactEmail: String?
}

struct CatalogItem: Content {
    let type: String
    let id: String
    let name: String
    let extra: [Extra]?
}

struct Extra: Content {
    let name: String
    let isRequired: Bool?
    let options: [String]?
    let optionsLimit: Int?
}