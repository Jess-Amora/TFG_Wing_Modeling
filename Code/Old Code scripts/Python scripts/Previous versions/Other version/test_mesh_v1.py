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
            points.append(App.Vector(x, y, z))
    return points

# Function to read line elements from a .csv file
def read_line_elements(file_path):
    elements = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            elements.append((int(row['Point1']) - 1, int(row['Point2']) - 1))  # Zero-based index
    return elements

# Function to read surface elements from a .csv file
def read_surface_elements(file_path):
    elements = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            elements.append((
                int(row['Point1']) - 1, 
                int(row['Point2']) - 1, 
                int(row['Point3']) - 1, 
                int(row['Point4']) - 1
            ))  # Zero-based index
    return elements

# Create geometry in FreeCAD
def create_geometry(points, line_elements, surface_elements, doc):
    # Create line elements
    for i, (p1_index, p2_index) in enumerate(line_elements):
        line = Part.LineSegment(points[p1_index], points[p2_index])
        edge = line.toShape()
        obj = doc.addObject("Part::Feature", f"Line_{i}")
        obj.Shape = edge

    # Create surface elements
    for i, (p1, p2, p3, p4) in enumerate(surface_elements):
        quad = Part.Face(Part.makePolygon([points[p1], points[p2], points[p3], points[p4], points[p1]]))
        obj = doc.addObject("Part::Feature", f"Surface_{i}")
        obj.Shape = quad

    doc.recompute()

# Export geometry as STEP file
def export_to_step(doc, output_path):
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::")]
    Part.export(objects, output_path)
    print(f"Model exported as STEP to: {output_path}")

# Main script
def main():
    # File paths
    points_csv = r"mesh\testv8_points.csv"
    line_elements_csv = r"mesh\testv8_line_elements.csv"
    surface_elements_csv = r"mesh\testv8_surface_elements.csv"
    step_output = r"mesh\testv8_output.step"

    # Read data
    points = read_points(points_csv)
    line_elements = read_line_elements(line_elements_csv)
    surface_elements = read_surface_elements(surface_elements_csv)

    # Create FreeCAD document
    doc = App.newDocument("MixedElementsModel")

    # Generate geometry
    create_geometry(points, line_elements, surface_elements, doc)

    # Export to STEP file
    export_to_step(doc, step_output)

if __name__ == "__main__":
    main()
