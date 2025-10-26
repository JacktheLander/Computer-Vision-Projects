%% Morphological Filter

%% Create synthetic test images
rows = 20;   % you can increase for larger visualization
cols = 20;

f1 = zeros(rows, cols);
f2 = zeros(rows, cols);
f3 = zeros(rows, cols);

% Define bright columns
f1(:,7) = 100;              % column 7 bright
f2(:,8) = 100;              % column 8 bright
f3(:,7) = 100; f3(:,8) = 100; % columns 7 and 8 bright

%% Apply a 3x3 median filter
f1_med = medfilt2(f1, [3 3]);
f2_med = medfilt2(f2, [3 3]);
f3_med = medfilt2(f3, [3 3]);

%% Display results
figure('Name','3x3 Median Filter Behavior');

subplot(3,3,1); imagesc(f1); axis image; title('f1 original (col 7 = 100)');
subplot(3,3,2); imagesc(f2); axis image; title('f2 original (col 8 = 100)');
subplot(3,3,3); imagesc(f3); axis image; title('f3 original (cols 7,8 = 100)');

subplot(3,3,4); imagesc(f1_med); axis image; title('f1 after median');
subplot(3,3,5); imagesc(f2_med); axis image; title('f2 after median');
subplot(3,3,6); imagesc(f3_med); axis image; title('f3 after median');

subplot(3,3,7:9);
plot(1:cols, f1(rows/2,:), 'b-', ...
     1:cols, f1_med(rows/2,:), 'b--', ...
     1:cols, f2(rows/2,:), 'r-', ...
     1:cols, f2_med(rows/2,:), 'r--', ...
     1:cols, f3(rows/2,:), 'g-', ...
     1:cols, f3_med(rows/2,:), 'g--', 'LineWidth',1.5);
legend('f1 orig','f1 med','f2 orig','f2 med','f3 orig','f3 med');
xlabel('Column index'); ylabel('Intensity'); title('Row profile comparison');
