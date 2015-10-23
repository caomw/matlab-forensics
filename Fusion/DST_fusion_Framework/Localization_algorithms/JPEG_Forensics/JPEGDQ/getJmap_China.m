function LLRmap = getJmap_China(image,c)

%format long

% image = jpeg_read(j); 
coeffArray = image.coef_arrays{1,1};
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

%pdisp = [];

for index = 1:c
    coe = coeff(index);
    ic1 = ceil(coe/8);
    ic2 = mod(coe,8); 
    if ic2 == 0
        ic2 = 8;
    end
    AC = coeffArray(ic1:8:end,ic2:8:end);

    binHist = (-2^11:1:2^11-1);
    num4Bin = hist(AC(:),binHist);
%     figure, plot(binHist, num4Bin)
                
    smax = length(num4Bin);
    smin = 1;
    [Y,s0] = max(num4Bin);
    hmax = 0;
    
    phist = 1;
    for ptemp = 1:(smax/20)
        imax = floor((smax-s0)/ptemp);
        imin = ceil((smin-s0)/ptemp);
        sum = 0;
        
        for i = imin:imax
            sum = sum + num4Bin(i*ptemp+s0);
        end
        
        h = 1/(imax-imin+1)*sum;
        
        if h > hmax
            hmax = h;
            phist = ptemp;
        end
    end

    f = abs(fft(num4Bin));
    
    if ~isempty(f)
        maxl = maxlocal(f,7);
        
        if length(maxl) ~= 1
            
            if maxl(2) < 128
                peak = maxl(2);
                pfft = round(length(binHist)/abs(peak-1));
            else
                pfft = 13;
            end

        else
            pfft = 1;
        end

    else
        pfft = 1;
    end
        
    if pfft < phist
        p = pfft;
    
    else
        p = phist;
    end  
         
    %pdisp = [pdisp p];
    
    if p ~= 1
        pt = 1/p;
        pu = zeros(1,smax);
        
        for s0 = 1:p:smax
            
            for i = 0:p-1
                sum = 0;
                
                for l = 0:p-1
                    
                    if (s0+l) <= smax
                        sum = sum + num4Bin(s0+l);
                    end
                end

                if (s0+i) <= smax 
                    if sum == 0
                        pu(s0+i) = 1/p;
                    else
                        pu(s0+i) = num4Bin(s0+i)/sum;
                    end
                end
            end
        end
        
        ppu = log(pu/pt);
        LLRmap(:,:,index) = ppu(AC + 2^11 + 1);
        
        % figure, plot(1:smax,pu,1:smax,pt)
        
    end
end

return