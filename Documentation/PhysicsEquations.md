# SwiftUIPhysicsKit – Physics Reference

1️⃣ Newton’s Second Law

F = m * a
a = F / m

Engine form:

a = F * inverseMass
where inverseMass = 1 / m


2️⃣ Semi-Implicit (Symplectic) Euler Integration

Velocity update:

v' = v + a * dt

Position update:

p' = p + v * dt

Note: Position uses the updated velocity.


3️⃣ Velocity Reflection (World Bounds Collision)

When a body collides with a world boundary on one axis:

v' = -v * e

Where:

v = velocity component on that axis

e = restitution (0 = no bounce, 1 = perfect bounce)


4️⃣ Linear Damping

Applied once per step:

v' = v * max(0, 1 - d * dt)

Where:

d = linear damping coefficient

dt = timestep

Ensures velocity gradually decreases over time
