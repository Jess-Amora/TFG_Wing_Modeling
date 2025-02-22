import sys
sys.path.append(r"C:\Program Files\FreeCAD 1.0\bin")  # Path to FreeCAD bin
sys.path.append(r"C:\Program Files\FreeCAD 1.0\lib")  # Path to FreeCAD lib
import FreeCAD as App
import Part
import csv
import os

# Function to read nodes from a .csv file
def read_nodes(file_path):
    nodes = []
    with open(file_path, 'r') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip header
        for row in reader:
            node_id = int(row[0])  # Node ID (not used for geometry but for reference)
            x = float(row[1])     # X coordinate
            y = float(row[2])     # Y coordinate
            z = 0.0               # Assuming 2D, set Z to 0
            nodes.append(App.Vector(x, y, z))
    return nodes

# Function to read CQUAD4 elements from a .csv file
def read_elements(file_path):
    elements = []
    with open(file_path, 'r') as csvfile:
        reader = csv.reader(csvfile)
        next(reader)  # Skip header
        for row in reader:
            element_id = int(row[0])  # Element ID (not used for geometry but for reference)
            node1 = int(row[1]) - 1  # Convert 1-based to 0-based index
            node2 = int(row[2]) - 1
            node3 = int(row[3]) - 1
            node4 = int(row[4]) - 1
            elements.append((node1, node2, node3, node4))
    return elements

# Create geometry in FreeCAD
def create_geometry(nodes, elements, doc):
    for i, (n1, n2, n3, n4) in enumerate(elements):
        # Create a surface (quadrilateral) using four points
        quad = Part.Face(Part.makePolygon([nodes[n1], nodes[n2], nodes[n3], nodes[n4], nodes[n1]]))
        obj = doc.addObject("Part::Feature", f"Quad_{i+1}")
        obj.Shape = quad
    doc.recompute()

def export_to_step(doc, output_path):
    # Set export preferences
    App.ParamGet("User parameter:BaseApp/Preferences/Mod/Part").SetInt("STEPExportSchema", 214)  # AP214 schema
    App.ParamGet("User parameter:BaseApp/Preferences/Mod/Part").SetFloat("STEPExportPrecision", 1e-6)  # High precision

    # Collect objects to export
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::")]
    Part.export(objects, output_path)
    print(f"Model exported as STEP to: {output_path}")
    
# Main script
def main():
    # Paths to input CSV files
    nodes_csv = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\test\nodes.csv"
    elements_csv = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\test\test_surface.csv"

    # Path to output STEP file
    step_output = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\test\output_surface.step"

    # Read data
    nodes = read_nodes(nodes_csv)
    elements = read_elements(elements_csv)

    # Create FreeCAD document
    doc = App.newDocument("SurfaceModel")

    # Generate geometry
    create_geometry(nodes, elements, doc)

    # Export as STEP file
    export_to_step(doc, step_output)

# Execute the script
if __name__ == "__main__":
    main()
