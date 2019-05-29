/*
 * Multiple live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 *
 * Needs Fullscreen - http://www.superduper.org/processing/fullscreen_api/
 * and GSVideo (must be *test version 20110709*) - http://gsvideo.sourceforge.net/
 *
 * Tested on Windows. Requires Quicktime and WinVDIG *1.0.1* - http://www.eden.net.nz/7/20071008/
 */


/*
 * Boilerplate
 */

// libs:
import processing.video.*;
import codeanticode.gsvideo.*;
import fullscreen.*;

// declarations

int $windowWidth, $windowHeight;
int $gridPositions;
int[] $allowCameras, $lockCameras;
boolean $videosDialog;
String $videosFolder;
boolean $Randomness, $Playing;
int $liveWidth, $liveHeight;
boolean $fillScreen;
int $fadeSpeed;
boolean $ratioAdjust;
String $okVideos;
String[] $Cameras;
Capture[] $Live;
int $liveLength;
int[] $lockLive = {};
int $Ghosting, $FX;
float $FXLevel;
int $numPixels;
int[] $previousFrame;
String[] $Videos;
int $videosIndex, $videosTotal;
GSMovie $Video;
int[] $Grid;
FullScreen $Canvas;
int $canvasWidth, $canvasHeight;
int $offsetY, $widths;
int $fade, $fading;
boolean $showHelp;
String $Help;
PFont $theFont;


/*
 * Config:
 */

Config $config;


void setup() {

	try {
		$config = new Config();
		// load a configuration from a file inside the data folder
		$config.load(openStream("config.txt"));

		// all values returned by the getProperty() method are Strings
		// so we need to cast them into the appropriate type ourselves
		// this is done for us by the convenience Config class

		$windowWidth 			= $config.getInt("mp.width", 640);
		$windowHeight 			= $config.getInt("mp.height", 480);

		$gridPositions			= $config.getInt("mp.gridPositions", 3);

		$allowCameras			= $config.getIntArray("live.allow");
		$lockLive				= $config.getIntArray("live.lock");

		$videosDialog			= $config.getBoolean("video.dialog", false);
		$videosFolder			= $config.getString("video.folder", "videos");
		$Randomness 			= $config.getBoolean("video.randomness", false);
		$Playing				= $config.getBoolean("video.playing", true);
		$liveWidth				= $config.getInt("live.width", 640);
		$liveHeight				= $config.getInt("live.height", 480);
		$fillScreen				= $config.getBoolean("mp.fillScreen", false);
		$fadeSpeed				= $config.getInt("mp.fadeSpeed", 4);
		$ratioAdjust			= $config.getBoolean("live.ratioAdjust", false);

		// allowed video formats, separated by pipes(|):
		$okVideos 				= $config.getString("video.formats", "mov|mpg");


		// declarations - camera:
		$liveLength = 0;
		$Ghosting = 1;			// webcam ghosting
		$FX = 0;		 		// FX
		$FXLevel = 127;			// FX - level

		// declarations - video files:
		$videosIndex = 0; 		// current video
		$videosTotal = 0; 		// number of videos

		// declarations - screen & measures
		$canvasWidth = $windowWidth;
		$canvasHeight = $windowHeight;
		$offsetY = 0; 			// vertical offset
		$fade = 0;				// fade tint level
		$fading = $fadeSpeed;	// fade effect speed


		// help:
		$showHelp = false;
		$Help = "MultiProjection 1.0 "+
			"by Eduardo Morais 2012 - www.eduardomorais.pt\n\n"+

			"SPACE: Video play / pause\n"+
			"N / F9: Next video / random video\n\n"+

			"ENTER: Toggle fill - horizontal grid mode\n"+
			"G: Toggle number of grid positions\n"+
			"PAGEUP, PAGEDOWN: Adjust vertical position\n"+
			"1..5: Toggle grid position content\n"+
			"6..0: Toggle effects on-off\n"+
			"UP, DOWN: Adjust effect level\n"+
			"LEFT, RIGHT: Adjust ghosting level\n\n"+

			"S / C: Swap video with camera / between cameras\n"+
			"F3: Enter / leave fullscreen mode\n"+
			"F: Fade from / to black\n\n"+
			"Q: Quit program\n"+
			"F1: Toggle help...";

		// GO!
		go();

	}
		catch(IOException e) {
		println("couldn't read config file...");
	}
}


/*
 * INCLUDED FILES:
 *
 * App:				app.pde
 * Keybindings:		inc_keys.pde
 * Visual effects:	inc_fx.pde
 * Misc. functions:	inc_utilities.pde
 *
 */
