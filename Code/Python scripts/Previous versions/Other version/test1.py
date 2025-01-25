import FreeCAD as App
import Part
import csv
import os

# Function to read .csv file and parse data
def read_csv(file_path):
    points = []
    forces = []
    
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            x = float(row['x'])
            y = float(row['y'])
            z = float(row['z'])
            fx = float(row['ForceX'])
            fy = float(row['ForceY'])
            fz = float(row['ForceZ'])
            points.append(App.Vector(x, y, z))
            forces.append(App.Vector(fx, fy, fz))
    
    return points, forces

# Create FreeCAD objects for points and force arrows
def create_geometry(points, forces, doc):
    # Create a Part object to represent the wing structure
    for i, point in enumerate(points):
        # Add a small sphere at each point for visualization
        sphere = doc.addObject("Part::Sphere", f"Point_{i}")
        sphere.Radius = 0.1  # Small sphere to represent node
        sphere.Placement = App.Placement(point, App.Rotation())
        
        # Add arrows to visualize forces at each point
        force = forces[i]
        arrow = doc.addObject("Part::Feature", f"Force_{i}")
        arrow.Shape = Part.makeCylinder(0.05, force.Length, point, force)
    
    doc.recompute()

# Export geometry as STEP file
def export_to_step(doc, output_path):
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::")]
    Part.export(objects, output_path)
    print(f"Model exported as STEP to {output_path}")

# Main script execution
def main():
    # Path to your .csv file
    csv_file = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\wing_data.csv"
    
    # Check if file exists
    if not os.path.isfile(csv_file):
        print(f"Error: File '{csv_file}' not found.")
        return
    
    # Read CSV and extract points and forces
    points, forces = read_csv(csv_file)
    
    # Create FreeCAD document and geometry
    doc = App.newDocument("WingModel")
    create_geometry(points, forces, doc)
    
    # Export to STEP
    output_path = r"C:\Users\jessa\OneDrive - Universidad Politécnica de Madrid\0. TFG 23-24\Matlab\main\wing_model.step"
    export_to_step(doc, output_path)

# Execute the script
if __name__ == "__main__":
    main()
