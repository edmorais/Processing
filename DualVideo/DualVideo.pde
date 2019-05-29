import processing.video.*;
Movie video1, video2;

void setup() {
  size(1024, 768);
  background(0);
  video1 = new Movie(this, "1.mov");
  video2 = new Movie(this, "2.mov");
  // os vídeos devem estar dentro de uma pasta chamada 'data' dentro da pasta do sketch
  video1.loop();  
  video2.loop();
}

void draw() {
  image(video1, 24, 154, 480, 360);
  image(video2, 520, 154, 480, 360);
  // var. vídeo, x, y, largura, altura
}

// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}
