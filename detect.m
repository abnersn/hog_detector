%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

%%% detect.m: Script para deteção de faces em imagens usando descritores
%%% HOG e um classificador SVM.

clear; clc; close all;

% Carrega a biblioteca libsvm.
addpath('libsvm');

% Tamanho do bloco utilizado no treino dos descritores.
BLOCK_SIZE = [32 32];

% Tamanho dos quadrados descritores de cada bloco.
PATCH_SIZE = 4;

% Quantidade de setores no histograma de direções.
BINS = 8;

% Tamanho do kernel para normalização dos histogramas.
NORM_KERNEL_SIZE = 2;

% Flag para ativar/desativar a visualização da varredura da imagem.
DISPLAY = true;

% Distância em pixels entre os blocos da varredura.
STEP = 2;

% Nível de confiança mínimo para considerar que um bloco contém uma face.
MIN_CONFIDENCE = 0.98;

% Leitura da imagem.
I = rgb2gray(imread('samples/sample_1.jpg'));

% Carregamento do classificador treinado com o script train.m.
load('svm_model.mat', 'svm_model');

% Cálculo do gradiente da imagem com filtragem de Sobel.
[m, p, g] = gradient(I);

% Definição dos intervalos de índices para a varredura.
last_y_index = BLOCK_SIZE(1) * (floor(size(I, 1) / BLOCK_SIZE(1)) - 1);
last_x_index = BLOCK_SIZE(2) * (floor(size(I, 2) / BLOCK_SIZE(2)) - 1);
x_range = 1:STEP:last_x_index;
y_range = 1:STEP:last_y_index;

f = figure;
detected_faces = []; % Faces detectadas.
confidence_scores = []; % Níveis de confiança para cada uma das detecções.
I_disp = cat(3, I, I, I); % Imagem para visualização da janela deslizante.
fprintf("\nProcessando...\n");
for i = y_range
    for j = x_range
        h_range = j:(j + BLOCK_SIZE(1) - 1);
        v_range = i:(i + BLOCK_SIZE(2) - 1);
        
        if DISPLAY
            imshow(I_disp);
            hold on;
            rectangle('Position',[j i BLOCK_SIZE], 'EdgeColor', 'g');
            pause(0.0001);
        end
        
        block = I(v_range, h_range);
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE);
        [label, accuracy, probability] = svmpredict(1, sparse(hist(:)'), svm_model, '-q -b 1');
        if label == 1 && probability(label + 1) > MIN_CONFIDENCE
            rect = [i j BLOCK_SIZE];
            detected_faces = [detected_faces; rect];
            confidence_scores = [confidence_scores; probability(label + 1)];
            % Desenha um retângulo amarelo
            I_disp = draw_rectangle(I_disp, [i, j], BLOCK_SIZE, [0, 0, 255]);
        end
    end
end

% Supressão não-máxima para eliminar detecções sobrepostas.
[sorted_scores, indexes] = sort(confidence_scores, 'descend');
detected_faces = detected_faces(indexes, :);
supressed_indexes = zeros(1, size(detected_faces, 1));
for i = 1:size(detected_faces, 1)
    if supressed_indexes(i) == 0
        face = detected_faces(i, :);
        for j = 1: size(detected_faces, 1)
            if i ~= j
                intersection = rectint(detected_faces(j, :), face);
                union = 2 * prod(BLOCK_SIZE) - intersection;
                IoU = intersection / union; % Intersection over union.
                if IoU > 0.3
                    supressed_indexes(j) = 1;
                end
            end
        end
    end
end

fprintf("\nConcluído\n");
I = cat(3, I, I, I);
for i = 1:length(supressed_indexes)
    if supressed_indexes(i) == 0
        face = detected_faces(i, 1:2);
        I = draw_rectangle(I, face, BLOCK_SIZE, [0, 0, 255]);
    end
end
imshow(I);