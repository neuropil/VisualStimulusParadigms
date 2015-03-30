function [new_dims] = stimulusDims(scr_width, scr_height, obj_width, obj_height, side)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


scr_widthVals = round(linspace(0,scr_width,9));
scr_heightVals = round(linspace(0,scr_height,9));

leftCen = [scr_widthVals(2) , scr_heightVals(5)];
rightCen = [scr_widthVals(8) , scr_heightVals(5)];

% Convert 
% half obj width subtract and add to width val
% repeat for height

% Width
if mod(obj_width, 2) == 0
    % even
    obj_wVals = repmat(obj_width/2,1,2);
else % odd
    maxW_Half = ceil(obj_width/2);
    obj_wVals = [maxW_Half , obj_width - maxW_Half];
end

% Height
if mod(obj_height, 2) == 0
    % even
    obj_hVals = repmat(obj_height/2,1,2);
else % odd
    maxH_Half = ceil(obj_height/2);
    obj_hVals = [maxH_Half , obj_height - maxH_Half];
end

if strcmp(side,'left')
    scrLocCens = leftCen;
else
    scrLocCens = rightCen;
end

new_dims = zeros(1,4);

new_dims(1) = scrLocCens(1) - obj_wVals(1);
new_dims(2) = scrLocCens(2) - obj_hVals(1);
new_dims(3) = scrLocCens(1) + obj_wVals(2);
new_dims(4) = scrLocCens(2) + obj_hVals(2);







end

