import trimesh

FILES = [
    'assets/models/orthopedics/tibia_fibula.glb',
    'assets/models/orthopedics/humerus.glb',
    'assets/models/cardiology/aortic_arch.glb',
    'assets/models/ent/paranasal_sinuses.glb',
    'assets/models/ophthalmology/extraocular_muscles.glb',
    'assets/models/ophthalmology/stargardt_macula.glb',
    'assets/models/urology/urinary_system.glb',
]

for path in FILES:
    try:
        scene = trimesh.load(path)
        if not isinstance(scene, trimesh.Scene):
            print(f"Skipping {path}: not a scene")
            continue
        
        geoms_to_keep = {}
        removed = []
        for name, g in scene.geometry.items():
            n_faces = len(g.faces)
            n_verts = len(g.vertices)
            
            # Cube (12 faces, 8-36 verts) or Shadow plane (<=2 faces, <=4 verts)
            if (n_faces == 12 and n_verts in (8, 24, 36)) or (n_faces <= 2 and n_verts <= 4):
                removed.append(f"{name} (v:{n_verts}, f:{n_faces})")
            else:
                geoms_to_keep[name] = g
                
        if removed:
            print(f"[{path}] Removing {len(removed)} artifacts: {removed}")
            new_scene = trimesh.Scene()
            for name, g in geoms_to_keep.items():
                new_scene.add_geometry(g, node_name=name, geom_name=name)
            new_scene.export(path, file_type='glb')
            print(f"[{path}] Cleaned successfully, kept {len(geoms_to_keep)} meshes.")
        else:
            print(f"[{path}] No cube artifacts found.")
    except Exception as e:
        print(f"Error on {path}: {e}")

print("Done targeted cleaning.")
