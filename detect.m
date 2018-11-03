clear; clc; close all;

BLOCK_SIZE = [32 32];
PATCH_SIZE = 4;
BINS = 8;
NORM_KERNEL_SIZE = 2;
DISPLAY = true;
STEP = 2;

I = rgb2gray(imread('samples/sample.jpg'));

load('svm_model.mat', 'svm_model');
[m,p,g] = gradient(I);

last_y_index = BLOCK_SIZE(1) * (floor(size(I, 1) / BLOCK_SIZE(1)) - 1);
last_x_index = BLOCK_SIZE(2) * (floor(size(I, 2) / BLOCK_SIZE(2)) - 1);
x_range = 1:STEP:last_x_index;
y_range = 1:STEP:last_y_index;

f = figure;
I_disp = cat(3, I, I, I);
fprintf("Processando");
for i = y_range
    for j = x_range
        b_hor = j:(j + BLOCK_SIZE(1) - 1);
        b_ver = i:(i + BLOCK_SIZE(2) - 1);
        
        if DISPLAY
            imshow(I_disp);
            hold on;
            rectangle('Position',[j i BLOCK_SIZE], 'EdgeColor', 'g');
            pause(0.0001);
        end
        
        block = I(b_ver, b_hor);
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
        [is_face, score] = predict(svm_model, hist(:)');
        if is_face == 1 && max(score) > 0.5
            if DISPLAY
                % Desenha um retângulo amarelo
                I_disp(b_ver, j, :) = 255;
                I_disp(b_ver, j, 3) = 0;
                I_disp(b_ver, j + BLOCK_SIZE(2), :) = 255;
                I_disp(b_ver, j + BLOCK_SIZE(2), 3) = 0;
                I_disp(i, b_hor, :) = 255;
                I_disp(i, b_hor, 3) = 0;
                I_disp(i + BLOCK_SIZE(1), b_hor, :) = 255;
                I_disp(i + BLOCK_SIZE(1), b_hor, 3) = 0;
            end
        end
    end
end
fprintf("\nConcluído\n");

imshow(I_disp);