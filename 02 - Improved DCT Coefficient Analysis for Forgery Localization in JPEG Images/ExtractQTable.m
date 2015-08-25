function QTable=ExtractQTable(coeffArray)
    QTable=zeros(8,8);
    for startX=1:8
        for startY=1:8
            coeffIndex=(startY-1)*8+startX;
            
            selectedCoeffs=coeffArray(startX:8:end, startY:8:end);
            coeffList=reshape(selectedCoeffs,1,numel(selectedCoeffs));
            minHistValue=min(coeffList);
            maxHistValue=max(coeffList);
            
            coeffHist=hist(coeffList,minHistValue:maxHistValue);
            %bar(coeffHist)
            %figure;subplot(1,2,1);
            %bar(coeffHist)
            AllHists{coeffIndex}=coeffHist;
            %Find period by estimating average over leaps and selecting the
            %index of the maximum
            if numel(coeffHist>0)
                [MaxHVal,s_0]=max(coeffHist);
                
                %if different lengths are allowed for "vals", longer leaps
                %are always favored since fewer values cause less reduction to
                %s_0's original huge value
                MaxAllowedCoeff=16;
                MaxValsPos=length(coeffHist(s_0:MaxAllowedCoeff:end));
                MaxValsNeg=length(coeffHist(s_0-MaxAllowedCoeff:-MaxAllowedCoeff:1));
                s_0_Out(coeffIndex)=s_0;
                dims(coeffIndex)=length(coeffHist);
                H=zeros(floor(length(coeffHist)/4),1);
                for coeffInd=2:MaxAllowedCoeff %(length(coeffHist)-1)
                    valsPos=coeffHist(s_0:coeffInd:end);
                    valsPos=valsPos(1:MaxValsPos);
                    valsNeg=coeffHist(s_0-coeffInd:-coeffInd:1);
                    valsNeg=valsNeg(1:MaxValsNeg);
                    vals=[valsPos valsNeg];
                    H(coeffInd)=mean(vals>0);
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
            
            %disp([p_h_avg(coeffIndex) p_h_fft(coeffIndex)])
            %period is the minimum of the two methods
            p_final(coeffIndex)=min([p_h_avg(coeffIndex) p_h_fft(coeffIndex)]);
            %p_final(coeffIndex)=p_h_fft(coeffIndex);
            QTable(startX,startY)=p_final(coeffIndex);
        end
    end