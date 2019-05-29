/*
 * Multiple live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 */


/*
 * Main proggy
 */

//
// START:
//
void go() {
	// set screen:
	size($windowWidth, $windowHeight);
	frame.setTitle("MultiProjection >>> press F1 for help");
	background(0);
	smooth();
	noCursor();
	$Canvas = new FullScreen(this);
	$Canvas.setShortcutsEnabled(false);
	$Canvas.setResolution(displayWidth, displayHeight);
	boolean EXITING = false;
	$Grid = new int[$gridPositions+3];
	for (int i = 0; i < $Grid.length; i++) {
		$Grid[i] = 999;
	}

	// be safe:
	if ($gridPositions < 2 || $gridPositions > 5) {
		$gridPositions = 2;
	}

	// needed for help:
	$theFont = createFont("sans-serif bold", 14, true);
	textFont($theFont);

	// select videos folder:
	while ($videosTotal < 1 && !EXITING) {
		// choosing video folder?
		if ($videosDialog) {
			selectFolder("Select videos folder", "folderSelected");
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
		$Grid[0] = 100;

		// check for cameras:
                /* DOESN'T WORK
                   Camera array must be a string now! */
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
					println("Initializing ("+$allowCameras[i]+"): "+$Cameras[c]);

					// add to locked camera position?
					if (int_in_array($allowCameras[i], $lockCameras)) {
						$lockLive = append($lockLive, c);
					}

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
                                        $Live[i].start();
					if (i < $Grid.length - 1) {
						$Grid[i+1] = i;
					}
				}
				$liveLength = $Live.length;
				// Create an array to store the previously captured frame
				$numPixels = $liveWidth * $liveHeight;
				$previousFrame = new int[$numPixels];
				// Adjust AR
				liveRatioAdjust();
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
		$widths = $canvasWidth/$gridPositions;
		int posY = ($canvasHeight/2) - ($canvasHeight/($gridPositions*2)) + $offsetY;

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

		// already drew fullscreen?
		boolean madeFull = false;

		// prepare webcam:
		for (int c = 0; c < $liveLength; c++) {
			if ($Live[c] != null && $Live[c].available()) {
				$Live[c].read();

				// effects:
				if ($FX == 1) {
					FX_gamma($Live[c]);
				}
				if ($FX == 2) {
					FX_add($Live[c]);
				}
				if ($FX == 3) {
					FX_difference($Live[c]);
				}
				if ($FX == 4) {
					float level = map($FXLevel, 0, 255, 2, 16);
					$Live[c].filter(POSTERIZE, level);
				}
				if ($FX == 5) {
					$Live[c].filter(GRAY);
				}
			}
		}

		// prepare movie:
		videoPlaylist(false, $Randomness); // call this
		if ($Video != null && $Video.available()) {
			$Video.read();
		}

		//
		// put things on screen!
		//
		for (int G = 0; G < $gridPositions; G++) {
			// horizontal position:
			int posX = G * $widths;

			//
			// DRAW MOVIE:
			//
			if ($Grid[G] == 100 && !madeFull && $Video != null) {
				if ($fade > 0) {
					if ($fading == 0){
						noTint();
					}
					if ($fillScreen) {
						// single video:
						image($Video, 0, 0, $canvasWidth, $canvasHeight);
						madeFull = true;
						break;
					} else {
						// dual video:
						image($Video, posX, posY, $widths-1, $canvasHeight/$gridPositions);
					}
				}
				continue;
			}

			//
			// DRAW WEBCAM:
			//
			if ($Grid[G] < $liveLength && !madeFull) {

				if ($Live[$Grid[G]] != null && $fade > 0) {
					if ($Ghosting > 1 && $fading == 0) {
						tint(255, 255/$Ghosting);
					} else if ($fading == 0){
						noTint();
					}

					// draw video:
					if ($fillScreen) {
						// single video:
						image($Live[$Grid[G]], 0, 0, $canvasWidth, $canvasHeight);
						madeFull = true;
						break;
					} else {
						// multi video:
						image($Live[$Grid[G]], posX, posY, $widths-1, $canvasHeight/$gridPositions);
					}
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
	if(($Video==null || $Video.time()>=$Video.duration() || advance) && $Playing) {
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
		$Video = new Movie(this, $Videos[$videosIndex]);
		println("\nPlaying "+ $Videos[$videosIndex]+" : "+$Video.duration()+"s");
		$Video.jump(0);
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
		for (int i = 0; i < $liveLength; i++) {
			if ($Live[i] != null) {
				// NEEDS WORK
			}
		}
	} else {
		println("Capture ratio adjust off");
		for (int i = 0; i < $liveLength; i++) {
			if ($Live[i] != null) {
				// NEEDS WORK
			}
		}
	}

}
