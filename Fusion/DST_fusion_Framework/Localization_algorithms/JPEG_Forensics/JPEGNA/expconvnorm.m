function [f] = expconvnorm(p,x)

idx1 = p(1)/2-x*p(2) > 26;
idx2 = p(1)/2+x*p(2) > 26;
idx3 = ~idx1 & ~idx2;
f = x;

f(idx3) = p(3) * (exp(-p(1)*p(2)^2*x(idx3)).*erfc(p(1)/2-x(idx3)*p(2)) + exp(p(1)*p(2)^2*x(idx3)).*erfc(p(1)/2+x(idx3)*p(2)));
f(idx1) = p(3) * exp(p(1)*p(2)^2*x(idx1)).*erfc(p(1)/2+x(idx1)*p(2));
f(idx2) = p(3) * exp(-p(1)*p(2)^2*x(idx2)).*erfc(p(1)/2-x(idx2)*p(2));

return