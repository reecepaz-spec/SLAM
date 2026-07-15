% Print out checkerboard by typing "open checkerboardPattern.pdf"
droneObj = ryze();
cam = camera(droneObj);

takeoff(droneObj);
pause(3); % IMPORTANT: allow camera stream to initialize

outputFolder = "tello_calib_images";
if ~exist(outputFolder, 'dir')
    mkdir(outputFolder);
end

numImages = 25;
i = 0;

% Make sure the checkerboard is within the camera
while i < numImages

    img = snapshot(cam);

    % FIX: skip empty frames
    if isempty(img)
        disp("Empty frame skipped...");
        pause(0.2);
        continue;
    end

    i = i + 1;

    filename = fullfile(outputFolder, sprintf("img_%02d.png", i));
    imwrite(img, filename);

    disp("Saved image " + i);

    pause(0.5);

    % Optional motion for better calibration coverage
    if mod(i,5)==0
        turn(droneObj, deg2rad(10));
    end
end

land(droneObj);