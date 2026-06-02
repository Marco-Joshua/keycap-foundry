// =====================================================
// Parametric Silver Keycap Library
// Features: hollow, legend engraving, multi-size, 5 profiles
// Units: millimeters
// =====================================================

// ---- Top-level parameters (override via openscad -D) ----
key_units      = 1.0;        // 1, 1.25, 1.5, 1.75, 2, 2.25, 2.75, 6.25
profile        = "cherry";   // "cherry" | "oem" | "sa" | "dsa" | "xda"
row            = 3;          // R1..R4 — only used by sculpted profiles
hollow         = false;
wall_thickness = 1.0;        // outer wall + top wall; minimum castable in 925 silver ≈ 0.6mm
legend         = "";         // "" = no engraving
legend_depth   = 0.45;
legend_size    = 7;
legend_font    = "Helvetica:style=Bold";
cutaway        = false;      // true → cut in half along XZ plane (y>=0 kept)
flat_top       = false;      // true → no dish curvature on top (overrides profile dish)
shrink_compensation = 1.0;   // scale factor: 1.018 ≈ 1.8% upscale for silver casting shrinkage

// ---- Constants ----
unit_pitch     = 19.05;
gap            = 0.95;
cross_w        = 4.10;
cross_t        = 1.27;
cross_d        = 4.0;
stem_wall      = 0.7;        // side wall around the cross slot (perpendicular to arm)
stem_arm_long  = cross_w;                  // 4.10mm — stem arm length = cross arm length (NO end caps)
stem_arm_short = cross_t + 2 * stem_wall;  // 2.67mm — side walls only
stab_off_2u    = 11.94;
stab_off_625   = 50.0;
stab_off_7u    = 57.0;

$fn = 96;

// ---- Profile registry ----
function spec(p, r) =
    p == "cherry" ? [ r == 1 ? 9.4 : r == 2 ? 8.7 : r == 3 ? 7.6 : 7.6,
                      3.0, 35, 0.7, "cyl" ]
  : p == "oem"    ? [ r == 1 ? 11.9 : r == 2 ? 11.0 : r == 3 ? 9.8 : 10.6,
                      3.0, 50, 0.7, "cyl" ]
  : p == "sa"     ? [ r == 1 ? 12.9 : r == 2 ? 12.0 : r == 3 ? 11.4 : 12.6,
                      4.5, 22, 1.5, "sph" ]
  : p == "dsa"    ? [ 7.4, 4.0, 22, 1.0, "sph" ]
  : p == "xda"    ? [ 9.2, 2.5, 26, 0.9, "sph" ]
  :                 [ 9.5, 3.0, 35, 0.7, "cyl" ];

specs    = spec(profile, row);
height   = specs[0];
top_in   = specs[1];
dish_r   = specs[2];
dish_d   = flat_top ? 0 : specs[3];
dish_typ = specs[4];

base_x = key_units * unit_pitch - gap;
base_y = unit_pitch - gap;
top_x  = base_x - 2 * top_in;
top_y  = base_y - 2 * top_in;

// ---- Modules ----
module outer_shell() {
    hull() {
        translate([0, 0, 0.001])         cube([base_x, base_y, 0.002], center=true);
        translate([0, 0, height - 0.001]) cube([top_x, top_y, 0.002], center=true);
    }
}

module inner_void() {
    // Open-bottom cavity with UNIFORM wall_thickness everywhere — top wall follows dish curvature.
    // Construction: base frustum extends up to (height - wall_thickness) at edges, then a
    // shifted dish-shape (offset down by wall_thickness) carves the curve into the ceiling.
    void_top_flat = height - wall_thickness;
    if (void_top_flat > 0.5) {
        difference() {
            hull() {
                translate([0, 0, -0.1])
                    cube([max(base_x - 2*wall_thickness, 1), max(base_y - 2*wall_thickness, 1), 0.001], center=true);
                translate([0, 0, void_top_flat])
                    cube([max(top_x - 2*wall_thickness, 1), max(top_y - 2*wall_thickness, 1), 0.001], center=true);
            }
            if (dish_d > 0) {
                if (dish_typ == "cyl") {
                    translate([0, 0, height - dish_d + dish_r - wall_thickness])
                        rotate([90, 0, 0])
                            cylinder(r=dish_r, h=base_y * 3, center=true);
                } else {
                    translate([0, 0, height - dish_d + dish_r - wall_thickness])
                        sphere(r=dish_r);
                }
            }
        }
    }
}

module dish_neg() {
    if (dish_d > 0) {
        if (dish_typ == "cyl") {
            translate([0, 0, height - dish_d + dish_r])
                rotate([90, 0, 0])
                    cylinder(r=dish_r, h=base_y * 3, center=true);
        } else {
            translate([0, 0, height - dish_d + dish_r])
                sphere(r=dish_r);
        }
    }
}

module mx_cross_neg() {
    // Hollow caps: cross extends nearly to underside of top wall (matches injection-molded keycap norm).
    // Solid caps: keep standard 4mm depth.
    ch = hollow ? (height - dish_d - wall_thickness - 0.4) : cross_d;
    translate([0, 0, -0.05])
        union() {
            translate([-cross_w/2, -cross_t/2, 0])
                cube([cross_w, cross_t, ch + 0.1]);
            translate([-cross_t/2, -cross_w/2, 0])
                cube([cross_t, cross_w, ch + 0.1]);
        }
}

module stem_boss_pos() {
    // "+" stem with side walls only — no end caps at the arm tips.
    // Arm length matches the cross slot exactly; side walls are 0.7mm thick.
    h = height - dish_d - wall_thickness + 0.6;
    union() {
        translate([-stem_arm_long/2, -stem_arm_short/2, 0])
            cube([stem_arm_long, stem_arm_short, h]);
        translate([-stem_arm_short/2, -stem_arm_long/2, 0])
            cube([stem_arm_short, stem_arm_long, h]);
    }
}

module stabilizers(units) {
    off = units >= 7    ? stab_off_7u
        : units >= 6.25 ? stab_off_625
        : units >= 2    ? stab_off_2u
        : 0;
    if (off > 0) {
        translate([ off, 0, 0]) children();
        translate([-off, 0, 0]) children();
    }
}

module legend_neg() {
    if (len(legend) > 0) {
        // place text-cutting prism above the keycap, extending down past dish bottom
        // by `legend_depth`, so engraving depth ≈ legend_depth measured from top surface
        translate([0, 0, height - dish_d - legend_depth])
            linear_extrude(height)
                text(legend, size=legend_size, font=legend_font,
                     halign="center", valign="center");
    }
}

module keycap() {
    difference() {
        union() {
            difference() {
                outer_shell();
                dish_neg();
                if (hollow) inner_void();
            }
            // re-add solid stem boss for hollow caps so MX stem grips
            if (hollow) {
                stem_boss_pos();
                stabilizers(key_units) stem_boss_pos();
            }
        }
        mx_cross_neg();
        stabilizers(key_units) mx_cross_neg();
        legend_neg();
    }
}

scale([shrink_compensation, shrink_compensation, shrink_compensation]) {
    if (cutaway) {
        intersection() {
            keycap();
            translate([0, 100, 0])
                cube([500, 200, 200], center=true);
        }
    } else {
        keycap();
    }
}
