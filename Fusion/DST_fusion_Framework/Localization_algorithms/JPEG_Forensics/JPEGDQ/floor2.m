function x2 = floor2(x1)
tol = 1e-12;
x2 = floor(x1);
idx = find(abs(x1 - x2) < tol);
x2(idx) = x1(idx) - 0.5;
return