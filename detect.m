clear; clc; close all;

I = rgb2gray(imread('sample.jpg'));

BLOCK_SIZE = [32 32];
PATCH_SIZE = 4;
BINS = 9;
NORM_KERNEL_SIZE = 2;

load('svm_model.mat', 'svm_model');
[m,p,g] = gradient(I);

last_y_index = BLOCK_SIZE(1) * (floor(size(I, 1) / BLOCK_SIZE(1)) - 1);
last_x_index = BLOCK_SIZE(2) * (floor(size(I, 2) / BLOCK_SIZE(2)) - 1);
x_range = 1:last_x_index;
y_range = 1:last_y_index;

faces = [];
current_face = 1;
last_detected_i = 0; last_detected_j = 0;

detection_matrix = zeros(size(I));
for i = y_range
    for j = x_range
        b_hor = j:(j + BLOCK_SIZE(1) - 1);
        b_ver = i:(i + BLOCK_SIZE(2) - 1);
        block = I(b_ver, b_hor);
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
        is_face = predict(svm_model, hist(:)');
        if is_face == 1
            x_pos = floor((b_hor(1) + b_hor(end))/2);
            y_pos = floor((b_ver(1) + b_ver(end))/2);
            detection_matrix(y_pos, x_pos) = 1;
        end
    end
end
se = ones(5);
r = I .* uint8(~imopen(detection_matrix, se));
imshow(r);