function x = maxlocal(vect,n)

medFFT = median(vect);
j = 1;
x = 1;
for i = 1:length(vect)
    minori = 0;
    for l = 1:n
        if (i-l) > 0
            if vect(i) > vect(i-l)
                minori = minori + 1;
            end
        end
    end
    for k = 1:n
        if (i+k) < length(vect)+1
            if vect(i) > vect(i+k)
                minori = minori + 1;
            end
        end
    end
    if i < n+1
        if minori == (n+i-1)
            x(j) = i;
            j = j+1;
        end
    end
    if i>=n+1 && i <= length(vect) - n
        if minori == 2*n && vect(i) > medFFT
            x(j) = i;
            j = j+1;
        end
    end
    if i > length(vect) - n
        if minori == n + length(vect) - i
            x(j) = i;
            j = j+1;
        end
    end
end

