I = imread("FacesDatabase/s30/5.pgm");

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

% Smoothing before thresholding
I_blur = imgaussfilt(I, 1.2);
mask = I_blur < threshold;
blurValues = I(mask);
subplot(3,3,4); imshow(I_blur, []); title('Blurred Image');
subplot(3,3,5); imshow(mask); title('Pixels Below Threshold');
subplot(3,3,6); histogram(blurValues); title('Histogram of Extracted Pixels');
