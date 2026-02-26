import Foundation

/// A lightweight 2D vector type used throughout the engine.
public struct Vector2: Sendable, Hashable {
    public var x: Double
    public var y: Double

    @inlinable
    public init(_ x: Double = .zero, _ y: Double = .zero) {
        self.x = x
        self.y = y
    }
}

// MARK: - Common values

public extension Vector2 {
    static let zero = Vector2(.zero, .zero)
}

// MARK: - Derived values

public extension Vector2 {
    @inlinable var magnitudeSquared: Double { (x * x) + (y * y) }
    @inlinable var magnitude: Double { sqrt(magnitudeSquared) }

    /// Returns a unit-length version of this vector (or `.zero` if it's too small).
    @inlinable func normalized(epsilon: Double = 1e-12) -> Vector2 {
        let m = magnitude
        guard m > epsilon else { return .zero }
        return self / m
    }

    @inlinable func dot(_ other: Vector2) -> Double {
        (x * other.x) + (y * other.y)
    }
}

// MARK: - Operators

public extension Vector2 {
    @inlinable static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x + rhs.x, lhs.y + rhs.y)
    }

    @inlinable static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(lhs.x - rhs.x, lhs.y - rhs.y)
    }

    @inlinable static prefix func - (v: Vector2) -> Vector2 {
        Vector2(-v.x, -v.y)
    }

    @inlinable static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.x * rhs, lhs.y * rhs)
    }

    @inlinable static func * (lhs: Double, rhs: Vector2) -> Vector2 {
        rhs * lhs
    }

    @inlinable static func / (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(lhs.x / rhs, lhs.y / rhs)
    }

    @inlinable static func += (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs + rhs
    }

    @inlinable static func -= (lhs: inout Vector2, rhs: Vector2) {
        lhs = lhs - rhs
    }

    @inlinable static func *= (lhs: inout Vector2, rhs: Double) {
        lhs = lhs * rhs
    }
}
