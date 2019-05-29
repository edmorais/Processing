/*
 * Dual live / recorded video projection (Processing 1.5 only!)
 * by Eduardo Morais 2012
 */

/*
 * Utilities
 */

// returns all the videos in a directory as an array of Strings 
String[] listFileNames(String dir) {
	String VIDEO_PATTERN = "([^\\s]+((.*/)*.+\\.(?i)("+$okVideos+"))$)";
	Pattern pattern = Pattern.compile(VIDEO_PATTERN);
	File file = new File(dir);
	if (file.isDirectory()) {
		String names[] = file.list();
		int v = 0;
		String[] videos = new String[names.length];
		for (int i = 0; i < names.length; i++) {
			Matcher matcher = pattern.matcher(names[i]);
			if (matcher.matches()) {
				videos[v] = names[i];
				v++;
			} else {
				videos = shorten(videos);
			}
		}
		return videos;
	} else {
		// If it's not a directory
		return null;
	}
}

