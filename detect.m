%%% UNIVERSIDADE FEDERAL DO CEARÁ
%%% CAMPUS SOBRAL
%%% PROCESSAMENTO DIGITAL DE SINAIS 2018.2

%%% ABNER SOUSA NASCIMENTO 374864

%%% detect.m: Aplica o método de detecção de faces implementado.

clear; clc; close all;

addpath('libsvm'); % Carrega a biblioteca libsvm.
BLOCK_SIZE = [32 32]; % Tamanho do bloco para geração dos descritores.
PATCH_SIZE = 4; % Tamanho dos quadrados descritores de cada bloco.
BINS = 8; % Quantidade de setores no histograma de direções.
NORM_KERNEL_SIZE = 2; % Tamanho do kernel de normalização dos histogramas.
DISPLAY = true; % Ativar/desativar a visualização da varredura da imagem.
STEP = 2; % Distância em pixels entre os blocos da varredura.
MIN_CONFIDENCE = 0.98; % Nível de confiança mínimo para detecção da face.
FILTER = 'sobel'; % Filtro a ser utilizado

% Leitura da imagem.
I = rgb2gray(imread('samples/sample_1.jpg'));

% Carregamento do classificador treinado com o script train.m.
if strcmp(FILTER, 'sobel')
    load('svm_model_sobel.mat', 'svm_model');
elseif strcmp(FILTER, 'prewitt')
    load('svm_model_prewitt.mat', 'svm_model');
end


% Definição dos intervalos de índices para a varredura.
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
detections = [];

% Níveis de confiança para cada uma das detecções.
confidences = [];

fprintf("Processando, por favor aguarde...\n");
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
        hist = hog(block, PATCH_SIZE, BINS, NORM_KERNEL_SIZE, FILTER);

        % Realiza predição
        [label, ~, confidence] = svmpredict(...
            1, sparse(hist(:)'), ...
            svm_model, ...
            '-q -b 1' ...
        );
        
        if label == 1 && confidence(label + 1) > MIN_CONFIDENCE
            rect = [i j BLOCK_SIZE];
            detections = [detections; rect];
            confidences = [confidences; confidence(label + 1)];
            
            if DISPLAY
                % Desenha um retângulo amarelo
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

if length(detections) > 1
    faces = nonmaxsup(detections, confidences, 0.3);
else
    faces = detections;
end

fprintf("Concluído.\n");
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