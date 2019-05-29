/*
  SAMPLER
  Eduardo Morais 2012 - www.eduardomorais.pt
  ---------------------------------------------------------------
  O rato grava/pára as gravações e toca os samples.
  Em alternativa pode-se usar a tecla R para gravar sucessivamente
  os samples e as teclas 1-6 para ouvir.
  ---------------------------------------------------------------
  O computador terá que ter um microfone correctamente configurado
  para isto funcionar.
  Usa a biblioteca de som Minim incluída no Processing

*/


// Importa Minim
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;


// DECLARAÇÕES
// -----------------------------------
// Objectos do Minim:
Minim minim;
// entrada de audio:
AudioInput in;
// array de gravadores de audio (um por sample):
AudioRecorder[] recorder;
// array de samples:
AudioSample[] sound;

// numero do sample a gravar:
int pad = 0;
// nome dos ficheiros gravados:
String ficheiro = "som";


// SETUP
// -------------------------------------
void setup() {
    background(0);
    size(600, 400);

    // 'Liga' o Minim:
    minim = new Minim(this);
    // Configura entrada de microfone:
    in = minim.getLineIn(Minim.STEREO, 2048);

    // vamos ter 6 gravadores para 6 sons diferentes:
    recorder = new AudioRecorder[6];
    sound = new AudioSample[6];

    // prepara gravação
    for (int i = 0; i < 6; i++) {
        // vamos preparar cada um dos seis gravadores
        // usam o input 'in' (o microfone),
        // gravam num ficheiro numerado em formato WAV:
        recorder[i] = minim.createRecorder(in, ficheiro+i+".wav", true);
    }
}


// DRAW
// -------------------------------------
void draw() {
    // na verdade não precisamos de nada aqui -
    // as coisas só acontecem quando se usa o rato ou o teclado
}


// CLICK NO RATO
// -------------------------------------
void mouseClicked() {
    // se o rato estiver dentro da janela...
    if (mouseX > 0 && mouseX < 600 && mouseY > 0 && mouseY < 400) {
        // vamos calcular o numero do sample (0-5) conforme onde se clicou
        // três quadrados de cima = 0-2, três de baixo = 3-5
        // a função floor arredonda um numero sempre para baixo:
        int p = floor(mouseY/200)*3 + floor(mouseX/200);
        // chama a função para tocar (ou se não existir, gravar) esse sample:
        playSound(p);
    }
}


// LARGA TECLA
// -------------------------------------
void keyReleased() {
    // Tecla R : grava
    if (key == 'r' || key == 'R') {
        // grava (sempre) o som com o numero da global 'pad'
        // (mesmo que já se tenham gravado todos os samples,
        // neste caso grava por cima):
        recSound(pad);
    }

    // Teclas 1-6: toca
    if (key >= '1' && key <= '6') {
        // o caracter 1 tem um código ASCII particular,
        // mas se o subtraírmos '1' - '1' dá 0.
        // como os outros algarismos se seguem, '2'-'1'=1, etc...
        int p = key - '1';
        // toca (ou grava se não existir) esse som:
        playSound(p);
    }
}


// TOCA UM SAMPLE
// int p : numero do sample a tocar
// -----------------------------------
void playSound(int p) {
    // vamos verificar se o sample existe (não é nulo)...
    if (sound[p] != null) {
        // toca o sample:
        println("Toca "+p);
        sound[p].trigger();

    // senão temos é que o gravar...
    } else {
        recSound(p);
    }
}


// GRAVA UM SAMPLE
// int p : numero do sample a tocar
// -----------------------------------
void recSound(int p) {
    // vamos por a global pad = p
    // (para poder por a gravar com o rato mas parar com a tecla R)
    pad = p;

    // se já estivermos a gravar...
    if (recorder[pad].isRecording()) {
        // temos que parar e gravar o ficheiro:
        recorder[pad].endRecord();
        recorder[pad].save();
        println("Gravação parada.");

        // vamos desenhar um rectângulo na janela:
        drawPad(false);

        // vamos carregar o ficheiro que acabámos de gravar,
        // para que esteja disponível para tocar:
        sound[pad] = minim.loadSample(ficheiro+pad+".wav", 2048);

        // vamos incrementar a global pad, para que da próxima vez
        // que usemos a tecla R o som seja gravado no espaço seguinte
        pad++;
        // ... mas sempre dentro dos espaços entre 0 e 5:
        if (pad > 5) {
            pad = 0;
        }

    // ...senão (estivermos a gravar) vamos gravar o som:
    } else {
        recorder[pad].beginRecord();

        // e desenhamos um rectângulo diferente:
        drawPad(true);
        println("Gravação "+pad+" iniciada.");
    }
}


// DESENHA RECTÂNGULOS NO ECRÃ
// boolean rec: conforme queiramos um 'rectângulo de gravação' ou 'normal'
// ----------------------------------------------------------------------
void drawPad(boolean rec) {
    noStroke();

    // conforme a global pad vamos calcular as coordenadas de origem para
    // o rectangulo a desenhar:
    int ox = pad * 200;
    int oy = 0;
    if (ox > 400) {
        ox = ox - 600;
        oy = 200;
    }
    // vamos tirar uma cor à sorte:
    color cor = color(random(100,255), random(0,160), random(0, 100));

    // se estiver a gravar, desenha um rectangulo vermelho e mais pequeno:
    if (rec) {
        fill(0);
        rect(ox, oy, 200, 200);
        stroke(#FF0000);
        rect(ox+50, oy+50, 100, 100);

    // senão - se estiver disponível para tocar - desenha um rectangulo
    // cheio e com a cor à sorte:
    } else {
        fill(cor);
        rect(ox, oy, 200, 200);
    }

}


// STOP
// o Minim aconselha desligar tudo ao sair do programa
// para libertar a placa de som
// -----------------------------------
void stop() {
  in.close();
  minim.stop();
  super.stop();
}
