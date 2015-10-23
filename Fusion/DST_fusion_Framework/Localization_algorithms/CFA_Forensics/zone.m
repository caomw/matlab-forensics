function [ R1,R2,R3 ] = zone( gradh,gradv,T )

R1=(gradh-gradv)>T; %creazione maschera zona R1
R2=(gradv-gradh)>T; %creazione maschera zona R2
R3=(1-(R1+R2)); %creazione maschera zona R3