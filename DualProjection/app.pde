/*
 * Dual live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 */


/* 
 * Main proggy
 */

//
// START:
//
void setup() {
	// set screen:
	size($windowWidth, $windowHeight);
	frame.setTitle("DualProjection >>> press F1 for help");
	background(0);
	smooth();
	noCursor();
	$Canvas = new FullScreen(this);
	$Canvas.setShortcutsEnabled(false);
	$Canvas.setResolution(screen.width, screen.height);
	boolean EXITING = false;
	
	// needed for help:
	$theFont = createFont("sans-serif", 15, true);
	textFont($theFont); 

	// select videos folder:
	while ($videosTotal < 1 && !EXITING) {
		// choosing video folder?
		if ($videosDialog) {
			$videosFolder = selectFolder("Select videos folder");
		} else {
			$videosFolder = sketchPath + "/" + $videosFolder; 
		}
		if ($videosFolder != null) {
			String[] filenames = listFileNames($videosFolder);
			if (filenames != null) {
				$videosTotal = filenames.length;
			}
			$videosDialog = true;	// if the folder has no videos, ask for a new one
		} else {
			EXITING = true;
			exit(); 
		}
	}

	if ($videosTotal > 0 || !EXITING) {
		// load video files:
		String[] filenames = listFileNames($videosFolder);
		println("Video files detected:\n---");
		$Videos = new String[filenames.length];
		for (int i = 0; i < filenames.length; i++) {
			$Videos[i] = $videosFolder + "/" + filenames[i];   
		}
		println($Videos);
		println("\n");
		 
		// check for cameras:
		String[] cams = Capture.list();
		if (cams.length > 0) {
			println("Detected video devices:\n---");
			println(cams);
			// load cameras:
			int c = 0;
			String[] $Cameras = new String[$allowCameras.length];
			for (int i = 0; i < $allowCameras.length; i++) {
				if ($allowCameras[i] < cams.length) {
					$Cameras[c] = cams[$allowCameras[i]];
					println("Initializing: "+$Cameras[c]);
					c++;
				} else {
					$Cameras = shorten($Cameras);
				}
			}
			if ($Cameras.length > 0) {
				// initialize cameras:
				$Live = new Capture[$Cameras.length];
				for (int i = 0; i < $Cameras.length; i++) {
					println($Cameras[i]);
					$Live[i] = new Capture(this, $liveWidth, $liveHeight, $Cameras[i]);
				}
				liveRatioAdjust();
				// Create an array to store the previously captured frame
				$numPixels = $liveWidth * $liveHeight;
				$previousFrame = new int[$numPixels];
			} else {
				println("ERROR! NO COMPATIBLE CAMERAS FOUND.");
				exit();
			}
		} else {
			println("ERROR! NO CAMERAS FOUND.");
			exit();
		}
	}
}


//
// MAIN LOOP:
//
void draw() {

	if ($showHelp) {
	// help:
		background(0);
		fill(255);
		text($Help,40,50);
		
	} else {
	
		// calculations:
		$widths = $canvasWidth/$grid;
		$videoX = $videoGrid * $widths;
		$liveX  = $liveGrid * $widths;
		int posY = ($canvasHeight/2) - ($canvasHeight/($grid*2)) + $offsetY;
	
		// fade
		if ($fading != 0) {
			if ($fade > 255) {
				$fade = 255;
				$fading = 0;
			}
			if ($fade < 0) {
				$fade = 0;
				$fading = 0;
			}
			background(0);
			tint(255, $fade);
			$fade += $fading;
		}
		
		// draw live video:
		if ($Live[$camIndex] != null && $Live[$camIndex].available() && $fade > 0) {
			if ($Ghosting > 1 && $fading == 0) {
				tint(255, 255/$Ghosting);
			} else if ($fading == 0){
				noTint();
			}
			
			// if is visible:
			if ($liveX < $videoX || !$fillScreen) {
				$Live[$camIndex].read();
				
				// effects:
				if ($FX == 1) {
					FX_difference($Live[$camIndex]);
				}
				if ($FX == 2) {
					float level = map($FXLevel, 0, 255, 0.1, 1);
					$Live[$camIndex].filter(THRESHOLD, level);
				}
				if ($FX == 3) {
					float level = map($FXLevel, 0, 255, 2, 255);
					$Live[$camIndex].filter(POSTERIZE, level);
				}
				if ($FX == 4) {
					$Live[$camIndex].filter(GRAY);
				}
				
				// draw video:
				if ($fillScreen) {
					// single video:
					image($Live[$camIndex], 0, 0, $canvasWidth, $canvasHeight);
				} else {
					// dual video:
					image($Live[$camIndex], $liveX, posY, $widths-1, $canvasHeight/$grid);
				}
			}
		}
		
		// draw movie:
		videoPlaylist(false, $Randomness); // call this
		if ($Video != null && $Video.available() && $fade > 0) {
			if ($fading == 0){
				noTint();
			}
			if ($videoX < $liveX || !$fillScreen) {
				$Video.read();
				if ($fillScreen) {
					// single video:
					image($Video, 0, 0, $canvasWidth, $canvasHeight);
				} else {
					// dual video:
					image($Video, $videoX, posY, $widths-1, $canvasHeight/$grid);
				}
			}
		}
			
	}
}


//
// VIDEO PLAYLIST CONTROL:
// (bool advance: force jump to next video)
//
void videoPlaylist(boolean advance, boolean atRandom) {
	if(($Video==null || !$Video.isPlaying() || advance) && $Playing) {
		// advance to new:
		if ($Video!=null) {
			$Video.dispose();
			// random?
			if (atRandom && $videosTotal > 1 ) {
				int rn = $videosIndex;
				while (rn == $videosIndex) {
					rn = floor(random($videosTotal));
				}
				$videosIndex = rn;
			} else {
				$videosIndex++;
			}
		}
		if ($videosIndex == $videosTotal) {
			$videosIndex = 0;
		}
		// init new video:
		$Video = new GSMovie(this, $Videos[$videosIndex]);
		println("\nPlaying "+ $Video.getFilename());
		$Video.goToBeginning();
		$Video.noLoop();
		$Video.play();
	}
}



//
// CAMERA RATIO ADJUST:
//
void liveRatioAdjust() {
	if ($ratioAdjust) {
		float ratio = float($canvasWidth)/float($canvasHeight);
		// vertical crop (eg. 4x3 capture in 16x9 screen):
		int liveCropW = $liveWidth;
		int liveCropH = floor($liveWidth / ratio);
		int liveCropY = floor(($liveHeight-liveCropH)/2);
		int liveCropX = 0;
		// horizontal crop (eg. 16x9 capture in 4x3 screen):
		if (liveCropY < 0) {
			liveCropW = floor($liveHeight * ratio);
			liveCropH = $liveHeight;
			liveCropY = 0;
			liveCropX = floor(($liveWidth-liveCropW)/2);
		}
		println("Capture ratio adjust on: R "+ratio+" / H "+liveCropH+" / Y "+liveCropY);
		for (int i = 0; i < $Live.length; i++) {
			if ($Live[i] != null) {
				$Live[i].crop(liveCropX, liveCropY, liveCropW, liveCropH);
			}
		}
	} else {
		println("Capture ratio adjust off");
		for (int i = 0; i < $Live.length; i++) {
			if ($Live[i] != null) {
				$Live[i].crop(0, 0, $liveWidth, $liveHeight);
				$Live[i].noCrop();
			}
		}
	}
}
