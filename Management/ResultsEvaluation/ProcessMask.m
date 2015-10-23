function [ProcessedMasks,Processes] = ProcessMask( InputMask )
    %PROCESSMASK Summary of this function goes here
    %   Detailed explanation goes here
    
    Processes{1}='Plain';
    ProcessedMasks{1}=InputMask;
    
    Processes{2}='Open1_Close1';
    S=strel('disk',1);
    tmpMask=imopen(InputMask,S);
    S=strel('disk',1);
    tmpMask=imclose(tmpMask,S);
    ProcessedMasks{2}=tmpMask;
    
    Processes{3}='Close1_Open1';
    S=strel('disk',1);
    tmpMask=imclose(InputMask,S);
    S=strel('disk',1);
    tmpMask=imopen(tmpMask,S);
    ProcessedMasks{3}=tmpMask;

    Processes{4}='Open1_Close2';
    S=strel('disk',1);
    tmpMask=imopen(InputMask,S);
    S=strel('disk',2);
    tmpMask=imclose(tmpMask,S);
    ProcessedMasks{4}=tmpMask;
    
    Processes{5}='Close1_Open2';
    S=strel('disk',1);
    tmpMask=imclose(InputMask,S);
    S=strel('disk',2);
    tmpMask=imopen(tmpMask,S);
    ProcessedMasks{5}=tmpMask;
   
    Processes{6}='Open2_Close4';
    S=strel('disk',2);
    tmpMask=imopen(InputMask,S);
    S=strel('disk',5);
    tmpMask=imclose(tmpMask,S);
    ProcessedMasks{6}=tmpMask;
    
    Processes{7}='Close2_Open4';
    S=strel('disk',2);
    tmpMask=imclose(InputMask,S);
    S=strel('disk',5);
    tmpMask=imopen(tmpMask,S);
    ProcessedMasks{7}=tmpMask;
    
end

