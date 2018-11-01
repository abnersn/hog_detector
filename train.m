clear; clc;
close all;

IMAGES_SIZE = [32 32];
PATCH_SIZE = 4;
BINS = 9;
NORM_KERNEL_SIZE = 2;
NUM_TRAIN_IMAGES = 4200;
NUM_IMAGES = 6000;
DATA_SIZE = prod([ IMAGES_SIZE / PATCH_SIZE BINS]);

%%% Carregamento das amostras
fprintf('Lendo imagens\n');

negative = zeros([IMAGES_SIZE NUM_IMAGES]);
positive = zeros([IMAGES_SIZE NUM_IMAGES]);

for i = 1:NUM_IMAGES
    neg_file = sprintf('dados/negative/negative_%d.jpg', i);
    I = imread(neg_file);
    I = imresize(I, [32, 32]);
    if (size(I, 3) == 3)
        negative(:, :, i) = rgb2gray(I);
    else
        negative(:, :, i) = I;
    end
    
    pos_file = sprintf('dados/positive/positive_%d.jpg', i);
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
indexes = randperm(NUM_IMAGES);
train_negative = negative(:, :, indexes(1:NUM_TRAIN_IMAGES));
test_negative = negative(:, :, indexes(1:(NUM_IMAGES - NUM_TRAIN_IMAGES)));

indexes = randperm(NUM_IMAGES);
train_positive = positive(:, :, indexes(1:NUM_TRAIN_IMAGES));
test_positive = positive(:, :, indexes(1:(NUM_IMAGES - NUM_TRAIN_IMAGES)));

train_data_negative = zeros([DATA_SIZE, NUM_TRAIN_IMAGES]);
train_data_positive = zeros([DATA_SIZE, NUM_TRAIN_IMAGES]);

%%% Descritores HOG
fprintf('Calculando descritores\n');
for i = 1:NUM_TRAIN_IMAGES
    I = train_negative(:, :, i);
    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
    train_data_negative(:, i) = hist(:);

    I = train_positive(:, :, i);
    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
    train_data_positive(:, i) = hist(:);
end

%%% Treino da SVM
train_data = [train_data_negative'; train_data_positive'];
class_data = [zeros([NUM_TRAIN_IMAGES, 1]); ones([NUM_TRAIN_IMAGES, 1])];

fprintf('Treinando SVM\n');
svm_model = fitcsvm(train_data, class_data);

save('svm_model.mat', 'svm_model');

error = 0;

%%% Cálculo do erro
fprintf('Calculando acurácia\n');
for i=1:(NUM_IMAGES - NUM_TRAIN_IMAGES)
    
    % Amostras negativas
    I = test_negative(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = predict(svm_model, hist(:)');
    if label ~= 0
        error = error + 1;
    end
    
    % Amostras positivas
    I = test_positive(:,:, i);

    hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

    label = predict(svm_model, hist(:)');
    if label ~= 1
        error = error + 1;
    end
end

error_percent = error / (2 * (NUM_IMAGES - NUM_TRAIN_IMAGES));
disp(1 - error_percent);