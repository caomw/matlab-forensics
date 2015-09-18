
Numbers=floor(randn(1,10^7)*10^4+8*10^4);

NumDigits=ceil(log10(Numbers+1));

FirstDigits=floor(Numbers./(10.^(NumDigits-1)));

Hist=hist(FirstDigits,1:9);