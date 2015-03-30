function [trial] = testVAR(varargin)

%%%% TO ADD

% 1) 1 second ITI
% 2) 0.75 second Fixation Time

% =========================================================================
% ===== Default values ====================================================
% =========================================================================

% INPUT PARSER CLASS
p = inputParser;
% VALIDATION FUNCTIONS
numValidationFcn = @(x) isnumeric(x);
colValidationFcn = @(x) isnumeric(x);
% DEFAULTS
nDots = 1000; % Original 1000
color = [255,255,255]; 
size = 5;  % Original 5
duration = 10;
tNumber = 20; 
dfdebugFlag = 0;
% INPUT PARAMETERS
addOptional(p,'dotNumber',nDots,numValidationFcn)
addOptional(p,'dotColor',color,colValidationFcn)
addOptional(p,'dotSize',size,@isnumeric)
addOptional(p,'trialDuration',duration,@isnumeric)
addOptional(p,'trialNumber',tNumber,@isnumeric)
addOptional(p,'debug',dfdebugFlag)
% PARSER
parse(p,varargin{:});
% INPUT ARGUMENTS
dots.nDots = p.Results.dotNumber;
dots.color = p.Results.dotColor;
dots.size = p.Results.dotSize;
dots.duration = p.Results.trialDuration;
trial.tNumber = p.Results.trialNumber;
debugFlag = p.Results.debug;

% =========================================================================
% ===== Setup Screen ======================================================
% =========================================================================

cd('C:\toolbox');
sca
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');
screenNumber = max(screens);
% white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
frameRate = FrameRate(window);
resolution = [screenXpixels, screenYpixels];
dispStruct.frameRate = frameRate;
dispStruct.resolution = resolution;
dispStruct.dist = 50;
dispStruct.width = 65;

% =========================================================================
% ===== Constants =========================================================
% =========================================================================

% Original Values
dots.center = [0,0];
% dots.apertureSize = [30,30];
% dots.speed = 30;


% Modified Values
% dots.center = [0,-12];
% dots.center = [screenXpixels/2, round(screenYpixels*0.333)];
dots.apertureSize = [27,27];
dots.speed = 35;


% =========================================================================
% ===== Setup Animation ===================================================
% =========================================================================

l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% trial.trialType = randi(3,trial.tNumber,1);
trial.trialType = datasample([1; 2; 3],trial.tNumber,'Weights',[0.25 0.25 0.5]);
coherences = [0.5 , 0.2, 0.05];
cohereTemp = zeros(trial.tNumber,1);
ranCohNum = zeros(trial.tNumber,1);
ranCohInd = false(trial.tNumber,dots.nDots);
for tt = 1:length(coherences)
    ttInd = trial.trialType == tt;
    cohereTemp(ttInd) = coherences(tt);
end

for tt2 = 1:trial.tNumber
    ranCohTemp = round(cohereTemp(tt2)*dots.nDots); 
    tempRow = false(1,dots.nDots);
    tempRand = randi(dots.nDots,ranCohTemp,1);
    tempRow(tempRand) = 1;
    ranCohInd(tt2,:) = tempRow;
    ranCohNum(tt2) = ranCohTemp;
end

trial.rt = nan(trial.tNumber,1);
trial.coherence = cohereTemp;
trial.direction = round(rand(trial.tNumber,1));
trial.userSel = nan(trial.tNumber,1);
trial.correct = zeros(trial.tNumber,1);

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
            
        case 0.2
            difString = 'Medium';
            difColor = [0.8 0.8 0.8];
            
        case 0.05
            difString = 'Hard';
            difColor = [0.55 0.55 0.55];
    end
    
    %     dx = dots.speed*sin(dots.direction*pi/180)/frameRate;
    %     dy = -dots.speed*cos(dots.direction*pi/180)/frameRate;
    
    nFrames = secs2frames(frameRate,dots.duration);
    
    %%% FIXATION POINT
    % Get the centre coordinate of the window
    [xCenter, yCenter] = RectCenter(windowRect);
    
    % Make a base Rect of 200 by 250 pixels
    baseRect = [0 0 50 50];
    
    % For Ovals we set a miximum diameter up to which it is perfect for
    maxDiameter = max(baseRect) * 1.01;
    
    % Center the rectangle on the centre of the screen
    centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
    
    % Set the color of the rect to red
    rectColor = [1 0 0];
    
    % Draw the rect to the screen
    Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
    
    Screen('Flip',window);
    
    pause(0.75)
    
    tic;
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
        
        %%% TEXT 
        
        Screen('TextFont', window, 'Ariel');
        Screen('TextSize', window, 20);
        
%         textString = 'Press Left or Right Arrow Key';
%         DrawFormattedText(window, textString, 'center', 10, white);
        
        if debugFlag
            
            DrawFormattedText(window, dirString, 500, 1000, dirColor);
            DrawFormattedText(window, difString, 1000, 1000, difColor);
            
        end
       
%         Screen('FillOval', window, rectColor, centeredRect, maxDiameter);
        
        Screen('Flip',window);
        
        [keyIsDown, ~, keyCode, ~] = KbCheck;
        
        if keyIsDown;
            
            toc;
            
            kbName = KbName(find(keyCode));
            if strcmp(kbName,'RightArrow')
                trial.userSel(ti) = 0;
            elseif strcmp(kbName,'LeftArrow')
                trial.userSel(ti) = 1;
            end
            
            if trial.userSel(ti) == trial.direction(ti)
                outCome = 'CORRECT';
                outComeCol = [0 1 0];
                trial.correct(ti) = 1;
            else
                outCome = 'INCORRECT';
                outComeCol = [1 0 0];
                trial.correct(ti) = 0;
            end
            
            trial.rt(ti) = toc;
            
            Screen('TextFont', window, 'Ariel');
            Screen('TextSize', window, 50);
            
            DrawFormattedText(window, outCome, 'center', 'center', outComeCol);
            Screen('Flip',window);
            
            break
            
        end
        
    end
    
    if ~keyIsDown
            Screen('TextFont', window, 'Ariel');
            Screen('TextSize', window, 50);
            
            DrawFormattedText(window, 'Too Slow!', 'center', 'center', outComeCol);
            Screen('Flip',window);
    end
    
    pause(1)
    
end

% Wait for a keyboard button press to exit
exitText = 'Press any key to exit and see Results';
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);
DrawFormattedText(window, exitText, 'center', 'center', [1 1 1]);
Screen('Flip',window);
KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them.
sca;



% =========================================================================
% ===== Process Data ======================================================
% =========================================================================

indexCorrect = trial.correct;
easyIndex = trial.trialType == 1;
medIndex = trial.trialType == 2;
hardIndex = trial.trialType == 3;

ert = nanmean(trial.rt(easyIndex));
mrt = nanmean(trial.rt(medIndex));
hrt = nanmean(trial.rt(hardIndex));

eCor = sum(indexCorrect(easyIndex))/sum(easyIndex);
mCor = sum(indexCorrect(medIndex))/sum(medIndex);
hCor = sum(indexCorrect(hardIndex))/sum(hardIndex);

figure(1);
bar([ert ; mrt ; hrt])
set(gca,'XTickLabel',{'Easy','Med','Hard'})
ylabel('Reaction Time');

figure(2);
bar([eCor ; mCor ; hCor])
set(gca,'XTickLabel',{'Easy','Med','Hard'})
ylabel('Percent Correct');















end