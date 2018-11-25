%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

%%% fig.m: Gera uma figura para exibição dos histogramas.

clear; clc; close all;

IMAGES_SIZE = [128 128];
PATCH_SIZE = 8;
BINS = 9;
NORM_KERNEL_SIZE = 2;
NUM_TRAIN_IMAGES = 15;
NUM_IMAGES = 20;

I = rgb2gray(imresize(imread('samples/sample_2.jpg'), [128, 128]));
hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

figure;
subplot(1, 2, 1);
imshow(I);
[x, y] = meshgrid(1:PATCH_SIZE:size(I,1),1:PATCH_SIZE:size(I,1));
x = x + PATCH_SIZE / 2;
y = y + PATCH_SIZE / 2;

subplot(1, 2, 2);
hold on;
imshow(I * 0);
for i=0:(BINS - 1)
    angle = i * 2 * pi / BINS;
    m = hist(:, :, i + 1);
    u = m .* sin(angle);
    v = m .* cos(angle);
    q = quiver(x, y, u, v);
    q.Color = 'white';
    q.ShowArrowHead = 'off';
end
axis([1 size(I, 1) 1 size(I, 2)]);