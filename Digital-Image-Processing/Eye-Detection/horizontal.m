I = imread("FacesDatabase/s6/9.pgm");
I = im2double(I);

figure;
subplot(1,3,1);
imshow(I, []);
title("Original Image");

%% Sobel Kernel for Horizontal Edges
% Detects horizontal edges by taking vertical intensity changes
Sobel_horizontal = [ -1 -2 -1;
                      0  0  0;
                      1  2  1 ];

% Apply filter
horizontal_edges = imfilter(I, Sobel_horizontal, "replicate");

% Magnitude scaling
horizontal_edges_mag = mat2gray(abs(horizontal_edges));

subplot(1,3,2);
imshow(horizontal_edges_mag, []);
title("Horizontal Edge Response");

% Threshold to show only strong horizontal edges
threshold = 0.2;
horizontal_edges_binary = horizontal_edges_mag > threshold;

subplot(1,3,3);
imshow(horizontal_edges_binary, []);
title("Strong Horizontal Edges");

%% Compute Row Edge Density (horizontal edges)
rowDensity = sum(horizontal_edges_binary, 2);   % sum edges per row

% Choose rows with above-threshold edge density
densityThreshold = 0.5 * max(rowDensity);
selectedRows = rowDensity > densityThreshold;

% Build Red Highlight Mask For Selected Rows
[rows, cols] = size(I);
rowMask = false(rows, cols);
rowIndices = find(selectedRows);

for k = 1:length(rowIndices)
    y = rowIndices(k);
    rowMask(y, :) = true;  % highlight whole row
end

% Convert grayscale I to RGB
Igray = mat2gray(I);
R = Igray; G = Igray; B = Igray;

% Highlight selected rows in red
R(rowMask) = 1;
G(rowMask) = 0;
B(rowMask) = 0;

highlightRGB = cat(3, R, G, B);

figure;
subplot(2,3,1);
imshow(I, []);
title("Original Image");

% Display Highlight Overlay
subplot(2,3,[2 3]);
imshow(highlightRGB);
title("Rows With High Horizontal Edge Density");

% Plot Row Density Curve
subplot(2,3,4);
plot(rowDensity, "LineWidth", 2);
title("Horizontal Edge Density per Row");
xlabel("Row Index");
ylabel("Edge Count");
grid on;

%% Histogram of Horizontal Edge Density (Bins of 5 pixels)
binSize = 5;   % <<< CHANGED FROM 10 TO 5

numCols = size(horizontal_edges_binary, 2);
colDensity = sum(horizontal_edges_binary, 1);

% Number of bins
numBins = ceil(numCols / binSize);

% Allocate histogram
densityHist = zeros(1, numBins);

% Sum each group of 5 columns
for b = 1:numBins
    startIdx = (b-1)*binSize + 1;
    endIdx   = min(b*binSize, numCols);
    densityHist(b) = sum(colDensity(startIdx:endIdx));
end

% Plot the histogram
subplot(2,3,5);
bar(densityHist, 'FaceColor', [0.2 0.2 0.8]);
title("Density Histogram (Bin Size = 5)");
xlabel("5-Pixel Column Groups");
ylabel("Edge Count");
grid on;

%% Detect bins above threshold
% Because you halved the bin size, each bin now holds ~half the edges.
% So threshold should be reduced, e.g., 200 → 100.
threshold = 60;           % <<< NEW
validRange = 10:14;        % <<< NEW (formerly 5:7)

% Subset the histogram
subset = densityHist(validRange);

% Find all bins above threshold
aboveIdxLocal = find(subset > threshold);

if isempty(aboveIdxLocal)
    disp("No bins above threshold.");
    return;
end

% Convert to actual histogram bin indices
selectedBins = validRange(aboveIdxLocal);

% Compute bin centers and boundaries
binCenters = (selectedBins*binSize - binSize/2) + 0.5;
binLowers  = (selectedBins - 1)*binSize + 1;
binUppers  = selectedBins * binSize;

%% Display horizontal lines
figure;
imshow(I, []);
title("Horizontal Lines for High-Density Bins (Bin Size = 5)");
hold on;

% Red center lines
for k = 1:length(binCenters)
    yline(binCenters(k), 'Color', 'red', 'LineWidth', 2);
end

% Green bin-boundary lines
for k = 1:length(selectedBins)
    yline(binLowers(k), 'Color', 'green', 'LineWidth', 1.5);
    yline(binUppers(k), 'Color', 'green', 'LineWidth', 1.5);
end

hold off;

%% Output details
disp("Selected bins (indices):");
disp(selectedBins);

disp("Centers (red lines):");
disp(binCenters);

disp("Boundaries (green lines):");
disp([binLowers(:), binUppers(:)]);
