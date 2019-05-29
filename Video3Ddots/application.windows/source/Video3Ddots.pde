// 3D WEBCAM 1.1
// by Eduardo Morais - June 13th 2009
// www.asseptic.org
//
// drag mouse to control camera, spacebar to reset
// press Ctrl or Shift for RGB separation, Enter/Return for settings

import peasy.*;
import JMyron.*;

JMyron video;
PeasyCam cam;
CameraState camstate;
PFont theFont;

int videoWidth = 640;
int videoHeight = 480;
int quality = 2;
int bg = 0;
boolean rgbMode = false;

boolean showHelp = false;
String help = "3D Webcam 1.1\n"+
  "by Eduardo Morais\n\n"+
  "Drag mouse (L button): Rotate view\n"+
  "Drag mouse (R button): Zoom view\n"+
  "Drag mouse (M button): Pan view\n"+
  "Enter / Return: Camera settings\n"+
  "Spacebar: Reset view\n"+
  "M: Toggle RGB separation mode\n"+
  "Q: Toggle quality setting\n"+    
  "B: Toggle background\n"+
  "H: Toggle help...";

void setup() {
 size(800,600,P3D);
 frame.setTitle("Eduardo Morais | 3D Webcam  (h = help)");
 cursor(HAND);  
 theFont = createFont("sans-serif", 16, true);
 textFont(theFont); 
 
 cam = new PeasyCam(this, 1000);
 cam.setMinimumDistance(600);
 cam.setMaximumDistance(3000);
 cam.lookAt(width/2,height/2,0); 
 cam.rotateY(PI);
 camstate = cam.getState();
 
 video = new JMyron();
 video.start(640,480);
}

void draw() {
  video.update();
  background(bg);
  translate(-240,-160,0);
  
  int[] videoPixels = video.image();
  
  for (int x=0; x < videoWidth; x = x+quality) {
   for (int y=0; y < videoHeight; y = y+quality) {
    int l = x + y*videoWidth;
      float r = red(videoPixels[l]);
      float g = green(videoPixels[l]);
      float b = blue(videoPixels[l]);
      float luma = brightness(videoPixels[l]);
      float z;

      if (rgbMode) {
        stroke(color(r,0,0,r));
        z = map(sqrt(r), 0, 16, 100, -100);
        point(x*2,y*2,z-100);

        stroke(color(0,g,0,g));
        z = map(sqrt(g), 0, 16, 100, -100);
        point(x*2,y*2,z);

        stroke(color(0,0,b,b));
        z = map(sqrt(b), 0, 16, 100, -100);         
        point(x*2,y*2,z+100);      

      } else {
        stroke(color(r,g,b));
        z = map(sqrt(luma), 0, 16, 100, -100);
        point(x*2,y*2,z);
      }
   }
  }
  if (showHelp) {
    textMode(SCREEN);
    text(help,20,20);
  }
}

void mouseDragged() {
  noCursor(); 
}

void mouseReleased() {
  cursor(HAND); 
}

void keyPressed() {
   if (key == 'h' || key == 'H') {
     if (showHelp) { showHelp = false;  } else { showHelp = true; }
   }
   if (key == 'q' || key == 'Q') {
     quality = quality+1;
     if (quality==5) { quality=1;  }
   }
   if (key == 'b' || key == 'B') {
     bg = bg + 63;
     if (bg > 255) { bg = 0; }
   }
   if (key == 'm' || key == 'M') {
     if (rgbMode) { rgbMode = false;  } else { rgbMode = true; }
   }
}

void keyReleased() {
  if (key == ' ') {
    cam.setState(camstate,2500);
    cam.lookAt(width/2,height/2,0);   
  }
  if (key == ENTER || key == RETURN) {
    video.settings();
  }
}
  
public void stop(){
  video.stop();//stop the object
  super.stop();
}
