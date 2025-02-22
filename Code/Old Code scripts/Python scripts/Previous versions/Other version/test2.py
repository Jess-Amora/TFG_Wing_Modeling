import FreeCAD as App
import Part
import csv
import os

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

# Function to read elements from a .csv file
def read_elements(file_path):
    elements = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            elements.append((int(row['Point1']) - 1, int(row['Point2']) - 1))  # Zero-based index
    return elements

# Create geometry in FreeCAD
def create_geometry(points, elements, doc):
    for i, (p1_index, p2_index) in enumerate(elements):
        # Create line between points
        line = Part.LineSegment(points[p1_index], points[p2_index])
        edge = line.toShape()
        obj = doc.addObject("Part::Feature", f"Edge_{i}")
        obj.Shape = edge
    doc.recompute()

# Export geometry as STEP file
def export_to_step(doc, output_path):
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::")]
    Part.export(objects, output_path)
    print(f"Model exported as STEP to: {output_path}")

# Main script
def main():
    # Paths to input CSV files
    points_csv = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\points.csv"  # Replace with actual path
    elements_csv = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\elements.csv"  # Replace with actual path

    # Path to output STEP file
    step_output = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\output_model.step"  # Replace with actual path

    # Read data
    points = read_points(points_csv)
    elements = read_elements(elements_csv)

    # Create FreeCAD document
    doc = App.newDocument("AssemblyModel")

    # Generate geometry
    create_geometry(points, elements, doc)

    # Export as STEP file
    export_to_step(doc, step_output)

# Execute the script
if __name__ == "__main__":
    main()
