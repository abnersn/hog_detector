clear; clc; close all;

I = rgb2gray(imread('sw.jpg'));

BLOCK_SIZE = [32 32];
PATCH_SIZE = 4;
BINS = 9;
NORM_KERNEL_SIZE = 2;

load('svm_model.mat', 'svm_model');
[m,p,g] = gradient(I);

last_y_index = BLOCK_SIZE(1) * (floor(size(I, 1) / BLOCK_SIZE(1)) - 1);
last_x_index = BLOCK_SIZE(2) * (floor(size(I, 2) / BLOCK_SIZE(2)) - 1);
x_range = 1:5:last_x_index;
y_range = 1:5:last_y_index;

faces = [];
current_face = 1;
last_detected_i = 0; last_detected_j = 0;

figure;
I_disp = I;
faces = [];
confidences = [];
for i = y_range
    for j = x_range
        b_hor = j:(j + BLOCK_SIZE(1) - 1);
        b_ver = i:(i + BLOCK_SIZE(2) - 1);
        imshow(I_disp);
        hold on;
        rectangle('Position',[j i 32 32]);
        pause(0.0001);
        
        block = I(b_ver, b_hor);
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
        [is_face, score] = predict(svm_model, hist(:)');
        if is_face == 1 && max(score) > 0.6
            I_disp(b_ver, b_hor) = I_disp(b_ver, b_hor) * 0.8;
        end
    end
end