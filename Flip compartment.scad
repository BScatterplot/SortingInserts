//Create a rotatable interior compartment
//flip_compartment(50,40,20, 10, 5);
use <Divided box.scad>;

flip_compartment("add",
                40, 20, 50,
                pip_ht = 2,
                pip_d = 8,
                base_ht = 0.1,
                wall_t = 1,
                crad = 3,
                x_div = 1, y_div = 1,
                div_height = 0,
                x_skips = [], y_skips = [],
                tolerance = 0.1,
                grabhole = [-5.5, 0.8]);
                
#flip_compartment("remove",
                40, 20, 50,
                pip_ht = 2,
                pip_d = 8,
                base_ht = 0.1,
                wall_t = 1,
                crad = 3,
                x_div = 2, y_div = 1,
                div_height = 0,
                x_skips = [], y_skips = [],
                tolerance = 0.1);


module flip_compartment(operation,
                        x, y, z,
                        pip_ht,
                        pip_d,
                        base_ht = 0,
                        wall_t = 0,
                        crad = 0,
                        x_div = 0, y_div = 0,
                        div_height = 0,
                        x_skips = [], y_skips = [],
                        tolerance = 0.1,
                        grabhole = [0, 0.5])
{
    //The "operation" field lets the user specify if they want to add the box or add the area to cut out FOR the box.
    if (operation == "add")
    {
        difference()
        {
            rad_div_box(x, y, z,
                        pip_ht,
                        pip_d,
                        base_ht,
                        wall_t,
                        crad,
                        x_div, y_div,
                        div_height,
                        x_skips, y_skips);
            if (grabhole[1] > 0)
            {
                grab_d = grabhole[1]*x/(x_div+1);
                grab_z_offset = grabhole[0] + z + grab_d/2;
                grab_thick = 2*y;
                grab_ctrdist = z;
                slot_area_w = x-wall_t;
                slot_spacing = slot_area_w/(1+x_div);
                echo("Slot area: ", slot_area_w);
                echo("Slot spacing: ",slot_spacing);
                if (x_div != 0)
                {
                    for (i = [(-slot_area_w + slot_spacing)/2:slot_spacing:(slot_area_w - slot_spacing)/2])
                        translate([i,0,grab_z_offset])
                            {
                                echo(i);
                                grabslot(grab_d, grab_thick, grab_ctrdist);
                            }
                }
                else
                    translate([0,0,grab_z_offset])
                        grabslot(grab_d, grab_thick, grab_ctrdist);
                                
            }
        }
    }
    else    //Generate negative shape to remove
    {
        union()
        {
            ht = 1.5*((pip_ht * 2) + x); //Make sure it's super long to poke through the box.
            dia = (pip_d + tolerance);
            rotate([0, 90, 0])
                teardrop(dia, ht);                      //Nub hole
            translate([0, 0, -(y/2 * cos(50)+(z/2))])
                translate([-x/2, -y/2, -z/2])
                    smooth_rect(x, y, z, crad);         //Support hole for base
        }
    }
}

module grabslot(diameter, thickness, length)
{
    hull()
        {
            rotate([90, 0, 0])
                cylinder(h = thickness, d = diameter, center = true);
            translate([0, 0, length])
                rotate([90, 0, 0])
                    cylinder(h = thickness, d = diameter, center = true);
        }
}

module rad_div_box(x, y, z,
                   pip_ht,
                   pip_d,
                   base_ht = 0,
                   wall_t = 0,
                   crad = 0,
                   x_div = 0, y_div = 0,
                   div_height = 0,
                   x_skips = [], y_skips = [])
{
    union()
    {
        //Box portion:
        divided_box(x, y, z, base_ht, wall_t, crad, x_div, y_div, div_height, x_skips, y_skips);
        //Round portion:
        flat_half_cylinder(x,y/2,crad, 50);
        //Pips:
          rotpat(2)
          {
            translate([x/2,0,0])
                rotate([0,90,0])
                    chamf_cylinder(pip_d, pip_ht);
          }
    }
}

module chamf_cylinder(diameter, height)
{
    difference()
    {
        cylinder(h=height, d=diameter, $fn=25);
        translate([0.5 * diameter,0,height])
            rotate([0,45,0])
                cube([height*sqrt(2), diameter*2,height*sqrt(2)], true);
    }
}

module half_cylinder(length, radius, fillet)
{
    clen = min(length, radius)/2;       //Corner length
    rotate([-90, 0, 90])
        rotate_extrude(angle=180)
            rotate([0,0,180])
                hull()
                {
                    if (fillet > 0)
                    {
                        for (dy = [-(length-2*fillet)/2:length-2*fillet:(length-2*fillet)/2])
                        {
                            translate([-(radius-fillet), dy, 0])
                                circle(r=fillet, $fn=25);
                        }
                    }
                    else
                    {
                        translate([-fillet/2, dy, 0])
                            square(1, true);
                    }
                    for (dy = [-(length-clen)/2:length-clen:(length-clen)/2])
                    {
                        translate([-clen/2, dy, 0])
                            square(clen, true);
                    }
                }
}
module flat_half_cylinder(length, radius, fillet, tan_ang = 45)
{
    difference()
    {
        half_cylinder(length, radius, fillet);
        translate([0, 0, -(radius * cos(tan_ang)+(radius/2))])
            cube([length*2, radius*2, radius], true);
    }
}
module rotpat(instances, totalangle = -1)
{
    dt = totalangle == -1? (360/(instances)):totalangle/(instances-1);
    for (i = [0:(instances-1)])
    {
        rotate([0,0,i*dt])
            children(0);
    }
}

module teardrop (diameter, height)
{
    union()
    {
        cylinder(h = height, d = diameter, center = true);
        sqsize = diameter/2;
        translate([-diameter/(2*sqrt(2)),0,0])
            rotate([0, 0, 45])
                cube([sqsize, sqsize, height], center = true);
    }
}