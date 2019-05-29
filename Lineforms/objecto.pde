/**
 * ACM 05
 * Eduardo Morais 2012
 * para Processing 2.0
 *
 * -------------------
 *
 * Objecto Forma
 * Define um traço animado
 *
 */


// cria uma classe de objectos chamada Forma:
class Forma {

    // PROPRIEDADES

    // coordenadas de início do traço:
    int oldX, oldY;
    // diferença máxima permitida entre coordenadas iniciais e finais:
    int diferenca;
    // cor do traço:
    color cor;


    /*
     * CONSTRUTOR - executado sempre que um novo objecto é criado.
     * Recebe valores temporários e insere-os nas propriedades do objecto.
     *
     * _x, _y : coordenadas de início do traço
     * _dif : diferença máxima permitida entre coordenadas iniciais e finais
     * _c : cor do traço
     */
    Forma(int _x, int _y, int _dif, color _c) {
        oldX = _x;
        oldY = _y;
        diferenca = _dif;
        cor = _c;
    }


    /*
     * DESENHA O TRAÇO (deve ser chamada em cada draw())
     */
    void desenha() {

        // faz com que a diferença máxima permitida seja mudada de vez em quando (ex. 2 em 20 vezes):
        if (random(0,20) > 18) {
            diferenca = int(random(3, 30));
        }

        // declara coordenadas finais do traço:
        int newX, newY;

        // SE - o rato estiver em cima da janela (com 20 pixels de margem):
        if (mouseX > 20 && mouseX < width-20 && mouseY > 20 && mouseY < height-20) {

            // se o rato estiver à direita do x inicial:
            if (mouseX > oldX) {
                // o x final aumenta (vai para a direita):
                newX = oldX + int(random(0,diferenca));
            } else {
                // senão o x final diminui (vai para a esquerda):
                newX = oldX - int(random(0,diferenca));
            }

            // se o rato estiver abaixo do y inicial:
            if (mouseY > oldY) {
                // o y final aumenta (vai para baixo):
                newY = oldY + int(random(0,diferenca));
            } else {
                // senão o y final diminui (vai para cima):
                newY = oldY - int(random(0,diferenca));
            }

        // SENÃO (o rato está fora da janela):
        } else {
            // faz as coordenadas finais estarem a uma certa distancia das iniciais
            // (no máximo o valor de 'diferenca'):
            newX = oldX + int(random(0-diferenca,diferenca));
            newY = oldY + int(random(0-diferenca,diferenca));
        }

        // desenha a linha só se as coordenadas finais estiverem dentro da janela:
        if (newX > 0 && newX < width && newY > 0 && newY < height) {

            // escolhe a cor e faz a linha:
            stroke(cor);
            line(oldX, oldY, newX, newY);

            // faz com que as coordenadas iniciais (para a próxima vez)
            // sejam iguais às coordenadas finais desta linha:
            oldX = newX;
            oldY = newY;
        }

    } // fim do desenha()

} // fim da classe
