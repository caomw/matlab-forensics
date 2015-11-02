function RevMat=BuildInversionMatrix(T)
    
    MaxV=2*T+1;
    RevMat=-1*ones(T^4,1);
    for Value1=0:MaxV-1
        for Value2=0:MaxV-1
            for Value3=0:MaxV-1
                for Value4=0:MaxV-1
                    RevMat(BaseN([Value1 Value2 Value3 Value4],MaxV)+1)=BaseN([4-Value4 4-Value3 4-Value2 4-Value1],MaxV)+1;
                end
            end
        end
    end   
