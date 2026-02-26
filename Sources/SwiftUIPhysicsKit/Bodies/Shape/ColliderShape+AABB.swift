import Foundation

public extension ColliderShape {
    func aabb(at position: Vector2) -> AABB {
        switch self {
        case .circle(let r):
            return AABB(
                min: Vector2(position.x - r, position.y - r),
                max: Vector2(position.x + r, position.y + r)
            )

        // Rect AABB assumes body position is shape center
        case .rect(let size):
            let half = size / 2
            return AABB(
                min: position - half,
                max: position + half
            )
        }
    }
}
