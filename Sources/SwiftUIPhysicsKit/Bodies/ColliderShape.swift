import Foundation

public enum ColliderShape: Sendable, Hashable {
    case circle(radius: Double)
    case rect(size: Vector2) // width = x, height = y
}
