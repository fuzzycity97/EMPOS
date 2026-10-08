import os
import trimesh

cleaned_models = []

for root, dirs, files in os.walk('assets/models'):
    for f in files:
        if f.endswith('.glb'):
            path = os.path.join(root, f)
            try:
                scene = trimesh.load(path)
                if not isinstance(scene, trimesh.Scene):
                    continue
                
                # Check if there are multiple geometries
                if len(scene.geometry) <= 1:
                    continue
                
                geoms_to_keep = {}
                cubes_removed = []
                quads_removed = []
                
                for name, g in scene.geometry.items():
                    n_faces = len(g.faces)
                    n_verts = len(g.vertices)
                    
                    # Detect 12-face cube (6 sides * 2 triangles) with 8 to 36 vertices
                    if n_faces == 12 and n_verts in (8, 24, 36):
                        cubes_removed.append((name, n_verts, n_faces, g.bounds.tolist()))
                        continue
                    
                    # Detect 2-face quad (shadow plane) with 4 vertices
                    if n_faces == 2 and n_verts == 4:
                        quads_removed.append((name, n_verts, n_faces))
                        continue
                        
                    geoms_to_keep[name] = g
                
                if cubes_removed or quads_removed:
                    print(f"[{path}]")
                    if cubes_removed:
                        print(f"  Removed CUBES: {cubes_removed}")
                    if quads_removed:
                        print(f"  Removed QUADS: {quads_removed}")
                    
                    # Reconstruct scene
                    new_scene = trimesh.Scene()
                    for name, g in geoms_to_keep.items():
                        new_scene.add_geometry(g, node_name=name, geom_name=name)
                    
                    # Export cleaned GLB
                    new_scene.export(path, file_type='glb')
                    cleaned_models.append(path)
            except Exception as e:
                print(f"Error on {path}: {e}")

print(f"\nDone! Cleaned {len(cleaned_models)} GLB models.")
