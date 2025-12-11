%% Load Image
I = imread("FacesDatabase/s14/6.pgm");
I = im2double(I);              % Convert to double for processing

% If grayscale, keep as 2D; if RGB, handle 3D
isColor = (ndims(I) == 3);

%% Define smoothing filter
h = fspecial('gaussian', [5 5], 1);   % 5×5 Gaussian, sigma = 1

%% MaxPool 2×2 function
function out = maxpool2(img)
    % Handles grayscale or RGB
    if ndims(img) == 2
        out = blockproc(img, [2 2], @(b) max(b.data(:)));
    else
        out = zeros(size(img,1)/2, size(img,2)/2, size(img,3));
        for c = 1:3
            out(:,:,c) = blockproc(img(:,:,c), [2 2], @(b) max(b.data(:)));
        end
    end
end

%% Case 1 — Smooth BEFORE downsampling
I_smooth_before = imfilter(I, h, 'replicate');
I_down_before   = maxpool2(I_smooth_before);

%% Case 2 — Smooth AFTER downsampling
I_down_first    = maxpool2(I);
I_smooth_after  = imresize(imfilter(I_down_first, h, 'replicate'), size(I), 'nearest');

%% Display
figure;
subplot(2,2,1); imshow(I, []);                  title('Original');

subplot(2,2,2); imshow(I_down_before, []);      title('Smooth → MaxPool 2×2');

subplot(2,2,3); imshow(I_down_first, []);       title('MaxPool 2×2 (no smoothing)');

subplot(2,2,4); imshow(I_smooth_after, []);     title('MaxPool → Smooth (Upsampled to compare)');
