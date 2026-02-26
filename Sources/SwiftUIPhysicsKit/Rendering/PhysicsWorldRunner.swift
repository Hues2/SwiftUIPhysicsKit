import SwiftUI

@MainActor
public final class PhysicsWorldRunner: ObservableObject {
    @Published public var world: PhysicsWorld

    private var displayLink: CADisplayLink?

    public init(world: PhysicsWorld) {
        self.world = world
    }

    public func start() {
        displayLink = CADisplayLink(target: self, selector: #selector(step))
        displayLink?.add(to: .main, forMode: .common)
    }

    public func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func step() {
        let dt = displayLink?.duration ?? (1.0 / 60.0)
        world.step(dt: dt)
        objectWillChange.send()
    }
}
