/*
 * Multiple live / recorded video projection (Processing 1.5 only!)
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

// int in array?
static boolean int_in_array(int n, int[] arr) {
	if (arr != null && arr.length > 0) {
		for (int i = 0; i < arr.length; i++) {
			if (arr[i] == n) {
				return true;
			}
		}
	}
	return false;
}

/*
 * Select Folder
 */
String folderSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
    return null;
  } else {
    println("User selected " + selection.getAbsolutePath());
    return selection.getAbsolutePath();
  }
}


/**
 * simple convenience wrapper object for the standard
 * Properties class to return pre-typed numerals
 */
class Config extends Properties {

  boolean getBoolean(String id, boolean defState) {
    return boolean(getProperty(id,""+defState));
  }

  int getInt(String id, int defVal) {
    return int(getProperty(id,""+defVal));
  }

  float getFloat(String id, float defVal) {
    return float(getProperty(id,""+defVal));
  }

  String getString(String id, String defVal) {
    return getProperty(id,""+defVal);
  }

  int[] getIntArray(String id) {
 	String[] str = getProperty(id).split("[, ]+");
 	int[] arr = new int[str.length];
 	for(int i = 0; i < arr.length; i++) {
 		arr[i] = -1;
 	}
  	for(int i = 0; i < str.length; i++) {
  		if (int_in_array(int(str[i]), arr) == false) {
	 	   arr[i] = int(str[i]);
		} else {
			arr = shorten(arr);
		}
	}
	println(arr);
	return arr;
  }
}
