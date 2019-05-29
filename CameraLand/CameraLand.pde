/**
 * CameraLand by Eduardo Morais
 * 9.Jan.2011
 * based on Transform: Transcoded Landscape
 * by Casey Reas, Chandler McWilliams, and LUST
 */

import processing.opengl.*;
import JMyron.*;

JMyron video;
int videoWidth = 640;
int videoHeight = 480;
int factor = 4;

PImage img;
int[][] values;
float angle;

void setup() {
  size(1024, 768, OPENGL);
  noFill();

  video = new JMyron();
  video.start(videoWidth,videoHeight);
  factor = ceil((width*3)/videoWidth);
  print(factor);
}

void draw() {
  values = new int[width][height];

  // Extract the brightness of each pixel in the image
  // and store in the "values" array
  video.update();
  int[] videoPixels = video.image();

  background(0);                     // Set black background
  translate(width/2, height/2, 0);   // Move to the center

  scale(factor); // Scale to 400%

  // Update the angle
  angle += 0.005;
  rotateY(angle);  

  for (int i = 0; i < videoHeight; i+=2) {
    for (int j = 0; j < videoWidth; j+=2) {
      color pixel = videoPixels[i*videoWidth + j];
      values[j][i] = int(brightness(pixel));
      stroke(values[j][i], 160);
      float x1 = j-videoWidth/2;
      float y1 = i-videoHeight/2;
      float z1 = -values[j][i]/2;
      float x2 = j-videoWidth/2;
      float y2 = i-videoHeight/2;
      float z2 = -values[j][i]/2-4;
      line(x1, y1, z1, x2, y2, z2);
    }
  }
}

