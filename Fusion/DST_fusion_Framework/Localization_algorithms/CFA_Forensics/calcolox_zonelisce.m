function [ X ] = calcolox_zonelisce( A,B )


if (isempty(A))
    X=[0;0;0;0;0;0;0;0];   
    return;
end
X=lsqnonneg(A,B); %risoluzione del sistema con vincolo di x>0



