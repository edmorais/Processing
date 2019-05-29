/** RED CUBE
 * by Eduardo Morais - June 9th 2009
 * www.asseptic.org
 *
 * drag mouse to control camera, press any key to reset
 */
 
import peasy.*; // camera control library
import ddf.minim.*; // sound library
import ddf.minim.signals.*;
//import processing.opengl.*;

int density = 32; // space between the lines that make the cube

PeasyCam cam;
Minim minim;
AudioOutput out;
TriangleWave triw;
SineWave sine;

void setup() {
  size(600,600,P3D);
  cursor(HAND);
  cam = new PeasyCam(this, width*2);
  cam.setMinimumDistance(width);
  cam.setMaximumDistance(width*5);
  cam.lookAt(width/2,height/2,height/2);
  cam.rotateX(PI/5);
  cam.rotateY(PI/5);  
  cam.rotateZ(PI/2);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO);
  sine = new SineWave(160, 0.1, out.sampleRate());
  out.addSignal(sine);
  sine.portamento(10);
  triw = new TriangleWave(70, 0.2, out.sampleRate());
  triw.portamento(1);
  out.addSignal(triw);
}

void draw() {
  int steps = width/density;
  lights();
  colorMode(RGB,255);
  background(0);

  noStroke();
  colorMode(HSB, steps);
  for (int i = 0; i <= steps; i++) {
    for (int j = 0; j <= steps; j++) {
      stroke(j/7, steps, steps, i*0.5);
      line(i*density, j*density, 0, i*density, j*density, width);
      line(i*density, 0, j*density, i*density, width, j*density);
    }
  }

  float camDist = (float) cam.getDistance();
  float shake = random(-1, 1) * map(camDist, 900, 3000, 3, 0);
  cam.pan(shake,shake);
}

void mouseDragged() {
  noCursor(); 

  float[] rotations = cam.getRotations();
  float rotY = rotations[1]/PI; // rotation Y axis (-0.5 a 0.5)
  float freq = map(rotY, -0.5, 0.5, 60, 90);
  triw.setFreq(freq);
  sine.setFreq(freq+90);

  float pan = map(rotY, -0.5, 0.5, 0, 1) - 0.5;
  triw.setPan(pan);

  float camDist = (float) cam.getDistance();
  float amp = map(camDist, 900, 3000, 1, 100);
  amp = 1 / sqrt(amp); // inverse square law

  float factor = map(rotY, -0.5, 0.5, 0.5, 1);
  triw.setAmp(amp*factor);  
  sine.setAmp(amp*factor/5);  
}
void mouseReleased() {
  cursor(HAND); 
}



