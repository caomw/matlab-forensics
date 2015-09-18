function y = color2gray(x)
    Kb = 0.114;
    Kr = 0.299;
    x = double(x);
    if size(x,3)==3,
        y = Kr * x(:,:,1) + (1-Kb-Kr) * x(:,:,2) + Kb * x(:,:,3);
    else
        y = x(:,:,1);
    end;