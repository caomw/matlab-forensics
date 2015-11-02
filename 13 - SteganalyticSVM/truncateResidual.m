function [ Quant ] = truncateResidual( denoised,trunc,quant )
    %TRUNCATERESIDUAL Summary of this function goes here
    %   Detailed explanation goes here
    
    Quant=round(denoised/quant);
    
    Quant(Quant>trunc)=trunc;
    Quant(Quant<-trunc)=-trunc;
    
end

