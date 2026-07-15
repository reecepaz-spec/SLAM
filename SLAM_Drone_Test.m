%% Before running this code
% First, run SLAM_Drone_Calibrator.m to take snapshots of the checkerboard by
% typing the command "open checkerboardPattern.pdf" and printing the sheet
% Make sure the checkerboard is within the drone camera's view.
% Next, run the CameraCalibrator app and load the images from the
% "tello_calib_images" folder and calibrate. Export the parameters and save 
% by typing the command: save('telloCameraParams.mat','cameraParams')
% Note: For best results, the camera should face towards a detailed
% background, like a cluttered table or a bedroom to travel in the 3D graph

% Original code from https://www.mathworks.com/help/vision/ug/performant-and-deployable-monocular-visual-slam.html
%% Tello Monocular SLAM
clear;
clc;
close all;

%% Connect to Tello
droneObj = ryze();
cam = camera(droneObj);

%% Load camera calibration
load('telloCameraParams.mat');   % contains cameraParams

%% --- Handle different calibration formats ---
if exist('cameraParams','var')
    intrinsics = cameraParams.Intrinsics;
    imageSize  = cameraParams.ImageSize;
else
    error("cameraParams not found. Re-export calibration as cameraParameters.");
end

%% Create SLAM object
vslam = monovslam(cameraParams.Intrinsics);

figure;

disp("Starting SLAM...");

%% Begin Takeoff
takeoff(droneObj);
pause(20); % Pause before graph pops up

numCycles = 300; % Increase for longer run time
for k = 1:20: numCycles
    %% --- Capture multiple frames per pose ---
    for i = 1:8

        frame = snapshot(cam);

        if isempty(frame)
            continue;
        end

        % Resize if needed (important for calibration match)
        frame = imresize(frame, imageSize);

        % Undistort + grayscale
        frame = undistortImage(frame, cameraParams);
        grayFrame = im2gray(frame);

        % Add to SLAM
        addFrame(vslam, grayFrame);

        if hasNewKeyFrame(vslam)
        % Display 3-D map points and camera trajectory
            disp("New keyframe added");
            plot(vslam);
            title("Tello SLAM");
            drawnow limitrate;
        end

        pause(0.1);
    end

    %% --- Motion step ---
    moveforward(droneObj,'Distance',0.3,'Speed',0.1);
    pause(3);

    turn(droneObj,deg2rad(-25));
    pause(1.5);

end

%% Land
land(droneObj);
disp("Finished SLAM flight");
