import sys
sys.path.append(r"C:\Program Files\FreeCAD 1.0\bin")  # Path to FreeCAD bin
sys.path.append(r"C:\Program Files\FreeCAD 1.0\lib")  # Path to FreeCAD lib
import FreeCAD as App
import Part
import csv

# Function to read points from a .csv file
def read_points(file_path):
    points = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            x = float(row['x'])
            y = float(row['y'])
            z = float(row['z'])
            points.append(App.Vector(x, y, z))  # Convert x, y, z into FreeCAD vectors
    return points

# Function to create geometry for points only
def create_geometry_for_points(points, doc):
    for i, point in enumerate(points):
        # Create a FreeCAD vertex for each point
        vertex = Part.Vertex(point)
        obj = doc.addObject("Part::Feature", f"Point_{i}")
        obj.Shape = vertex  # Assign the vertex shape to the object
    doc.recompute()

# Export points geometry as a STEP file
def export_to_step(doc, output_path):
    # Filter objects of type Part::Feature (points in this case)
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::Feature")]
    Part.export(objects, output_path)
    print(f"Points exported as STEP to: {output_path}")

# Main script
def main():
    # File paths
    points_csv = r"output\points.csv"  # Path to the points CSV file
    step_output = r"..\Freecad\points_output.step"  # Output STEP file path

    # Read points data from CSV
    points = read_points(points_csv)

    # Create FreeCAD document
    doc = App.newDocument("PointsOnlyModel")

    # Generate geometry for points only
    create_geometry_for_points(points, doc)

    # Export points to STEP file
    export_to_step(doc, step_output)

if __name__ == "__main__":
    main()
