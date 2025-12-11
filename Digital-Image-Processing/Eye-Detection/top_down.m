function [bin1_upper, bin2_lower] = top_down(I)
I = im2double(I);

figure;
subplot(1,3,1);
imshow(I, []);
title("Original Image");

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

hold off;
end