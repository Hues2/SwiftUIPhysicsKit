import SwiftUI

public struct PhysicsWorldDebugView: View {
    @ObservedObject private var runner: PhysicsWorldRunner

    public init(runner: PhysicsWorldRunner) {
        self.runner = runner
    }

    public var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for body in runner.world.bodies {
                    draw(body: body, in: context)
                }
            }
            .onAppear {
                runner.start()
            }
            .onDisappear {
                runner.stop()
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
            context.stroke(
                Path(ellipseIn: rect),
                with: .color(.blue),
                lineWidth: 2
            )

        case .rect(let size):
            let rect = CGRect(
                x: body.position.x - size.x / 2,
                y: body.position.y - size.y / 2,
                width: size.x,
                height: size.y
            )
            context.stroke(
                Path(rect),
                with: .color(.red),
                lineWidth: 2
            )
        }
    }
}

#Preview {
    let bounds = WorldBounds(min: Vector2(0, 0), max: Vector2(300, 600))

    var world = PhysicsWorld(
        gravity: .init(0, 100),
        bounds: bounds
    )

    world.addBody(
        PhysicsBody(
            position: Vector2(150, 200),
            velocity: Vector2(0, 0),
            mass: 1,
            shape: .circle(radius: 25),
            restitution: 0.8,
            linearDamping: 0.001
        )
    )

    let runner = PhysicsWorldRunner(world: world)

    return PhysicsWorldDebugView(runner: runner)
        .frame(width: 300, height: 600)
        .background(.black)
}
