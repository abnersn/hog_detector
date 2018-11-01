clear; clc;
close all;

IMAGES_SIZE = [128 128];
PATCH_SIZE = 8;
BINS = 9;
NORM_KERNEL_SIZE = 2;
NUM_TRAIN_IMAGES = 15;
NUM_IMAGES = 20;

I = rgb2gray(imresize(imread('image.jpg'), [128, 128]));
hist = hog(I, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

figure;
imshow(I);
[x, y] = meshgrid(size(I,1):-PATCH_SIZE:1,size(I,1):-PATCH_SIZE:1);
x = x - PATCH_SIZE / 2;
y = y - PATCH_SIZE / 2;
hold on;
imshow(I * 0);
for i=0:(BINS - 1)
    angle = (i + 0.5) * 2 * pi / BINS;
    m = hist(:, :, i + 1);
    u = m .* sin(angle);
    v = m .* cos(angle);
    q = quiver(x, y, u, v);
    q.Color = 'white';
    q.ShowArrowHead = 'off';
end