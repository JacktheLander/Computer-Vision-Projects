%% Edge -> Morphological  -> Circles, Detection Pipeline
I = imread("FacesDatabase/s1/7.pgm");
figure('Name','Eye Detection with Filtering');

subplot(3,4,1); imshow(I, []); title('1) Original image');


% Histogram Equalize
equalized = histeq(I);
subplot(3,4,2); imshow(equalized, []); title('2) Equalized image');

% Adding smoothing for edge improvement
smoothed = imgaussfilt(equalized, 0.2);

subplot(3,4,3); imshow(smoothed, []); title('3) Smoothed image');

% Sobel edges
E_sobel = edge(smoothed, 'sobel', 0.13);
subplot(3,4,4); imshow(E_sobel);   title('4) Sobel edge map');

E_sobel  = imdilate(E_sobel, se_circle);    % dilation
E_sobel = imerode(E_sobel, se_circle);    % erosion (closing: dilate then erode)
subplot(3,4,5); imshow(E_sobel);   title('5) Closed Sobel edge map');

% Canny edges
E_canny = edge(equalized, 'Canny', 0.5, 1.5); 
subplot(3,4,6); imshow(E_canny, []); title('6) Canny Edge Map');

E_canny  = imdilate(E_canny, se_circle);    % dilation
E_canny = imerode(E_canny, se_circle);    % erosion (closing: dilate then erode)
subplot(3,4,7); imshow(E_canny);   title('7) Closed Canny edge map');


% Morphological Filtering

E = mat2gray(1.3*E_sobel + 0.7*E_canny); % Weighted Fusion of Sobel and Canny
subplot(3,4,8); imshow(E, []); title('8) Combined Edge Map');

% Remove small noisy blobs

minArea = 5;                            % tune for your images
E_clean = bwareaopen(E, minArea);

%subplot(3,4,8); imshow(E_clean); title('8) After removing small blobs');


% Elliptical donut kernel (oval iris template)
radiusX_outer = 9;   % horizontal radius (make larger for wide eyes)
radiusY_outer = 6;   % vertical radius

radiusX_inner = 4;   % inner hole radii
radiusY_inner = 5;

[x, y] = meshgrid(-radiusX_outer:radiusX_outer, -radiusY_outer:radiusY_outer);

outerEllipse = (x.^2)/(radiusX_outer^2) + (y.^2)/(radiusY_outer^2) <= 1;
innerEllipse = (x.^2)/(radiusX_inner^2) + (y.^2)/(radiusY_inner^2) < 1;

ovalKernel = outerEllipse & ~innerEllipse;

subplot(3,4,9); imshow(ovalKernel, []); title('Oval Kernel');

% Normalized cross-correlation

% Convert to double for normxcorr2
E_double = im2double(E);
K_double = im2double(ovalKernel);

Corr = normxcorr2(K_double, E_double);   % correlation map (bigger than image)
Cnorm = mat2gray(Corr);                  % scale to [0,1] for display

subplot(3,4,10); imshow(Cnorm, []); title('10) Correlation map');


% Find candidate peaks in correlation

% Simple global threshold (you can refine this)
peakThresh = 0.9 * max(Corr(:));         % 70% of max response
peakMask   = Corr > peakThresh;

subplot(3,4,11); imshow(peakMask, []); title('11) Correlation peaks');


% Overlay detected centers on original image

% Find peak coordinates
[ypeak, xpeak] = find(peakMask);

% Convert normxcorr2 coords to original image coords
% normxcorr2 output is larger: size(E) + size(kernel) - 1
corr_h = size(Corr, 1);
corr_w = size(Corr, 2);

% Offsets due to padding
xoff = xpeak - radius - 1;
yoff = ypeak - radius - 1;

subplot(3,4,12); imshow(I, []); title('12) Detected circles on image');
hold on;
for k = 1:numel(xoff)
    % Draw circles at detected locations (if inside the image bounds)
    if xoff(k) > 0 && xoff(k) <= w && yoff(k) > 0 && yoff(k) <= h
        viscircles([xoff(k), yoff(k)], radius, 'LineWidth', 0.7);
    end
end
hold off;