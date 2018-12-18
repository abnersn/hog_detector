# Detecção de Faces com Histogramas de Gradientes Orientados

## Requisitos
Os softwares abaixo (ou versões compatíveis) são necessários para executar os scripts.
* [MATLAB r2017a](https://www.mathworks.com/products/matlab.html);
* [Mathworks Image Acquisition Toolbox](https://www.mathworks.com/products/imaq.html);
* [LibSVM 3.23](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) (incluso no repositório);

## Como executar
O repositório já inclui classificadores SVM pré treinados com parte dos dados (200 amostras positivas e 20.000 negativas), nos arquivos `svm_model_sobel.mat` e `svm_model_prewitt.mat`. Para efetuar a detecção, execute o script `detect.m`, especificando o arquivo de imagem na linha 21 e o filtro a ser utilizado na linha 19.

## Como treinar um novo modelo
Para treino do classificador SVM, são necessárias amostras de imagens com tamanho 32x32 que contém faces (positivas) e que não contém (negativas). Para melhor desempenho, as amostras devem apresentar similaridade com os blocos da janela deslizante que serão processados durante a fase de detecção. As imagens devem ser organizadas conforme a seguinte estrutura de diretórios:
```
- data
    |_ positive
        |_ positive_1.jpg
        |_ positive_2.jpg
        |_ ...
    |_ negative
        |_ negative_1.jpg
        |_ negative_2.jpg
        |_ ...
```
A pasta `data` contém amostras já preparadas, com 200 exemplares positivos e 20 mil negativos. Uma vez organizados os dados para treino, basta executar o script `train.m`, especificando os parâmetros de treino desejados. O script deve produzir um arquivo `svm_model_sobel.mat` ou `svm_model_prewitt.mat`, conforme o filtro escolhido. Os arquivos `.mat` contém os modelos SVM usados para executar a detecção.

**Autor:**
Abner Sousa Nascimento

# Documentação

- [Introdução](#introdução-e-justificativa)
- [Fundamentação Teórica](#fundamentação-teórica)
  - [Sinais bidimensionais discretos e imagens digitais](#sinais-bidimensionais-discretos-e-imagens-digitais)
  - [Processamento de sinais bidimensionais discretos](#processamento-de-sinais-bidimensionais-discretos)
  - [Sistemas lineares invariantes](#sistemas-lineares-invariantes)
  - [Convolução](#convolução)
  - [Filtros diferenciadores](#filtros-diferenciadores)
  - [Filtro de Prewitt](#filtro-de-prewitt)
  - [Filtro de Sobel](#filtro-de-sobel)
  - [Histogramas de gradientes](#histogramas-de-gradientes)
  - [Classificação](#classificação)
- [Metodologia](#metodologia)
  - [Aquisição e pré-processamento dos dados](#aquisição-e-pré-processamento-dos-dados)
  - [Cálculo dos gradientes e histogramas](#cálculo-dos-gradientes-e-histogramas)
  - [Treino do classificador e testes de desempenho](#treino-do-classificador-e-testes-de-desempenho)
- [Resultados](#resultados)
  - [Aplicação dos filtros](#aplicação-dos-filtros)
  - [Visualização dos histogramas](#visualização-dos-histogramas)
  - [Resultados nas bases de teste](#resultados-nas-bases-de-teste)
- [Conclusões](#conclusões)

## Introdução

A capacidade de reconhecer rostos familiares é uma habilidade inata dos seres humanos, fruto evolutivo da necessidade de interação social e comunicação entre indivíduos de uma espécie na qual a visão é um dos principais sentidos. Entretanto, em termos computacionais, essa habilidade não é trivial, uma vez que a representação matemática da face, em seus diversos ângulos e formas, é inerentemente não-linear e não-convexa. Na ilustração abaixo, encontram-se exemplificados graus de variabilidade possíveis na imagem de um rosto humano.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/variacoes_.jpg" alt=" Exemplos de possíveis variações de aspectos como ângulo, expressão, oclusão e condições de iluminação para imagens de faces." style="width:80.0%" />
<figcaption>
Exemplos de possíveis variações de aspectos como ângulo, expressão, oclusão e condições de iluminação para imagens de faces.
</figcaption>
</figure>

Porém, independentemente do nível de sofisticação do método empregado na tarefa de identificação, o passo primordial no fluxo de implementação geral de sistemas de reconhecimento facial passa pela segmentação da região da face, _i.e._, a detecção facial. Tal fase, por sua vez, depende de uma série de operações de filtragem e pré-processamento que viabilizam a extração das características descritivas imprescindíveis à maioria dos algoritmos e metodologias. Assim, a compreensão das imagens enquanto entidades matemáticas que codificam mensagens e, portanto, estão intrinsecamente ligadas ao conceito de sinais, revela-se uma tarefa de crítica importância na implementação de sistemas computacionais que buscam imitar a visão humana.

## Fundamentação Teórica

### Sinais bidimensionais discretos e imagens digitais

Um sinal bidimensional discreto pode ser matematicamente definido por uma função ![](https://latex.codecogs.com/png.latex?s%3A%20%5Cmathbb%7BZ%7D%5E2%20%5Crightarrow%20%5Cmathbb%7BC%7D), isto é, uma mapeamento de pontos representados por 2 coordenadas inteiras a um valor no plano complexo. Em analogia aos sinais unidimensionais, é possível definir um impulso bidimensional ![\delta[x, y]](https://latex.codecogs.com/png.latex?%5Cdelta%5Bx%2C%20y%5D "\delta[x, y]"), com ![](https://latex.codecogs.com/png.latex?x%2C%20y%20%5Cin%20%5Cmathbb%7BZ%7D), conforme a equação abaixo. Na figura abaixo, encontra-se uma representação gráfica da função impulso.

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Aimpulso%7D%0A%20%20%20%20%5Cdelta%5Bx%2C%20y%5D%20%3D%20%5Cbegin%7Bcases%7D%0A%20%20%20%20%20%20%20%201%5Ctext%7B%2C%20se%20%7Dx%20%3D%20y%20%3D%200%20%5C%5C%0A%20%20%20%20%20%20%20%200%20%5Ctext%7B%2C%20caso%20contr%C3%A1rio.%7D%0A%20%20%20%20%5Cend%7Bcases%7D)

Assim, qualquer sinal bidimensional pode ser representado por uma soma de impulsos deslocados nas duas dimensões e escalonados:

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Asoma%7D%0A%20%20%20%20s%5Bx%2C%20y%5D%20%3D%20%5Csum_%7Bk_1%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7D%5Csum_%7Bk_2%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7Ds%5Bk_1%2C%20k_2%5D%5Cdelta%5Bx%20-%20k_1%2C%20y%20-%20k_2%5D.)

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/impulso.jpg" alt=" Representação gráfica da função impulso bidimensional." style="width: 300px" />
<figcaption>
Representação gráfica da função impulso bidimensional.
</figcaption>
</figure>

Computacionalmente, uma imagem digital em níveis de cinza consiste numa matriz ![](https://latex.codecogs.com/png.latex?A_%7Bm%20%5Ctimes%20n%7D), cujos elementos, chamados de _pixels_, representam níveis de brilho que os componentes da mídia utilizada para exibição devem assumir. Imagens coloridas são representadas por múltiplas matrizes, denominadas canais, de modo que cada uma carrega as informações de intensidade apenas para a componente de cor à qual está associada. Neste trabalho, a fim de sintetizar as definições, apenas imagens em níveis de cinza serão consideradas nas seções que se seguem.

Uma imagem digital pode, portanto, ser representada por uma função bidimensional ![i[x, y]](https://latex.codecogs.com/png.latex?i%5Bx%2C%20y%5D "i[x, y]"), em que ![](https://latex.codecogs.com/png.latex?x) e ![](https://latex.codecogs.com/png.latex?y) representam índices de um elemento ![](https://latex.codecogs.com/png.latex?a_%7Bxy%7D) na matriz de _pixels_. Como os elementos ![](https://latex.codecogs.com/png.latex?a_%7Bxy%7D) carregam informações sobre níveis de intensidade luminosa, uma imagem ![i[x, y]](https://latex.codecogs.com/png.latex?i%5Bx%2C%20y%5D "i[x, y]") é, em geral, convencionada como um sinal puramente real, _i.e._, sem componentes complexas. Na figura a seguir, é possível visualizar uma imagem digital tanto em sua forma matricial quanto a função discreta bidimensional associada.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/plotdisc.jpg" alt="Uma imagem digital e o gráfico da função discreta." />
<figcaption>
Uma imagem digital e o gráfico da função discreta.
</figcaption>
</figure>

### Processamento de sinais bidimensionais discretos

### Sistemas lineares invariantes

Um sistema bidimensional é definido como um operador matemático ![](https://latex.codecogs.com/png.latex?T), que mapeia uma função bidimensional de entrada ![i[x, y]](https://latex.codecogs.com/png.latex?i%5Bx%2C%20y%5D "i[x, y]") a uma saída ![o[x, y]](https://latex.codecogs.com/png.latex?o%5Bx%2C%20y%5D "o[x, y]"). As propriedades de linearidade e invariância também podem estabelecidas para os sistemas bidimensionais, da seguinte forma:

- **Linearidade**: ![T{ai_1[x, y] + bi_2[x, y]} = aT{i_1[x, y]} + bT{i_2[x, y]}](https://latex.codecogs.com/png.latex?T%5C%7Bai_1%5Bx%2C%20y%5D%20%2B%20bi_2%5Bx%2C%20y%5D%5C%7D%20%3D%20aT%5C%7Bi_1%5Bx%2C%20y%5D%5C%7D%20%2B%20bT%5C%7Bi_2%5Bx%2C%20y%5D%5C%7D "T{ai_1[x, y] + bi_2[x, y]} = aT{i_1[x, y]} + bT{i_2[x, y]}").

- **Invariância**: ![T{i[x - x_0, y - y_0]} = o[x - x_0, y - y_0]](https://latex.codecogs.com/png.latex?T%5C%7Bi%5Bx%20-%20x_0%2C%20y%20-%20y_0%5D%5C%7D%20%3D%20o%5Bx%20-%20x_0%2C%20y%20-%20y_0%5D "T{i[x - x_0, y - y_0]} = o[x - x_0, y - y_0]").

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/SLIT_2D.jpg" alt="[fig:slit2d] Representação em blocos de um sistema bidimensional." />
<figcaption>
Representação em blocos de um sistema bidimensional.
</figcaption>
</figure>

### Convolução

Se um sistema ![](https://latex.codecogs.com/png.latex?T) observa as propriedades de linearidade e invariância no tempo, pode-se proceder conforme a equação abaixo para se estabelecer a operação de convolução em duas dimensões. Analogamente aos sinais unidimensionais, a função ![h[x, y]](https://latex.codecogs.com/png.latex?h%5Bx%2C%20y%5D "h[x, y]") também é denominada resposta ao impulso do sistema ![](https://latex.codecogs.com/png.latex?T). A convolução em duas dimensões guarda as mesmas propriedades da convolução simples, isto é, a comutatividade, associatividade e distributividade.

![](https://latex.codecogs.com/png.latex?%5Cbegin%7Baligned%7D%0A%20%20%20%20o%5Bx%2Cy%5D%20%26%3D%20T%5Cleft%5C%7B%20i%5Bx%2C%20y%5D%20%5Cright%5C%7D%20%5C%5C%0A%20%20%20%20%20%26%3D%20T%5Cleft%5C%7B%20%5Csum_%7Bk_1%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7D%5Csum_%7Bk_2%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7Ds%5Bk_1%2C%20k_2%5D%5Cdelta%5Bx%20-%20k_1%2C%20y%20-%20k_2%5D%20%5Cright%5C%7D%20%5C%5C%0A%20%20%20%20%20%26%3D%20%5Csum_%7Bk_1%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7D%5Csum_%7Bk_2%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7Ds%5Bk_1%2C%20k_2%5DT%5C%7B%5Cdelta%5Bx%20-%20k_1%2C%20y%20-%20k_2%5D%5C%7D%20%5C%5C%0A%20%20%20%20%20%26%3D%20%5Csum_%7Bk_1%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7D%5Csum_%7Bk_2%20%3D%20-%5Cinfty%7D%5E%7B%5Cinfty%7Ds%5Bk_1%2C%20k_2%5Dh%5Bx%20-%20k_1%2C%20y%20-%20k_2%5D%20%5C%5C%0A%20%20%20%20%20o%5Bx%2C%20y%5D%20%26%3D%20i%5Bx%2C%20y%5D%20%2A%20h%5Bx%2C%20y%5D.%5Cend%7Baligned%7D)

Em imagens, a convolução pode ser visualmente compreendida em termos de janelas deslizantes. Nesse processo, a resposta ao impulso do sistema ![](https://latex.codecogs.com/png.latex?h%5Bx%2C%20y%5D), representada na forma matricial, é deslizada sobre a imagem. Pelo resultado acima, cada _pixel_ da saída corresponde, portanto, à soma das multiplicações ponto a ponto entre a matriz de ![](https://latex.codecogs.com/png.latex?h%5Bx%2C%20y%5D) e os elementos da imagem sobre os quais ela está sobreposta. Uma ilustração para um dos passos do processo está exposta na figura abaixo. No contexto do processamento de imagens, a resposta ao impulso ![](https://latex.codecogs.com/png.latex?h) é denominada máscara de filtragem.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/conv2d.jpg" alt="[fig:slit2d] Representação em blocos de um sistema bidimensional." />
<figcaption>
Um dos passos do processo de convolução de uma imagem e da resposta ao impulso de um sistema para o cálculo do elemento central da saída.
</figcaption>
</figure>

### Filtros diferenciadores

O operador gradiente ![](https://latex.codecogs.com/png.latex?%5Cnabla%20f%28a%2C%20b%29%20%3D%20%5Cleft%28%5Cfrac%20%7B%5Cpartial%20f%28a%2C%20b%29%7D%7B%5Cpartial%20a%7D%2C%20%5Cfrac%20%7B%5Cpartial%20f%28a%2C%20b%29%7D%7B%5Cpartial%20b%7D%5Cright%29), definido sobre funções contínuas, expressa a magnitude, direção e sentido de variação nos valores de uma função de duas variáveis ![](https://latex.codecogs.com/png.latex?f%28a%2C%20b%29), ao longo de seu domínio. Em sinais unidimensionais, é possível expressar um diferenciador ![](https://latex.codecogs.com/png.latex?g%28a%29%20%3D%20%5Cfrac%7Bdf%28a%29%7D%7Bda%7D) como um sistema cuja resposta em frequência ideal é ![](https://latex.codecogs.com/png.latex?G%28j%5COmega%29%20%3D%20j%5COmega). As respostas em magnitude e fase do diferenciador ideal são representadas nos gráficos a seguir.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/ideal.jpg" title="fig:" alt="Resposta em frequência para o filtro diferenciador ideal." />
<figcaption>
Resposta em frequência para o filtro diferenciador ideal.
</figcaption>
</figure>

Em muitas aplicações do processamento de imagens, o cálculo do gradiente é útil para demarcar contornos e sintetizar as formas dos objetos. Entretanto, esse operador não pode ser utilizado, a rigor, no contexto discreto das imagens digitais. Todavia, se ![](https://latex.codecogs.com/png.latex?i_c%28x%2C%20y%29) for uma função contínua a partir da qual ![](https://latex.codecogs.com/png.latex?i%5Bx%2C%20y%5D) foi amostrada, é possível obter uma aproximação para as derivadas parciais de ![](https://latex.codecogs.com/png.latex?i_c) através da equação a seguir, com os intervalos discretos ![](https://latex.codecogs.com/png.latex?%5CDelta%20x) e ![](https://latex.codecogs.com/png.latex?%5CDelta%20y) tão pequenos quanto possível. Essa formulação é a base para a definição dos filtros de Prewitt e Sobel.

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Agradiente%7D%0A%20%20%20%20%5Cfrac%20%7B%5Cpartial%20i_c%28x%2C%20y%29%7D%7B%5Cpartial%20x%7D%20%5Capprox%20%5Cfrac%7Bi%5Bx%20%2B%20%5CDelta%20x%2C%20y%5D%20-%20i%5Bx%20-%20%5CDelta%20x%2C%20y%5D%7D%7B2%5CDelta%20x%7D%3B%20%5Cquad%20%5Cfrac%20%7B%5Cpartial%20i_c%28x%2C%20y%29%7D%7B%5Cpartial%20y%7D%20%5Capprox%20%5Cfrac%7Bi%5Bx%2C%20y%20%20%2B%20%5CDelta%20y%5D%20-%20i%5Bx%2C%20y%20-%20%5CDelta%20y%5D%7D%7B2%5CDelta%20y%7D.)

### Filtro de Prewitt

O filtro de Prewitt consiste numa implementação não-escalonada da equação do gradiente, com ![](https://latex.codecogs.com/png.latex?%5CDelta%20x%20%3D%20%5CDelta%20y%20%3D%201). A máscaras de filtragem de Prewitt para cálculo das derivadas parciais no eixo horizontal e vertical são definidas conforme:

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Aprewitt%7D%0A%20%20%20%20h_x%5Bx%2C%20y%5D%20%3D%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%3B%5Cquad%0A%20%20%20%20h_y%5Bx%2C%20y%5D%20%3D%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20-1%20%26%20-1%20%26%20-1%20%5C%5C%0A%20%20%20%200%20%26%200%20%26%200%20%5C%5C%0A%20%20%20%201%20%26%201%20%26%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D.)

Essas máscaras advém da convolução de dois filtros unidimensionais, um derivador ![](https://latex.codecogs.com/png.latex?h_d), a ser aplicado no eixo principal, e um suavizador, ![](https://latex.codecogs.com/png.latex?h_s), aplicado no eixo transversal. Abaixo, encontram-se expressas as componentes do filtro de Prewitt para cálculo da derivada no eixo horizontal. As componentes verticais estão expostas logo a seguir.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/diferenciador_prewitt.jpg" alt="Diferenciador." />
<figcaption>
Resposta em frequência da componente diferenciadora do filtro de Prewitt.
</figcaption>
</figure>

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/suavizador_prewitt.jpg" alt="Suavizador." />
<figcaption>
Resposta em frequência da componente suavizadora do filtro de Prewitt.
</figcaption>
</figure>

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Aprewittcomp%7D%0A%20%20%20%20h_x%5Bx%2C%20y%5D%20%3D%20h_s%5By%5D%20%2A%20h_d%5Bx%5D%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20-1%20%26%200%20%26%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%3D%20%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%5C%5C%0A%20%20%20%201%20%5C%5C%0A%20%20%20%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%2A%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20-1%20%26%200%20%26%201%0A%20%20%20%20%5Cend%7Bbmatrix%7D)

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Aprewittcompv%7D%0A%20%20%20%20h_y%5Bx%2C%20y%5D%20%3D%20h_d%5Bx%5D%5ET%20%2A%20h_s%5By%5D%5ET%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20-1%20%26%20-1%20%26%20-1%20%5C%5C%0A%20%20%20%200%20%26%200%20%26%200%20%5C%5C%0A%20%20%20%201%20%26%201%20%26%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20%20%20%20%20-1%20%5C%5C%0A%20%20%20%20%20%20%20%200%20%5C%5C%0A%20%20%20%20%20%20%20%201%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%2A%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%26%201%20%26%201%0A%20%20%20%20%5Cend%7Bbmatrix%7D)

Na imagem a seguir, é possível observar a resposta em frequência unidimensional de ambas as componentes do filtro de Prewitt. Para baixas frequências, a resposta em magnitude da componente diferenciadora aproxima-se do que se observa no diferenciador contínuo ideal, porém com atenuação das altas frequências. O papel do filtro suavizador, por sua vez, é reduzir a ruidosidade eventualmente intensificada no eixo transversal pela aplicação da componente diferenciadora.

### Filtro de Sobel

O filtro de Sobel é uma variação do filtro de Prewitt, com o sinal da componente derivadora invertido e um suavizador mais intenso. As componentes e máscaras desse filtro são definidas conforme as matrizes abaixo. A resposta em magnitude da componente diferenciadora do filtro de Sobel é similar à que se observa no filtro de Prewitt. Porém, na resposta do suavizador, ilustrada na mesma figura, verifica-se um comportamento mais próximo de um filtro passa-baixa, sem os pequenos picos nas altas frequências observados em Prewitt.

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Asobel%7D%0A%20%20%20%20h_x%5Bx%2C%20y%5D%20%3D%20h_s%5By%5D%20%2A%20h_d%5Bx%5D%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%26%200%20%26%20-1%20%5C%5C%0A%20%20%20%202%20%26%200%20%26%20-2%20%5C%5C%0A%20%20%20%201%20%26%200%20%26%20-1%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%3D%20%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%5C%5C%0A%20%20%20%202%20%5C%5C%0A%20%20%20%201%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%2A%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%26%200%20%26%20-1%0A%20%20%20%20%5Cend%7Bbmatrix%7D)

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Asobelv%7D%0A%20%20%20%20h_y%5Bx%2C%20y%5D%20%3D%20h_d%5Bx%5D%5ET%20%2A%20h_s%5By%5D%5ET%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%26%202%20%26%201%20%5C%5C%0A%20%20%20%200%20%26%200%20%26%200%20%5C%5C%0A%20%20%20%20-1%20%26%20-2%20%26%20-1%20%5C%5C%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%3D%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%20%20%20%20%201%20%5C%5C%0A%20%20%20%20%20%20%20%200%20%5C%5C%0A%20%20%20%20%20%20%20%20-1%0A%20%20%20%20%5Cend%7Bbmatrix%7D%20%2A%0A%20%20%20%20%5Cbegin%7Bbmatrix%7D%0A%20%20%20%201%20%26%202%20%26%201%0A%20%20%20%20%5Cend%7Bbmatrix%7D)

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/derivador.jpg" alt="Diferenciador." />
<figcaption>
Resposta em frequência da componente diferenciadora do filtro de Sobel.
</figcaption>
</figure>

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/suavizador.jpg" alt="Suavizador." />
<figcaption>
Resposta em frequência da componente suavizadora do filtro de Sobel.
</figcaption>
</figure>

### Histogramas de gradientes

Histogramas de Gradientes Orientados – abreviados por HOGs, do inglês _Histogram of Oriented Gradients_ – são um recurso computacional que permitem sintetizar matematicamente o aspecto morfológico de objetos em imagens (Dalal and Triggs 2005). O cálculo dos HOGs baseia-se na magnitude, direção e sentido dos vetores gradientes da imagem obtidos através da aplicação de um filtro diferenciador. Os filtros fornecem as componentes horizontais e verticais do gradiente de cada _pixel_, a partir das quais pode-se calcular o ângulo e módulo do vetor, conforme:

![](https://latex.codecogs.com/png.latex?%5Clabel%7Beq%3Apolar%7D%0A%20%20%20%20%7Cv%28x%2C%20y%29%7C%20%3D%20%5Csqrt%7Bo_x%5Bx%2C%20y%5D%5E2%20%2B%20o_y%5Bx%2C%20y%5D%5E2%7D%3B%20%5Cquad%20%5Cangle%20v%28x%2C%20y%29%20%3D%20%5Carctan%7B%5Cfrac%7Bo_y%5Bx%2C%20y%5D%7D%7Bo_x%5Bx%2C%20y%5D%7D%7D)

Em que ![](https://latex.codecogs.com/png.latex?o_x) e ![](https://latex.codecogs.com/png.latex?o_y) representam, respectivamente, o resultado da convolução de um filtro diferenciador parcial horizontal ![](https://latex.codecogs.com/png.latex?h_x), e vertical, ![](https://latex.codecogs.com/png.latex?h_y), sobre uma imagem ![](https://latex.codecogs.com/png.latex?i%5Bx%2C%20y%5D).

Após o cálculo dos vetores gradientes, a imagem é setorizada em blocos quadrados de igual tamanho. Para cada bloco, um histograma das faixas de ângulos existentes é construído, de modo que o valor dos intervalos corresponde à soma das magnitudes dos ângulos correspondentes. O processo é ilustrado na imagem abaixo para blocos de tamanho ![](https://latex.codecogs.com/png.latex?3%20%5Ctimes%203) e um histograma de ![](https://latex.codecogs.com/png.latex?4) setores. Na figura seguinte, encontra-se uma imagem descrita por histogramas de gradientes orientados de uma imagem de dimensões ![](https://latex.codecogs.com/png.latex?128%5Ctimes%20128), blocos de tamanho ![](https://latex.codecogs.com/png.latex?8%20%5Ctimes%208) e histogramas de ![](https://latex.codecogs.com/png.latex?9) setores. As linhas brancas localizadas sobre os blocos expressam a magnitude final de cada setor do histograma após a soma dos módulos dos vetores.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/histograma.jpg" alt=" Processo de construção dos histograma em um bloco 3\times3, com 4 intervalos de orientações." />
<figcaption> Processo de construção dos histograma em um bloco <img style="vertical-align:middle" src="https://latex.codecogs.com/png.latex?3%5Ctimes3" alt="3\times3" title="3\times3" />, com 4 intervalos de orientações.</figcaption>
</figure>

<figure><img src="https://s3.amazonaws.com/abnersn/github/hog-detector/image_comb.jpg" alt="HOG" /><figcaption> Representação gráfica dos histogramas de gradientes orientados da imagem
de um rosto, calculados com 9 intervalos em blocos de tamanho 8 por 8.</figcaption></figure>

### Classificação

As Máquinas de Vetores de Suporte – do inglês, SVM, ou _Support Vector Machines_ – são classificadores lineares binários que podem ser empregados na tarefa de identificar objetos em imagens previamente descritas por HOGs. Classificadores SVM, munidos de dados para treino, calculam hiperplanos separadores para as duas classes, de modo a maximizar a distância entre os planos e as amostras. Uma vez obtidos os hiperplanos, a predição de classe para uma amostra inédita é feita de forma extremamente eficaz, pois basta determinar a qual subespaço a amostra pertence, _i.e._, de qual lado do hiperplano ela está.

<figure><img src="https://s3.amazonaws.com/abnersn/github/hog-detector/svm_2.jpg" alt=" Representação do hiperplano separador de duas classes calculado por um SVM." /><figcaption> Representação do hiperplano separador de duas classes calculado por um SVM.</figcaption></figure>

## Metodologia

### Aquisição e pré-processamento dos dados

A fim de treinar o algoritmo classificador adotado, um conjunto de amostras positivas, isto é, de imagens que contém faces, e negativas, sem faces, foi preparado. As amostras positivas foram extraídas da base de dados Caltech Web Faces.

<figure><img src="https://s3.amazonaws.com/abnersn/github/hog-detector/positive_comb.jpg" alt="Exemplares de amostras positivas e negativas da base de dados." /><figcaption> Exemplares de amostras positivas e negativas da base de dados.</figcaption></figure>

### Cálculo dos gradientes e histogramas

As máscaras correspondentes aos filtros de Prewitt e Sobel foram definidas no software MATLAB e aplicadas sobre as imagens com auxílio da função `conv2`, que realiza a convolução bidimensional. A partir do resultado obtido pelos filtros parciais em cada eixo, o cálculo da magnitude e ângulo dos vetores gradientes foram feitos conforme as definições apresentadas. As filtragens com ambos os operadores foram realizadas no domínio do espaço.

Para a construção dos histogramas, cada imagem foi dividida em 64 blocos de tamanho ![](https://latex.codecogs.com/png.latex?4%20%5Ctimes%204), sobre os quais histogramas de 8 setores foram calculados e distribuídos ao longo da terceira dimensão. Em seguida, a matriz resultante, de dimensões ![](https://latex.codecogs.com/png.latex?8%20%5Ctimes%208%20%5Ctimes%208), foi comprimida em um vetor com 512 características para treino do classificador. Na figura abaixo, encontra-se uma síntese desse processo.

<figure><img src="https://s3.amazonaws.com/abnersn/github/hog-detector/histimg.jpg" alt=" Representação do hiperplano separador de duas classes calculado por um SVM." /><figcaption> Processo de construção dos vetores de descritores a partir dos histogramas dos gradientes de uma imagem filtrada com filtros diferenciadores.</figcaption></figure>

### Treino do classificador e testes de desempenho

Para reduzir a incidência de falsas detecções, as amostras foram tomadas numa razão de 100 amostras negativas para cada positiva. No total, 200 amostras positivas e 20 mil negativas foram utilizadas, das quais 70% foram destinadas para treino e 30% para testes. A performance do algoritmo foi avaliada quanto ao erro de classificação nas amostras de teste, além da capacidade de detecção em imagens com múltiplas faces por meio de uma janela deslizante de classificação. Nesse último caso, as detecções sobrepostas foram eliminadas conforme o grau de confiabilidade retornado pelo classificador e o tamanho da área de sobreposição, de modo que blocos de detecção com muitos _pixels_ em coincidência com outros blocos positivos detectados foram descartados. Esse procedimento configura uma versão simplificada da técnica de supressão não-máxima.

## Resultados

### Aplicação dos filtros

A fim de visualizar o resultado da convolução dos filtros de Prewitt e Sobel sobre as imagens, a magnitude e o ângulo dos vetores calculados foram normalizadas e exibidas na forma matricial. É possível verificar que ambos os filtros apresentam resultados similares, com forte resposta na região das bordas dos objetos. De fato, contornos são regiões com brusca variação de intensidade nos tons de cinza da imagem, o que explica a saída observada para os filtros diferenciadores. Embora seja capaz de filtrar ruídos de alta frequência melhor que o filtro de Prewitt, o resultado da aplicação do operador de Sobel não apresentou diferenças significativas em relação ao primeiro. Isso se deve, principalmente, à redução na resolução das amostras, processo que atenua significativamente a presença de ruído.

<figure><img src="https://s3.amazonaws.com/abnersn/github/hog-detector/resultados_filtros.jpg" alt="Resultado para as magnitudes dos vetores gradientes calculados com os
filtros de Sobel e Prewitt." /><figcaption> Resultado para as magnitudes dos vetores gradientes calculados com os
filtros de Sobel e Prewitt.</figcaption></figure>

### Resultados nas bases de teste

A fim de verificar a robustez da metodologia quanto à capacidade de detectar a presença de faces em novos blocos, foram efetuados testes com 30% das imagens, cujos resultados estão expostos na tabela a seguir. Ambos os filtros obtiveram desempenho similar, com baixas taxas de erro. O índice de falsos positivos nulo deve-se ao favorecimento das amostras negativas em detrimento das positivas, que tende limitar significativamente a região N-dimensional para a qual o classificador sinaliza uma detecção.

<figure>
<img src="https://s3.amazonaws.com/abnersn/github/hog-detector/res.jpg" alt="Resultados obtidos pela janela deslizante de detecção." />
<figcaption>
Resultados obtidos pela janela deslizante de detecção.
</figcaption>
</figure>

<table><caption>Resultados obtidos por classificadores treinados com descritores de ambos os filtros.</caption><thead><tr class="header"><th style="text-align: center;">Filtro utilizado</th><th style="text-align: center;">Erro global</th><th style="text-align: center;">Falsos-positivos</th><th style="text-align: center;">Falsos-negativos</th></tr></thead><tbody><tr class="odd"><td style="text-align: center;">Prewitt</td><td style="text-align: center;">0,53%</td><td style="text-align: center;">0%</td><td style="text-align: center;">0,53%</td></tr><tr class="even"><td style="text-align: center;">Sobel</td><td style="text-align: center;">0,47%</td><td style="text-align: center;">0%</td><td style="text-align: center;">0,47%</td></tr></tbody></table>

Por fim, para avaliar a performance da técnica na detecção de múltiplas faces em imagens com resolução maior, foi implementada uma janela de detecção com os classificadores associados. Ambos alcançaram desempenhos próximos, porém apresentaram dificuldade na detecção de faces inclinadas ou com tamanho maior, em virtude da ausência de amostras suficientemente similares na base de treino.

## Referências

Angelova, Anelia, Yaser Abu-Mostafam, and Pietro Perona. 2005a. “Pruning Training Sets for Learning of Object Categories.” In _Computer Vision and Pattern Recognition, 2005. CVPR 2005. IEEE Computer Society Conference on_, 1:494–501. IEEE.

Chalup, Stephan, Kenny Hong, and Michael Ostwald. 2009. “Simulating Pareidolia of Faces for Architectural Image Analysis.” _International Journal of Computer Information Systems and Industrial Management Applications_ 2 (January).

Dalal, Navneet, and Bill Triggs. 2005. “Histograms of Oriented Gradients for Human Detection.” In _Computer Vision and Pattern Recognition, 2005. CVPR 2005. IEEE Computer Society Conference on_, 1:886–93. IEEE.

Fei-Fei, Li, Rob Fergus, and Pietro Perona. 2007. “Learning Generative Visual Models from Few Training Examples: An Incremental Bayesian Approach Tested on 101 Object Categories.” _Computer Vision and Image Understanding_ 106 (1): 59–70.

Gonzalez, Rafael C, Richard E Woods, and others. 2002. “Digital Image Processing.” Prentice hall Upper Saddle River, NJ.

Griffin, Gregory, Alex Holub, and Pietro Perona. 2007. “Caltech-256 Object Category Dataset.”

Hearst, Marti A., Susan T Dumais, Edgar Osuna, John Platt, and Bernhard Scholkopf. 1998. “Support Vector Machines.” _IEEE Intelligent Systems and Their Applications_ 13 (4): 18–28.

Kanade, Takeo. 1974. “Picture Processing System by Computer Complex and Recognition of Human Faces.”

Neubeck, Alexander, and Luc Van Gool. 2006. “Efficient Non-Maximum Suppression.” In _Pattern Recognition, 2006. ICPR 2006. 18th International Conference on_, 3:850–55. IEEE.

Prewitt, Judith MS. 1970. “Object Enhancement and Extraction.” _Picture Processing and Psychopictorics_ 10 (1): 15–19.

Schroff, Florian, Dmitry Kalenichenko, and James Philbin. 2015. “Facenet: A Unified Embedding for Face Recognition and Clustering.” In _Proceedings of the Ieee Conference on Computer Vision and Pattern Recognition_, 815–23.

Sobel, Irwin. 1968. “An Isotropic 3x3 Image Gradient Operator.” _Presentation at Stanford A.I. Project 1968_, February.

Stan Z. Li, Anil K. Jain. 2011. _Handbook of Face Recognition_. 2nd ed. Springer-Verlag London.

Woods, J.W. 2011. _Multidimensional Signal, Image, and Video Processing and Coding_. Elsevier Science. <https://books.google.com.br/books?id=0lJ0atc5X-UC>.
