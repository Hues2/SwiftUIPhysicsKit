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

// MARK: - applyLinearDamping

@Test("applyLinearDamping reduces velocity using k = max(0, 1 - damping*dt)")
func applyLinearDamping_reducesVelocity() {
    let world = PhysicsWorld(gravity: .zero)
    
    var body = PhysicsBody(
        position: .zero,
        velocity: Vector2(10, -4),
        mass: 1
    )
    body.linearDamping = 2
    
    // k = 1 - 2 * 0.25 = 0.5
    world.applyLinearDamping(to: &body, dt: 0.25)
    
    #expect(abs(body.velocity.x - 5) < eps)
    #expect(abs(body.velocity.y - (-2)) < eps)
}

@Test("applyLinearDamping clamps velocity to zero when k < 0")
func applyLinearDamping_clampsToZero() {
    let world = PhysicsWorld(gravity: .zero)
    
    var body = PhysicsBody(
        position: .zero,
        velocity: Vector2(3, 3),
        mass: 1
    )
    body.linearDamping = 10
    
    // k = max(0, 1 - 10*1) = 0
    world.applyLinearDamping(to: &body, dt: 1)
    
    #expect(body.velocity == .zero)
}


// MARK: - resolveAxis

@Test("resolveAxis pushes body inside min bound and reflects velocity when moving into wall")
func resolveAxis_minSide_reflectsVelocity() {
    let world = PhysicsWorld(gravity: .zero)
    
    var body = PhysicsBody(
        position: Vector2(5, 0),
        velocity: Vector2(-10, 0),
        mass: 1
    )
    body.restitution = 0.5
    
    // minEdge is 2 units outside
    world.resolveAxis(
        body: &body,
        minEdge: -2,
        maxEdge: 2,
        boundsMin: 0,
        boundsMax: 10,
        positionKeyPath: \.position.x,
        velocityKeyPath: \.velocity.x
    )
    
    // position.x += penetration (2)
    #expect(abs(body.position.x - 7) < eps)
    
    // velocity.x = -(-10) * 0.5 = 5
    #expect(abs(body.velocity.x - 5) < eps)
}

@Test("resolveAxis does not reflect velocity if already moving away from wall")
func resolveAxis_minSide_noReflectionWhenMovingAway() {
    let world = PhysicsWorld(gravity: .zero)
    
    var body = PhysicsBody(
        position: Vector2(5, 0),
        velocity: Vector2(10, 0),
        mass: 1
    )
    body.restitution = 0.5
    
    world.resolveAxis(
        body: &body,
        minEdge: -2,
        maxEdge: 2,
        boundsMin: 0,
        boundsMax: 10,
        positionKeyPath: \.position.x,
        velocityKeyPath: \.velocity.x
    )
    
    // Still corrected
    #expect(abs(body.position.x - 7) < eps)
    
    // But velocity unchanged
    #expect(abs(body.velocity.x - 10) < eps)
}


// MARK: - resolveBounds

@Test("resolveBounds corrects both axes and reflects appropriately")
func resolveBounds_correctsBothAxes() {
    let world = PhysicsWorld(gravity: .zero)
    
    let bounds = WorldBounds(
        min: Vector2(0, 0),
        max: Vector2(10, 10)
    )
    
    var body = PhysicsBody(
        position: Vector2(-1, 11),
        velocity: Vector2(-4, 6),
        mass: 1
    )
    body.restitution = 0.5
    
    world.resolveBounds(for: &body, in: bounds)
    
    // Expect body moved inside bounds.
    // Exact values depend on your shape's half-extents.
    // These assume half-extents = (1,1).
    
    #expect(body.position.x > 0)
    #expect(body.position.y < 10)
    
    // Velocity reflected
    #expect(body.velocity.x > 0)
    #expect(body.velocity.y < 0)
}

// MARK: step early return
@Test("step(dt:) returns early when dt <= 0")
func step_returnsEarly_whenDtIsZeroOrNegative() {
    var world = PhysicsWorld(gravity: Vector2(0, -10))
    
    var body = PhysicsBody(
        position: Vector2(1, 2),
        velocity: Vector2(3, 4),
        mass: 1
    )
    
    body.applyForce(Vector2(5, 6))
    
    world.addBody(body)
    
    // Call with dt = 0 (should early return)
    world.step(dt: 0)
    
    let unchanged = world.bodies[0]
    
    #expect(unchanged.position == Vector2(1, 2))
    #expect(unchanged.velocity == Vector2(3, 4))
    #expect(unchanged.accumulatedForce == Vector2(5, 6))
    
    // Also test negative dt
    world.step(dt: -1)
    
    let stillUnchanged = world.bodies[0]
    
    #expect(stillUnchanged.position == Vector2(1, 2))
    #expect(stillUnchanged.velocity == Vector2(3, 4))
    #expect(stillUnchanged.accumulatedForce == Vector2(5, 6))
}

// MARK: Created world has bounds
@Test("step(dt:) calls resolveBounds when world has bounds and body exits them")
func step_callsResolveBounds_whenBoundsExist() {
    // Small world so it's easy to escape
    var world = PhysicsWorld(
        gravity: .zero,
        bounds: WorldBounds(
            min: Vector2(0, 0),
            max: Vector2(10, 10)
        )
    )
    
    // Start near the right edge, moving right
    let body = PhysicsBody(
        position: Vector2(9, 5),
        velocity: Vector2(5, 0),
        mass: 1
    )
    
    world.addBody(body)
    
    // dt large enough to push it past x = 10
    world.step(dt: 1)
    
    let updated = world.bodies[0]
    
    // If resolveBounds ran:
    // 1. Position should have been corrected back inside bounds
    #expect(updated.position.x <= 10)
    
    // 2. Velocity should have flipped (reflected)
    #expect(updated.velocity.x <= 0)
}
