import Testing
@testable import SwiftUIPhysicsKit

@Test("AABB intersection works")
func aabb_intersects() {
    let a = AABB(min: Vector2(0, 0), max: Vector2(1, 1))
    let b = AABB(min: Vector2(0.5, 0.5), max: Vector2(2, 2))
    let c = AABB(min: Vector2(2.1, 2.1), max: Vector2(3, 3))

    #expect(a.intersects(b) == true)
    #expect(a.intersects(c) == false)
}

@Test("Circle AABB at position")
func colliderShape_circleAABB() {
    let shape: ColliderShape = .circle(radius: 2)
    let box = shape.aabb(at: Vector2(10, 10))
    #expect(box.min == Vector2(8, 8))
    #expect(box.max == Vector2(12, 12))
}

@Test("Rect AABB assumes center position")
func colliderShape_rectAABB() {
    let shape: ColliderShape = .rect(size: Vector2(4, 6)) // half = (2,3)
    let box = shape.aabb(at: Vector2(10, 10))
    #expect(box.min == Vector2(8, 7))
    #expect(box.max == Vector2(12, 13))
}

@Test("Get AABB size")
func colliderShape_AABBSize() {
    let shapeSize = Vector2(4, 6)
    let shape: ColliderShape = .rect(size: shapeSize)
    let box = shape.aabb(at: Vector2(10, 10))    
    #expect(box.size == shapeSize)
}
