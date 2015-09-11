function [Feature_Vector, OutputMap, coeffArray] = Extract_Features_NonJPEG( im, Display )
%DETECT_CROP Summary of this function goes here
%   Display==true pops up demo image/figures

%currently min-max picked only from Y channel, for all hists. Should I pick
%it separately for each channel? Should I pick the extremes of all three?
%(what about the zero-tails created by that?) Huge variations even within
%the same channel. Maybe a list of per-histogram defined hists?

%How many DCT coeffs in each direction to take into account
MaxCoeffs=15;
coeff = [1 9 2 3 10 17 25 18 11 4 5 12 19 26 33 41 34 27 20 13 6 7 14 21 28 35 42 49 57 50 43 36 29 22 15 8 16 23 30 37 44 51 58 59 52 45 38 31 24 32 39 46 53 60 61 54 47 40 48 55 62 63 56 64];

%chroma channels give worse results, maybe leave them out (or come back to
%study them)
for channel=1%:length(im.coef_arrays)
    coeffArray = ExtractYDCT(im);
    %DeqY  = dequantize(coeffArray, qtable);
    %max(max(DeqY))
    %min(min(DeqY))
    for coeffIndex=1:MaxCoeffs
        
        coe = coeff(coeffIndex);
        startY = mod(coe,8);
        if startY == 0
            startY = 8;
        end
        startX=ceil(coe/8);
        selectedCoeffs=coeffArray(startX:8:end, startY:8:end);
        coeffList=reshape(selectedCoeffs,1,numel(selectedCoeffs));

        
        minHistValue=min(coeffList)-1;
        maxHistValue=max(coeffList)+1;

        coeffHist=hist(coeffList,minHistValue:maxHistValue);
        %figure;subplot(1,2,1);
        %bar(coeffHist)
        AllHists{coeffIndex}=coeffHist;
        %Find period by estimating average over leaps and selecting the
        %index of the maximum
        if numel(coeffHist>0)
            [MaxHVal,s_0]=max(coeffHist);
            s_0_Out(coeffIndex)=s_0;
            dims(coeffIndex)=length(coeffHist);
            H=zeros(floor(length(coeffHist)/4),1);
            for coeffInd=1:(length(coeffHist)-1)
                vals=[coeffHist(s_0:coeffInd:end) coeffHist(s_0-coeffInd:-coeffInd:1)];
                H(coeffInd)=mean(vals);
            end
            H_Out{coeffIndex}=H;
            [a,p_h_avg(coeffIndex)]=max(H);
        else
            s_0_Out(coeffIndex)=0;
            dims(coeffIndex)=0;
            H_Out{coeffIndex}=[];
            p_h_avg(coeffIndex)=1;
        end
        
        %Find period by max peak in the FFT minus DC term
        FFT=abs(fft(coeffHist));
        %subplot(1,2,2);bar(FFT)
        FFT_Out{coeffIndex}=FFT;
        
        if length(FFT)>0
            DC=FFT(1);
            
            %Find first local minimum, to remove DC peak
            FreqValley=1;
            while (FreqValley<length(FFT)-1) && (FFT(FreqValley)>= FFT(FreqValley+1))
                FreqValley=FreqValley+1;
            end
            
            FFT=FFT(FreqValley:floor(length(FFT)/2));
            FFT_smoothed{coeffIndex}=FFT;
            [maxPeak,FFTPeak]=max(FFT);
            FFTPeak=FFTPeak+FreqValley-1-1; %-1 bc FreqValley appears twice, and -1 for the 0-freq DC term
            if length(FFTPeak)==0 | maxPeak<DC/5 | min(FFT)/maxPeak>0.9 %threshold at 1/5 the DC and 90% the remaining lowest to only retain significant peaks
                p_h_fft(coeffIndex)=1;
            else
                p_h_fft(coeffIndex)=round(length(coeffHist)/FFTPeak);
            end
        else
            FFT_Out{coeffIndex}=[];
            FFT_smoothed{coeffIndex}=[];
            p_h_fft(coeffIndex)=1;
        end
        
        %period is the minimum of the two methods
        %disp([p_h_avg(coeffIndex) p_h_fft(coeffIndex)]);
        %p_final(coeffIndex)=min([p_h_avg(coeffIndex) p_h_fft(coeffIndex)])
        p_final(coeffIndex)=p_h_fft(coeffIndex);
        
        %calculate per-block probabilities
        if p_final(coeffIndex)~=1
            adjustedCoeffs=selectedCoeffs-minHistValue+1;
            period_start=adjustedCoeffs-(rem(adjustedCoeffs-s_0_Out(coeffIndex),p_final(coeffIndex)));
            for kk=1:size(period_start,1)
                for ll=1:size(period_start,2)
                    if period_start(kk,ll)>=s_0_Out(coeffIndex)
                        period=period_start(kk,ll):period_start(kk,ll)+p_final(coeffIndex)-1;
                        
                        if period_start(kk,ll)+p_final(coeffIndex)-1>length(coeffHist)
                            period(period>length(coeffHist))=period(period>length(coeffHist))-p_final(coeffIndex);
                        end
                        
                        num(kk,ll)=coeffHist(adjustedCoeffs(kk,ll));
                        denom(kk,ll)=sum(coeffHist(period));
                    else
                        period=period_start(kk,ll):-1:period_start(kk,ll)-p_final(coeffIndex)+1;
                        
                        if period_start(kk,ll)-p_final(coeffIndex)+1<= 0
                            period(period<=0)=period(period<=0)+p_final(coeffIndex);
                        end
                        num(kk,ll)=coeffHist(adjustedCoeffs(kk,ll));
                        denom(kk,ll)=sum(coeffHist(period));
                        
                    end
                end
            end
            P_u=num./denom;
            P_t=1./p_final(coeffIndex);
            P_tampered(:,:,coeffIndex)=P_t./(P_u+P_t);
            P_untampered(:,:,coeffIndex)=P_u./(P_u+P_t);
            
            %image(uint8( P_tampered(:,:,coeffIndex)*255));colormap(gray(255));
            
        else
            P_tampered(:,:,coeffIndex)=ones(floor(size(im,1)/8),floor(size(im,2)/8))*0.5;
            P_untampered(:,:,coeffIndex)=1-P_tampered(:,:,coeffIndex);
        end
    end
end

P_tampered_Overall=prod(P_tampered,3)./(prod(P_tampered,3)+prod(P_untampered,3));
P_tampered_Overall(isnan(P_tampered_Overall))=0;

    %OutputMap=uint8(P_tampered_Overall*64);

    OutputMap=P_tampered_Overall;
    
    if Display
    figure;
    imagesc(OutputMap);
end

s=var(reshape(P_tampered_Overall,numel(P_tampered_Overall),1));
for T=0.01:0.01:0.99
    Class0=P_tampered_Overall<T;
    Class1=~Class0;
    s0=var(P_tampered_Overall(Class0));
    s1=var(P_tampered_Overall(Class1));
    Teval(round(T*100))=s/(s0+s1);
end

[val,Topt]=max(Teval);
Topt=Topt/100-0.01;

Class0=P_tampered_Overall<Topt;
Class1=~Class0;

s0=var(P_tampered_Overall(Class0));
s1=var(P_tampered_Overall(Class1));

%figure;
%image(uint8(Class1*255));colormap(gray(255));

%Lin et al propose a "medium filter" over the BPPM. They probably mean a
%median filter, and do they mean over C1 (/C0)?
Class1_filt=medfilt2(Class1,[3 3]);
Class0_filt=medfilt2(Class0,[3 3]);

%figure;
%image(uint8(Class1_filt*255));colormap(gray(255));

e_i=(Class0_filt(1:end-2,2:end-1)+Class0_filt(2:end-1,1:end-2)+Class0_filt(3:end,2:end-1)+Class0_filt(2:end-1,3:end)).*Class1_filt(2:end-1,2:end-1);

if sum(sum(Class0)) > 0 && sum(sum(Class0)) < numel(Class0)
    K_0=sum(sum(max(e_i-2,0)))/sum(sum(Class0));
else
    %disp('none');
    K_0=1;
    s0=0;
    s1=0;
    
end

Feature_Vector=[Topt, s, s0+s1, K_0];


 