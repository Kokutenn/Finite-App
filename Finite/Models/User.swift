import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    let appleId: String
    var productiveYearsRemaining: Int
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case appleId = "apple_id"
        case productiveYearsRemaining = "productive_years_remaining"
        case createdAt = "created_at"
    }
    
    init(id: UUID = UUID(), appleId: String, productiveYearsRemaining: Int, createdAt: Date = Date()) {
        self.id = id
        self.appleId = appleId
        self.productiveYearsRemaining = productiveYearsRemaining
        self.createdAt = createdAt
    }
}
