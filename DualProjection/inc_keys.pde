/*
 * Dual live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 */

//
// KEYBINDINGS
//
void keyPressed() {
	if (key == CODED) {
		// help:
		if (keyCode == KeyEvent.VK_F1) {
			if ($showHelp) {
				$showHelp = false;
			} else {
				$showHelp = true;
				println("HELP!");
			}
			background(0);
		}	
	
		// adjust video positions:
		if (keyCode == UP) {
			$offsetY -= 5;
		} 
		if (keyCode == DOWN) {
			$offsetY += 5;
		}
		
		// effect level + ghosting:
		if (keyCode == LEFT && $FX > 0 && $FXLevel > 0) {
			$FXLevel--;
		} 
		if (keyCode == LEFT && $FX == 0 && $Ghosting > 1) {
			$Ghosting--;
		}
		if (keyCode == RIGHT && $FX > 0 && $FXLevel < 255) {
			$FXLevel++;
		}
		if (keyCode == RIGHT && $FX == 0 && $Ghosting < 25) {
			$Ghosting++;
		}
		
		// advance at random:
		if (keyCode == KeyEvent.VK_F9) {
			if ($Playing && $Video!=null && $Video.isPlaying()) { 
				videoPlaylist(true, true);
			}
		}
		
		// fullscreen:
		if (keyCode == KeyEvent.VK_F3) {
			if ($Canvas.isFullScreen()) {
				$Canvas.leave();
				$canvasWidth = $windowWidth;
				$canvasHeight = $windowHeight;
				size($windowWidth, $windowHeight);
			} else {
				$Canvas.enter();
				$canvasWidth = screen.width;
				$canvasHeight = screen.height;
				size(screen.width, screen.height);
			} 
			liveRatioAdjust();
		}
	}
  

  
	// play/pause:
	if (key == ' ') {
		if ($Playing && $Video!=null && $Video.isPlaying()) { 
			$Playing = false;
			$Video.pause();
			println("Video paused.");
		} else {
			$Playing = true; 
			println("Video playing.");
			if ($Video !=null && $Video.isPaused()) {
				$Video.play();
			}	  
		}
	}
	
	// advance to next video:
	if (key == 'n' || key == 'N') {
		if ($Playing && $Video!=null && $Video.isPlaying()) { 
			videoPlaylist(true, false);
		}
	}
		
  
	// swap sides:
	if (key == 's' || key == 'S') {
		int t = $videoGrid;
		$videoGrid = $liveGrid;
		$liveGrid = t;
	}
	
	
	// horizontal position:
	if (key == 'k' || key == 'K') {
		if ($grid > 2 && $Playing) {
			int t = $videoGrid;
			$videoGrid++;
			if ($videoGrid >= $grid) {
				$videoGrid = 0;
			}
			if ($videoGrid == $liveGrid) {
				$liveGrid = t;
			}
			background(0);			
		}
	}
	if (key == 'l' || key == 'L') {
		if ($grid > 2) {
			int t = $liveGrid;
			$liveGrid++;
			if ($liveGrid >= $grid) {
				$liveGrid = 0;
			}
			if ($videoGrid == $liveGrid) {
				$videoGrid = t;
			}
			background(0);			
		}
	}
		
  
	// toggle camera:
	if (key == 'c' || key == 'C') {
		if ($Live != null && $Live.length > 1) {
			$camIndex++;
			if ($camIndex==$Live.length) {
				$camIndex = 0; 
			}
		}
	}
	if (key >= '1' && key <= '4') {
		int ck = key - '1';
		if ($Live != null && $Live.length > 1) {
			if (ck < $Live.length) {
				$camIndex = ck; 
			}
		}
	}
	
	// toggle feed mode:
	if (key == ENTER || key == RETURN) {
		if (!$fillScreen) {
			$fillScreen = true;
			println("Single feed mode");
		} else {
			$fillScreen = false;
			println("Dual feed mode");
		}
		background(0);
	}
	
	// select FX:
	if (key == '0') {
		$FX = 0; // off
		println("Effect off.");
	}	
	if (key >= '5' && key <= '9') {
		$FX = key - '4';
		println("Effect " + $FX + " on.");
	}
	
	// ghosting:
	if ((key == 'g' || key == 'G') && $Ghosting > 1) {
		$Ghosting--;
	} 
	if ((key == 'h' || key == 'H')  && $Ghosting < 25) {
		$Ghosting++;
	}
	
	// toggle capture ratio adjust:
	if (key == 'a' || key == 'A') {
		if ($ratioAdjust) {
			$ratioAdjust = false;
		} else {
			$ratioAdjust = true;
		}
		liveRatioAdjust();
		background(0);
	}	
	
	// fade in/out
	if (key == 'f' || key == 'F') {
		if ($fading == 0) {
			if ($fade == 255) {
				$fading = 0 - $fadeSpeed;
				println("Fade out");
			}
			if ($fade == 0) {
				$fading = $fadeSpeed;
				println("Fade in");
			}
		}
	}
	
	// quit:
	if (key == 'q' || key == 'Q') {
	/* // should be here but crashes - WTF?
		for (int i=0; i<$Live.length; i++) {
			if ($Live[i] != null) {
				$Live[i].stop();
				$Live[i].dispose();
			}
		}
	*/
		if ($Video != null) {
			$Video.stop();
			$Video.dispose();
		}
		exit();
	}
}

// clear screen on release
void keyReleased() {
	if (key == CODED) {
		if (keyCode == UP || keyCode == DOWN) {
			background(0);
		}
	}
}
