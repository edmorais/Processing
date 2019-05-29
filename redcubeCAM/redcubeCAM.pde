
// RED CUBE
// by Eduardo Morais - June 9th 2009
// www.eduardomorais.com
//
// drag mouse to control camera, press any key to reset

import peasy.*; // camera control library
import ddf.minim.*; // sound library
import ddf.minim.signals.*;
import JMyron.*;




//import processing.opengl.*;

int density = 32; // space between the lines that make the cube

PeasyCam cam;
Minim minim;
AudioOutput out;
TriangleWave triw;
SineWave sine;
JMyron motion;

float objx = 320;
float objy = 240;
float objdestx = 320;
float objdesty = 240;

void setup() {
  size(640,480,P3D);
  cursor(HAND);
  // CAM TRACKING
  motion = new JMyron();//make a new instance of the object
  motion.start(640,480);//start a capture at 320x240
  motion.trackColor(255,255,255,256*3-100);//track white
  motion.update();
  motion.adaptivity(0);
  motion.adapt();// immediately take a snapshot of the background for differencing
  println("Myron " + motion.version());
  // 3D CAM
  cam = new PeasyCam(this, 1100);
  cam.setMinimumDistance(700);
  cam.setMaximumDistance(3000);
  cam.lookAt(width/2,width/2,width/2);
  cam.rotateX(PI/5);
  cam.rotateY(PI/5);  
  cam.rotateZ(PI/2);
  // SOUND
  minim = new Minim(this);
  out = minim.getLineOut(minim.STEREO);
  sine = new SineWave(160, 0.1, out.sampleRate());
  out.addSignal(sine);
  sine.portamento(10);
  triw = new TriangleWave(70, 0.2, out.sampleRate());
  triw.portamento(1);
  out.addSignal(triw);
}

void draw() {
  background(0);
  // CAM TRACKING
    motion.update();//update the camera view
  drawCamera();
  
  int[][] centers = motion.globCenters();//get the center points
  //draw all the dots while calculating the average.
  float avX=0;
  float avY=0;
  for(int i=0;i<centers.length;i++){
    avX += centers[i][0];
    avY += centers[i][1];
  }
  if(centers.length-1>0){
    avX/=centers.length-1;
    avY/=centers.length-1;
  }
 
  // DO CUBE!
  int steps = width/density;
  lights();

  noStroke();
  colorMode(HSB, steps);
  for (int i = 0; i <= steps; i++) {
    for (int j = 0; j <= steps; j++) {
      stroke(steps/2+j/7, steps, steps, i*0.5);
      line(i*density, j*density, 0, i*density, j*density, width);
      line(i*density, 0, j*density, i*density, width, j*density);
    }
  }

  float camDist = (float) cam.getDistance();
  float shake = random(-1, 1) * map(camDist, 900, 3000, 3, 0);
  cam.pan(shake,shake);
  motion.adapt();
  
  
 //update the location of the thing on the screen.
  if(!(avX==0&&avY==0)&&centers.length>0){
    objdestx = avX;
    objdesty = avY;
  }
  objx += (objdestx-objx)/10.0f;
  objy += (objdesty-objy)/10.0f;

  float rotY = map(objx-width/2, 0, width, 0, 20);
  cam.rotateY(radians(rotY));
  float rotX = map(objy-height/2, 0, height, 0, 10);
  cam.rotateX(radians(-rotX));
  move();
}

void mouseDragged() {
  noCursor(); 
  move();
}
  
void move() {

  float[] rotations = cam.getRotations();
  float rotY = rotations[1]/PI; // rotation Y axis (-0.5 a 0.5)
  float freq = map(rotY, -0.5, 0.5, 60, 90);
  triw.setFreq(freq);
  sine.setFreq(freq+90);

  float pan = map(rotY, -0.5, 0.5, 0, 1) - 0.5;
  triw.setPan(pan);

  float camDist = (float) cam.getDistance();
  float amp = map(camDist, 700, 3000, 1, 100);
  amp = 1 / sqrt(amp); // inverse square law

  float factor = map(rotY, -0.5, 0.5, 0.5, 1);
  triw.setAmp(amp*factor);  
  sine.setAmp(amp*factor/5);  
}

void drawCamera(){
  int[] img = motion.differenceImage(); //get the normal image of the camera
  loadPixels();
  for(int i=0;i<640*480;i++){ //loop through all the pixels
    pixels[i] = img[i]; //draw each pixel to the screen
  }
  updatePixels();
}

void mouseReleased() {
  cursor(HAND); 
}

public void stop(){
  motion.stop();//stop the object
  super.stop();
}


