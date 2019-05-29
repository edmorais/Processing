PGraphics im = createGraphics(1300, 2000);
im.beginDraw();
im.background(255);
int s = 130;
//im.stroke(255);
im.stroke(#CC3322);
im.strokeWeight(50);
im.smooth();

for (int ix = 0; ix < im.width; ix += s) {
    for (int iy = 0; iy < im.height; iy += s) {
        if (random(0,50) > 25) {
            im.line(ix,iy+s,ix+s,iy);
        } else {
            im.line(ix,iy,ix+s,iy+s);
        }
    } 
}
im.endDraw();
im.save("04_"+im.width+"x"+im.height+".jpg");
