import Foundation

public struct PhysicsWorld: Sendable {
    public var gravity: Vector2
    public private(set) var bodies: [PhysicsBody]

    public init(
        gravity: Vector2 = Vector2(0, -9.81),
        bodies: [PhysicsBody] = []
    ) {
        self.gravity = gravity
        self.bodies = bodies
    }

    public mutating func addBody(_ body: PhysicsBody) {
        bodies.append(body)
    }

    /// Advances the simulation by `dt` seconds.
    public mutating func step(dt: Double) {
        guard dt > 0 else { return }
        
        for i in bodies.indices {
            // Get the gravity force
            let gravityForce = gravity * bodies[i].mass
            // Get the total force to be applied to the body
            let totalForce = bodies[i].accumulatedForce + gravityForce
            // Calculate the acceleration (a = F / m)
            // Use inverse mass because divisions are more expensive than multiplications
            let acceleration = totalForce * bodies[i].inverseMass
            // Update the body's velocity and position
            bodies[i].velocity += acceleration * dt
            bodies[i].position += bodies[i].velocity * dt
            // Prepare the body for the next step/iteration
            bodies[i].clearForces()
        }
    }
}
