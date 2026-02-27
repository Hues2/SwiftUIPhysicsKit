import SwiftUI

@MainActor
final class PhysicsWorldSystem {
    private(set) var world: PhysicsWorld
    private var lastUpdate = Date.now.timeIntervalSinceReferenceDate
    
    init(world: PhysicsWorld) {
        self.world = world
    }
    
    
    func update(date: TimeInterval) {
        let delta = date - lastUpdate
        self.lastUpdate = date

        // Clamp dt to avoid huge jumps (e.g. when preview pauses)
        let clampedDt = min(max(delta, 0), 1.0 / 15.0)
        world.step(dt: clampedDt)
        
    }
}

public struct PhysicsWorldDebugView: View {
    @State private var physicsWorldSystem: PhysicsWorldSystem
    @State private var lastDate: Date?

    public init(world: PhysicsWorld) {
        self._physicsWorldSystem = State(initialValue: PhysicsWorldSystem(world: world))
    }

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                // Step the simulation
                physicsWorldSystem.update(date: timeline.date.timeIntervalSinceReferenceDate)

                // Draw bodies
                for body in physicsWorldSystem.world.bodies {
                    draw(body: body, in: context)
                }

                // Optional: draw world bounds
                if let bounds = physicsWorldSystem.world.bounds {
                    let rect = CGRect(
                        x: bounds.min.x,
                        y: bounds.min.y,
                        width: bounds.max.x - bounds.min.x,
                        height: bounds.max.y - bounds.min.y
                    )
                    context.stroke(Path(rect), with: .color(.red), lineWidth: 10)
                }
            }
        }
    }

    private func draw(body: PhysicsBody, in context: GraphicsContext) {
        switch body.shape {
        case .circle(let radius):
            let rect = CGRect(
                x: body.position.x - radius,
                y: body.position.y - radius,
                width: radius * 2,
                height: radius * 2
            )
            context.stroke(Path(ellipseIn: rect), with: .color(.blue), lineWidth: 2)

        case .rect(let size):
            let rect = CGRect(
                x: body.position.x - size.x / 2,
                y: body.position.y - size.y / 2,
                width: size.x,
                height: size.y
            )
            context.stroke(Path(rect), with: .color(.red), lineWidth: 2)
        }
    }
}

#Preview {
    let bounds = WorldBounds(min: Vector2(0, 0), max: Vector2(350, 650))

    var world = PhysicsWorld(
        gravity: Vector2(0, 250), // NOTE: SwiftUI y+ goes DOWN, so positive gravity falls down visually
        bounds: bounds
    )

    world.addBody(
        PhysicsBody(
            position: Vector2(150, 80),
            velocity: Vector2(.zero, .zero),
            mass: 1,
            shape: .circle(radius: 20),
            restitution: 0.8,
            linearDamping: 0.03
        )
    )

    return PhysicsWorldDebugView(world: world)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
}
