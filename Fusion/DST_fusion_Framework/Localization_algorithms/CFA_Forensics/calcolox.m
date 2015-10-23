function [ X ] = calcolox( A,B )
% Uso della pseudo inversa per il calcolo dei coefficienti di
% interpolazione
 X = pinv(A)*B ;
