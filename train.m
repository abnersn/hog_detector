%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

%%% train.m: Treina um classificador SVM e salva em svm_model.mat.

clear; clc; close all;

addpath('libsvm'); % Carrega a biblioteca libsvm.
SAMPLES_SIZE = [32 32]; % Tamanho das amostras.
PATCH_SIZE = 4; % Tamanho dos quadrados descritores de cada bloco.
BINS = 8; % Quantidade de setores no histograma de direções..
NORM_KERNEL_SIZE = 2; % Tamanho do kernel de normalização dos histogramas.
IMAGES_POSITIVE = 200; % Quantidade de amostras positivas.
IMAGES_NEGATIVE = 20000; % Quantidade de amostras negativa.
TRAIN_PERCENT = 70; % Percentual a ser usado para treino.

% Carregamento das amostras
fprintf('Lendo imagens\n');

negative = zeros([SAMPLES_SIZE IMAGES_NEGATIVE]);
positive = zeros([SAMPLES_SIZE IMAGES_POSITIVE]);

for i = 1:IMAGES_NEGATIVE
    neg_file = sprintf('data/negative/negative_%d.jpg', i);
    I = imread(neg_file);
    I = imresize(I, [32, 32]);
    if (size(I, 3) == 3)
        negative(:, :, i) = rgb2gray(I);
    else
        negative(:, :, i) = I;
    end
end

for i = 1:IMAGES_POSITIVE
    pos_file = sprintf('data/positive/positive_%d.jpg', i);
    I = imread(pos_file);
    I = imresize(I, [32, 32]);
    if (size(I, 3) == 3)
        positive(:, :, i) = rgb2gray(I);
    else
        positive(:, :, i) = I;
    end
end

% Sorteio das amostras de treino
fprintf('Sorteando amostras para treino\n');
indexes = randperm(IMAGES_NEGATIVE);
negative_trainset_size = floor(TRAIN_PERCENT * IMAGES_NEGATIVE / 100);
train_negative = negative(:, :, indexes(1:negative_trainset_size));
test_negative = negative(:, :, indexes((negative_trainset_size + 1):end));

indexes = randperm(IMAGES_POSITIVE);
positive_trainset_size = floor(TRAIN_PERCENT * IMAGES_POSITIVE / 100);
train_positive = positive(:, :, indexes(1:positive_trainset_size));
test_positive = positive(:, :, indexes((positive_trainset_size + 1):end));

train_data_negative = zeros(prod(SAMPLES_SIZE / PATCH_SIZE) * BINS, IMAGES_NEGATIVE);
train_data_positive = zeros(prod(SAMPLES_SIZE / PATCH_SIZE) * BINS, IMAGES_POSITIVE);

% Cálculo dos descritores HOG
fprintf('Calculando descritores\n');
for i = 1:negative_trainset_size
    I = train_negative(:, :, i);
    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
    train_data_negative(:, i) = hist(:);
end

for i = 1:positive_trainset_size
    I = train_positive(:, :, i);
    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
    train_data_positive(:, i) = hist(:);
end

% Treino da SVM
train_data = [train_data_negative'; train_data_positive'];
class_data = [zeros(IMAGES_NEGATIVE, 1); ones(IMAGES_POSITIVE, 1)];

fprintf('Treinando SVM\n');
svm_model = svmtrain(class_data, sparse(train_data), '-q -b 1');

save('svm_model.mat', 'svm_model');

error = 0;
false_positives = 0;
false_negatives = 0;
count = 0;

% Cálculo da acurácia de predição no dataset de testes.
fprintf('Calculando acurácia...\n');
for i=1:size(test_negative, 3)
    I = test_negative(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = svmpredict(0, sparse(hist(:)'), svm_model, '-q');
    if label ~= 0
        error = error + 1;
        false_positives = false_positives + 1; 
    end
    count = count + 1;
end

for i=1:size(test_positive, 3)    
    I = test_positive(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = svmpredict(0, sparse(hist(:)'), svm_model, '-q');
    if label ~= 1
        error = error + 1;
        false_negatives = false_negatives + 1;
    end
    count = count + 1; 
end

fprintf('# Resultados:\n');
fprintf('Taxa de erro global: %.2f%%\n', 100 * error / count);
fprintf('Falsos positivos: %.2f%%\n', 100 * false_positives / count);
fprintf('Falsos negativos: %.2f%%\n\n', 100 * false_negatives / count);