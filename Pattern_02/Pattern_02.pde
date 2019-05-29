// inits
size(900,900);
background(64);
color[] cols = new color[7];

// config vars
cols[0] = color(#FCF9E0); // background
cols[1] = color(#4C1C1C);
cols[2] = color(#F6E696);
cols[3] = color(#B9131C);
cols[4] = color(#BC8C46);

cols[5] = cols[1];
cols[6] = cols[3];

int s = 65; // cell size
int sratio = 5; // foreground ratio
PGraphics im = createGraphics(1300, 2000); // width, height
String name = "10";
String format = "jpg";

// begin
im.beginDraw();
im.background(cols[0]);
im.strokeWeight(s/sratio);
im.smooth();

// draw pattern
for (int iy = 0; iy < im.height; iy += s) {
    im.stroke(cols[int(random(1,5))]);
    /*
    if (random(0,10) > 7) {
        im.noStroke();
    }
    */
    for (int ix = 0; ix < im.width; ix += s) {
        int r = int(random(0,100));
        if (r < 20) {
            im.line(ix,iy+s,ix+s,iy);
        } else if (r < 40) {
            im.line(ix,iy,ix+s,iy+s);
        } else if (r < 70) {
            im.line(ix,iy+s/2,ix+s,iy+s/2);
        } else {
            im.line(ix+s/2,iy,ix+s/2,iy+s);
        }
    }
}

// save
im.endDraw();
im.save(name+"_"+im.width+"x"+im.height+"."+format);

// Display image
if (im.width > im.height) {
  image(im, 0, (height-height*float(im.height)/float(im.width))/2, width, height*(float(im.height)/float(im.width)));
} else {
  image(im, (width-width*float(im.width)/float(im.height))/2, 0, width*(float(im.width)/float(im.height)), height);
}

