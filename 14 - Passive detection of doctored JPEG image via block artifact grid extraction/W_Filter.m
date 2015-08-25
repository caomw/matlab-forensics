function res=W_Filter(ht,MACROBLOCK_W,MACROBLOCK_H)

NH=MACROBLOCK_H*2+1; NW=MACROBLOCK_W*2+1;
[height,width]=size(ht);
pro=zeros(height,width);

hta=abs(ht);
ht_s=ht;
%纵向特征提取：var()
a=sum(hta(1:MACROBLOCK_H*2+1,:));
ht_s(MACROBLOCK_H+1,:)=a;
for i=MACROBLOCK_H+2:height-MACROBLOCK_H
    a=a-hta(i-MACROBLOCK_H-1,:)+hta(i+MACROBLOCK_H,:);
    ht_s(i,:)=a;
end
ht_s(1:MACROBLOCK_H,:)=ones(MACROBLOCK_H,1)*ht_s(MACROBLOCK_H+1,:);
ht_s(height-MACROBLOCK_H+1:height,:)=ones(MACROBLOCK_H,1)*ht_s(height-MACROBLOCK_H,:);
clear hta;

for i=1:height
    %横向,每点减去窗口内中值
    for j=1:width
        %选取一段a:[j-MACROBLOCK_W,j+MACROBLOCK]
        left=j-MACROBLOCK_W; right=j+MACROBLOCK_W;
        if (left<1)
            left=1;
        end
        if (right>width)
            right=width;
        end
        k=j-left+1;
        %求得中值s，计算a-s
        a=ht_s(i,left:right);
        s=Mid_Value(a);
        ht_sf(i,j)=a(k)-s;
    end
    %横向,以8为周期滤波
    for j=1:width
        %选取一段a:[j-MACROBLOCK_W,j+MACROBLOCK]
        left=j-MACROBLOCK_W; right=j+MACROBLOCK_W;
        if (left<1)
            left=1;
        end
        if (right>width)
            right=width;
        end
        k=j-left+1;
        a=ht_sf(i,left:right);
        c=[a(8-mod(8-k,8):8:right-left+1)];
        pick=Mid_Value(c);
%        if (pick<0)% || mod(i,8)==0 || mod(j,8)==0)
%            pick=0;
%        end
        pro(i,j)=pick;
    end
end

res=pro;
toc
