import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Pattern_02 extends PApplet {
  public void setup() {
// inits
size(900,900);
background(64);
int[] cols = new int[7];

// config vars
cols[0] = color(0xffFCF9E0); // background
cols[1] = color(0xff4C1C1C);
cols[2] = color(0xffF6E696);
cols[3] = color(0xffB9131C);
cols[4] = color(0xffBC8C46);

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
    im.stroke(cols[PApplet.parseInt(random(1,5))]);
    /*
    if (random(0,10) > 7) {
        im.noStroke();
    }
    */
    for (int ix = 0; ix < im.width; ix += s) {
        int r = PApplet.parseInt(random(0,100));
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
  image(im, 0, (height-height*PApplet.parseFloat(im.height)/PApplet.parseFloat(im.width))/2, width, height*(PApplet.parseFloat(im.height)/PApplet.parseFloat(im.width)));
} else {
  image(im, (width-width*PApplet.parseFloat(im.width)/PApplet.parseFloat(im.height))/2, 0, width*(PApplet.parseFloat(im.width)/PApplet.parseFloat(im.height)), height);
}

    noLoop();
  }

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Pattern_02" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
