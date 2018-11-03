clear; clc;
close all;

SAMPLES_SIZE = [32 32];
PATCH_SIZE = 4;
BINS = 8;
DATA_SIZE = prod(SAMPLES_SIZE / PATCH_SIZE) * BINS;
NORM_KERNEL_SIZE = 2;

%%% Quantidade de amostras positivas e negativas para utilizar no treino.
IMAGES_POSITIVE = 200;
IMAGES_NEGATIVE = 20000;
TRAIN_PERCENT = 70;

%%% Carregamento das amostras
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

%%% Sorteio das amostras
fprintf('Sorteando amostras para treino\n');
indexes = randperm(IMAGES_NEGATIVE);
negative_trainset_size = floor(TRAIN_PERCENT * IMAGES_NEGATIVE / 100);
train_negative = negative(:, :, indexes(1:negative_trainset_size));
test_negative = negative(:, :, indexes((negative_trainset_size + 1):end));

indexes = randperm(IMAGES_POSITIVE);
positive_trainset_size = floor(TRAIN_PERCENT * IMAGES_POSITIVE / 100);
train_positive = positive(:, :, indexes(1:positive_trainset_size));
test_positive = positive(:, :, indexes((positive_trainset_size + 1):end));

train_data_negative = zeros(DATA_SIZE, IMAGES_NEGATIVE);
train_data_positive = zeros(DATA_SIZE, IMAGES_POSITIVE);

%%% Descritores HOG
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

%%% Treino da SVM
train_data = [train_data_negative'; train_data_positive'];
class_data = [zeros(IMAGES_NEGATIVE, 1); ones(IMAGES_POSITIVE, 1)];

fprintf('Treinando SVM\n');
svm_model = fitcsvm(train_data, class_data);

save('svm_model.mat', 'svm_model');

error = 0;
count = 0;

%%% Cálculo do erro
fprintf('Calculando acurácia\n');
for i=1:size(test_negative, 3)
    I = test_negative(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = predict(svm_model, hist(:)');
    if label ~= 0
        error = error + 1;
    end
    count = count + 1;
end

for i=1:size(test_positive, 3)    
    % Amostras positivas
    I = test_positive(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = predict(svm_model, hist(:)');
    if label ~= 1
        error = error + 1;
    end
    count = count + 1;
end

error_percent = error / count;
disp(1 - error_percent);