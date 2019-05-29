/**
 * RandomChairs by Eduardo Morais
 * 8.Jan.2011
 * based on Parameterize: Chair
 * by Casey Reas, Chandler McWilliams, and LUST
 *
 * drag mouse to control camera, 
 * spacebar = new chair / enter = switch mode
 */
 
import peasy.*; // camera control library
import processing.opengl.*;

PeasyCam cam;
int chairSeatHeight      = 1000;
int chairWidth           = 500;
int chairDepth           = 500;
int chairBackHeight      = 1000;
int chairFrameThickness  = 100;
int refresh = 1;
int fr = 128;
int fg = 128;
int fb = 128;

void setup() {
  size(600,600,P3D);
  //size(1024,768,OPENGL);
  cursor(HAND);
  cam = new PeasyCam(this, width/2,height/1.5,height/2, width*2);
  cam.setMinimumDistance(width/2);
  cam.setMaximumDistance(width*5);
  cam.rotateX(PI/5);
  cam.rotateY(PI/5);  
  cam.rotateZ(PI/2);
  stroke(0);
  noStroke();
  background(0);
  scrambleChair();
}

void draw() {
  if (refresh==1) {
    background(0);
    fill(fr,fg,fb,128);
  } else {
    fill(fr,fg,fb,32);
  }
  drawChair();  

}

void mouseDragged() {
  noCursor(); 
}

void mouseReleased() {
  cursor(HAND);
}



void drawChair() {
  // back
  pushMatrix();
  translate(chairWidth/2, chairBackHeight/2);
  box(chairWidth, chairBackHeight, chairFrameThickness);
  popMatrix();

  // seat
  pushMatrix();
  translate(chairWidth/2, chairBackHeight + chairFrameThickness/2, chairDepth/2 - chairFrameThickness/2);
  box(chairWidth, chairFrameThickness, chairDepth);
  popMatrix();


  // legs
  pushMatrix();
  translate(chairFrameThickness/2, chairBackHeight + chairSeatHeight/2 + chairFrameThickness, 0);
  box(chairFrameThickness, chairSeatHeight, chairFrameThickness);
  popMatrix();

  pushMatrix();
  translate(chairWidth - chairFrameThickness/2, chairBackHeight + chairSeatHeight/2 + chairFrameThickness, 0);
  box(chairFrameThickness, chairSeatHeight, chairFrameThickness);
  popMatrix();

  pushMatrix();
  translate(chairWidth - chairFrameThickness/2, chairBackHeight + chairSeatHeight/2 + chairFrameThickness, chairDepth - chairFrameThickness);
  box(chairFrameThickness, chairSeatHeight, chairFrameThickness);
  popMatrix();

  pushMatrix();
  translate(chairFrameThickness/2, chairBackHeight + chairSeatHeight/2 + chairFrameThickness, chairDepth - chairFrameThickness);
  box(chairFrameThickness, chairSeatHeight, chairFrameThickness);
  popMatrix();
}

void scrambleChair() {
  chairSeatHeight = floor(random(100, width));
  chairWidth      = floor(random(100, width));
  chairDepth      = floor(random(100, width));
  chairBackHeight = floor(random(100, width));
  
  fr = floor(random(0, 200));
  fg = floor(random(0, 200));
  fb = floor(random(0, 200));
}

void keyPressed() {
  if (key == ' ') {
    scrambleChair();
    drawChair();  
  }
  if (key == ENTER) {
    refresh = refresh == 1 ? 0 : 1;
  }
}

