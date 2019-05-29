import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import processing.video.*; 
import sojamo.drop.*; 
import java.util.*; 
import java.text.*; 
import java.awt.event.KeyEvent; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Slitscanner extends PApplet {

/*
 * SlitScanner
 * by Eduardo Morais 2012-2013 - www.eduardomorais.pt
 *
 */


// Libs

  // http://www.sojamo.de/libraries/drop/
// needed by 2.08+




// GLOBALS (denoted by $)
String $version = "1.2";

int $windowWidth = 854;
int $windowHeight = 480;  // screen size
int $drawPos;  // draw X postion
int $direction;  // drawing direction (1 / -1)

Capture $cam;  // camera object
Movie $video;
PImage $feed;
SDrop $drop; // drag and drop object

int $capWidth = 640;
int $capHeight = 480;  // capture dimensions
int $scanPos;  // line to capture
int $pxl;  // a pixel

// default options:
boolean $live = true;
boolean $pip = false;
boolean $scroll = false;
boolean $scrollDir = false;
boolean $vertical = false;
boolean $uiShow = true;
boolean $stopped = false;
String $saveFolder = "Saved Images";
boolean $savePNG = true;

// allowed video file extensions:
String[] $videoExts = {"mov", "avi", "mp4", "mpg", "mpeg"};

// control flags:
boolean $saving = false;
boolean $pressing = false;
boolean $dragged = false;
boolean $showHelp = false;
int $camNum = 0;
String $videoFile;
int $stepping = 1;
int $cycle = 0;

PGraphics $buffer, $help;  // scanned image buffer
UI $ui;  // ui object

String $helpText;
String $msgs;
int $msgCycle = 0;
String $fontName = "ui/type/leaguegothic-regular.ttf";
PFont $font, $defaultFont;


/*
 * SETUP
 */
public void setup() {

    // try to load config file:
    Config cfg = new Config();

    try {
        // load a configuration from a file inside the data folder
        InputStream cf = openStream("config.txt");
        if (cf != null) {
            cfg.load(cf);

            // all values returned by the getProperty() method are Strings
            // so we need to cast them into the appropriate type ourselves
            // this is done for us by the convenience Config class

            $windowWidth       = cfg.getInt("win.width", $windowWidth);
            $windowHeight      = cfg.getInt("win.height", $windowHeight);
            $capWidth          = cfg.getInt("cap.width", $capWidth);
            $capHeight         = cfg.getInt("cap.height", $capHeight);

            $scroll            = cfg.getBoolean("opt.scroll", $scroll);
            $pip               = cfg.getBoolean("opt.pip", $pip);
            $scrollDir         = cfg.getBoolean("opt.left_to_right", $scrollDir);
            $vertical          = cfg.getBoolean("opt.left_to_right", $vertical);

            $uiShow            = cfg.getBoolean("ui.show", $uiShow);

            $saveFolder        = cfg.getString("opt.save", $saveFolder);
            $savePNG           = cfg.getBoolean("opt.png", $savePNG);
        }
    } catch(IOException e) {
        println("couldn't read config file...");
    }

    // set screen:
    $windowWidth = $windowWidth < 800 ? 800 : $windowWidth;
    $windowHeight = $windowHeight < 480 ? 480 : $windowHeight;
    size($windowWidth, $windowHeight);
    frame.setTitle("Slitscanner "+$version+" >>> press F1 for help");
    $defaultFont = createFont($fontName, 20, true);
    smooth();
    background(0);

    // initialise GUI:
    $ui = new UI(760, 50);
    if (!$uiShow) {
        noCursor();
    }
    $drop = new SDrop(this);

    // initialise camera:
    $camNum = Capture.list().length;
    
    if ($live && $camNum > 0) {
        // prepare camera and initialise scanned image buffer:
        prepareCamera();
        prepareBuffer();
    } else {
        // load a file:
        selectInput("Select a video file:", "selectVideo");
        prepareBuffer();
    }
    
    $drawPos = 0;
    $direction = $scrollDir ? 1 : -1;    


    //
    // prepare Help
    //
    $help = createGraphics(760, 400);
    $help.beginDraw();
    $help.background(0, 128);
    $font = createFont($fontName, 48, true);
    $help.fill(255);
    $help.textFont($font, 48);
    $help.text("SLITSCANNER", 19, 60);
    float hw = $help.textWidth("SLITSCANNER");
    
    $font = createFont($fontName, 20, true);
    $help.fill(255, 128);
    $help.textFont($font, 20);
    $help.text($version, hw+25, 60);

    $font = createFont($fontName, 20, true);
    $help.fill(255);
    $help.textFont($font, 20);
    hw = $help.textWidth("EDUARDO MORAIS 2012-2013");
    $help.text("EDUARDO MORAIS 2012-2013", $help.width-20-hw, 40);

    
    $help.fill(0xffFF9933);
    $help.textFont($font, 20);
    hw = $help.textWidth("WWW.EDUARDOMORAIS.PT");
    $help.text("WWW.EDUARDOMORAIS.PT", $help.width-20-hw, 60);

    $help.stroke(0xffFF9933, 192);
    $help.line(20, 72, $help.width-20, 72);
    
    $help.textFont($defaultFont, 20);
    $help.fill(255, 192);

    $helpText =
          "[ C ]  Live camera mode\n"+
          "[ O ]  Open video file\n"+
          "[ S ]  Save image\n"+
          "[ F ]  Select saved images folder\n"+
          "[ G ]  Toggle saving images as JPEG / PNG\n\n"+
          "[ V ]  Toggle viewfinder display\n"+
          "[ H ]  Toggle on-screen user interface";
    $help.text($helpText, 20, 110);

    $helpText =
          "[ M ]  Toggle static / scrolling mode\n"+
          "[ D ]  Toggle scanning direction\n"+
          "[ A ]  Toggle vertical / horizontal axis\n\n"+
          "[ SPACE BAR ]  Pause / resume scanning\n"+
          "[ ARROW KEYS ]  Adjust scan line\n"+
          "[ PG UP/DOWN ]  Adjust scanning speed\n\n"+

          "[ F 1 ]  Show keyboard shortcuts";
    $help.text($helpText, 400, 110);
    $help.endDraw();
    
    textFont($defaultFont, 20);    
}

/*
 * SlitScanner
 * by Eduardo Morais 2012 - www.eduardomorais.pt
 *
 */

/*
 * PREPARE WEBCAM
 */
public void prepareCamera() {
    if ($camNum > 0) {
        $cam = new Capture(this, $capWidth, $capHeight);
        $cam.start();   
        $feed = $cam;
        $live = true;
        if ($video != null) {
            $video.stop(); 
        }
        $ui.prepare();
        $msgs = "Live camera feed";
    }
}


/*
 * PREPARE VIDEO FILE
 */
public void prepareVideo() {
    if ($videoFile != null) {
        if ($video != null) {
            $video.stop(); 
        }
        $video = new Movie(this, $videoFile);
        $video.jump(0);
        $video.loop();
        $video.play();
        $video.read(); // we need to know its size before calling prepareBuffer()
        $feed = $video;
        $live = false;        
        if ($cam != null) {
            $cam.stop(); 
        }
    }
}


/*
 * Select video file
 */
public void selectVideo(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
        $videoFile = null;
    } else {
        println("User selected " + selection.getAbsolutePath());
        String fn = selection.getName();
        String fext = fn.substring(fn.lastIndexOf(".") + 1, fn.length());
        String ext;
        boolean ok = false;
        
        for (int i = 0; i < $videoExts.length; i++) {
            ext = $videoExts[i];
            if (ext.equalsIgnoreCase(fext)) {
                ok = true;
                break;      
            }
        }
        
        if (ok) {
            $videoFile = selection.getAbsolutePath();
            boolean s = $stopped;
            $stopped = true;
            prepareVideo();
            prepareBuffer();
            $stopped = s;
            $ui.prepare();
            $msgs = "Loaded " + $videoFile;
        } else if (!$dragged) {
            selectInput("Please select a supported video file...", "selectVideo"); 
        }
    }
    $dragged = false;
}


/*
 * PREPARE DRAWING BUFFER
 */
public void prepareBuffer() {
    int fw = width;
    int fh = height;
  
    if ($feed != null && $feed.width > 0 && $feed.height > 0) {
        fw = $feed.width;
        fh = $feed.height;
    }
  
    if ($vertical) { // vertical scanning
        $buffer = createGraphics(width, fw);
        $scanPos = fh/2;
    } else { // horizontal scanning
        $buffer = createGraphics(width, fh);
        $scanPos = fw/2;
    }
    $buffer.beginDraw();
    $buffer.background(0);
    $buffer.endDraw();
}


/*
 * Select Folder
 */
public void folderSelected(File selection) {
    if (selection == null) {
        println("Window was closed or the user hit cancel.");
    } else {
        println("User selected " + selection.getAbsolutePath());
        $saveFolder = selection.getAbsolutePath();
        $msgs = "Selected save folder " + $saveFolder;
    }
}


/*
 * Save image with the date in the filename
 */
public void saveImage() {
    String ff = $savePNG ? ".png" : ".jpg";
    Date now = new Date();
    SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd_hhmmss");
    save($saveFolder+"/scan_" + df.format(now) + ff);
    $msgs = "Saved image";
}


/*
 * DRAW
 */
public void draw() {
    
    boolean ok = false; 
  
    if ($live && $cam != null && $cam.available()) {
        ok = true;
        $cam.read(); 
    } else if ($video != null && $video.available()) {
        ok = true;
        $video.read();
    }
  
    if (ok) {
        
        // step counter:
        $cycle++;
        if ($cycle % $stepping == 0) {
            // reset cycle:
            $cycle = 0;
          
            $feed.loadPixels();
            $buffer.beginDraw();
            $buffer.loadPixels();
    
            if ($scroll && !$stopped) {
            // scroll the entire buffer:
    
                if ($direction > 0) {
                    $drawPos = $buffer.width - 1;
                } else {
                    $drawPos = 0;
                }
    
                for (int iy = 0; iy < $buffer.height; iy++) {
    
                    if ($direction > 0) {
                        // scroll right:
                        for (int ix = 0; ix < $buffer.width-1; ix++) {
                            $pxl = $buffer.pixels[iy*$buffer.width+ix+1];
                            $buffer.pixels[iy*$buffer.width+ix] = $pxl;
                        }
                    } else {
                        // scroll left:
                        for (int ix = $buffer.width-1; ix > 0; ix--) {
                            $pxl = $buffer.pixels[iy*$buffer.width+ix-1];
                            $buffer.pixels[iy*$buffer.width+ix] = $pxl;
                        }
                    }
                }
    
            } else if (!$stopped) {
            // not scrolling:
    
                $drawPos = $drawPos + $direction;
    
                // wrap around:
                if ($drawPos >= $buffer.width) {
                    $drawPos = 1;
                }
                if ($drawPos <= 0) {
                    $drawPos = $buffer.width-1;
                }
            }
    
            if (!$stopped) {
             // get the scanline:
    
                int scanEnd = $vertical ? $feed.width : $feed.height;
                for (int i = 0; i < scanEnd; i++) {
                    if ($vertical) {
                        $pxl = $feed.pixels[$scanPos*$feed.width+i];
                    } else {
                        $pxl = $feed.pixels[i*$feed.width+$scanPos];
                    }
    
                    // draw the scanline:
                    $buffer.pixels[i*$buffer.width+$drawPos] = $pxl;
                }
            }
    
            // draw buffer:
            $buffer.updatePixels();
            $buffer.endDraw();            
        
        } // end step counter
        
        // draw buffer:
        image($buffer, 0, 0, width, height);

        // show picture-in-picture (cam preview):
        if ($pip || $pressing) {
            float pos = 20;
            float cw = width/4;
            float ch = ($feed.height/PApplet.parseFloat($feed.width))*(width/4);
            image($feed, pos, pos, cw, ch);

            // draw scanline:
            stroke(0xffFF9933, 128);
            if ($vertical) {
                float cy = map($scanPos, 0, $feed.height, 0, ch);
                line(pos, pos+cy, cw+pos-1, pos+cy);
            } else {
                float cx = map($scanPos, 0, $feed.width, 0, cw);
                line(cx+pos, pos, cx+pos, ch+pos-1);
            }
           
        } 
        
        // draw messages:
        if ($msgCycle < 50 && $msgs != "") {
            fill(255);
            float tw = textWidth($msgs);
            text($msgs, width-20-tw, 36);
            $msgCycle++;
        } else {
            // clear messages:
            $msgs = "";
            $msgCycle = 0;
        }
        
        // flash screen on save:
        if ($saving) {
            background(255);
            $saving = false;
        }
        
        // show UI:
        if ($uiShow) {
            $ui.show();
        }
    
        // show help overlay:
        if ($showHelp) {
            image($help, (width-$help.width)/2, (height-$help.height)/2-40);
        }
    }
    
    if ($feed == null) {
        background(0);
        $ui.show();
        if ($showHelp) {
            image($help, (width-$help.width)/2, (height-$help.height)/2-40);
        }
    }
}


/*
 * SlitScanner
 * by Eduardo Morais - www.eduardomorais.pt
 */

/*
 * Keyboard
 */

public void keyReleased() {
  
    // camera mode
    if (key == 'c' || key == 'C') {
        if ($camNum > 0 && !$live) {
            prepareCamera();
            prepareBuffer();
        }
    }

    // video file mode
    if (key == 'o' || key == 'O') {
        selectInput("Select a video file:", "selectVideo");
    }

    // camera preview
    if (key == 'v' || key == 'V') {
        $pip = !$pip;
    }

    // scroll mode
    if (key == 'm' || key == 'M') {
        $buffer.background(0);
        $scroll = !$scroll;
    }

    // direction
    if (key == 'd' || key == 'D') {
        $buffer.background(0);
        $scrollDir = !$scrollDir;
        $direction = 0 - $direction;
        $drawPos = 0;
    }

    // pause
    if (key == ' ') {
        $stopped = !$stopped;
    }

    // orientation
    if (key == 'a' || key == 'A') {
        $vertical = !$vertical;
        prepareBuffer();
    }

    // save png
    if (key == 'S' || key == 's') {
        image($buffer, 0, 0, width, height);
        saveImage();
        $saving = true;
    }

    // select save folder
    if (key == 'F' || key == 'f') {
        selectFolder("Where do you want to save images?", "folderSelected");
    }
    
    // select JPEG/PNG
    if (key == 'g' || key == 'G') {
        $savePNG = !$savePNG;
        $msgs = $savePNG ? "Images will be saved as PNG" : "Images will be saved as JPEG";
    }

    // show/hide UI
    if (key == 'h' || key == 'H') {
        $uiShow = !$uiShow;
        if (!$uiShow) {
            noCursor();
        }
    }


    if (key == CODED) {

        // show help:
        if (keyCode == KeyEvent.VK_F1) {
            $showHelp = !$showHelp;
            image($buffer, 0, 0, width, height);
        }
        
        $pressing = false;
        // move scan position
        if (keyCode == LEFT || keyCode == RIGHT || keyCode == UP || keyCode== DOWN) {
            // controls whether to overlay camera preview:
            
        }
    }

    // redraw UI
    $ui.prepare();
}



/*
 * KEY PRESSED
 */
public void keyPressed() {

    // move scan position
    if (key == CODED) {
        if ((keyCode == LEFT && !$vertical)
        || (keyCode == UP && $vertical)) {
            $pressing = true;
            $scanPos--;
            if ($scanPos <10) {
                $scanPos = 5;
            }
        }

        if (keyCode == RIGHT && !$vertical) {
            $pressing = true;
            $scanPos++;
            if ($scanPos > $feed.width-10) {
                $scanPos = $feed.width-5;
            }
        }

        if (keyCode == DOWN && $vertical) {
            $pressing = true;
            $scanPos++;
            if ($scanPos > $feed.height-10) {
                $scanPos = $feed.height-5;
            }
        }
        
        // scanning stepping
        if (keyCode == KeyEvent.VK_PAGE_DOWN) {
            if ($stepping < 100) {
                $stepping++;
                $msgs = "Scanning every "+$stepping+" frames";
            }

        }
        if (keyCode == KeyEvent.VK_PAGE_UP) {
            if ($stepping > 1) {
                $stepping--;
                $msgs = $stepping > 1 ? "Scanning every "+$stepping+" frames" : "";
            }
        }
        
        // get rid of help on keys:
        if (keyCode != KeyEvent.VK_F1) {
            $showHelp = false;
        }
    } else {
        $showHelp = false;
    }   
}

/*
 * SlitScanner
 * by Eduardo Morais - www.eduardomorais.pt
 */

/*
 * UI
 */


class UI {

    /*
     * Properties
     */

    // buttons:
    String files[]   = {"stopped", "pip",    "scroll", "dir",    "axis",   "save",  "folder",  "live",  "load",  "png"};

    // positions:
    int offsets[][]  = {{10,5},    {275,5},  {370,5},  {455,5},  {520,5},  {670,5}, {590,5},   {190,5}, {105,5}, {630,5}};

    // assets folder:
    String assetsDir = "ui/";

    PGraphics buffer;
    int posX, posY;
    PImage images[];



    /*
     * Constructor
     * (width, height)
     */
    UI(int w, int h) {
        buffer = createGraphics(w, h);
        images = new PImage[files.length];

        prepare();

        posX = (width - w) / 2;
        posY = (height - h) - 30;
    }


    /*
     * Load and prepare buttons:
     */
    public void prepare() {
        for (int i = 0; i < files.length; i++) {
            images[i] = loadImage(assetsDir+files[i]+".png");
            if (
            (files[i] == "pip" && $pip) ||
            (files[i] == "scroll" && $scroll) ||
            (files[i] == "dir" && $scrollDir) ||
            (files[i] == "stopped" && $stopped) ||
            (files[i] == "axis" && $vertical) ||
            (files[i] == "live" && $live) ||
            (files[i] == "png" && $savePNG)
            ) {
                images[i] = loadImage(assetsDir+files[i]+"_on.png");
            }
            else if (
            (files[i] == "live" && $camNum < 1)
            ) {
                images[i] = loadImage(assetsDir+files[i]+"_disabled.png");
            }
        }
    }


    /*
     * Render UI:
     */
    public void show() {
        // only if mouse over the window:
        if (mouseX > 20 && mouseX < width-20 && mouseY > 20 && mouseY < height-20) {

            // Draw buttons:
            buffer.beginDraw();
            buffer.background(0, 128);

            int s = 0; // mouse cursor? 1 or more points for hand

            for (int i = 0; i < files.length; i++) {
                buffer.image(images[i], offsets[i][0], offsets[i][1]);
                if (isOver(i)) {
                    // exclude these:
                    if (
                    (files[i] == "live" && ($camNum < 1 || $live))
                    ) {
                        continue;
                    }
                    // position button:
                    buffer.image(images[i], offsets[i][0], offsets[i][1]);
                    s++;
                }
            }

            if (s > 0) {
                cursor(HAND);
            } else {
                cursor(ARROW);
            }

            // position UI:
            buffer.endDraw();
            image(buffer, posX, posY);
        }
    }

    /*
     * Mouse over image #?
     */
    public boolean isOver(int off) {
        // find out where that button is:
        int offX = offsets[off][0];
        int offY = posY + offsets[off][1];
        offX = offX + posX;

        if (mouseX > offX && mouseX < images[off].width+offX && mouseY > offY && mouseY < images[off].height+offY) {
            return true;
        }
        return false;
    }

} // end class UI


/*
 * Mouse Clicked
 */
public void mouseClicked() {

    // pause
    if ($ui.isOver(0)) {
        $stopped = !$stopped;
    }

    // camera preview
    if ($ui.isOver(1)) {
        $pip = !$pip;
    }

    // scroll
    if ($ui.isOver(2)) {
        $buffer.background(0);
        $scroll = !$scroll;
    }

    // direction
    if ($ui.isOver(3)) {
        $scrollDir = !$scrollDir;
        $direction = 0 - $direction;
        $drawPos = 0;
    }

    // axis
    if ($ui.isOver(4)) {
        $vertical = !$vertical;
        prepareBuffer();
    }

    // save
    if ($ui.isOver(5)) {
        image($buffer, 0, 0, width, height);
        saveImage();
        $saving = true;
    }

    // select save folder
    if ($ui.isOver(6)) {
        selectFolder("Where do you want to save images?", "folderSelected");
    }
    
    // camera mode
    if ($ui.isOver(7)) {
        if ($camNum > 0 && !$live) {
            prepareCamera();
            prepareBuffer();
        }
    }
    
    // video file mode
    if ($ui.isOver(8)) {
        selectInput("Select a video file:", "selectVideo");
    }
    
    // select JPEG/PNG
    if ($ui.isOver(9)) {
        $savePNG = !$savePNG;
        $msgs = $savePNG ? "Images will be saved as PNG" : "Images will be saved as JPEG";
    }
    
    // get rid of help on click:
    $showHelp = false;

    // redraw:
    $ui.prepare();
}


/*
 * Drag & drop
 */
public void dropEvent(DropEvent dropped) {
    if (dropped.isFile()) {
        $dragged = true;
        selectVideo(dropped.file());
    }
}
/*
 * SlitScanner
 * by Eduardo Morais - www.eduardomorais.pt
 */

/*
 * Utilities
 */


/**
 * simple convenience wrapper object for the standard
 * Properties class to return pre-typed numerals
 */
class Config extends Properties {

    public boolean getBoolean(String id, boolean defState) {
        return PApplet.parseBoolean(getProperty(id,""+defState));
    }

    public int getInt(String id, int defVal) {
        return PApplet.parseInt(getProperty(id,""+defVal));
    }

    public float getFloat(String id, float defVal) {
        return PApplet.parseFloat(getProperty(id,""+defVal));
    }

    public String getString(String id, String defVal) {
        return getProperty(id,""+defVal);
    }

    public int[] getIntArray(String id) {
        String[] str = getProperty(id).split("[, ]+");
        int[] arr = new int[str.length];
        for(int i = 0; i < arr.length; i++) {
            arr[i] = -1;
        }
        for(int i = 0; i < str.length; i++) {
            if (int_in_array(PApplet.parseInt(str[i]), arr) == false) {
                arr[i] = PApplet.parseInt(str[i]);
            } else {
                arr = shorten(arr);
            }
        }
        println(arr);
        return arr;
    }

} // end class Config


/*
 * INTEGER IN ARRAY?
 */
public static boolean int_in_array(int n, int[] arr) {
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
 * WAIT millisseconds
 */
public void wait(int ms) {
    long st = millis();
    while (st + ms > millis()) {
        // wait
    }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "Slitscanner" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
