%%% UNIVERSIDADE FEDERAL DO CEAR�
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

%%% detect.m: Script para dete��o de faces em imagens usando descritores
%%% HOG e um classificador SVM.

clear; clc; close all;

addpath('libsvm'); % Carrega a biblioteca libsvm.
BLOCK_SIZE = [32 32]; % Tamanho do bloco para gera��o dos descritores.
PATCH_SIZE = 4; % Tamanho dos quadrados descritores de cada bloco.
BINS = 8; % Quantidade de setores no histograma de dire��es.
NORM_KERNEL_SIZE = 2; % Tamanho do kernel de normaliza��o dos histogramas.
DISPLAY = true; % Ativar/desativar a visualiza��o da varredura da imagem.
STEP = 2; % Dist�ncia em pixels entre os blocos da varredura.
MIN_CONFIDENCE = 0.98; % N�vel de confian�a m�nimo para detec��o da face.

% Leitura da imagem.
I = rgb2gray(imread('samples/sample_3.jpg'));

% Carregamento do classificador treinado com o script train.m.
load('svm_model.mat', 'svm_model');

% Defini��o dos intervalos de �ndices para a varredura.
last_y_index = BLOCK_SIZE(1) * (floor(size(I, 1) / BLOCK_SIZE(1)) - 1);
last_x_index = BLOCK_SIZE(2) * (floor(size(I, 2) / BLOCK_SIZE(2)) - 1);
x_range = 1:STEP:last_x_index;
y_range = 1:STEP:last_y_index;

if DISPLAY
    f = figure;
    I_disp = cat(3, I, I, I);
    imshow(I_disp);
end

% Vetor para armazenar as faces detectadas.
detecttions = [];

% N�veis de confian�a para cada uma das detec��es.
confidences = [];

fprintf("\nProcessando...\n");
for i = y_range
    for j = x_range
        h_range = j:(j + BLOCK_SIZE(1) - 1);
        v_range = i:(i + BLOCK_SIZE(2) - 1);
        
        if DISPLAY
            r = rectangle(...
                'Position', [j i BLOCK_SIZE], ...
                'EdgeColor', 'g', ...
                'LineWidth', 2 ...
            );
            drawnow;
            delete(r);
        end
        
        
        block = I(v_range, h_range);
        
        % Calcula histogramas
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);

        % Realiza predi��o
        [label, ~, confidence] = svmpredict(...
            1, sparse(hist(:)'), ...
            svm_model, ...
            '-q -b 1' ...
        );
        
        if label == 1 && confidence(label + 1) > MIN_CONFIDENCE
            rect = [i j BLOCK_SIZE];
            detecttions = [detecttions; rect];
            confidences = [confidences; confidence(label + 1)];
            
            if DISPLAY
                % Desenha um ret�ngulo amarelo
                color = [255, 255, 0];
                rectangle( ...
                    'Position',[j i BLOCK_SIZE], ...
                    'EdgeColor', 'y', ...
                    'LineWidth', 2 ...
                );
            end
        end
    end
end

faces = nonmaxsup(detecttions, confidences, 0.3, BLOCK_SIZE);

fprintf("\nConclu�do\n");
I = cat(3, I, I, I);
hold on;
imshow(I);
for i = 1:size(faces, 1)
    face = faces(i, 1:2);
    rectangle( ...
        'Position',[face([2, 1]) BLOCK_SIZE], ...
        'EdgeColor', 'w', ...
        'LineWidth', 2 ...
    );
end