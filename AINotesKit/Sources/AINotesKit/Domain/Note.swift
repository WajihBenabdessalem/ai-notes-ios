import Foundation

/// Une note utilisateur, telle que manipulée par le domaine (indépendante de tout format réseau).
public struct Note: Identifiable, Codable, Equatable, Hashable, Sendable {
    public let id: UUID
    public var title: String
    public var content: String
    public var createdAt: Date

    public init(id: UUID = UUID(), title: String, content: String, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdAt = createdAt
    }
}
