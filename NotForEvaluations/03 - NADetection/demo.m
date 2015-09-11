function demo(im)
    
    % threshold on min-entropy of IPM
    th1 = 4;
    % threshold on min-entropy of DIPM
    th2 = 2.5;
    
    
    [H1,H2] = minHNA(im);
    [k1,k2,Q,IPM,DIPM] = detectNA(im,1,th1,th2,false);
    subplot(1,2,1), imagesc(IPM,[0 1]), title(['IPM: min-H = ', num2str(H1)]), axis square
    subplot(1,2,2), imagesc(DIPM,[0 1]), title(['DIPM: min-H = ', num2str(H2)]), axis square

    if Q > 0
        GridShift=[mod(9-k1,8) mod(9-k2,8)]; 
    else
        GridShift=[0 0]; 
    end

    disp(GridShift)