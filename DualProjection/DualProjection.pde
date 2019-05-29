/*
 * Dual live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 *
 * Needs Fullscreen - http://www.superduper.org/processing/fullscreen_api/
 * and GSVideo (must be *test version 20110709*) - http://gsvideo.sourceforge.net/
 *
 * Tested on Windows. Requires Quicktime and WinVDIG *1.0.1* - http://www.eden.net.nz/7/20071008/
 */
 
/*
 * Config:
 */

int $windowWidth 		= 800;
int $windowHeight 		= 600;

int $grid				= 3;			// video/live positions (> 2)
int $videoGrid			= 1;			// video grid position
int $liveGrid			= 2;			// live feed grid position

int[] $allowCameras		= {0,1};		// allowed cameras array:
 
boolean $videosDialog	= false;		// select folder
String $videosFolder	= "videos";		// videos folder (if no dialog)
boolean $Randomness 	= false;		// play at random
boolean $Playing		= false;		// playing at start
int $liveWidth			= 720;			// capture width
int $liveHeight			= 540;			// capture height
boolean $fillScreen		= false;		// start on fill screen mode
int $fadeSpeed			= 4;			// fade effect speed (must be > 0)
boolean $ratioAdjust	= false;		// webcam widescreen adjust
		
// allowed video formats, separated by pipes(|):
String $okVideos 		= "mp4|avi|mov|mpg|m4v|m2t|ts";



/*
 * Boilerplate
 */

// libs:
import processing.video.*;
import codeanticode.gsvideo.*;
import fullscreen.*;
import japplemenubar.*;

// declarations - camera:
String[] $Cameras;			// cameras array
int $camIndex = 0; 		// current camera
Capture[] $Live; 			// live video object
int $Ghosting = 1;			// webcam ghosting
int $FX = 0;		 		// FX
float $FXLevel = 127;		// FX - level
int $numPixels;				// FX - number of pixels in frame
int[] $previousFrame;		// FX - frame

// declarations - video files:
String[] $Videos; 			// videos array
int $videosIndex = 0; 		// current video
int $videosTotal = 0; 		// number of videos
GSMovie $Video; 			// recorded video object

// declarations - screen & measures
FullScreen $Canvas;
int $canvasWidth = $windowWidth;
int $canvasHeight = $windowHeight;
int $offsetY = 0; 			// vertical offset
int $widths;				// video/live width
int $videoX;				// video X position
int $liveX;					// live feed X position
int $fade = 0;				// fade tint level
int $fading = $fadeSpeed;	// fade effect speed


// help:
boolean $showHelp = false;
String $Help = "DualProjection beta 6 "+
	"by Eduardo Morais 2012 - www.eduardomorais.pt\n\n"+
	"UP / DOWN: Adjust vertical position\n"+
	"F3: Fullscreen mode\n"+
	"SPACE: Video play / pause\n\n"+
	"N / F9: Next video / random video\n"+
	"ENTER: Switch single/double feed mode\n"+
	"K / L: Video/webcam horizontal position\n"+
	"S: Swap video/webcam position\n"+
	"1..4 / C: Select / switch camera (if available)\n"+
	"5..9 / 0: Select / cancel effect\n"+
	"LEFT, RIGHT / G, H: Adjust effect / ghosting level\n\n"+
	"A: Toggle aspect ratio adjustment\n\n"+
	"F: Fade in / out\n"+
	"Q: Quit program\n"+
	"F1: Toggle help...";
PFont $theFont;



/*
 * INCLUDED FILES:
 *
 * App:				app.pde
 * Keybindings:		inc_keys.pde
 * Visual effects:	inc_fx.pde
 * Misc. functions:	inc_utilities.pde
 *
 */
