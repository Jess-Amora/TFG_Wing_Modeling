import gmsh

gmsh.initialize()
gmsh.model.add("test_model")

# Add four points
p1 = gmsh.model.geo.addPoint(0, 0, 0, 0.1)
p2 = gmsh.model.geo.addPoint(1, 0, 0, 0.1)
p3 = gmsh.model.geo.addPoint(1, 1, 0, 0.1)
p4 = gmsh.model.geo.addPoint(0, 1, 0, 0.1)

# Add four lines
l1 = gmsh.model.geo.addLine(p1, p2)
l2 = gmsh.model.geo.addLine(p2, p3)
l3 = gmsh.model.geo.addLine(p3, p4)
l4 = gmsh.model.geo.addLine(p4, p1)

# Add a curve loop and surface
cl = gmsh.model.geo.addCurveLoop([l1, l2, l3, l4])
surface = gmsh.model.geo.addPlaneSurface([cl])

# Synchronize and write to STEP
gmsh.model.geo.synchronize()
gmsh.write("minimal_example.step")
gmsh.finalize()

print("STEP file created: minimal_example.step")
