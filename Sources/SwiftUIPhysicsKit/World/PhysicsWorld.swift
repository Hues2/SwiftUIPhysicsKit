import Foundation

public struct PhysicsWorld: Sendable {
    public var gravity: Vector2
    public var bounds: WorldBounds?
    public private(set) var bodies: [PhysicsBody]
    
    public init(
        gravity: Vector2 = Vector2(0, -9.81),
        bounds: WorldBounds? = nil,
        bodies: [PhysicsBody] = []
    ) {
        self.gravity = gravity
        self.bounds = bounds
        self.bodies = bodies
    }
    
    public mutating func addBody(_ body: PhysicsBody) {
        bodies.append(body)
    }
    
    /// Advances the simulation by `dt` seconds.
    public mutating func step(dt: Double) {
        guard dt > 0 else { return }
        
        for i in bodies.indices {
            var body = bodies[i]
            stepBody(&body, dt: dt)
            bodies[i] = body
        }
    }
}

// MARK: Step funcitonality for 1 body
private extension PhysicsWorld {
    func stepBody(_ body: inout PhysicsBody, dt: Double) {
        // Get the gravity force
        let gravityForce = gravity * body.mass
        // Get the total force to be applied to the body
        let totalForce = body.accumulatedForce + gravityForce
        // Calculate the acceleration (a = F / m)
        // Use inverse mass because divisions are more expensive than multiplications
        let acceleration = totalForce * body.inverseMass

        // Update the body's velocity and position
        body.velocity += acceleration * dt
        body.position += body.velocity * dt
        // Prepare the body for the next step/iteration
        body.clearForces()

        if let bounds {
            resolveBounds(for: &body, in: bounds)
        }

        applyLinearDamping(to: &body, dt: dt)
    }
}

// MARK: Resolve Bounds
extension PhysicsWorld {
    func resolveBounds(
        for body: inout PhysicsBody,
        in bounds: WorldBounds
    ) {
        let box = body.shape.aabb(at: body.position)
        
        resolveAxis(
            body: &body,
            minEdge: box.min.x,
            maxEdge: box.max.x,
            boundsMin: bounds.min.x,
            boundsMax: bounds.max.x,
            positionKeyPath: \.position.x,
            velocityKeyPath: \.velocity.x
        )
        
        resolveAxis(
            body: &body,
            minEdge: box.min.y,
            maxEdge: box.max.y,
            boundsMin: bounds.min.y,
            boundsMax: bounds.max.y,
            positionKeyPath: \.position.y,
            velocityKeyPath: \.velocity.y
        )
    }
    
    func resolveAxis(
        body: inout PhysicsBody,
        minEdge: Double,
        maxEdge: Double,
        boundsMin: Double,
        boundsMax: Double,
        positionKeyPath: WritableKeyPath<PhysicsBody, Double>,
        velocityKeyPath: WritableKeyPath<PhysicsBody, Double>
    ) {
        // Min side (left / floor)
        if minEdge < boundsMin {
            let penetration = boundsMin - minEdge
            body[keyPath: positionKeyPath] += penetration
            
            if body[keyPath: velocityKeyPath] < 0 {
                body[keyPath: velocityKeyPath] = -body[keyPath: velocityKeyPath] * body.restitution
            }
        }
        
        // Max side (right / ceiling)
        if maxEdge > boundsMax {
            let penetration = maxEdge - boundsMax
            body[keyPath: positionKeyPath] -= penetration
            
            if body[keyPath: velocityKeyPath] > 0 {
                body[keyPath: velocityKeyPath] = -body[keyPath: velocityKeyPath] * body.restitution
            }
        }
    }
}

// MARK: Apply Damping
extension PhysicsWorld {
    func applyLinearDamping(to body: inout PhysicsBody, dt: Double) {
        guard body.linearDamping > 0 else { return }
        let k = max(0, 1 - body.linearDamping * dt)
        body.velocity *= k
    }
}
