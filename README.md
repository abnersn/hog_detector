# Detecção de Faces com Histogramas de Gradientes Orientados

## Requisitos
Os softwares abaixo (ou versões compatíveis) são necessários para executar os scripts.
* [MATLAB r2017a](https://www.mathworks.com/products/matlab.html);
* [Mathworks Image Acquisition Toolbox](https://www.mathworks.com/products/imaq.html);
* [LibSVM 3.23](https://www.csie.ntu.edu.tw/~cjlin/libsvm/) (incluso no repositório);
* Sistema Operacional Windows;

## Como executar
O repositório já inclui um classificador SVM pré treinado com parte dos dados (200 amostras positivas e 20.000 negativas), no arquivo `svm_model.mat`. Para efetuar a detecção, execute o script `detect.m`, especificando o arquivo de imagem na linha 21.

## Como treinar um novo modelo
Para treino do classificador SVM, são necessárias amostras de imagens com tamanho 32x32 que contém faces (positivas) e que não contém (negativas). Para melhor desempenho, as amostras devem apresentar similaridade com os blocos da janela deslizante que serão processados durante a fase de detecção. As imagens devem ser organizadas conforme a seguinte estrutura de diretórios e nomenclaturas:
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
O arquivo `data.zip` contém amostras já preparadas, basta extrair a pasta no mesmo diretórios dos scripts. Há 6.123 exemplares positivos e 24.128 negativos. Para evitar lentidão no processamento, não recomenda-se o uso de todas as amostras, mas sim uma quantidade inferior, preferencialmente na razão de 100 exemplares negativos para cada exemplar positivo.

Uma vez organizados os dados para treino, basta executar o script `train.m`, especificando os parâmetros de treino desejados. O script deve produzir um arquivo `svm_model.mat`, que pode ser usado para executar a detecção.

**Autor:**
Abner Sousa Nascimento.