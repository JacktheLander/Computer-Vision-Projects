I = imread("FacesDatabase/s5/7.pgm");
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

%% Mask the output with face regiod predictor
[bin1_upper, bin2_lower] = top_down(I);

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