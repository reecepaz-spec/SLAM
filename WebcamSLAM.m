%% Notes
% Calibrate your webcam through CameraCalibration app with the checkerboard
% from "open checkerboardPattern.pdf" and export  Export the parameters and save 
% by typing the command below:
% (name may be different): save('C310Calibration.mat','cameraParams')
% Keep the webcam steady and translate it left & right slowly

% Note: For best results, the camera should face towards a detailed
% background, like a cluttered table or a bedroom to travel in the 3D graph
% Do not rely on rotation alone

% Original code from: https://www.mathworks.com/help/vision/ug/performant-and-deployable-monocular-visual-slam.html

clear all
clc
close all

cam = webcam('Logi C310 HD WebCam'); % Replace with your camera
load('C310Calibration.mat') % Replace with your calibration file

cam.Resolution = '640x480';

vslam = monovslam(cameraParams.Intrinsics);

targetSize = cameraParams.ImageSize;  % MUST match calibration

figure;

while true

    frame = snapshot(cam);

    % --- enforce correct size (critical) ---
    frame = imresize(frame, [targetSize(1), targetSize(2)]);

     % --- add frame ---
    addFrame(vslam, frame);

    if hasNewKeyFrame(vslam)
        % Display 3-D map points and camera trajectory
        disp("Keyframe added");
        plot(vslam);
        drawnow limitrate;
    end
end

