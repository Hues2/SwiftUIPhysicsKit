import Testing
@testable import SwiftUIPhysicsKit

private let eps = 1e-9

private func approxEqual(_ a: Double, _ b: Double, eps: Double = eps) -> Bool {
    abs(a - b) < eps
}

private func approxEqual(_ a: Vector2, _ b: Vector2, eps: Double = eps) -> Bool {
    approxEqual(a.x, b.x, eps: eps) && approxEqual(a.y, b.y, eps: eps)
}

@Test("Vector2 common values")
func vector2_zero() {
    #expect(Vector2.zero == Vector2(0, 0))
}

@Test("Vector2 magnitude and magnitudeSquared")
func vector2_magnitude() {
    let v = Vector2(3, 4)
    #expect(approxEqual(v.magnitudeSquared, 25))
    #expect(approxEqual(v.magnitude, 5))
}

@Test("Vector2 dot product")
func vector2_dot() {
    let a = Vector2(1, 2)
    let b = Vector2(3, 4)
    // 1*3 + 2*4 = 11
    #expect(approxEqual(a.dot(b), 11))
}

@Test("Vector2 normalization")
func vector2_normalized() {
    let v = Vector2(3, 4) // magnitude 5
    let n = v.normalized()
    #expect(approxEqual(n, Vector2(0.6, 0.8)))
    #expect(approxEqual(n.magnitude, 1))
}

@Test("Vector2 normalization returns zero for very small vectors")
func vector2_normalized_smallVector() {
    let tiny = Vector2(1e-15, 1e-15)
    #expect(tiny.normalized() == .zero)
}

@Test("Vector2 addition and subtraction")
func vector2_add_subtract() {
    let a = Vector2(1, 2)
    let b = Vector2(3, 5)
    #expect(a + b == Vector2(4, 7))
    #expect(b - a == Vector2(2, 3))
}

@Test("Vector2 unary minus")
func vector2_unaryMinus() {
    let v = Vector2(3, -5)
    #expect(-v == Vector2(-3, 5))
}

@Test("Vector2 scalar multiply and divide")
func vector2_scalarOps() {
    let v = Vector2(2, -3)
    #expect(v * 2 == Vector2(4, -6))
    #expect(2 * v == Vector2(4, -6))
    #expect(v / 2 == Vector2(1, -1.5))
}

@Test("Vector2 compound assignment operators")
func vector2_compoundOps() {
    var v = Vector2(1, 2)

    v += Vector2(3, 4)
    #expect(v == Vector2(4, 6))

    v -= Vector2(1, 1)
    #expect(v == Vector2(3, 5))

    v *= 2
    #expect(v == Vector2(6, 10))
}
