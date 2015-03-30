cd('C:\toolbox');


%%
% TO DO
% 1. MAKE INTO A CIRCLE
% 2. DISPLAY TEXT

% Clear the workspace
close all;
clear all;
sca

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
% DOTS
dots.nDots = 500;                % NUMBER of DOTS
dots.color = [255,255,255];      % color of the dots
dots.size = 5;                   % SIZE of DOTS (pixels)
dots.center = [0,0];             % center of the field of dots (x,y)
dots.apertureSize = [30,30];     % size of rectangular aperture [w,h] in degrees. SIZE of DOT CLUSTER
% DISPLAY
tempVals = Screen('Resolution', screenNumber);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

[screenXpixels, screenYpixels] = Screen('WindowSize', window);

frameRate = FrameRate(window);

resolution = [screenXpixels, screenYpixels];

dispStruct.frameRate = frameRate;
dispStruct.resolution = resolution;
dispStruct.dist = 50;
dispStruct.width = 65;

% ANIMATION
dots.speed = 30;        %degrees/second
dots.duration = 4;    %seconds
% dots.direction = 0;   %degrees (clockwise from straight up)

l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% TRIAL STRUCTURE

% Set up coherence structure
% Start with Easy Medium Hard 50 25 5; 1 2 3

trial.tNumber = 10;
trial.trialType = randi(3,trial.tNumber,1);
%
coheres = [0.5 , 0.25, 0.05];
cohereTemp = zeros(trial.tNumber,1);
ranCohNum = zeros(trial.tNumber,1);
ranCohInd = false(trial.tNumber,dots.nDots);
for tt = 1:3
    ttInd = trial.trialType == tt;
    ranCohTemp = round(coheres(tt)*dots.nDots);
    cohereTemp(ttInd) = coheres(tt);
    ranCohNum(ttInd) = ranCohTemp;
    
    tempRow = false(1,dots.nDots);
    tempRand = randi(dots.nDots,ranCohTemp,1);
    tempRow(tempRand) = 1;
    
    ranCohInd(ttInd,tempRow) = 1;
end

trial.coherence = cohereTemp;
trial.direction = round(rand(trial.tNumber,1));
trial.userSel = zeros(trial.tNumber,1);

% Give each dot direction a random number to create an 'uncorrelated noise' stimulus. Hint: instead of dx and dy being a single number, make them vectors of length dots.nDots.

% Trial number

for ti = 1:trial.tNumber;
    
    if trial.direction(ti) == 1;
        dirString = 'Left';
        dirColor = [0 1 0];
        dots.direction = 270;%degrees (clockwise from straight up)
    else
        dirString = 'Right';
        dirColor = [1 0 0];
        dots.direction = 90;%degrees (clockwise from straight up)
    end
    
    cohSet = trial.coherence(ti);
    idInd = logical(ranCohInd(ti,:));
    randDirs = randi(360,sum(~idInd),1);
    
    dx = zeros(1,dots.nDots);
    dy = zeros(1,dots.nDots);
    
    dx(idInd) = dots.speed*sin(dots.direction*pi/180)/frameRate;
    dx(~idInd) = dots.speed*sin(randDirs*pi/180)/frameRate;
    
    dy(idInd) = -dots.speed*cos(dots.direction*pi/180)/frameRate;
    dy(~idInd) = -dots.speed*cos(randDirs*pi/180)/frameRate;
    
    switch cohSet
        case 0.5
            difString = 'Easy';
            difColor = [1 1 1];
            
        case 0.25
            difString = 'Medium';
            difColor = [0.8 0.8 0.8];
            
        case 0.05
            difString = 'Hard';
            difColor = [0.55 0.55 0.55];
    end
    
    %     dx = dots.speed*sin(dots.direction*pi/180)/frameRate;
    %     dy = -dots.speed*cos(dots.direction*pi/180)/frameRate;
    
    nFrames = secs2frames(frameRate,dots.duration);
    
    keyCode = 0;
    
    for i = 1:nFrames
        %convert from degrees to screen pixels
        pixpos.x = angle2pix(dispStruct,dots.x)+ dispStruct.resolution(1)/2;
        pixpos.y = angle2pix(dispStruct,dots.y)+ dispStruct.resolution(2)/2;
        
        inCirleDots = (dots.x-dots.center(1)).^2/(dots.apertureSize(1)/2)^2 + ...
            (dots.y-dots.center(2)).^2/(dots.apertureSize(2)/2)^2 < 1;
        
        
        Screen('DrawDots', window ,[pixpos.x(inCirleDots);pixpos.y(inCirleDots)], dots.size, dots.color, [0,0], 1);
        %update the dot position
        
        % Give coherent Dots an index
        % Give decoherent Dots an index
        
        dots.x = dots.x + dx;
        dots.y = dots.y + dy;
        
        %move the dots that are outside the aperture back one aperture
        %width.
        dots.x(dots.x<l) = dots.x(dots.x<l) + dots.apertureSize(1);
        dots.x(dots.x>r) = dots.x(dots.x>r) - dots.apertureSize(1);
        dots.y(dots.y<b) = dots.y(dots.y<b) + dots.apertureSize(2);
        dots.y(dots.y>t) = dots.y(dots.y>t) - dots.apertureSize(2);
        
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 50);
        
        textString = 'Press Left or Right Arrow Key';
        DrawFormattedText(window, textString, 'center', 10, white);
        
        DrawFormattedText(window, dirString, 500, 1000, dirColor);
        DrawFormattedText(window, difString, 1000, 1000, difColor);
        
        Screen('Flip',window);
        
        [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
        
        if keyIsDown;
            
            kbName = KbName(find(keyCode));
            if strcmp(kbName,'RightArrow')
                trial.userSel(ti) = 0;
            elseif strcmp(kbName,'LeftArrow')
                trial.userSel(ti) = 1;
            else
                trial.userSel(ti) = 2;
            end
            
            if trial.userSel(ti) == trial.direction(ti)
                outCome = 'CORRECT';
                outComeCol = [0 1 0];
            else
                outCome = 'INCORRECT';
                outComeCol = [1 0 0];
            end
            
            Screen('TextFont', window, 'Ariel');
            Screen('TextSize', window, 50);
            
            DrawFormattedText(window, outCome, 'center', 'center', outComeCol);
            Screen('Flip',window);
            
            break
            
        end
        
    end
    
    pause(0.5)
    
end

% Wait for a keyboard button press to exit
exitText = 'Press any key to exit';
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);
DrawFormattedText(window, exitText, 'center', 'center', [1 1 1]);
Screen('Flip',window);
KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them.
sca;