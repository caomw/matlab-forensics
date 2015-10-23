function [] = validate_model(im, k1e, k2e, Q1)
% image: jpeg object from jpeg_read
% ncomp: index of color component (1 = Y, 2 = Cb, 3 = Cr)
% c1: first DCT coefficient to consider (1 <= c1 <= 64)
% c2: last DCT coefficient to consider (1 <= c1 <= 64)
%
% maskTampered: estimated probability of being tampered for each 8x8 image block
ncomp = 1;
qtable = im.quant_tables{im.comp_info(ncomp).quant_tbl_no};


I = uint8(jpeg_rec(im));
b = double(I(:,:,3));
g = double(I(:,:,2));
r = double(I(:,:,1));
Y = (0.299 * r + 0.587 * g + 0.114 * b);
v = (0.299^2 + 0.587^2 + 0.114^2)/12;
DC = conv2(Y - 128, ones(8)/8);
DC = DC(8:end,8:end);
Q2 = qtable(1,1);

for k1 = 1:8
    for k2 = 1:8
        DCpoly = DC(k1:8:end,k2:8:end);
        
        if k1 == 1 && k2 == 1
            binHist = (0:0.05:Q2-1+0.025) - floor(Q2/2);
            data = mod(DCpoly(:) + floor(Q2/2),Q2) - floor(Q2/2);
            num4Bin = histc(data,binHist)/numel(DCpoly(:))/0.05;
            y = normpdf(binHist(1:end-1)+0.025,0,sqrt(v));
            figure, plot(binHist(1:end-1)+0.025, num4Bin(1:end-1),binHist(1:end-1)+0.025,y,'r--')
            xlabel('DC mod Q_2');
            ylabel('frequency');
            legend('histogram','Gaussian fitting')
        elseif k1 == k1e && k2 == k2e
            binHist = (0:0.2:Q1-1+0.1) - floor(Q1/2);
            data = mod(DCpoly(:) + floor(Q1/2),Q1) - floor(Q1/2);
            num4Bin = histc(data,binHist)/numel(DCpoly(:))/0.2;
            y = normpdf(binHist(1:end-1)+0.1,0,sqrt((1+Q2^2)/12));
            figure, plot(binHist(1:end-1)+0.1, num4Bin(1:end-1),binHist(1:end-1)+0.1,y,'r--')
            xlabel('DC mod Q_1');
            ylabel('frequency');
            legend('histogram','Gaussian fitting')
        elseif k1 == 3 && k2 == 3
            binHist = (0:0.2:Q2-1+0.1) - floor(Q2/2);
            data = mod(DCpoly(:) + floor(Q2/2),Q2) - floor(Q2/2);
            num4Bin = histc(data,binHist)/numel(DCpoly(:))/0.2;
            figure, plot(binHist(1:end-1)+0.1, num4Bin(1:end-1)),axis([-floor(Q2/2) Q2-1-floor(Q2/2) 0 2/Q2])
            xlabel('DC mod Q_2');
            ylabel('frequency');
        end
        
    end
end




return