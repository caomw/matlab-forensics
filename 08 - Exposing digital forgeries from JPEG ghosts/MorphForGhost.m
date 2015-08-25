for all=4 %:7
   tic
    load(['.\RealWorldData\AmericanFlag\' num2str(all) '.mat']); BinMask=mean(imread('D:\markzampoglou\ImageForensics\datasets\mark - Real World Splices\organized Collection\americanFlag\mask\Mask2.png'),3)>0;
   %load('SyntheticData\VIPPDempSchaSynth_au\1604.mat');BinMask=0;
    %load(['.\RealWorldData\WhaleCayak\' num2str(all) '.mat']); BinMask=mean(imread('D:\markzampoglou\ImageForensics\datasets\mark - Real World Splices\organized Collection\WhaleCayak\mask\0_49cd8_703f0f93_L.png'),3)>0;
    %load('SyntheticData\VIPPDempSchaSynth_sp\1603.mat')
    
    BinMask=imresize(BinMask,size(Results.dispImages{1}))>0;
    SpOutput=[];
    for ii=1:length(Results.imin)
        % if (Results.imin(ii)~=1) && (Results.imin(ii)~=length(Results.dispImages))
        ImToProcess=Results.dispImages{Results.imin(ii)};
        Lvl=graythresh(ImToProcess);
        Binarized=GetBinaryOutput_Ghosts(ImToProcess,Lvl);
        for jj=1:size(Binarized,3)
            tmpResult=Binarized(:,:,jj);
            
            Straight=[numel(tmpResult) sum(sum(tmpResult)) sum(sum(BinMask)) sum(sum(tmpResult&BinMask)) sum(sum(tmpResult&~BinMask))];
            AuStraight=numel(tmpResult)>0;
            tmpResult=~tmpResult;
            Inv=[numel(tmpResult) sum(sum(tmpResult)) sum(sum(BinMask)) sum(sum(tmpResult&BinMask)) sum(sum(tmpResult&~BinMask))];
            AuInv=numel(tmpResult)>0;
            StraightVal=Straight(4).^2/(Straight(2)*Straight(3));
            InvVal=Inv(4).^2/(Inv(2)*Inv(3));
            
            %imagesc(tmpResult)
            %title([ii jj StraightVal InvVal])
            %pause;
            
            SpOutput(1,:,jj,1,ii)=Straight;
            SpOutput(1,:,jj,2,ii)=Inv;
           AuOutput(1,:,jj,1,ii)=AuStraight;
           AuOutput(1,:,jj,2,ii)=AuInv;
           
        end
        %end
    end
    disp(max(max(max(SpOutput(:,4,:,:,:).^2./(SpOutput(:,2,:,:,:).*SpOutput(:,3,:,:,:))))))
    disp(min(min(min(AuOutput))))
end
toc
FromMorph=SpOutput;