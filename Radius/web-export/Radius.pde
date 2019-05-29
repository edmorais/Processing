/* @pjs pauseOnBlur=true; 
 */

/*
 * Radius
 * by Eduardo Morais 2012 - http://www.eduardomorais.com
 *
 * Drag mouse to draw. 
 * Up/down arrows to change background.
 * SPACE = auto draw.
 * S to save image.
 *
 */


/* Config */
int canvasW		= 720;
int canvasH		= 720;
int bgColor		= 255;
int lineOpacity	= 127;
boolean auto 		= true;


/* Declarations */
int lineColor;
int saved;
int autoX;
int autoY;
 
 
/* Setup */
void setup() {
	size(720, 720);
        saved = 1;
        autoX = int(random(0, width));
        autoY = int(random(0, height));
	background(bgColor);
	smooth();
}


/* Loop */
void draw() {
	// maintain line color contrast:	
	if (bgColor > 127) {
		lineColor = 0;
	} else {
		lineColor = 255;
	}
	
	
	// auto?
	if (auto) {
		autoX += (random(0, 30) - 15);
		if (autoX > width || autoX < 0) { autoX = width/2; }
		autoY += (random(0, 30) - 15);
		if (autoY > height || autoY < 0) { autoY = height/2; }
		drawLine(autoX, autoY);
	}
}

void drawLine(int x, int y) {
	stroke(lineColor, map(dist(x, y, width/2, height/2), width/2, 0, 0, lineOpacity));
	line(width/2+(random(0, width/3) - width/6), height/2+(random(0, height/3) - height/6), x+(random(0, 40) - 20), y+(random(0, 40) - 20)); 
}


/* Mouse */
void mouseDragged() {
	drawLine(mouseX, mouseY);
	autoX = mouseX;
	autoY = mouseY;
}

/* Keyboard */
void keyPressed() {
	if (key == CODED) {
		// adjust colors:
		if (keyCode == UP && bgColor < 255) {
			bgColor += 5;
			background(bgColor);
		} 
		if (keyCode == DOWN && bgColor > 0) {
			bgColor -= 5;
			background(bgColor);
		}
		if (keyCode == LEFT && lineOpacity > 25) {
			lineOpacity -= 5;
		} 
		if (keyCode == RIGHT && lineOpacity < 250) {
			lineOpacity += 5;
		}
	}
	
	// save:
	if (key == 's' || key == 'S') {
		save("radius-" + saved + ".png");
		saved++;
	}
	
	// toggle auto:
	if (key == ' ') {
		if (auto) {
			auto = false;
		} else {
			auto = true;
		}
	}
}

