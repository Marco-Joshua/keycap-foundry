#!/usr/bin/env python3
"""Scan STL files, run trimesh analysis, write manifest.json."""
import json, os
import trimesh

ROOT = os.path.dirname(__file__)
SILVER_DENSITY = 10.49

# (path-relative-to-root, group, label, order)
ITEMS = [
    ('out/flat_1u_hollow.stl',           'flat',    'Hollow 1.0mm wall', 0),
    ('out/flat_1u_hollow_thin.stl',      'flat',    'Hollow 0.8mm wall', 1),
    ('out/flat_cutaway_hollow.stl',      'section', 'Hollow 1.0mm 단면', 0),
    ('out/flat_cutaway_hollow_thin.stl', 'section', 'Hollow 0.8mm 단면', 1),

    ('production/ESC_1u_flat_hollow_1.0mm_design.stl', 'esc', 'ESC 1.0mm (design)', 0),
    ('production/ESC_1u_flat_hollow_1.0mm_cast.stl',   'esc', 'ESC 1.0mm (cast 1.8%↑)', 1),
    ('production/ESC_1u_cutaway.stl',                  'esc', 'ESC 1.0mm 단면', 2),
    ('production/ESC_1u_flat_hollow_0.8mm_design.stl', 'esc', 'ESC 0.8mm (design)', 3),
    ('production/ESC_1u_flat_hollow_0.8mm_cast.stl',   'esc', 'ESC 0.8mm (cast)', 4),
    ('production/ESC_1u_cutaway_0.8mm.stl',            'esc', 'ESC 0.8mm 단면', 5),
]

items = []
for relpath, group, label, order in ITEMS:
    path = os.path.join(ROOT, relpath)
    if not os.path.exists(path):
        print(f'  skip (missing): {relpath}')
        continue
    mesh = trimesh.load(path, force='mesh')
    bb = mesh.bounds
    size = bb[1] - bb[0]
    vol_cm3 = mesh.volume / 1000.0 if mesh.is_volume else 0
    weight = vol_cm3 * SILVER_DENSITY
    items.append({
        'file': relpath,
        'group': group,
        'label': label,
        'order': order,
        'size_mm': [round(float(s), 2) for s in size],
        'volume_cm3': round(vol_cm3, 3),
        'weight_g': round(weight, 2),
        'watertight': bool(mesh.is_watertight),
    })

items.sort(key=lambda x: (x['group'], x['order']))
out_path = os.path.join(ROOT, 'manifest.json')
with open(out_path, 'w') as f:
    json.dump(items, f, ensure_ascii=False, indent=2)
print(f'Wrote {len(items)} entries to {out_path}')
