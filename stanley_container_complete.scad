mode = "both";   // [boxonly:Box only, baseonly:Base only, both:Both]
/* [General] */
// How many horizontal slots?
x_length = 4;       // min/max: [1:10]
// How many vertical slots?
y_length = 2;       // min/max: [1:4]
// X direction dividers
x_dividers = 1;
// X dividers to skip (e.g., [1,3])
x_skips = [];       //Dividers to skip, e.g. [1, 3]
// Y direction dividers
y_dividers = 1;
// Y dividers to skip (e.g., [2])
y_skips = [];
// How many boxes per stack?
boxes_in_stack = 1;
// What type of Stanley container?
short_box = true;  // [false:Tall,true:Short]
// Reduce divider height? (If dividers could hit the alignment pegs above it)
reduce_divider_height = true; // [false:No,true:Yes]
// Base nubs
base_mid_nubs = false; // [false:Corners only,true:All]
/* [Flip-up] */
// Add flip up section?
flip_up = true;         //[false:No,true:Yes]
// Flip-up length percentage
flip_size = 0.75;       // min/max: [0.1:1]
// Add grab hole?
flip_grab = true;       //[false:No,true:Yes]
// Horizontal orientation?
flip_horiz = true;      //[false:Axis on Y,true:Axis on X]
// Grab hole diameter (in multiple of compartment width)
flip_grab_d = 1.15;
// Grab hole offset (edge of hole to edge of box, should be negative)
flip_grab_off = -10;
/* [Advanced] */
// Box corner radius
corner_radius = 3;
// Wall thickness
wall_thickness = 1.35;   //0.05
// Box piece base thickness
box_base_height = 2;
// Base piece thickness
base_height = 1;
// Only print base perimeters
print_base_centers = false; // [false:Edges only,true:Full base];
// Solid box (for vase mode)?
solidbox = false;   // [false:No,true:Yes]

/* [Hidden] */
//Measured parameters- don't change these unless you need to fine-tune the design.
cyl_ht = 2.5;                 //Nub height off of base
cyl_diam = 17;              //Diameter of nub cylinder
x_l_perslot = 40;           //Spacing of the x-axis slots
y_l_perslot = 55;           //Spacing of y-axis slots
x_shrink = 0.70;             //Removes this amount from the total x dimension. Makes it easier to insert/remove bins.
y_shrink = 0.70;             //Removes this amount from the total y dimension. Makes it easier to insert/remove bins.
// Flip-up tolerance (gap between flip box and main box)
flip_tol = 0.3;
// Flip-up pip tolerance (gap between flip peg and hole)
flip_pip_tol = 0.2;

use <Divided_box.scad>;
use <Flip_compartment.scad>;
$fn = $preview ? 32 : 120;


wall = wall_thickness;
height = box_ht(boxes_in_stack, base_height, short_box);
gap = 2*wall + 1;             //Slot in the base nubs; slightly larger than the wall
x_totalsize = x_l_perslot * x_length - x_shrink;    //Total x width
y_totalsize = y_l_perslot * y_length - y_shrink;    //Total y width
x_l_perslot_eff = x_totalsize / x_length;           //Effective X per-slot value
y_l_perslot_eff = y_totalsize / y_length;           //Effective Y per-slot value

crad=corner_radius;
divider_height = reduce_divider_height? height-cyl_ht-1.5:height;
middle = base_mid_nubs;
int_crad = crad - wall;     //Internal corner thickness

function box_ht(num_per_stack, base_ht, half_t_box) =
    let(full_ht = 91)
    let(half_ht = 41)
    let(tot_ht = (half_t_box)? half_ht:full_ht)
    tot_ht/num_per_stack - base_ht;

module stanley_container(x_div, y_div, height, divider_height)
{
    if (flip_up == false)
    {
        divided_box(x_totalsize, y_totalsize, height,
            box_base_height,
            wall_thickness,
            crad,
            x_dividers,
            y_dividers,
            divider_height,
            x_skips, y_skips);
    }
    else
    {
        //The divided box command is repeated because you actually make two boxes-
        //the "base" box that holds everything, and the flipup box.
        
        interior = [x_totalsize - 2*wall_thickness, y_totalsize - 2*wall_thickness, height - wall_thickness];
        flipsize_std = [interior.x - 2*flip_tol, interior.z - 2*flip_tol, flip_size*(interior.y - (interior.z/2))];
        flipsize_rot = [interior.y - 2*flip_tol, interior.z - 2*flip_tol, flip_size*(interior.x - (interior.z/2))];
        flipsize = flip_horiz? flipsize_std:flipsize_rot;
        rot_ang = flip_horiz? 0:-90;
        axis_offset_std = [0, -0.5*(interior.y-flipsize.y)+flip_tol, base_height + flip_tol + 0.5*flipsize.y ];
        axis_offset_rot = [-0.5*(interior.x-flipsize.y)+flip_tol, 0, base_height + flip_tol + 0.5*flipsize.y ];
        axis_offset = flip_horiz?axis_offset_std:axis_offset_rot;
        
        flip_div_height = reduce_divider_height?flipsize.z-cyl_ht-1.5:flipsize.z;
        
        difference()
        {
            divided_box(x_totalsize, y_totalsize, height,
                        box_base_height,
                        wall_thickness,
                        crad,
                        0,
                        0,
                        divider_height,
                        x_skips, y_skips);
            translate(axis_offset)
                rotate([0,0,rot_ang])
                    flip_compartment("remove",
                                flipsize.x,
                                flipsize.y,
                                flipsize.z,
                                wall_thickness,
                                0.4 * height,
                                0.1,
                                wall_thickness,
                                crad,
                                0, 0,
                                1,
                                [], [],
                                flip_pip_tol,
                                [flip_grab == true? flip_grab_off:0, flip_grab_d]);
        }
        color("blue")
        translate(axis_offset)
            rotate([0,0,rot_ang])
                flip_compartment("add",
                            flipsize.x,
                            flipsize.y,
                            flipsize.z,
                            wall_thickness,
                            0.4 * height,
                            0.1,
                            wall_thickness,
                            crad,
                            x_dividers, y_dividers,
                            flip_div_height,
                            [], [],
                            flip_pip_tol,
                            [flip_grab == true? flip_grab_off:0, flip_grab_d]);
    }
}
module one_bump()
{
    cylinder(base_height+cyl_ht,cyl_diam/2,(cyl_diam/2)*0.95,$fn=25);
}

module stanley_base() {
    //Don't forget that the nubs must remain centered on the actual X and Y perslot values. Don't include the shrink parameters when calculating the nubs spacing, but do use it to space out where the first one starts.
    translate([-x_totalsize/2, -y_totalsize/2, 0])
    {
        ht = base_height;
        if (print_base_centers)
            smooth_rect(x_totalsize, y_totalsize, ht, crad);        //Full base rectangle
        else {
            difference() {
                smooth_rect(x_totalsize, y_totalsize, ht, crad);    //Full base rectangle, minus a centered rectangle
                translate([cyl_diam/2, cyl_diam/2, -ht]) smooth_rect(x_totalsize - cyl_diam, y_totalsize - cyl_diam, ht*4,crad);
                }
        }
        translate([-x_shrink/2,-y_shrink/2,0]) intersection() {
           //The nubs- lay these out in a grid, translated by half the shrink
           union(){
                translate([x_l_perslot*0,y_l_perslot*0,0]) one_bump();
                translate([x_l_perslot*0,y_l_perslot*y_length,0]) one_bump();
                translate([x_l_perslot*x_length,y_l_perslot*0,0]) one_bump();
                translate([x_l_perslot*x_length,y_l_perslot*y_length,0]) one_bump();
           }
           //Intersect the nubs with a box to create the gaps.
          translate([gap/2, gap/2,ht]) cube([x_l_perslot*x_length - gap,y_l_perslot*y_length - gap,cyl_ht+ht]);
        }
    }
}


module stanley_base_expanded() {
    //Creates the base then splits and expands it to go around the box.
    //The pieces need to be a little shorter than the full sized base as printers tend to
    //oversize them a bit.
    //function to help get the correct offset values to shift the edges outward
    function getoffset(index) = index==1 ? 1 : -1;
    //Translation shenanigans (including stanley_base later) are because this was
    //originally programmed to create the box centered on the corner,
    //not centered on the middle of the box.
    translate([-x_totalsize/2, -y_totalsize/2, 0])
    {
        for(xtemp = [0:1]) {
            for(ytemp = [0:1]) {
                translate([getoffset(xtemp)*cyl_diam*0.75, getoffset(ytemp)*cyl_diam*0.75,0]) {
                    intersection() {
                        translate([x_totalsize/2, y_totalsize/2, 0])
                            stanley_base();
                            translate([xtemp*(x_totalsize/2 + 1), ytemp*(y_totalsize/2 + 1),0]) {
                                cube([x_totalsize/2 - 1, y_totalsize/2 - 1, base_height+cyl_ht]);
                        }
                    }
                }
            }
        }
    }
}

if (mode == "boxonly")
    stanley_container(x_dividers,y_dividers,height, divider_height);
else if (mode == "baseonly")
    stanley_base();
else {
    stanley_container(x_dividers,y_dividers,height, divider_height);
    stanley_base_expanded();
}
