function [ Matrix ] = GetCoOccurenceMatrices( ImIn,T,CoOcDim, ReversionMatrix, InversionMatrix )
    %GETCOOCCURENCEMATRICES Summary of this function goes here
    %   Detailed explanation goes here
    C=CoOcDim;
    ImIn=ImIn+T;
    VRange=2*T+1;
    
    Im1=ImIn;
    Im1=Im1(1:C*floor(end/C),1:C*floor(end/C));
    Samples=reshape(Im1,C,[]);
    Im1=ImIn(2:end,:);
    Im1=Im1(1:C*floor(end/C),1:C*floor(end/C));
    Samples=[Samples reshape(Im1,C,[])];
    Im1=ImIn(3:end,:);
    Im1=Im1(1:C*floor(end/C),1:C*floor(end/C));
    Samples=[Samples reshape(Im1,C,[])];
    Im1=ImIn(4:end,:);
    Im1=Im1(1:C*floor(end/C),1:C*floor(end/C));
    Samples=[Samples reshape(Im1,C,[])];
    
    Indexes=1+Samples(1,:)+Samples(2,:)*VRange+Samples(3,:)*VRange^1+Samples(4,:)*VRange^3;
    
    Histogram=hist(Indexes,1:VRange^4);
    
    Matrix=Histogram;
    
    
    for ii=1:length(InversionMatrix)
        if (InversionMatrix(ii)>ii)
            
        end
            
    end
    for ii=1:length(ReversionMatrix)
        
    end
    
    
end