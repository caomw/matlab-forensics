function b = BlockValue( BLOCK_STRUCT )
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    blockData=BLOCK_STRUCT.data;
    
    Max1=max(sum(blockData(2:7,2:7)));
    Min1=min(sum(blockData(2:7,[1 8])));
    Max2=max(sum(blockData(2:7,2:7),2));
    Min2=min(sum(blockData([1 8],2:7),2));
    
    b=Max1-Min1+Max2-Min2;
    
end