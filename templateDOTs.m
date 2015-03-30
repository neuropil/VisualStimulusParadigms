function [] = templateDOTs(varargin)
% TEMPLATEDOTS

% INPUTS
% 'dotNumber' = numeric and scalar : Ex. 100
%               DEFAULT: 1000
% 'dotColor' = numeric vector size 1x3 : Ex. [1 0 0]
%               DEFAULT: [1 1 1]
% 'dotSize' = numeric and scalar : Ex. 3 (pixels)
%               DEFAULT: 5
% 'trialDuration' = numeric and scalar, duration of dot presenation : Ex. 8 (seconds)
%               DEFAULT: 4
% 'trialNumber' = numeric and scalar, number of dot trials : Ex. 10
%               DEFAULT: 6
%
% USAGE
% Example 1: No inputs, all defaults
%          >> templateDOTs
% Example 2: dot number and color
%          >> templateDOTs('dotNumber',1500,'dotColor',[0 1 0]);
% Example 3: trial duration and number
%          >> templateDOTS('trialDuration',15,'trialNumber',100);
%
%
%
% J.A. Thompson PhD, 2/23/2015
% VERSION 1.0



%%% TO DO
% Add defaults for weights and coherences
% Add output


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
duration = 4;
tNumber = 6; 
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

% =========================================================================
% ===== Setup PsychToolbox ================================================
% =========================================================================

% Here we call some default settings for setting up Psychtoolbox
cd('C:\toolbox');
sca
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
screenWidth = windowRect(3);
screenHeight = windowRect(4);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% =========================================================================
% ===== Setup Screen ======================================================
% =========================================================================
frameRate = FrameRate(window);
resolution = [screenXpixels, screenYpixels];
dispStruct.frameRate = frameRate;
dispStruct.resolution = resolution;
dispStruct.dist = 50;
dispStruct.width = 65;

% =========================================================================
% ===== Constants =========================================================
% =========================================================================

% Where dots are located on the screen (coordinates)
dots.center = [0,0];
% Dot area diameter
dots.apertureSize = [27,27];
% Dot speed
dots.speed = 35;

% =========================================================================
% ===== Setup Animation ===================================================
% =========================================================================

% Left, Right, Bottom and Top positions of dots
l = dots.center(1)-dots.apertureSize(1)/2;
r = dots.center(1)+dots.apertureSize(1)/2;
b = dots.center(2)-dots.apertureSize(2)/2;
t = dots.center(2)+dots.apertureSize(2)/2;

% Random assignment of dots in coordinate space for starting location
dots.x = (rand(1,dots.nDots)-.5)*dots.apertureSize(1) + dots.center(1);
dots.y = (rand(1,dots.nDots)-.5)*dots.apertureSize(2) + dots.center(2);

% Set up weights of randomly selected trial types
% NOTE: consider adding as input argument. 
% CURRENT: Weighted towards HARD
trial.trialType = datasample([1; 2; 3],trial.tNumber,'Weights',[0.25 0.25 0.5]);
% Coherence values, order is important: EASY, MEDIUM, HARD
coherences = [0.5, 0.25, 0.05];
cohereTemp = zeros(trial.tNumber,1);
ranCohNum = zeros(trial.tNumber,1);
ranCohInd = false(trial.tNumber,dots.nDots);
for tt = 1:length(coherences)
    ttInd = trial.trialType == tt;
    cohereTemp(ttInd) = coherences(tt);
end

% Randomly assign dot positions
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


% =========================================================================
% ===== Setup OBJECTS =====================================================
% =========================================================================


% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);
% CENTER CIRCLES
baseRect = [0 0 300 300]; % OUTLINE CIRCLE
overlayRect = [0 0 290 290]; % LAYER CIRCLE
targetRect = [0 0 20 20]; % TARGET CIRCLE
% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameterB = max(baseRect) * 1.01;
maxDiameterO = max(overlayRect) * 1.01;
maxDiameterT = max(targetRect) * 1.01;
% Center the rectangle on the centre of the screen
outlineBase = CenterRectOnPointd(baseRect, xCenter, yCenter);
outlineOverlay = CenterRectOnPointd(overlayRect, xCenter, yCenter);
outlineTarget = CenterRectOnPointd(targetRect, xCenter, yCenter);
% Set the color of the rect to red
rectColorB = [1 0 0];
rectColorO = [0 0 0];
rectColorT = [1 1 1];

% STIMULUS CIRCLES
leftRect = [0 0 60 60];
rightRect = [0 0 60 60];
maxDiamLR = max(leftRect) * 1.01;
maxDiamRR = max(rightRect) * 1.01;
outLR = stimulusDims(screenWidth, screenHeight, leftRect(3), leftRect(4), 'left');
outRR = stimulusDims(screenWidth, screenHeight, rightRect(3), rightRect(4), 'right');
leftColor = [0 1 0];
rightColor = [1 0 0];





% Run function to get coodinates for circle (x,y,radius);
[xc, yc] = getmidpointcircle(xCenter, yCenter, 150);



% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 50);

% Here we set the initial position of the mouse to a random position on the
% screen
SetMouse(round(rand * screenXpixels), round(rand * screenYpixels), window);

% Set the mouse to the top left of the screen to start with
SetMouse(0, 0, window);

% Loop the animation until a key is pressed

curState = 1;
trialNum = 1;

while trialNum < trial.tNumber;
    
    outTar = true;
    
    switch curState
        
        case 1 % FIXATE ON TARGET
            
            while outTar
                
                % Get the current position of the mouse
                [x, y, ~] = GetMouse(window);
                
                % We clamp the values at the maximum values of the screen in X and Y
                % incase people have two monitors connected. This is all we want to
                % show for this basic demo.
                x = min(x, screenXpixels);
                y = min(y, screenYpixels);

                if inpolygon(x,y,xc,yc);
                    
                    dotCol = [0 1 0];
                    
                    %%% CHANGE  BACK IF NEEDED
                    outTar = false;
                    
                    curState = 2; % If mouse enters target change to STATE 2
%                     
                    tic
                else
                    dotCol = [1 1 1];
                end

                % Construct our text string
                textString = ['Trial ' num2str(trialNum)];
                
                % Draw the rect to the screen
                Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
                Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
                Screen('FillOval', window, rectColorT, outlineTarget, maxDiameterT);
                
                
                % Text output of mouse position draw in the centre of the screen
                DrawFormattedText(window, textString, 'center', 1000, white);
                
                % Draw a white dot where the mouse cursor is
                Screen('DrawDots', window, [x y], 25, dotCol, [], 2);
                
                % Flip to the screen
                Screen('Flip', window);
                
            end
            
        case 2 % CHECK FIXATION
            
            badtrial = 0;
            while toc < 2
                
                % Get the current position of the mouse
                [x, y, ~] = GetMouse(window);

                % We clamp the values at the maximum values of the screen in X and Y
                % incase people have two monitors connected. This is all we want to
                % show for this basic demo.
                x = min(x, screenXpixels);
                y = min(y, screenYpixels);
                
                
                if ~inpolygon(x,y,xc,yc) && toc < 2
                    
                    badtrial = 1;
                    
                    badText = 'Be Patient!';
                    DrawFormattedText(window, badText, 'center', 1000, [1 0 0]);
                    Screen('Flip', window);
                    pause(1.5);
                    
                    break;
                    
                else
                    
                    % Construct our text string
                    textString = ['Trial ' num2str(trialNum)];
                    %                 dotString = 'DOTS';
                    % Draw the rect to the screen
                    Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
                    Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
                    
                    
                    % Text output of mouse position draw in the centre of the screen
                    DrawFormattedText(window, textString, 'center', 1000, white);
                    %                 DrawFormattedText(window, dotString, 'center', 'center', white);
                    % Draw a white dot where the mouse cursor is
                    Screen('DrawDots', window, [x y], 25, dotCol, [], 2);
                    
                    % Flip to the screen
                    Screen('Flip', window);
                    
                end

            end
            
            if badtrial
                
                curState = 1;
                trialNum = trialNum + 1;
                
            else
                curState = 3;
                
                tic
            end
            
            
        case 3 % SHOW DOTS
            
%             while toc < 5
                
                %                 %%%%%%%%%%%%%%%%%%%%%% OLD CODE
                %                 % Get the current position of the mouse
                %                 [x, y, ~] = GetMouse(window);
                %
                %                 % We clamp the values at the maximum values of the screen in X and Y
                %                 % incase people have two monitors connected. This is all we want to
                %                 % show for this basic demo.
                %                 x = min(x, screenXpixels);
                %                 y = min(y, screenYpixels);
                %
                %                 % Construct our text string
                %                 textString = ['Trial ' num2str(trialNum)];
                %                 dotString = 'DOTS';
                %                 % Draw the rect to the screen
                %                 Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
                %                 Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
                %
                %                 % Text output of mouse position draw in the centre of the screen
                %                 DrawFormattedText(window, textString, 'center', 1000, white);
                %                 DrawFormattedText(window, dotString, 'center', 'center', white);
                %                 % Draw a white dot where the mouse cursor is
                %                 Screen('DrawDots', window, [x y], 10, dotCol, [], 2);
                %
                %                 % Flip to the screen
                %                 Screen('Flip', window);
                
                if trial.direction(trialNum) == 1;
                    %                     dirString = 'Left';
                    %                     dirColor = [0 1 0];
                    dots.direction = 270;%degrees (clockwise from straight up)
                else
                    %                     dirString = 'Right';
                    %                     dirColor = [1 0 0];
                    dots.direction = 90;%degrees (clockwise from straight up)
                end
                
%                 cohSet = trial.coherence(trialNum);
                idInd = logical(ranCohInd(trialNum,:));
                randDirs = randi(360,sum(~idInd),1);
                
                dx = zeros(1,dots.nDots);
                dy = zeros(1,dots.nDots);
                
                dx(idInd) = dots.speed*sin(dots.direction*pi/180)/frameRate;
                dx(~idInd) = dots.speed*sin(randDirs*pi/180)/frameRate;
                
                dy(idInd) = -dots.speed*cos(dots.direction*pi/180)/frameRate;
                dy(~idInd) = -dots.speed*cos(randDirs*pi/180)/frameRate;
                
                %                 switch cohSet
                %                     case 0.5
                %                         difString = 'Easy';
                %                         difColor = [1 1 1];
                %
                %                     case 0.2
                %                         difString = 'Medium';
                %                         difColor = [0.8 0.8 0.8];
                %
                %                     case 0.05
                %                         difString = 'Hard';
                %                         difColor = [0.55 0.55 0.55];
                %                 end
                nFrames = secs2frames(frameRate,dots.duration);
                
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
                    
                    Screen('Flip',window);
                end
  
%             end
            
            curState = 4;
            
            tic
            
        case 4 % DELAY
            
            while toc < 3
                
                % Get the current position of the mouse
                [x, y, ~] = GetMouse(window);
                
                % We clamp the values at the maximum values of the screen in X and Y
                % incase people have two monitors connected. This is all we want to
                % show for this basic demo.
                x = min(x, screenXpixels);
                y = min(y, screenYpixels);
                
%                 if inpolygon(x,y,xc,yc);
%                     dotCol = [0 1 0];
%                 else
                    dotCol = [1 1 1];
%                 end
                
                % Construct our text string
                dispString = 'Delay';
                textString = ['Trial ' num2str(trialNum)];
                
                % Draw the rect to the screen
%                 Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
%                 Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
                
%                 % Text output of mouse position draw in the centre of the screen
                DrawFormattedText(window, textString, 'center', 1000, white);
                DrawFormattedText(window, dispString, 'center', 'center', white);
%                 
%                 % Draw a white dot where the mouse cursor is
                Screen('DrawDots', window, [x y], 25, dotCol, [], 2);
                
                % Flip to the screen
                Screen('Flip', window);
                
            end
            
            curState = 5;
            chooseState = 1;
            
        case 5 % MAKE CHOICE
            tic;
            while chooseState
                
                [x, y, ~] = GetMouse(window);

                x = min(x, screenXpixels);
                y = min(y, screenYpixels);
                
                % ADD IF LEFT OR RIGHT
                
                % RIGHT CHOICE
                if x >= 1600 && x <= 1920;
                    
                    dotCol = [1 0 0];
                    chooseState = 0;
                    trial.userSel(trialNum) = 0;
                    curState = 6;
                    
                    if trial.userSel(trialNum) == trial.direction(trialNum)
                        trial.correct(trialNum) = 1;
                    else
                        trial.correct(trialNum) = 0;
                    end
                    
                    trial.rt(trialNum) = toc;
                    
                    % LEFT CHOICE
                elseif x <= 320 && x >= 0
                    
                    dotCol = [0 1 0];
                    chooseState = 0;
                    trial.userSel(trialNum) = 1;
                    curState = 6;
                    
                    if trial.userSel(trialNum) == trial.direction(trialNum)
                        trial.correct(trialNum) = 1;
                    else
                        trial.correct(trialNum) = 0;
                    end
                    
                    trial.rt(trialNum) = toc;
                    
                else
                    dotCol = [1 1 1];
                end
                dispString = 'Choose';
                textString = ['Trial ' num2str(trialNum)];

                % Draw center Target
%                 Screen('FillOval', window, rectColorB, outlineBase, maxDiameterB);
%                 Screen('FillOval', window, rectColorO, outlineOverlay, maxDiameterO);
                
                % Draw side stimulus targets
                Screen('FillOval', window, leftColor, outLR, maxDiamLR);
                Screen('FillOval', window, rightColor, outRR, maxDiamRR);
                
                DrawFormattedText(window, textString, 'center', 1000, white);
                DrawFormattedText(window, dispString, 'center', 'center', white);

                Screen('DrawDots', window, [x y], 25, dotCol, [], 2);

                Screen('Flip', window);
                
            end


        case 6 % OUTCOME
            
            if trial.correct(trialNum) == 1;
                outCome = 'CORRECT';
                outComeCol = [0 1 0];
                
            else
                outCome = 'INCORRECT';
                outComeCol = [1 0 0];
            end
            
            tic;
            while toc < 2
                
                Screen('TextFont', window, 'Ariel');
                Screen('TextSize', window, 50);
                DrawFormattedText(window, outCome, 'center', 'center', outComeCol);
                Screen('Flip',window);
                
            end
            curState = 1;
            trialNum = trialNum + 1;
  
    end

end

% Clear the screen
sca;


end





