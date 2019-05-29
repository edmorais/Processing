/**
 * Frame Differencing, video file
 * by Golan Levin, adapted by Eduardo Morais 2015
 *
 * Quantify the amount of movement in the video frame using frame-differencing.
 */ 


import processing.video.*;

int numPixels;
int[] previousFrame;
Movie video;
PGraphics buffer;

void setup() {
  size(640, 480);

  // Load video  
  video = new Movie(this, "turntable.mov");
  
  // Start capturing the images from the file
  video.loop(); 
  
  // Ed: we need an intermediary video buffer, as many video files return 0 width
  buffer = createGraphics(width, height);
  numPixels = buffer.width * buffer.height;

  // Create an array to store the previously captured frame
  previousFrame = new int[numPixels];
}

void draw() {
  loadPixels();
  if (video.available()) {
    // When using video to manipulate the screen, use video.available() and
    // video.read() inside the draw() method so that it's safe to draw to the screen
    video.read(); // Read the new frame from the camera

    // Ed: draw to intermediary buffer and go from there
    buffer.image(video, 0,0, buffer.width, buffer.height);
    buffer.loadPixels(); // Make its pixels[] array available
    
    int movementSum = 0; // Amount of movement in the frame
    for (int i = 0; i < numPixels; i++) { // For each pixel in the video frame...
      color currColor = buffer.pixels[i];
      color prevColor = previousFrame[i];
      // Extract the red, green, and blue components from current pixel
      int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
      int currG = (currColor >> 8) & 0xFF;
      int currB = currColor & 0xFF;
      // Extract red, green, and blue components from previous pixel
      int prevR = (prevColor >> 16) & 0xFF;
      int prevG = (prevColor >> 8) & 0xFF;
      int prevB = prevColor & 0xFF;
      // Compute the difference of the red, green, and blue values
      int diffR = abs(currR - prevR);
      int diffG = abs(currG - prevG);
      int diffB = abs(currB - prevB);
      // Add these differences to the running tally
      movementSum += diffR + diffG + diffB;
      // Render the difference image to the screen
      pixels[i] = color(diffR, diffG, diffB);
      // The following line is much faster, but more confusing to read
      //pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
      // Save the current color into the 'previous' buffer
      previousFrame[i] = currColor;
    }
    // To prevent flicker from frames that are all black (no movement),
    // only update the screen if the image has changed.
    if (movementSum > 0) {
      updatePixels();
      println(movementSum); // Print the total amount of movement to the console
    }
  }
}


