% Code based on: https://www.mathworks.com/help/vision/ug/perform-zero-shot-object-detection-using-grounding-dino.html

%% DINO with TELLO Drone
clear;
clc;
close all;

%% Connecting to Drone Camera
droneObj = ryze();
cameraObj = camera(droneObj);
cam = cameraObj;
%% DINO Code
name = "swin-base";
detector = groundingDinoObjectDetector(name);
% Change inputs (make labels and descriptions more detailed for best
% results (may still give false detections)
labels = {'Brown Cardboard Box','Yellow Robot'};
descriptions = {'Detecting Brown Cardboard Box','Detecting Yellow Robot'};

figure;
hImage = imshow(zeros(480, 640, 3));

%% Takeoff
takeoff(droneObj);
pause(2);

Duration = 150;        % total seconds in the air
turnStep = deg2rad(45);     % rotate in small steps each loop iteration
startTime = tic;

while toc(startTime) < Duration && ishandle(hImage)
    turn(droneObj, turnStep);

    I = snapshot(cam);
    I = imresize(I,[480 480]);

    [bboxes,scores,detectedLabels] = detect(detector,I, ...
        ClassNames=labels,ClassDescriptions=descriptions);
    
    outputLabels = compose("%s: %.2f",string(detectedLabels),scores);
    detections = insertObjectAnnotation(I,"rectangle",bboxes,outputLabels);
  
    set(hImage,'CData',detections);
    drawnow limitrate;
end

%% Land
land(droneObj);
clear cam
