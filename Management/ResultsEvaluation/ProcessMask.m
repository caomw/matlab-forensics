function [ProcessedMasks,Processes] = ProcessMask( InputMask )
    %PROCESSMASK Summary of this function goes here
    %   Detailed explanation goes here
    
    Processes{1}='Open1_Close1';
    S=strel('disk',1);
    tmpMask=imopen(InputMask,S);
    S=strel('disk',1);
    tmpMask=imclose(tmpMask,S);
    ProcessedMasks{1}=tmpMask;
      
    Processes{2}='Open2_Close4';
    S=strel('disk',2);
    tmpMask=imopen(InputMask,S);
    S=strel('disk',5);
    tmpMask=imclose(tmpMask,S);
    ProcessedMasks{2}=tmpMask;
    
    Processes{3}='Close2_Open4';
    S=strel('disk',2);
    tmpMask=imclose(InputMask,S);
    S=strel('disk',5);
    tmpMask=imopen(tmpMask,S);
    ProcessedMasks{3}=tmpMask;
    
end

