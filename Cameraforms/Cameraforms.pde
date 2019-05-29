import processing.video.*;

Capture cam;
Lineform[] lforms;
int num = 200;
int rdiff = 50;
int bX, bY;
float maxLuma;

void setup() {
 size(1024,768, P2D);
 background(0);
 smooth();
 frameRate(30);
 
 lforms = new Lineform[num];
 for (int i = 0; i < num; i++) {
   int diff = int(random(1,(random(2, rdiff))));
   color cor = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
   
   lforms[i] = new Lineform(width/2, height/2, color(cor), diff);
 }
 
 cam = new Capture(this, 640, 480);
 cam.start();
}

void draw() {
 if (cam.available()) { 
   cam.read();
   cam.loadPixels();
   maxLuma = 0;
   bX = cam.width/2;
   bY = cam.height/2;
   for (int ix = 0; ix < cam.width; ix++) {
     for (int iy = 0; iy < cam.height; iy++) {
       float luma = red(cam.pixels[ix+iy*cam.width])*0.3+green(cam.pixels[ix+iy*cam.width])*0.6+blue(cam.pixels[ix+iy*cam.width])*0.1;
       if (ix % 10 == 0 && iy % 10 == 0) {
         if (luma > maxLuma) {
           maxLuma = luma;
           bX = ix;
           bY = iy;
         }
         luma = 255-luma;
       }
       cam.pixels[ix+iy*cam.width] = color(luma/2, 64);
     }
   }
   cam.updatePixels();
   bX = int(map(bX, 0, 640, 0, 1024));
   bY = int(map(bY, 0, 480, 0, 768));
   image(cam, 0, 0, 1024, 768);   
 }
 println(bX+", "+bY+":: "+maxLuma);
 for (int i = 0; i < num; i++) { 
  lforms[i].update(bX, bY);
 }
}
