function OutputMap = ELA( ImIn, Quality, Multiplier, Flatten)
    %ELA Summary of this function goes here
    %   Detailed explanation goes here
    
    imwrite(ImIn,'tmp.jpg','Quality',Quality);
    ImJPG=imread('tmp.jpg');
    
    OutputMap=(abs(double(ImIn)-double(ImJPG))*Multiplier);
    
    
    if Flatten
        OutputMap=mean(OutputMap,3);
    end
end

