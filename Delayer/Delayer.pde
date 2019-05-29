/*
 * Delayer
 * by Eduardo Morais 2015 - www.eduardomorais.pt
 *
 */


import processing.video.*;
import java.util.*;
import java.text.*;

Capture cam;
PImage[] buffer;
PGraphics display;
int buffer_max = 150;

int cam_x = 640;
int cam_y = 480;
float cam_mult = 1;

int delay = 20;

float[] offsets = new float[cam_x*cam_y];

// modes:
final int RAND = 0;
final int GRADIENT_LR = 1;
final int GRADIENT_RL = 2;
final int GRADIENT_TB = 3;
final int GRADIENT_BT = 4;
int mode = RAND;

boolean showMap = false; // show delay map

void setup() {
  size(round(cam_x*cam_mult), round(cam_y*cam_mult));
  background(0);
  
  /* Init offsets & window */
  
  offsets();

  /* Init cameras */

  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
      
    // Start capturing the images from the camera
    cam = new Capture(this, cam_x, cam_y);
    cam.start();

    // init buffer & etc
    buffer = new PImage[buffer_max];
    display = createGraphics(cam_x, cam_y);
  }
}

/*
Prepare pixel offsets
*/
void offsets() {
  if (delay < 0) {
    delay = 0; 
  }
  if (delay >= buffer_max) {
    delay = buffer_max - 1; 
  }
    
  if (mode == RAND) {
    for (int i = 0; i < offsets.length; i++) {
      float r = random(0, delay);
      offsets[i] = r;
    }
  }
  // horizontal gradient
  if (mode == GRADIENT_LR || mode == GRADIENT_RL) {
    for (int x = 0; x < cam_x; x++) {
      float o = 0;
      if (mode == GRADIENT_LR) {
        o = map(x, 0, cam_x, 0, delay);
      } else if (mode == GRADIENT_RL) {
        o = map(x, cam_x, 0, 0, delay);
      }
      for (int y = 0; y < cam_y; y++) {   
         offsets[y*cam_x+x] = o;
      }
    }
  }
  // vertical gradient
  if (mode == GRADIENT_TB || mode == GRADIENT_BT) {
    for (int y = 0; y < cam_y; y++) {
      float o = 0;
      if (mode == GRADIENT_TB) {
        o = map(y, 0, cam_y, 0, delay);
      } else if (mode == GRADIENT_BT) {
        o = map(y, cam_y, 0, 0, delay);
      }
      for (int x = 0; x < cam_x; x++) {   
         offsets[y*cam_x+x] = o;
      }
    }
  }
}


void draw() {
  if (cam.available() == true) {
    cam.read();
    
    buffer[0] = cam.get();
    buffer[0].loadPixels();
    
    for (int tx = delay-2; tx >= 0; tx--) {
      if (buffer[tx] != null) {
        buffer[tx+1] = buffer[tx];
        buffer[tx+1].loadPixels();
      }
    }
    
    display.beginDraw();
    display.loadPixels();
    for (int i = 0; i < offsets.length; i++) {
      if (showMap) {
        display.pixels[i] = color(map(offsets[i], 0, buffer_max, 0, 255));
      } else
      if (buffer[floor(offsets[i])] != null) {
        color cf = buffer[floor(offsets[i])].pixels[i];
        if (buffer[ceil(offsets[i])] != null) {
          float r = offsets[i] - floor(offsets[i]); 
          color cc = buffer[ceil(offsets[i])].pixels[i];
          cf = lerpColor(cf, cc, r);
        }
        display.pixels[i] = cf;
      }
    }
    display.updatePixels();
    display.endDraw();
    image(display, 0, 0, width, height);
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT && delay > 0) {
      delay--;
    }
    if (keyCode == RIGHT && delay < buffer_max) {
      delay++;
    }  
    offsets();
  }
  if (key == 'm' || key == 'M') {
    showMap = true; 
  }
  
}

void keyReleased() {
  if (key >= '1' && key <= '5') {
     if (mode != key - '1') {
       mode = key - '1';
       offsets();
       background(0);
     }
  }
 
  if (key == 'm' || key == 'M') {
     showMap = false; 
   }
  
  if (key == 's' || key == 'S') {
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_HHmmss");
    save("delayer_" + df.format(now) + ".jpg");
  }

}
