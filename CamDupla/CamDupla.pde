/*
  DUPLA CÂMARA
  Eduardo Morais 2012 - www.eduardomorais.pt
  ---------------------------------------------------------------
  Mostra a imagem, com efeito, de duas Webcams
  (mas usa arrays para ser fácil de acrescentar mais câmaras...)

*/


// importa biblioteca de vídeo
import processing.video.*;

// declara um array de capturas:
Capture[] camaras;


// SETUP
// -------------------------------------
void setup() {
    // o comando blendMode() precisa que o ecrã esteja em modo P2D:
    size(640, 480, P2D);
    background(0);

    // lista as câmaras disponíveis, útil para ver os nomes e resoluções
    println(Capture.list());

    // prepara dois espaços para o array de câmaras
    camaras = new Capture[2];

    // prepara as câmaras -
    // temos que colocar a resolução da captura e o nome da câmara
    // EXACTAMENTE como aparece na lista de câmaras disponíveis.
    // o programa não funciona sem que ajustem isto:
    camaras[0] = new Capture(this, 640, 480, "Microsoft LifeCam");
    camaras[1] = new Capture(this, 640, 480, "USB 2.0 VGA UVC WebCam");

    // percorre o array de câmaras e inicia-as
    for (int i = 0; i < camaras.length; i++) {
        camaras[i].start();
    }
}


// DRAW
// -------------------------------------
void draw() {

    // vamos verificar se as câmaras estão todas OK
    // e disponíveis:
    boolean ok = true;
    for (int i = 0; i < camaras.length; i++) {
        // percorremos o array de câmaras e caso alguma
        // não esteja ok (o != quer dizer 'diferente de')...
        if (camaras[i] == null) {
            ok = false;
            // o comando break faz o programa 'saltar fora' do ciclo for().
            // ficamos assim com ok = false.
            println("Erro na camara: "+i);
            break;
        }
    }

    if (ok == true) {
      
        // vamos percorrer o array de camaras
        // aqui usamos uma variavel 'cam' para guardar o número da câmara actual:
        for (int cam = 0; cam < camaras.length; cam++) {
            // ler a imagem da câmara actual:
            camaras[cam].read();
            // cria a propriedade pixels[] para podermos manipulá-los:
            camaras[cam].loadPixels();

            // percorre cada linha horizontal da imagem:
            for (int iy = 0; iy < camaras[cam].height; iy++) {
                // percorre cada pixel dentro de cada linha:
                for (int ix = 0; ix < camaras[cam].width; ix++) {

                    // AQUI PODEMOS MANIPULAR A IMAGEM DE CADA CÂMARA
                    // ----------------------------------------------
                    // a relebrar que o pixel actual é
                    // camaras[cam].pixels[iy*width+ix]
                    // - que é um objecto do tipo color.

                    // CAMARA 0:
                    if (cam==0) {
                        // vamos tirar o valor de verde:
                        float g = green(camaras[cam].pixels[iy*width+ix]);
                        // vamos dizer que a cor passa a ser:
                        camaras[cam].pixels[iy*width+ix] = color(0, g, g);
                    }


                    // CAMARA 1:
                    if (cam==1) {
                        // vamos tirar o valor de vermelho:
                        float r = red(camaras[cam].pixels[iy*width+ix]);
                        // vamos dizer que a cor passa a ser:
                        camaras[cam].pixels[iy*width+ix] = color(r, r/2, 0);
                    }

                    // & etc se existirem mais câmaras

                }
            }

            // no final, actualizamos a imagem de cada câmara com as alterações:
            camaras[cam].updatePixels();
        }

        // VAMOS COLOCAR AS IMAGENS NO ECRÃ
        // ---------------------------------------------
        // vamos por o blendMode normal e apagar o fundo,
        // para que as imagens não acumulem:
        blendMode(BLEND);
        background(0);

        // vamos ligar um blendMode que adicione as imagens.
        // há outros a experimentar:
        // http://www.processing.org/reference/blendMode_.html
        blendMode(ADD);
        // vamos por a imagem de uma câmara no ecrã sem lhe mexer nas dimensões:
        image(camaras[0], 0, 0);
        // e vamos alterar a posição de origem e as dimensões de outra...
        image(camaras[1], 80, 60, 480, 360);

    } // fim do if (ok == true)

} // fim do draw()
