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

def read_elements(file_path):
    """Reads CSV with columns 'Point1', 'Point2'."""
    elements = []
    with open(file_path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            try:
                p1 = int(row['Point1']) - 1
                p2 = int(row['Point2']) - 1
                elements.append((p1, p2))
            except (KeyError, ValueError):
                print(f"Skipping invalid line row: {row}")
    return elements

def create_geometry(points, elements, doc, create_vertices=False):
    """Create edges from point indices. Optionally create separate vertices."""
    edges = []
    n_points = len(points)
    
    # Create edges
    for i, (p1_index, p2_index) in enumerate(elements):
        if p1_index < 0 or p1_index >= n_points or p2_index < 0 or p2_index >= n_points:
            print(f"Warning: Invalid element {i} references out-of-range index.")
            continue
        line = Part.LineSegment(points[p1_index], points[p2_index])
        edges.append(line.toShape())
    
    # Combine edges into a single compound
    if edges:
        compound = Part.makeCompound(edges)
        compound_obj = doc.addObject("Part::Feature", "AllEdges")
        compound_obj.Shape = compound
    
    # Optionally create vertices (for debugging or specific workflows)
    if create_vertices:
        for i, pt in enumerate(points):
            vtx_shape = Part.Vertex(pt)
            vtx_obj = doc.addObject("Part::Feature", f"Vertex_{i}")
            vtx_obj.Shape = vtx_shape

    doc.recompute()

def export_to_step(doc, output_path):
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
    points_csv = "..\output\points.csv"
    elements_csv = "..\output\lines.csv"
    step_output = "..\\..\\Freecad\output_model.step"

    points = read_points(points_csv)
    elements = read_elements(elements_csv)

    doc = App.newDocument("GeometryModel")
    create_geometry(points, elements, doc, create_vertices=True)  # toggle as needed
    export_to_step(doc, step_output)

    # Optional: close the document when done if running headless
    # App.closeDocument(doc.Name)

if __name__ == "__main__":
    main()
