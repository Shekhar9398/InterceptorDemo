
import Foundation

struct Post: Identifiable, Decodable, Hashable {
    let id: Int
    let title: String
    let body: String
}
