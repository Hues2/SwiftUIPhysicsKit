import Testing
@testable import SwiftUIPhysicsKit

@Test("PhysicsBody stores provided shape")
func body_storesShape() {
    let b = PhysicsBody(shape: .circle(radius: 2))
    #expect(b.shape == .circle(radius: 2))
}

@Test("PhysicsBody default shape is circle")
func body_defaultShape() {
    let b = PhysicsBody()
    let defaultShape: ColliderShape = .circle(radius: 10)
    #expect(b.shape == defaultShape)
}
