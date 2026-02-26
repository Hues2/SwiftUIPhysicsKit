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
            // 1) Compute acceleration from forces + gravity            
            var body = bodies[i]

            let gravityForce = gravity * body.mass
            let totalForce = body.accumulatedForce + gravityForce
            let acceleration = totalForce * body.inverseMass

            // 2) Integrate (Euler)
            body.velocity += acceleration * dt
            body.position += body.velocity * dt

            // 3) Clear forces for next step
            body.clearForces()

            bodies[i] = body
        }
    }
}
