function [scr_obj_dims] = objDimens(scr_width, scr_height, obj_width, obj_height)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

scr_widthVals = round(linspace(0,scr_width,9));
scr_heightVals = round(linspace(0,scr_height,9));

topLeft = [scr_widthVals(2) , scr_heightVals(2)];
topRight = [scr_widthVals(8) , scr_heightVals(2)];
botLeft = [scr_widthVals(2) , scr_heightVals(8)];
botRight = [scr_widthVals(8) , scr_heightVals(8)];
topCen = [scr_widthVals(5) , scr_heightVals(2)];
botCen = [scr_widthVals(5) , scr_heightVals(8)];
leftCen = [scr_widthVals(2) , scr_heightVals(5)];
rightCen = [scr_widthVals(8) , scr_heightVals(5)];
center = [scr_widthVals(5) , scr_heightVals(5)];

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

scrLocCens = [topLeft ; topRight ; botLeft ; botRight ; topCen ; botCen ; leftCen ; rightCen ; center];

scr_obj_dims = zeros(9,4);
for sri = 1:size(scrLocCens,1)

    scr_obj_dims(sri,1) = scrLocCens(sri,1) - obj_wVals(1);
    scr_obj_dims(sri,2) = scrLocCens(sri,2) - obj_hVals(1);
    scr_obj_dims(sri,3) = scrLocCens(sri,1) + obj_wVals(2);
    scr_obj_dims(sri,4) = scrLocCens(sri,2) + obj_hVals(2);

end




end

