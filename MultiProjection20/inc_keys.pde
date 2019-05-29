/*
 * Multiple live / recorded video projection (Processing 1.5 only!)
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
		if (keyCode == KeyEvent.VK_PAGE_UP) {
			$offsetY -= 5;
		}
		if (keyCode == KeyEvent.VK_PAGE_DOWN) {
			$offsetY += 5;
		}

		// effect level + ghosting:
		if (keyCode == UP && $FX > 0 && $FXLevel < 255) {
			$FXLevel++;
		}
		if (keyCode == DOWN && $FX > 0 && $FXLevel > 0) {
			$FXLevel--;
		}
		if (keyCode == LEFT && $FX == 0 && $Ghosting > 1) {
			$Ghosting--;
		}
		if (keyCode == RIGHT && $FX == 0 && $Ghosting < 25) {
			$Ghosting++;
		}

		// advance at random:
		if (keyCode == KeyEvent.VK_F9) {
			if ($Playing && $Video!=null && $Video.available()) {
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
				$canvasWidth = displayWidth;
				$canvasHeight = displayHeight;
				size(displayWidth, displayHeight);
			}
			liveRatioAdjust();
		}
	}



	// play/pause:
	if (key == ' ') {
		if ($Playing && $Video!=null && $Video.available()) {
			$Playing = false;
			$Video.pause();
			println("Video paused.");
		} else {
			$Playing = true;
			println("Video playing.");
			if ($Video !=null && $Video.available()) {
				$Video.play();
			}
		}
	}

	// advance to next video:
	if (key == 'n' || key == 'N') {
		if ($Playing && $Video!=null && $Video.available()) {
			videoPlaylist(true, false);
		}
	}


	// swap camera / video:
	if (key == 's' || key == 'S') {
		int vp = 999;
		int cp = 999;

		for (int i = $gridPositions - 1; i >= 0; i--) {
			if ($Grid[i] == 100) {
				vp = i;
			}
			if ($Grid[i] < $liveLength && !int_in_array($Grid[i], $lockLive)) {
				cp = i;
			}
		}

		// simple swap:
		if (cp < $gridPositions && vp < $gridPositions) {
			$Grid[vp] = $Grid[cp];
			$Grid[cp] = 100;
		} else if (cp < $gridPositions) {
			// only camera visible:
			if (cp == 0 && !int_in_array($Grid[1], $lockLive)) {
				$Grid[1] = $Grid[0];
				$Grid[0] = 100;
			} else if (!int_in_array($Grid[0], $lockLive)) {
				$Grid[0] = $Grid[cp];
				$Grid[cp] = 100;
			}
		} else if (vp < $gridPositions) {
			// only video visible:
			if (vp == 0 && !int_in_array($Grid[1], $lockLive)) {
				$Grid[1] = 100;
				$Grid[0] = 0;
			} else if (!int_in_array($Grid[0], $lockLive)) {
				$Grid[0] = 100;
				$Grid[vp] = 0;
			}
		} else if (!int_in_array($Grid[0], $lockLive) && !int_in_array($Grid[1], $lockLive)) {
			// both invisible
			$Grid[0] = 0;
			$Grid[1] = 100;
		}
		background(0);
	}


	// toggle camera:
	if (key == 'c' || key == 'C') {
		println($lockLive);
		if ($Live != null && $liveLength > 1) {
			for (int i = 0; i < $gridPositions; i++) {
				if ($Grid[i] < $liveLength && !int_in_array($Grid[i], $lockLive)) {
					int ng = $Grid[i] + 1;
					if (ng >= $liveLength) {
						ng = 0;
					}
					if (!int_in_array(ng, $lockLive)) {
						$Grid[i] = ng;
					}
				}
			}
		}
	}

	// toggle grid position:
	if (key >= '1' && key <= '5') {
		int k = key - '1';
		int gp = $Grid[k];

		if ($Live != null && k < $gridPositions) {
			gp++;
			if (gp > 999) {
				gp = 0;
			} else if (gp > 100) {
				gp = 999;
			} else if (gp >= $liveLength) {
				gp = 100;
			}

			$Grid[k] = gp;
			background(0);
		}
	}

	// grid control:
	if (key == 'g' || key == 'G') {
		$gridPositions++;
		if ($gridPositions > 5) {
			$gridPositions = 2;
		}
		background(0);
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
	if ((key >= '6' && key <= '9') || key == '0') {
		int fx = 0;
		if (key == '0') {
			fx = 5;
		} else {
			fx = key - '5';
		}
		if ($FX == fx ) {
			$FX = 0; // off
			println("Effect off.");
		} else {
			$FX = fx;
			println("Effect " + $FX + " on.");
		}
	}

	// toggle capture ratio adjust:
	/* CRASHY!
	if (key == 'a' || key == 'A') {
		if ($ratioAdjust) {
			$ratioAdjust = false;
		} else {
			$ratioAdjust = true;
		}
		liveRatioAdjust();
		background(0);
	}
	*/

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
		for (int i=0; i<$liveLength; i++) {
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
