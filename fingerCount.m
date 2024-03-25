% Clear workspace and command window
clear;
clc;

% Initialize webcam
cam = webcam("Integrated Camera");
preview(cam);  % Optional: Show preview of camera feed

% Get initial video frame and dimensions
videoframe = snapshot(cam);
frameSize = size(videoframe);

% Create video player
videoplayer = vision.VideoPlayer('Position', [100 100 frameSize(2) frameSize(1)]);

% Main loop
runloop = true;
while runloop
    % Capture current frame
    img1 = snapshot(cam);

    % Preprocess image
    img1 = rgb2gray(img1);       % Convert to grayscale
    img1 = imresize(img1, [480 640]);  % Resize to 480x640
    img2 = imcomplement(imbinarize(img1));  % Invert and binarize
    img3 = imfill(img2, 'holes');     % Fill holes
    img4 = bwareaopen(img3, 10000);   % Remove small objects

    % Apply morphological operations
    SE1 = strel('disk', 50);  % Create structuring elements
    SE2 = strel('disk', 60);
    img4e = imerode(img4, SE1);   % Erode
    img4d = imdilate(img4e, SE2);  % Dilate

    % Process image for object segmentation
    imgfo = img4 - img4d;      % Subtract eroded image from dilated image
    imgfo(imgfo == -1) = 0;    % Set -1 values to 0
    imgfo = logical(imgfo);    % Convert to logical type
    imgfo = bwareaopen(imgfo, 5000);   % Remove small objects again

    % Count connected components
    CC = bwconncomp(imgfo);
    nof = CC.NumObjects;           % Get number of objects

    % Display results
    imgfog = uint8(255.*imgfo);   % Convert mask to uint8 for display
    nofs = num2str(nof);          % Convert object count to string
    imgfogrgb = insertText(imgfog, [0 0], nofs, ...
        'FontSize', 30, 'BoxColor', 'green', 'BoxOpacity', 1, 'TextColor', 'black');
    step(videoplayer, imgfogrgb);  % Display processed image with text

    % Check for user exit
    runloop = isOpen(videoplayer);  % Continue loop if video player is open
    pause(2);                      % Delay for 2 seconds
end

% Clean up resources
clear cam;
release(videoplayer);
