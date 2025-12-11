%% Edge -> Morphological  -> Circles, Detection Pipeline
I = imread("FacesDatabase/s16/2.pgm");
figure('Name','Eye Detection with Filtering');

subplot(3,4,1); imshow(I, []); title('1) Original image');


% Histogram Equalize
equalized = histeq(I);
subplot(3,4,2); imshow(equalized, []); title('2) Equalized image');

% Adding smoothing for edge improvement
smoothed = imgaussfilt(equalized, 1.5);

subplot(3,4,3); imshow(smoothed, []); title('3) Smoothed image');

% Sobel edges
E_sobel = edge(equalized, 'sobel', 0.15);
subplot(3,4,4); imshow(E_sobel);   title('4) Sobel edge map');

SE = strel("disk", 1)
E_sobel  = imdilate(E_sobel, SE);    % dilation
E_sobel = imerode(E_sobel, SE);    % erosion (closing: dilate then erode)
subplot(3,4,5); imshow(E_sobel);   title('5) Closed Sobel edge map');

% Canny edges
E_canny = edge(equalized, 'Canny', 0.5, 1.5);
subplot(3,4,6); imshow(E_canny, []); title('6) Canny Edge Map');

E_canny  = imdilate(E_canny, SE);    % dilation
E_canny = imerode(E_canny, SE);    % erosion (closing: dilate then erode)
subplot(3,4,7); imshow(E_canny);   title('7) Closed Canny edge map');


% Morphological Filtering

E = mat2gray(1.3*E_sobel + 0.7*E_canny); % Weighted Fusion of Sobel and Canny
subplot(3,4,8); imshow(E, []); title('8) Combined Edge Map');
