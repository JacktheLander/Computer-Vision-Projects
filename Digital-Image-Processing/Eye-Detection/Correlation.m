% Normalized cross-correlation
K = imread("FacesDatabase/s1/2.pgm");
kernel = K(40:50, 25:40);

figure;
subplot(2,2,1); imshow(kernel); title('Kernel');

% Convert to double for normxcorr2
I = imread("FacesDatabase/s24/9.pgm");
subplot(2,2,2); imshow(I); title('Image');
E_double = im2double(I);
K_double = im2double(kernel);

Corr = normxcorr2(K_double, E_double);   % correlation map (bigger than image)
Cnorm = mat2gray(Corr);                  % scale to [0,1] for display

subplot(2,2,3); imshow(Cnorm, []); title('Correlation map');


% Find candidate peaks in correlation

% Simple global threshold (you can refine this)
peakThresh = 0.8 * max(Corr(:));         % 70% of max response
peakMask   = Corr > peakThresh;

subplot(2,2,4); imshow(peakMask, []); title('Correlation peaks');

%% Normalized cross-correlation of edges
G = fspecial('gaussian', [7 7], 1.2); 
kernel = 1 - G;   % if G is normalized

figure;
subplot(2,2,1); imshow(kernel); title('Kernel');

% Convert to double for normxcorr2
I = imread("FacesDatabase/s24/9.pgm");
subplot(2,2,2); imshow(I); title('Image');
E_double = im2double(I);
K_double = im2double(kernel);

Corr = normxcorr2(K_double, E_double);   % correlation map (bigger than image)
Cnorm = mat2gray(Corr);                  % scale to [0,1] for display

subplot(2,2,3); imshow(Cnorm, []); title('Correlation map');


% Find candidate peaks in correlation

% Simple global threshold (you can refine this)
peakThresh = 0.8 * max(Corr(:));         % 70% of max response
peakMask   = Corr > peakThresh;

subplot(2,2,4); imshow(peakMask, []); title('Correlation peaks');

%% Custom kernel
kernel = [
    0  0  1  2  1  0  0;
    0  1  5  7  5  1  0;
    1  5  7  9  7  5  1;
    2  7  9 10  9  7  2;
    1  5  7  9  7  5  1;
    0  1  5  7  5  1  0;
    0  0  1  2  1  0  0
];

kernel = mat2gray(kernel);

figure;
subplot(2,2,1); imshow(kernel); title('Kernel');

% Convert to double for normxcorr2
I = imread("FacesDatabase/s24/9.pgm");
I = 255-I;
subplot(2,2,2); imshow(I); title('Image');
E_double = im2double(I);
K_double = im2double(kernel);

Corr = normxcorr2(K_double, E_double);   % correlation map (bigger than image)
Cnorm = mat2gray(Corr);                  % scale to [0,1] for display

subplot(2,2,3); imshow(Cnorm, []); title('Correlation map');


% Find candidate peaks in correlation

% Simple global threshold (you can refine this)
peakThresh = 0.8 * max(Corr(:));         % 70% of max response
peakMask   = Corr > peakThresh;

subplot(2,2,4); imshow(peakMask, []); title('Correlation peaks');

%% Normalized cross-correlation
I = imread("FacesDatabase/s1/7.pgm");
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

% Convert to double for normxcorr2
E_double = im2double(I);
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