I = imread("FacesDatabase/s15/7.pgm");
D = im2double(I);


figure;
subplot(2,2,1);
imshow(I, []);
title("Original Image");

%% --- FFT ---
F = fft2(D);
F_shift = fftshift(F);

%% --- Build Gaussian High-Pass Filter ---
[rows, cols] = size(I);
[u, v] = meshgrid(-floor(cols/2):floor(cols/2-1), -floor(rows/2):floor(rows/2-1));

D = sqrt(u.^2 + v.^2);   % distance from center
sigma = 30;              % low sigma = more sharpening, high sigma = less
H = 1 - exp(-(D.^2) / (2*sigma^2));

subplot(2,2,2);
imshow(H, []);
title("Gaussian High-Pass Filter");

%Apply Filter in Frequency Domain
F_hp = F_shift .* H;

% Magnitude Spectrum After Filtering
mag_after = log(1 + abs(F_hp));
subplot(2,2,3);
imshow(mag_after, []);
title("High-Frequency Spectrum");

% Reconstruct Sharpened Image
F_unshift = ifftshift(F_hp);
I_hp = real(ifft2(F_unshift));

subplot(2,2,4);
imshow(I_hp, []);
title("Edge-Enhanced Image (FFT Sharpening)");



%% Sobel Edge Detection
Gx = imfilter(I_hp, fspecial('sobel')', 'replicate');   % horizontal edges
Gy = imfilter(I_hp, fspecial('sobel'),  'replicate');    % vertical edges

Gmag = sqrt(Gx.^2 + Gy.^2);
Gmag_norm = mat2gray(Gmag);
sobel_binary = Gmag_norm > 0.2;

% Morphological closing
SE = strel("disk", 1);
sobel_binary = imdilate(sobel_binary, SE);
sobel_binary = imerode(sobel_binary, SE);

% Remove borders
border = 2;
sobel_clean = sobel_binary;
sobel_clean(1:border,:) = 0;
sobel_clean(end-border+1:end,:) = 0;
sobel_clean(:,1:border) = 0;
sobel_clean(:,end-border+1:end) = 0;

figure;
subplot(2,2,1); imshow(sobel_clean, []); title("Sobel");

%% Canny Edge Detection
E_canny = edge(I_hp, 'canny', 0.2, 1.5);

% Morph closing
E_canny = imdilate(E_canny, SE);
E_canny = imerode(E_canny, SE);

% Remove borders
canny_clean = E_canny;
canny_clean(1:border,:) = 0;
canny_clean(end-border+1:end,:) = 0;
canny_clean(:,1:border) = 0;
canny_clean(:,end-border+1:end) = 0;

subplot(2,2,2); imshow(canny_clean, []); title("Canny");

%% Weighted Combination of Sobel + Canny

sobel_f = double(sobel_clean);
canny_f = double(canny_clean);

% Gaussian blur BEFORE fusion to expand edges and create overlap field
sobel_blur = imgaussfilt(sobel_f, 1.2);   % sigma = 1.2 (tune)
canny_blur = imgaussfilt(canny_f, 1.2);

subplot(2,2,3); imshow(sobel_blur, []); title("Blurred Sobel");
subplot(2,2,4); imshow(canny_blur, []); title("Blurred Canny");

% Convert both to double for weighted sum
sobel_f = double(sobel_clean);
canny_f = double(canny_clean);

w_sobel = 0.5;
w_canny = 0.7;

combined_soft = w_sobel * sobel_blur + w_canny * canny_blur;

% Normalize combined field
combined_norm = mat2gray(combined_soft);

figure;
subplot(1,2,1); imshow(combined_norm, []); title("Soft Combined Map");

% Final threshold
edge_thresh = 0.5;   % tune for your image
combined_binary = combined_norm > edge_thresh;

% Morphological clean-up
combined_binary = imdilate(combined_binary, SE);
combined_binary = imerode(combined_binary, SE);

subplot(1,2,2); imshow(combined_binary); title("Final Combined Binary Edges");


%% Thresholding
% --- Set threshold value
threshold = 90;                % adjust for your case (0–255)

% Create binary mask of below-threshold pixels
mask = I < threshold;

% Extract pixel values using the mask
pixelValues = I(mask);

% --- Display results
figure;
subplot(3,3,1); imshow(I, []); title('Original Image');
subplot(3,3,2); imshow(mask); title('Pixels Below Threshold');
subplot(3,3,3); histogram(pixelValues); title('Histogram of Extracted Pixels');

% Equalized before thresholding
I_eq = histeq(I);
eq_mask = I_eq < threshold;
eqValues = I(eq_mask);
subplot(3,3,4); imshow(I_eq, []); title('Equalized Image');
subplot(3,3,5); imshow(eq_mask); title('Pixels Below Threshold');
subplot(3,3,6); histogram(eqValues); title('Histogram of Extracted Pixels');

% Smoothing before thresholding
I_blur = imgaussfilt(I, 1.2);
sm_mask = I_blur < threshold;
blurValues = I(sm_mask);
subplot(3,3,7); imshow(I_blur, []); title('Blurred Image');
subplot(3,3,8); imshow(sm_mask); title('Pixels Below Threshold');
subplot(3,3,9); histogram(blurValues); title('Histogram of Extracted Pixels');


%% Clean and Resize Canny to match threshold image size

figure;
imshow(combined_binary, []);
E_resized = imresize(combined_binary, size(mask), "nearest");

% Dilate
SE = strel("disk", 2);
dil_mask = imdilate(eq_mask, SE);

subplot(1,3,1)
imshow(E_resized, []);
title("Combined Edge Map");

subplot(1,3,2)
imshow(dil_mask);
title("Equalized, Thresholded, Dilated");

%% Create output showing where BOTH are 1

size(E_resized)
size(dil_mask)
bothMask = dil_mask & E_resized;

subplot(1,3,3);
imshow(bothMask, []);
title("Points of Union");

bothMask_resized = imresize(bothMask, size(I), "nearest");

%% Sobel Kernel for Vertical Edges
Sobel_vertical = [ -1  0  1;
                   -2  0  2;
                   -1  0  1 ];

% Apply filter
vertical_edges = imfilter(I, Sobel_vertical, "replicate");

% Magnitude scaling
vertical_edges_mag = mat2gray(abs(vertical_edges));

subplot(1,3,2);
imshow(vertical_edges_mag, []);
title("Vertical Edge Response");

% Threshold to show only strong vertical edges
threshold = 0.2;
vertical_edges_binary = vertical_edges_mag > threshold;

subplot(1,3,3);
imshow(vertical_edges_binary, []);
title("Strong Vertical Edges");


%% Compute Column Edge Density
colDensity = sum(vertical_edges_binary, 1);   % sum edges per column

% Choose columns with above-threshold edge density
densityThreshold = 0.5 * max(colDensity);    % top 50%
selectedColumns = colDensity > densityThreshold;


% Build Red Highlight Mask For Selected Columns
[rows, cols] = size(I);

columnMask = false(rows, cols);
columnIndices = find(selectedColumns);

for k = 1:length(columnIndices)
    x = columnIndices(k);
    columnMask(:, x) = true;   % highlight whole column
end

% Convert grayscale I to RGB
Igray = mat2gray(I);
R = Igray; G = Igray; B = Igray;

% Highlight selected columns in red
R(columnMask) = 1;
G(columnMask) = 0;
B(columnMask) = 0;

highlightRGB = cat(3, R, G, B);

figure;
subplot(2,3,1);
imshow(I, []);
title("Original Image");

% Display Highlight Overlay
subplot(2,3,[2 3]);
imshow(highlightRGB);
title("Columns With High Vertical Edge Density");


% Plot Column Density Curve
subplot(2,3,4);
plot(colDensity, "LineWidth", 2);
title("Vertical Edge Density per Column");
xlabel("Column Index");
ylabel("Edge Count");
grid on;

% List output columns
disp("Selected vertical edge columns:");
disp(columnIndices);


%% Histogram of Vertical Edge Density (Bins of 10 pixels)
binSize = 10;

numCols = size(vertical_edges_binary, 2);
colDensity = sum(vertical_edges_binary, 1);

% Number of bins
numBins = ceil(numCols / binSize);

% Allocate histogram
densityHist = zeros(1, numBins);

% Sum each group of 10 columns
for b = 1:numBins
    startIdx = (b-1)*binSize + 1;
    endIdx = min(b*binSize, numCols);
    densityHist(b) = sum(colDensity(startIdx:endIdx));
end

% Plot the histogram
subplot(2,3,5);
bar(densityHist, 'FaceColor', [0.2 0.2 0.8]);
title("Density Histogram");
xlabel("10-Pixel Column Groups");
ylabel("Edge Count");
grid on;


%% Find the 2 highest-density bins
[~, sortedIdx] = sort(densityHist, 'descend');
topBins = sortedIdx(1:2);
topBins = sort(topBins);   % left bin first, right bin second

% Compute center x-positions of each bin
binCenter = ((topBins - 1) * binSize) + (binSize / 2);
binCenter = round(binCenter);

x1 = binCenter(1);
x2 = binCenter(2);

% Lower and upper x-boundaries for each 10-pixel bin
bin1 = topBins(1);
bin2 = topBins(2);

bin1_lower = (bin1-1)*binSize + 1;
bin1_upper = bin1*binSize;

bin2_lower = (bin2-1)*binSize + 1;
bin2_upper = bin2*binSize;

% Overlay the lines on the original image
figure;
imshow(I, []);
title("Predicted Face Lines");
hold on;

% Draw red lines at the bin centers
xline(x1, 'Color', 'red', 'LineWidth', 2);
xline(x2, 'Color', 'red', 'LineWidth', 2);

% --- Green lines: left & right boundaries of each selected bin ---
%xline(bin1_lower, 'Color', 'green', 'LineWidth', 1.5);
xline(bin1_upper, 'Color', 'green', 'LineWidth', 1.5);

xline(bin2_lower, 'Color', 'green', 'LineWidth', 1.5);
%xline(bin2_upper, 'Color', 'green', 'LineWidth', 1.5);

yline(36, 'Color', 'blue', 'LineWidth', 1.5);
yline(72, 'Color', 'blue', 'LineWidth', 1.5);


%% Mask the output with face regiod predictor

fprintf("bin1_upper = %d\n", bin1_upper);
fprintf("bin2_lower = %d\n", bin2_lower);

% Check the horizontal span
span = bin2_lower - bin1_upper;

if span < 40
    % Reset allowable range
    bin1_upper = 1;
    bin2_lower = 91;
end

% Compute middle-upper section in the Y direction
y_start = 36;
y_end   = 72;

% Turn ON only the pixels inside the chosen region
final_mask = false(size(I));   % full image mask

final_mask(y_start:y_end, bin1_upper:bin2_lower) = ...
    bothMask_resized(y_start:y_end, bin1_upper:bin2_lower);


%% Build translucent red overlay
I_gray = mat2gray(I);   % base grayscale image

alpha = 0.40;           % transparency (0 = none, 1 = solid red)

% Start with the original grayscale for each RGB channel
R = I_gray;
G = I_gray;
B = I_gray;

% Define the red tint color (full red = [1 0 0])
red_val = 1;

% Apply translucent overlay where final_mask == 1
R(final_mask) = (1 - alpha)*I_gray(final_mask) + alpha*red_val;
G(final_mask) = (1 - alpha)*I_gray(final_mask) + alpha*0;
B(final_mask) = (1 - alpha)*I_gray(final_mask) + alpha*0;

overlayRGB = cat(3, R, G, B);

figure;
imshow(overlayRGB);
title("Final Overlay");