function [ hist ] = normalize( hist, image_size, patch_size, norm_kernel )
%NORMALIZE Summary of this function goes here
%   Detailed explanation goes here

%%% Normalização
for i=1:norm_kernel:(image_size(1)/patch_size)
    for j=1:norm_kernel:(image_size(2)/patch_size)
        x_range = i:(i + norm_kernel - 1);
        y_range = j:(j + norm_kernel - 1);
        norm_block = hist(x_range, y_range, :);
        norm_block = norm_block / max(norm_block(:));
        hist(x_range, y_range, :) = norm_block;
    end
end

end

