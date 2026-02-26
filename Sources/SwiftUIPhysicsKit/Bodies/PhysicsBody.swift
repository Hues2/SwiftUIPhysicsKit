import Foundation

public struct PhysicsBody: Sendable, Hashable {
    public var position: Vector2
    public var velocity: Vector2

    /// Mass in kg (or arbitrary units). Must be > 0.
    public var mass: Double
    private let minMass: Double = 0.000_001
    
    // Shape
    public var shape: ColliderShape

    /// Accumulated force for the current simulation step.
    public private(set) var accumulatedForce: Vector2 = .zero

    public init(
        position: Vector2 = .zero,
        velocity: Vector2 = .zero,
        mass: Double = 1,
        shape: ColliderShape = .circle(radius: 10)
    ) {
        self.position = position
        self.velocity = velocity
        self.mass = max(mass, minMass) // avoid division by zero
        self.shape = shape
    }

    public var inverseMass: Double {
        1.0 / mass
    }

    public mutating func applyForce(_ force: Vector2) {
        accumulatedForce += force
    }

    public mutating func clearForces() {
        accumulatedForce = .zero
    }
}
