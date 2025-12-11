I = imread("FacesDatabase/s1/2.pgm");
imshow(I)
figure;
subplot(4,4,1); imshow(I, []); title('1) Original Image');


%% 2) Gaussian smoothing to capture soft gradients
I_smooth = imgaussfilt(I, 1.2);   % sigma controls softness sensitivity
subplot(4,4,2); imshow(I_smooth, []); title('2) Gaussian Smoothed');


%% 3) Gradient magnitude (not binary edges!)
[Gx, Gy] = imgradientxy(I_smooth, 'sobel');
Gmag = sqrt(Gx.^2 + Gy.^2);
Gmag = mat2gray(Gmag);              % normalize for visibility

subplot(4,4,3); imshow(Gmag, []); title('3) Gradient Magnitude');


%% 4) Difference of Gaussians (DoG) to enhance circular blobs
I_g1 = imgaussfilt(I, 1.0);
I_g2 = imgaussfilt(I, 2.0);
DoG = I_g1 - I_g2;
DoG = mat2gray(abs(DoG));           % emphasize structure

subplot(4,4,4); imshow(DoG, []); title('4) DoG (Blob Enhancer)');


%% 5) Combine gradient blobs + DoG for eye emphasis
EyeSignal = mat2gray(Gmag .* DoG);  % elementwise multiply
subplot(4,4,5); imshow(EyeSignal, []); title('5) Combined Gradient Blob Signal');


%% 6) Optional: restrict to eye region (vertical ROI)
[h, w] = size(EyeSignal);
top = round(0.2*h);
bottom = round(0.75*h);

Mask = false(h, w);
Mask(top:bottom, :) = true;

EyeROI = EyeSignal .* Mask;
subplot(4,4,6); imshow(EyeROI, []); title('6) ROI (Approx Eye Region)');


%% 7) Morphological smoothing (small dilation → closing)
SE = strel('disk', 1);          % gentle dilation to connect faint arcs
EyeDil = imdilate(EyeROI, SE);
EyeClose = imclose(EyeDil, SE);

subplot(4,4,7); imshow(EyeDil, []);   title('7) Dilated');
subplot(4,4,8); imshow(EyeClose, []); title('8) Closed (Dilate → Erode)');


%% 8) Clean remaining noise
EyeClean = bwareaopen(EyeClose > 0.1, 25);    % threshold + remove tiny blobs
subplot(4,4,9); imshow(EyeClean, []); title('9) Cleaned (Small Blob Removal)');


%% 9) Build circular eye kernel for correlation
radius = 5;                          % adjust per face size
[x, y] = meshgrid(-radius:radius);
CircleKernel = double((x.^2 + y.^2) <= radius^2);

subplot(4,4,10); imshow(CircleKernel, []); title('10) Circular Eye Kernel');


%% 10) Normalized cross correlation with CircleKernel
Corr = normxcorr2(CircleKernel, EyeClose);   % use grayscale, not binary
CorrN = mat2gray(Corr);

subplot(4,4,11); imshow(CorrN, []); title('11) Correlation Map');


%% 11) Peak detection (candidate eyes)
peakThresh = 0.7 * max(Corr(:));     % tune threshold if needed
PeakMask = Corr > peakThresh;

subplot(4,4,12); imshow(PeakMask, []); title('12) Correlation Peaks');


%% 12) Convert correlation peaks to image coordinates
[ypeak, xpeak] = find(PeakMask);

% normxcorr2 output is larger than image
xoff = xpeak - radius - 1;
yoff = ypeak - radius - 1;


%% 13) Overlay detected eye centers on original image
subplot(4,4,13); imshow(I, []); title('13) Detected Eye Centers'); hold on;

for k = 1:numel(xoff)
    if xoff(k) > 0 && xoff(k) <= w && yoff(k) > 0 && yoff(k) <= h
        viscircles([xoff(k), yoff(k)], radius, 'LineWidth', 0.7);
    end
end

hold off;


%% 14) Display extracted eye response (signal map)
subplot(4,4,14); imagesc(EyeSignal); axis image; colormap jet;
title('14) Eye Blob Signal (Jet Colormap)');


%% 15) Display cleaned region
subplot(4,4,15); imagesc(EyeClean); axis image; colormap gray;
title('15) Cleaned Eye Candidates');


%% 16) Summary Text
subplot(4,4,16); axis off;
text(0,0.5, sprintf('Detected %d candidate eye centers.\nTune radius & thresholds.', numel(xoff)), ...
    'FontSize', 10);
title('16) Summary');