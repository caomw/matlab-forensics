function [noise]=DTWDenoise(I, Depth,nor)
    % emir - denoising
    % formerly denoiseit4.m, acquired by Ahmet Emir Dirik
    
    [m n d]=size(I);
    if d==1
        I(:,:,2)=I;
    end
    w=max([m n]);
    
    I=I(:,:,2);
    
    w2=2^ceil(log2(w));
    I0=randn(w2);
    I0(1:m,1:n)=I;
    
    DEN=denoising_dtdwt(I0, Depth, nor);
    noise=I-DEN(1:m,1:n);
    
    return