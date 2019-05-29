/** BOUNCING MUSICAL CIRCLES
 * by Eduardo Morais - June 10th 2009
 * www.asseptic.org
 *
 * drag mouse to control camera, press any key to reset
 */

import peasy.*; // camera control library
import ddf.minim.*; // sound library
import ddf.minim.signals.*;
import processing.opengl.*;

float gravity = 0.01; // more gravity, more speed
float atrito = 0.9; // ammount of speed retained after each bounce
float[] sounds = { 
  261.63, 293.66, 329.63, 392, 440, 523.25, 587.33, 659.26, 783.99, 880 };
  // frequencies (Hz) corresponding to two octaves in the pentatonic scale (CDEGA)

Minim minim;
AudioOutput out;
SineWave sqwave;
PeasyCam cam;
Ball[] bola = new Ball[100];


void setup() {
  size(960,600,OPENGL);
  cursor(HAND);
  cam = new PeasyCam(this, width);
  cam.setMinimumDistance(width/5);
  cam.setMaximumDistance(width*1.5);
  cam.lookAt(0,width*(-0.2),0);
  cam.rotateY(TWO_PI/5);

  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 10; j++) {
      colorMode(RGB, 100);
      color cor = color(i*10,j*2,j*7,80); 

      bola[i*10+j] = new Ball(i*60, j*60, 56, 600+i*50+j*30, cor);
    }
  }

  minim = new Minim(this);
  out = minim.getLineOut(Minim.MONO, 1024, 22050, 16);
  out.setGain(-10);   
}

class Ball {
  float altura;
  float vel;
  float raio;
  float xPos;
  float yPos;
  color cor;
  boolean falling;

  Ball(float xPosTemp, float yPosTemp, float raioTemp, float alturaTemp, color corTemp) {
    xPos = xPosTemp;
    yPos = yPosTemp;
    vel = 0;
    raio = raioTemp;
    altura = alturaTemp;
    cor = corTemp;
    falling = true;
  }

  void display() {
    noStroke();
    pushMatrix();  // ESFERA
    translate(xPos-250, altura*-1, yPos-250);
    fill(cor);
    rotateX(PI/2);        
    ellipse(0,0,raio,raio);
    //box(raio/2);
    popMatrix();
    pushMatrix();  // SOMBRA    
    translate(xPos-250, -1, yPos-250);
    float sombra = map(altura, 2000, 0, 0, 10);
    color sombraCor = color(0,0,0,sombra*sombra*0.3);
    if (altura < 100 && !falling) {
     sombraCor = color(red(cor),green(cor),blue(cor),50); 
    }
    fill(sombraCor);
    rotateX(PI/2);  
    ellipse(0,0,raio,raio);
    popMatrix();    
  }

  void calcula() {
    altura = altura - vel;
    vel = vel + gravity;
    if (altura <= 0 && falling) {
      if (abs(vel) > 0.5) {
        float r = random(-5, 5)/100;
        vel = vel * (atrito*-1 + r);
        float freq = sounds[round(yPos/60)];
        sqwave = new SineWave(freq, 0.1, out.sampleRate());
        sqwave.portamento(100);          
        out.addSignal(sqwave);        
        if (out.signalCount() > 8) {
          out.removeSignal(0);              
        }
      } 
      else {
        out.clearSignals();
        altura = 0;
        vel = 0;
      }
    }
    if (vel >= 0) {
      falling = true;
    } 
    else {
      falling = false; 
    }
  }

}

void draw() {
  colorMode(RGB, 255);
  background(255);
  noStroke();
  // lights();
  ellipseMode(CENTER);
  pushMatrix(); // PLANO
  rotateX(PI/2);
  fill(0,0,0,20);
  ellipse(0,0,width,width);
  popMatrix();

  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 10; j++) {
      bola[i*10+j].display();
      bola[i*10+j].calcula();
    }
  }
  
}

void keyPressed() {
  out.clearSignals();
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < 10; j++) {
      bola[i*10+j].altura = 600+i*50+j*30;
      bola[i*10+j].vel = 0;
      bola[i*10+j].falling = true;
    }
  }
}

void mouseDragged() {
  noCursor();
  float camDist = (float) cam.getDistance();
  float amp = map(camDist, 200, 1500, 0, -16);
  out.setGain(amp);
}
void mouseReleased() {
  cursor(HAND); 
}
