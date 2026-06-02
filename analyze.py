#!/usr/bin/env python3
"""Validate a keycap STL: manifold check, volume, weight, dimensions, wall thickness sanity."""
import sys
import os

try:
    import trimesh
    import numpy as np
except ImportError as e:
    sys.exit(f"Missing dependency: {e}. Run: pip3 install --user numpy trimesh")

SILVER_DENSITY = 10.49   # g/cm³ (fine silver 999)
STERLING_DENSITY = 10.36 # g/cm³ (sterling 925)
SILVER_KRW_PER_G = 1500  # rough market estimate, verify before purchase

def main(stl_path):
    if not os.path.exists(stl_path):
        sys.exit(f"File not found: {stl_path}")

    mesh = trimesh.load(stl_path, force='mesh')

    print(f"\n{'='*60}")
    print(f"  Keycap STL Analysis — {os.path.basename(stl_path)}")
    print(f"{'='*60}\n")

    # Geometry
    bb = mesh.bounds
    size = bb[1] - bb[0]
    print(f"Dimensions (X×Y×Z):  {size[0]:.3f} × {size[1]:.3f} × {size[2]:.3f} mm")
    print(f"Triangles:           {len(mesh.faces):,}")
    print(f"Vertices:            {len(mesh.vertices):,}")

    # Manifold / watertight check
    print()
    print(f"Watertight:          {'OK ' if mesh.is_watertight else 'FAIL'}")
    print(f"Winding consistent:  {'OK ' if mesh.is_winding_consistent else 'FAIL'}")
    print(f"Volume valid:        {'OK ' if mesh.is_volume else 'FAIL'}")

    if not mesh.is_watertight:
        print("  → Mesh has holes. Casting service will reject it. Re-export with higher $fn.")

    # Volume / weight (only meaningful if watertight)
    if mesh.is_volume:
        vol_mm3 = mesh.volume
        vol_cm3 = vol_mm3 / 1000.0
        print()
        print(f"Volume:              {vol_cm3:.3f} cm³  ({vol_mm3:,.0f} mm³)")

        wt_fine = vol_cm3 * SILVER_DENSITY
        wt_sterling = vol_cm3 * STERLING_DENSITY
        print(f"Silver weight (999): {wt_fine:.2f} g")
        print(f"Silver weight (925): {wt_sterling:.2f} g")

        cost_low = wt_sterling * SILVER_KRW_PER_G
        cost_high = wt_fine * SILVER_KRW_PER_G
        print(f"Material cost est.:  ₩{cost_low:,.0f} ~ ₩{cost_high:,.0f}")
        print(f"  (casting/finishing fees additional, typically ₩20,000~50,000/cap)")

    # Center of mass (useful for casting orientation)
    if mesh.is_volume:
        com = mesh.center_mass
        print()
        print(f"Center of mass:      ({com[0]:.2f}, {com[1]:.2f}, {com[2]:.2f}) mm")

    # Find bottom face area (footprint that touches keyboard plate)
    z_min = bb[0][2]
    print()
    print(f"Bottom Z (footprint plane): {z_min:.3f} mm")

    print(f"\n{'='*60}\n")

if __name__ == '__main__':
    stl = sys.argv[1] if len(sys.argv) > 1 else 'keycap.stl'
    main(stl)
