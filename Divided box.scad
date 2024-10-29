//divided_box(100, 50, 30, 4, 2, 8, 3, 2, 25,0,[1]);
smooth_rect(10,20,30,4);
//Divided box module
//x, y, and z are the size of the box.
//base_ht is the thickness of the base.
//wall_t is the thickness of the walls.
//crad is the radius of the corners. If it's <= 0, the box will have sharp corners.
//If either the base height or the wall thickness are <= 0, the box will be solid.
//x_div and y_div are the numbers of divisions in the box in the x and y directions.
//div_height is the height of the dividers; if <=0, this is set to the height of the box.
//x_skips and y_skips are arrays that list the numbered dividers to skip.

module divided_box(x, y, z,
                    base_ht = 0,
                    wall_t = 0,
                    crad = 0,
                    x_div = 0,
                    y_div = 0,
                    div_height = 0,
                    x_skips = [], y_skips = [])
{
    translate([-x/2, -y/2, 0])
    {
        int_crad = crad - wall_t;
        //Set or clear the divider heights
        divider_height = div_height <=0? z:div_height;
        //Set or clear whether or not the box is solid
        solidbox = ((base_ht <= 0)||(wall_t <= 0))? true:false;
        echo ("Solidbox: ");
        echo (solidbox);
    //    bht = box_base_height;
        difference() {
            //Outside of box:
            smooth_rect(x, y, z,crad);
            //If not a solid box, remove the inside area:
            if (!solidbox)
            {
                translate([crad-int_crad, crad-int_crad, base_ht]) smooth_rect(x - 2*wall_t, y - 2*wall_t, z, int_crad);
            }
        }
        //Add the X dividers
        if (x_div > 0) {
            for(i = [1:x_div])
            {
                skip = len(search(i, x_skips)) > 0? true : false;
                if (!skip)
                {
                    compartment = (x)/(x_div + 1);
                    translate([compartment * i - (wall_t/2),0,0]) cube([wall_t, y, divider_height]);
                }
            }
        }
        if (y_div > 0) {
            for(i = [1:y_div])
            {
                skip = len(search(i, y_skips)) > 0? true : false;
                if (!skip)
                {
                    compartment = (y)/(y_div + 1);
                    translate([0,compartment * i - (wall_t/2),0]) cube([x, wall_t, divider_height]);
                }
            }
        }
    }
}

module smooth_rect(x, y, z, rad)
{
    module corner()
        {
            cylinder(z,rad,rad,$fn=25);
        }
    if (rad > 0)
    {
        hull() {
            translate([rad,rad,0]) corner();
            translate([x-rad,rad,0]) corner();
            translate([rad,y-rad,0]) corner();
            translate([x-rad,y-rad,0]) corner();
        }
    }
    else
    {
        cube([x,y,z]);
    }
}