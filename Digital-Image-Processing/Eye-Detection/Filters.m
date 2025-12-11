%% Digital Laplacian
I = imread("FacesDatabase/s20/2.pgm");
%imshow(I)
I = imgaussfilt(I, 0.8, "FilterSize", [3 3]);
H = [0 -1 0; -1 4 -1; 0 -1 0];
g = conv2(I, H, 'full');

figure('Name','Digital Laplacian Test');
imshow(g); title('Digital Laplacian'); % Doesnt work well

%% Sobel Gradient
H1 = [1 3 1; 0 0 0; -1 -3 -1];
H2 = [1 0 -1; 3 0 -3; 1 0 -1];
g1 = conv2(I, H1, 'full');
g2 = conv2(I, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);
Gclean = Gmag(3:end-2, 3:end-2);

figure('Name','Sobel Filter Gradient Test');
subplot(2,2,1); imagesc(Gclean); title('Gradient Magnitude'); colorbar;
subplot(2,2,2); imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

subplot(2,2,3); imagesc(Gclean); title('Horizontal Magnitude'); colorbar;
subplot(2,2,4); imagesc(Gclean); title('Vertical Magnitude'); colorbar;

EyeEdges = 0.7 * abs(Gy) + 0.3 * abs(Gx);


%% Prewitt Filter
H1 = [-1 0 1; -1 0 1; -1 0 1];
H2 = [-1 -1 -1; 0 0 0; 1 1 1];
g1 = conv2(I, H1, 'full');
g2 = conv2(I, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);
Gclean = Gmag(3:end-2, 3:end-2);

figure('Name','Prewitt Filter Gradient Test');
subplot(1,2,1); imagesc(Gclean); title('Gradient Magnitude'); colorbar;
subplot(1,2,2); imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

%% Canny Edge Detector

edges = edge(I, 'Canny');        % Apply Canny edge detector

figure('Name','Canny Edge Detector Test');
imshow(edges);                       % Display result
title('Canny Edge Detection');

%% Median Filter

median = medfilt2(I, [3 3]);
figure('Name','Canny Edge Detector Test');
imshow(median);                       % Display result
title('Canny Edge Detection');

%% Horizontal filter
I = imread("FacesDatabase/s1/7.pgm");

% Sobel kernel for horizontal edges
Gy = [1 2 1; 0 0 0; -1 -2 -1];

% Apply filter
horizontalEdges = imfilter(I, Gy, 'replicate');

figure;
imshow(horizontalEdges, []);
title('Horizontal Edges (Sobel)');