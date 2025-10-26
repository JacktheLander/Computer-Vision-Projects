%% Mean and Median Filtering
I = imread('blockTest.png');   % Replace with your image file

%% ========== LINEAR SMOOTHING FILTERS ==========

% a) 3x3 mean value filter
mean3 = fspecial('average', [3 3]);
I_mean3 = imfilter(I, mean3, 'replicate');

% b) 5x5 mean value filter
mean5 = fspecial('average', [5 5]);
I_mean5 = imfilter(I, mean5, 'replicate');

% c) 3x3 mean filter applied twice
I_mean3_twice = imfilter(I_mean3, mean3, 'replicate');

% d) 5x5 Gaussian filter with σ = 1.0
gauss5 = fspecial('gaussian', [5 5], 1.0);
I_gauss5 = imfilter(I, gauss5, 'replicate');

% e) 11x11 Gaussian filter with σ = 2.0
gauss11 = fspecial('gaussian', [11 11], 2.0);
I_gauss11 = imfilter(I, gauss11, 'replicate');

%% Display linear results
figure('Name', 'Linear Smoothing Filters');
subplot(2,3,1); imshow(uint8(I)); title('Original');
subplot(2,3,2); imshow(uint8(I_mean3)); title('3x3 Mean Filter');
subplot(2,3,3); imshow(uint8(I_mean5)); title('5x5 Mean Filter');
subplot(2,3,4); imshow(uint8(I_mean3_twice)); title('3x3 Mean Filter Twice');
subplot(2,3,5); imshow(uint8(I_gauss5)); title('5x5 Gaussian, σ=1.0');
subplot(2,3,6); imshow(uint8(I_gauss11)); title('11x11 Gaussian, σ=2.0');

%% ========== NONLINEAR SMOOTHING FILTERS ==========

% a) 3x3 median value filter
I_med3 = medfilt2(I, [3 3]);

% b) 5x5 median value filter
I_med5 = medfilt2(I, [5 5]);

% c) 3x3 median filter applied twice
I_med3_twice = medfilt2(I_med3, [3 3]);

% d) 11x11 median filter
I_med11 = medfilt2(I, [11 11]);

%% Display nonlinear results
figure('Name', 'Nonlinear Smoothing Filters');
subplot(2,3,1); imshow(uint8(I)); title('Original');
subplot(2,3,2); imshow(uint8(I_med3)); title('3x3 Median Filter');
subplot(2,3,3); imshow(uint8(I_med5)); title('5x5 Median Filter');
subplot(2,3,4); imshow(uint8(I_med3_twice)); title('3x3 Median Filter Twice');
subplot(2,3,5); imshow(uint8(I_med11)); title('11x11 Median Filter');

