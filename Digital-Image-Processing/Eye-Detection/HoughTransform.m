%% Hough transform
E = edge(I, "Canny");

subplot(2,3,2);
imshow(E, []);
title("Canny Edge Map");

% Hough Transform
[H, theta, rho] = hough(E);

subplot(2,3,3);
imshow(H, [], "XData", theta, "YData", rho);
xlabel("\theta (degrees)");
ylabel("\rho");
title("Hough Transform");
axis on; axis normal;
colormap(gca, hot);

% Extract Hough peaks (strong lines)
numPeaks = 12;  
peaks = houghpeaks(H, numPeaks, "Threshold", 0.3 * max(H(:)));

% Find Hough lines from peaks
linesDetected = houghlines(E, theta, rho, peaks, ...
                           "FillGap", 10, "MinLength", 15);

% Keep only vertical lines
% Vertical lines ≈ theta near 0° (perfect vertical)
verticalTolerance = 10;   % degrees

verticalLines = [];
for k = 1:length(linesDetected)
    if abs(linesDetected(k).theta) < verticalTolerance  % near-vertical
        verticalLines = [verticalLines, linesDetected(k)];
    end
end

% Display vertical lines on the image
subplot(2,3,[4 5 6]);
imshow(I, []);
title("Detected Vertical Lines (Hough Transform)");
hold on;

for k = 1:length(verticalLines)
    xy = [verticalLines(k).point1; verticalLines(k).point2];
    plot(xy(:,1), xy(:,2), "LineWidth", 2, "Color", "red");

    % mark endpoints
    plot(xy(1,1), xy(1,2), "x", "Color", "yellow");
    plot(xy(2,1), xy(2,2), "x", "Color", "yellow");
end

hold off;