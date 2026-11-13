%% Logitech C310
clear;
clc;
close all;

%% Connect webcam
cam = webcam('Logi C310 HD WebCam');
cam.Resolution = '320x240'; % capture smaller directly — skip the resize cost

%% DINO Code
name = "swin-base";
detector = groundingDinoObjectDetector(name);
labels = {'Phone', 'Apple'};
descriptions = {'Mobile Phone', 'Detecting Apple'};

figure;
hImage = imshow(zeros(240, 320, 3));

Duration = 90;        % total seconds
startTime = tic;

while toc(startTime) < Duration && ishandle(hImage)

    I = snapshot(cam);
    I = imresize(I,[480 480]);

    [bboxes,scores,detectedLabels] = detect(detector,I, ...
        ClassNames=labels,ClassDescriptions=descriptions);
    
    outputLabels = compose("%s: %.2f",string(detectedLabels),scores);
    detections = insertObjectAnnotation(I,"rectangle",bboxes,outputLabels);
  
    set(hImage,'CData',detections);
    drawnow limitrate;
end
imshow(detections)
title("Objects Detected Using Text Queries with Grounding DINO")
clear cam
