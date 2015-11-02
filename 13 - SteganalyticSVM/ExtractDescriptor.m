function [ CoOccurence ] = ExtractDescriptor( InputPatch )
    CoOcDim=4;
    T=2;
    Q=1;
    
    YCbCr=rgb2ycbcr(InputPatch);
    Y=double(InputPatch(:,:,1));
    
    Den=DenoiseFilt(Y);
    Trunc=truncateResidual(Den,T,Q);


    CoOccurence=GetCoOccurenceMatrices(Trunc,T,CoOcDim);
end

