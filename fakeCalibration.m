function [] = fakeCalibration()


% Clear the workspace and the screen
close all;
clear all;
sca

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);
% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
screens = Screen('Screens');

screenNumber = max(screens);

white = WhiteIndex(screenNumber);


% Do a simply calculation to calculate the luminance value for grey. This
% will be half the luminace values for white
grey = white / 2;

% Open an on screen window using PsychImaging and color it grey.
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.
screenWidth = windowRect(3);
screenHeight = windowRect(4);

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Make a base Rect of 200 by 250 pixels
baseRect = [0 0 50 50];
overlayRect = [0 0 20 20];

% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameterB = max(baseRect) * 1.01;
maxDiameterO = max(overlayRect) * 1.01;

% x1, y1, x2, y2


% Center the rectangle on the centre of the screen
outlineBase = CenterRectOnPointd(baseRect, xCenter, yCenter);
outlineOverlay = CenterRectOnPointd(overlayRect, xCenter, yCenter);

% Set the color of the rect to red
rectColorB = [0 0 0];
rectColorO = [1 1 1];

objLocsBase = objDimens(screenWidth, screenHeight, baseRect(3), baseRect(4));
objLocsLay = objDimens(screenWidth, screenHeight, overlayRect(3), overlayRect(4));

objLocsBase = repmat(objLocsBase,8,1);
objLocsLay = repmat(objLocsLay,8,1);

randSeq = randperm(size(objLocsBase,1))';

objLocsBase = objLocsBase(randSeq,:);
objLocsLay = objLocsLay(randSeq,:);

% Draw the rect to the screen
% Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
% Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);

for fli = 1:size(objLocsBase,1)
    
    if fli == 1
        
        Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
        Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
        Screen('Flip', window);
        pause(10)
    end
        
    
    Screen('FillOval', window, rectColorB, objLocsBase(fli,:), maxDiameterB);
    Screen('FillOval', window, rectColorO, objLocsLay(fli,:), maxDiameterO);
    
    %     textString = 'Calibration';
    %     % Text output of mouse position draw in the centre of the screen
    %     DrawFormattedText(window, textString, 'center', 300, white);
    % Draw a white dot where the mouse cursor is
    
    
    % Flip to the screen. This command basically draws all of our previous
    % commands onto the screen. See later demos in the animation section on more
    % timing details. And how to demos in this section on how to draw multiple
    % rects at once.
    % For help see: Screen Flip?
    Screen('Flip', window);
    
    % Now we have drawn to the screen we wait for a keyboard button press (any
    % key) to terminate the demo.
    % For help see: help KbStrokeWait
    pause(1);
    
    [keyIsDown, ~, keyCode, ~] = KbCheck;
    
    if keyIsDown;
        break
    end
    

    
end


KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;





end

