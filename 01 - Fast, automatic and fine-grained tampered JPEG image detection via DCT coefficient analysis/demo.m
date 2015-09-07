function demo(im)
    
    [Feature_Vector, OutputMap, coeffArray] = Extract_Features( im );
    
    imagesc(OutputMap);
    