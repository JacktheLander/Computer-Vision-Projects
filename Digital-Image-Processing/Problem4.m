%% Gradient and Edge Detection
f = zeros(11, 11);
f(5:11,5:11) = 100;

H1 = [1 2 1; 0 0 0; -1 -2 -1];
H2 = [1 0 -1; 2 0 -2; 1 0 -1];

g1 = conv2(f, H1, 'full');
g2 = conv2(f, H2, 'full');

figure('Name','Sobel Filtered Corner');

subplot(3,2,1); imagesc(f); title('Corner Image'); colorbar;

subplot(3,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(3,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(3,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(3,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

%% Gradient Vector
% Gradient magnitude and direction
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

% Plot magnitude
figure('Name','Gradient Magnitude and Direction');

subplot(1,2,1);
imagesc(Gmag);
axis image; colorbar;
title('Gradient Magnitude');

% Plot direction (converted to degrees for readability)
subplot(1,2,2);
imagesc(Gdir * 180/pi);
axis image; colorbar;
title('Gradient Direction (degrees)');

%% Test Images
[cc,rr] = meshgrid([1:13],[1:13]);
test1 = 100*ones(size(rr)) + 100*((rr > 3)&(rr < 9));
test2 = 100*ones(size(cc)) + 100*((cc > 3)&(cc < 9));
test3 = 100*ones(size(cc)) + 100*(cc>rr);
test4 = 100*ones(size(cc)) + 100*(cc>rr) + 50*(cc == rr);
test5 = (100/13)*cc;

% Test1
g1 = conv2(test1, H1, 'full');
g2 = conv2(test1, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(test1); title('Test Image'); colorbar;

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

% Test2
g1 = conv2(test2, H1, 'full');
g2 = conv2(test2, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(test2); title('Test Image'); colorbar;

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

% Test3
g1 = conv2(test3, H1, 'full');
g2 = conv2(test3, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(test3); title('Test Image'); colorbar;

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

% Test4
g1 = conv2(test4, H1, 'full');
g2 = conv2(test4, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(test4); title('Test Image'); colorbar;

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

% Test5
g1 = conv2(test5, H1, 'full');
g2 = conv2(test5, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(test5); title('Test Image'); colorbar;

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

%% House Test
house = rgb2gray(imread('4.1.05.tiff'));
g1 = conv2(house, H1, 'full');
g2 = conv2(house, H2, 'full');
Gmag = sqrt(g1.^2 + g2.^2);
Gdir = atan2(g1, g2);

figure('Name','Sobel Filter Gradient Test');

subplot(4,2,1); imagesc(house); title('Test Image');

subplot(4,2,3); imagesc(H1); title('Filter H1'); axis image; colorbar;
subplot(4,2,4); imagesc(H2); title('Filter H2'); axis image; colorbar;

subplot(4,2,5); imagesc(g1); axis image; title('Filtered by H1'); colorbar;
subplot(4,2,6); imagesc(g2); axis image; title('Filtered by H2'); colorbar;

subplot(4,2,7);imagesc(Gmag); title('Gradient Magnitude'); colorbar;
subplot(4,2,8);imagesc(Gdir * 180/pi); title('Gradient Direction'); colorbar;

%% Digital Laplacian

H = [0 1 0; 1 -4 1; 0 1 0];

house = rgb2gray(imread('4.1.05.tiff'));
g = conv2(house, H, 'full');

figure('Name','Sobel Filter Gradient Test');

subplot(2,2,1); imagesc(house); title('Test Image');
subplot(2,2,2); imagesc(H); title('Digital Laplacian'); axis image; colorbar;
subplot(2,2,3); imshow(g, []); title('Filtered []');
subplot(2,2,4); imshow(g, [0 255]); title('Filtered [0:255]');

imshow(g, [0 255])