import processing.opengl.*;
import peasy.*;

PeasyCam cam;
int density = 10;

void setup() {
  size(640,640,OPENGL);
   cam = new PeasyCam(this, 1800);
 cam.setMinimumDistance(900);
 cam.setMaximumDistance(3000);
 cam.lookAt(0,0,0);
 cam.rotateX(PI/5);
  cam.rotateY(PI/4);
}

void draw() {
  int steps = width/density;

  lights();
  background(0);


  noStroke();
  colorMode(RGB, steps);
  for (int i = 0; i < steps; i++) {
      stroke(steps, i, 0, steps/3);
      noFill();
      pushMatrix();
      rotateX(TWO_PI/steps*i);
      ellipseMode(CENTER);
      ellipse(0, 0, height, height);
      popMatrix();
      /*
      pushMatrix();
      rotateY(i*TWO_PI/steps);
      ellipse(0, 0, height*1, height*1);
      popMatrix();
      */
  }
}


