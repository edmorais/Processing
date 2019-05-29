/*
 * Multiple live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 */

/*
 * Visual effects
 */

//
// FX: difference - based on Frame Differencing by Golan Levin
//
void FX_difference(PImage video) {
	video.loadPixels(); // Make its pixels[] array available
        $numPixels = video.pixels.length;

	int movementSum = 0; // Amount of movement in the frame
	for (int i = 0; i < $numPixels; i++) { // For each pixel in the video frame...
		color currColor = video.pixels[i];
		color prevColor = $previousFrame[i];
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
		// video.pixels[i] = color(diffR, diffG, diffB);
		// The following line is much faster, but more confusing to read
		video.pixels[i] = 0xff000000 | (diffR << 16) | (diffG << 8) | diffB;
		// Save the current color into the 'previous' buffer
		$previousFrame[i] = currColor;
	}
	// To prevent flicker from frames that are all black (no movement),
	// only update the screen if the image has changed.
	if (movementSum > 0) {
		video.updatePixels();
	}
}

void FX_add(PImage video) {
	video.loadPixels(); // Make its pixels[] array available
        $numPixels = video.pixels.length;
	float gamma = map($FXLevel, 0, 255, 0.2, 2.5);

	for (int i = 0; i < $numPixels; i++) { // For each pixel in the video frame...
		color currColor = video.pixels[i];
		color prevColor = $previousFrame[i];
		// Extract the red, green, and blue components from current pixel
		int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
		int currG = (currColor >> 8) & 0xFF;
		int currB = currColor & 0xFF;
		// Extract red, green, and blue components from previous pixel
		int prevR = (prevColor >> 16) & 0xFF;
		int prevG = (prevColor >> 8) & 0xFF;
		int prevB = prevColor & 0xFF;
		// Compute the new red, green, and blue values
				
		// screen blend:
		float newR = 255 - (float((255-currR)*(255-prevR)) / 255);
		float newG = 255 - (float((255-currG)*(255-prevG)) / 255);
		float newB = 255 - (float((255-currB)*(255-prevB)) / 255);
		
		// gamma:
		newR = newR * newR * gamma / 255 - (64 - (32*gamma));;
		newR = (newR > 255) ? 255 : newR;
		newR = (newR < 0) ? 0 : newR;
		newG = (newG * newG * gamma / 255) - (64 - (32*gamma));
		newG = (newG > 255) ? 255 : newG;
		newG = (newG < 0) ? 0 : newG;
		newB = newB * newB * gamma / 255 - (64 - (32*gamma));;
		newB = (newB > 255) ? 255 : newB;
		newB = (newB < 0) ? 0 : newB;
		
		// The following line is much faster, but more confusing to read
		video.pixels[i] = 0xff000000 | (int(newR) << 16) | (int(newG) << 8) | int(newB);
		// Save the current color into the 'previous' buffer
		$previousFrame[i] = currColor;
	}
	video.updatePixels();
}

void FX_gamma(PImage video) {
	video.loadPixels(); // Make its pixels[] array available
        $numPixels = video.pixels.length;
	float gamma = map($FXLevel, 0, 255, 0.2, 4);

	for (int i = 0; i < $numPixels; i++) { // For each pixel in the video frame...
		color currColor = video.pixels[i];
		// Extract the red, green, and blue components from current pixel
		int currR = (currColor >> 16) & 0xFF; // Like red(), but faster
		int currG = (currColor >> 8) & 0xFF;
		int currB = currColor & 0xFF;

		// screen blend:
		float newR = float(currR);
		float newG = float(currG);
		float newB = float(currB);
		
		// gamma:
		newR = newR * newR * gamma / 255 - (64 - (32*gamma));;
		newR = (newR > 255) ? 255 : newR;
		newR = (newR < 0) ? 0 : newR;
		newG = (newG * newG * gamma / 255) - (64 - (32*gamma));
		newG = (newG > 255) ? 255 : newG;
		newG = (newG < 0) ? 0 : newG;
		newB = newB * newB * gamma / 255 - (64 - (32*gamma));;
		newB = (newB > 255) ? 255 : newB;
		newB = (newB < 0) ? 0 : newB;
		
		// The following line is much faster, but more confusing to read
		video.pixels[i] = 0xff000000 | (int(newR) << 16) | (int(newG) << 8) | int(newB);
		// Save the current color into the 'previous' buffer
		$previousFrame[i] = currColor;
	}
	video.updatePixels();
}
