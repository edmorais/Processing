class Lineform {

  int posX, posY, newX, newY;
  color linecolor;
  int diff;
  
  Lineform(int startX, int startY, color cor, int difference) {
    posX = startX;
    posY = startY;
    diff = difference;
    linecolor = cor;
  }
  
  void update(int lX, int lY) {
    
    if (lX > posX) {
     newX = posX + int(random(0, diff));
    } else {
     newX = posX - int(random(0, diff));
    } 
    if (lY > posY) {
     newY = posY + int(random(0, diff));
    } else {
     newY = posY - int(random(0, diff));
    } 
    
    if (random(0, 50) > 45) {
      diff = int(random(1,(random(2, rdiff))));
    }
  
    if (newX > 0 && newX < width && newY > 0 && newY < width) {
      int transp = int(map(diff, 1, rdiff, 255, 127));
      
      stroke(linecolor, transp);
     // blendMode(ADD);
      line(posX, posY, newX, newY);
      posX = newX;
      posY = newY;    
    }
  
  }
}
