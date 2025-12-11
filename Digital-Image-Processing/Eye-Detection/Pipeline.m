I = imread("FacesDatabase/s22/5.pgm");
I = im2double(I);

%% face edge detection function
[bin1_upper, bin2_lower] = top_down(I);

fprintf("bin1_upper = %d\n", bin1_upper);
fprintf("bin2_lower = %d\n", bin2_lower);

% Compute middle-upper quarter in the Y direction
y_start = round(rows * 0.25);
y_end   = round(rows * 0.50);

% Create 2D mask (same size as image)
mask = false(rows, cols);

% Turn ON only the pixels inside the chosen region
mask(y_start:y_end, bin1_upper:bin2_lower) = true;

% Apply mask to the image
I_masked = I .* mask;

figure; 
imshow(I_masked, []);
title("Masked Image (only selected X and Y range visible)");