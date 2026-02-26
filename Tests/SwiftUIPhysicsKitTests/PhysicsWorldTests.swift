import Testing
@testable import SwiftUIPhysicsKit

private let eps = 1e-9 /* (eps = 0.000000001) */

@Test("step(dt:) applies gravity and integrates position/velocity (Euler)")
func step_appliesGravityAndIntegrates() {
    // Use a nice round gravity value for easy math
    var world = PhysicsWorld(gravity: Vector2(0, -10))

    let body = PhysicsBody(
        position: Vector2(0, 0),
        velocity: Vector2(0, 0),
        mass: 1
    )

    world.addBody(body)
    world.step(dt: 1)

    let updatedBody = world.bodies[0]

    // With our current Euler order:
    // a = g = -10
    // v = 0 + a*dt = -10
    // p = 0 + v*dt = -10
    #expect(abs(updatedBody.velocity.y - (-10)) < eps)
    #expect(abs(updatedBody.position.y - (-10)) < eps)
}

@Test("step(dt:) clears accumulated forces and applies F = m*a")
func step_clearsAccumulatedForces() {
    var world = PhysicsWorld(gravity: .zero)

    var body = PhysicsBody(mass: 2)
    body.applyForce(Vector2(4, 0)) // a = F/m = 2, dt=1 => v.x = 2

    world.addBody(body)
    world.step(dt: 1)

    let updatedBody = world.bodies[0]
    // After the step method, the forces get cleared
    #expect(updatedBody.accumulatedForce == .zero)
    #expect(abs(updatedBody.velocity.x - 2) < eps)
}
