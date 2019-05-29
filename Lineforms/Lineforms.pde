/**
 * ACM 05
 * Eduardo Morais 2012
 * para Processing 2.0
 *
 * Traços animados aleatóriamente, seguem o rato quando este
 * anda por cima da janela
 *
 */


// DECLARAÇÕES:

// array de traços - cada um definido pelo objecto Forma (em objecto.pde):
Forma[] tracos;
// número de objectos a gerar:
int numero = 200;


// SETUP:
void setup() {
    size(500, 500);
    background(0);

    // inicializa o array de traços com o número certo de objectos:
    tracos = new Forma[numero];

    // loop que coloca um novo objecto Forma em cada item do array:
    int i = 0; // variavel de controlo
    while (i < numero) {
        // cada novo objecto é criado com coordenadas x, y no centro da imagem,
        // uma diferença de posição aleatória e uma cor à sorte:
        tracos[i] = new Forma(width/2, height/2, int(random(3, 30)), corSorte());

        i++; // incrementa variável de controlo
    }

} // fim do setup()


// DRAW:
void draw() {
    // vamos preencher o ecrã com um rectângulo preto mas com alguma transparência,
    // para dar um efeito de desvanecimento:
    stroke(0);
    fill(0,32);
    rect(0,0,width,height);

    // loop que percorre o array de traços e executa o método desenha() em cada um:
    int i = 0;
    while (i < numero) {
        tracos[i].desenha();
        i++;
    }

} // fim do draw()


/*
 * Função que cria uma cor aleatória.
 * Devolve dados do tipo color.
 */
color corSorte() {
    int r = int(random(0,255));
    int g = int(random(0,255));
    int b = int(random(0,255));
    return color(r, g, b);
}

