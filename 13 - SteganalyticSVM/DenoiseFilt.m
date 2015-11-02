function TruncatedIm = DenoiseFilt( GrayIm )

    Shift_2=GrayIm(4:end,:);
    Shift_1=GrayIm(3:end-1,:);
    Shift_0=GrayIm(2:end-2,:);
    Shift_M1=GrayIm(1:end-3,:);
    
    DenoisedIm=-Shift_2+3*Shift_1-3*Shift_0+Shift_M1;
    
    TruncatedIm=truncateResidual(DenoisedIm,2,1);
    
    
end