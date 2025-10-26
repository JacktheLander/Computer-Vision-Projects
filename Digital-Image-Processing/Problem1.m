%% Separable Filters
% Define filter A (a simple blur)
A = [1 1 1;
     0 0 0;
     -1 -1 -1];

% Define filter B (vertical edge detector, like Sobel)
B = [1 0 -1;
     1 0 -1;
     1 0 -1];

% Combine them by 2D convolution
C = conv2(A, B, 'full');

% Display results
disp('Combined filter C =');
disp(C);

% Visualize
figure;
subplot(1,3,1); imagesc(A); title('Filter A'); axis image; colorbar;
subplot(1,3,2); imagesc(B); title('Filter B'); axis image; colorbar;
subplot(1,3,3); imagesc(C); title('Combined Filter C'); axis image; colorbar;
