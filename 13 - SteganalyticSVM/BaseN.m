function [ Out ] = base5( in, n )
    %BASE5 Summary of this function goes here
    %   Detailed explanation goes here
    Out=0;
    for ii=1:length(in)
        Out=Out+in(ii)*n^(ii-1);
    end
    
    
end

