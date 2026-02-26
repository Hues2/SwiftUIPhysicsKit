import Foundation

// AABB -> Axis-Aligned Bounding Box
public struct AABB: Sendable, Hashable {
    public var min: Vector2
    public var max: Vector2

    public init(min: Vector2, max: Vector2) {
        self.min = min
        self.max = max
    }

    public var size: Vector2 {
        Vector2(max.x - min.x, max.y - min.y)
    }

    public func intersects(_ other: AABB) -> Bool {
        // Separating Axis Test for AABBs
        !(max.x < other.min.x ||
          min.x > other.max.x ||
          max.y < other.min.y ||
          min.y > other.max.y)
    }
}
