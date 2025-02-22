import FreeCAD as App
import Part
import csv

def read_points(file_path):
    """Reads CSV with columns 'x', 'y', 'z'."""
    points = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            try:
                x = float(row['x'])
                y = float(row['y'])
                z = float(row['z'])
                points.append(App.Vector(x, y, z))
            except (KeyError, ValueError):
                print(f"Skipping invalid point row: {row}")
    return points

def create_spheres(points, doc, radius=0.1):
    """Create small spheres at each point."""
    for i, pt in enumerate(points):
        sphere = Part.makeSphere(radius, pt)  # Create a sphere at the point
        sphere_obj = doc.addObject("Part::Feature", f"Sphere_{i}")  # Add to FreeCAD document
        sphere_obj.Shape = sphere
    doc.recompute()

def export_to_step(doc, output_path):
    """Export all objects in the document to a STEP file."""
    # Set STEP export parameters
    App.ParamGet("User parameter:BaseApp/Preferences/Mod/Part").SetInt("STEPExportSchema", 214)
    App.ParamGet("User parameter:BaseApp/Preferences/Mod/Part").SetFloat("STEPExportPrecision", 1e-6)
    
    # Gather all Part objects
    objects = [obj for obj in doc.Objects if obj.TypeId.startswith("Part::")]
    if not objects:
        print("No Part objects found to export.")
        return
    
    # Export
    Part.export(objects, output_path)
    print(f"Model exported as STEP to: {output_path}")

def main():
    points_csv = "points.csv"  # Path to the CSV file with points
    step_output = "points_model.step"  # Output STEP file path

    points = read_points(points_csv)  # Read points from the CSV file

    doc = App.newDocument("PointsModel")  # Create a new FreeCAD document
    create_spheres(points, doc, radius=0.1)  # Add points as spheres to the document
    export_to_step(doc, step_output)  # Export the spheres to a STEP file

    # Optional: close the document when done if running headless
    # App.closeDocument(doc.Name)

if __name__ == "__main__":
    main()
