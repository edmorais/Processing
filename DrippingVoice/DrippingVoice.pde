import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

Minim minim;
AudioInput in;
int t = 0;
int cel = 300;
float s;
int cm = 0;
color cor;
int cl = 128;
  
void setup() {
   size(1024, 640);
   background(255);
   minim = new Minim(this);
   in = minim.getLineIn();
   cm = floor(random(0,4));
   s = random(100, width-100);
}

void draw() {

  for (int i = 0; i < in.bufferSize(); i++) {
     float y = map(i, 0, in.bufferSize(), t-cel, t);  // pos
     float c = map(abs(in.mix.get(i)), 0, 1, 100, 255); // color
     float trans = map(i, 0, in.bufferSize(), 0, 255);
     
     if (trans > cl) {
       trans = cl - map(trans, cl, 255, 0, cl);
     }
       
     if (cm == 0) cor = color(c, c/2, 0, trans);
     if (cm == 1) cor = color(0, c/2, c, trans);
     if (cm == 2) cor = color(c/2, 0, c, trans);
     if (cm == 3) cor = color(c, 0, c/2, trans);
     stroke(cor);
     line(s - in.mix.get(i)*in.mix.get(i)*2000, y,
          s + in.mix.get(i)*in.mix.get(i)*2000, y);
  }
  s = s + random(-1,1);
  
  noStroke();
  fill(lerpColor(cor, color(255), 0.75), 1);
  rect(0,0, width, height); 
  
  t++;
  
  if(t > height + 50) {
    t = 0;
    s = random(100, width-100);
    cm = floor(random(0,4));
  }
}
