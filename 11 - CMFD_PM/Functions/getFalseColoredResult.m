function [col,map] = getFalseColoredResult(value,gt)

    if ischar(value), value = imread(value)>0; end;
    if ischar(gt)   , gt = imread(gt); end;
    
    map = [106 106 106; 235 125 125; 180 180 180; 195 177 164; 255 255 255; 155 230 203]/255;
    gt  = (gt>0)+(gt==max(gt(:)));
    col = uint8(2*gt+value);