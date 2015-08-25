function mid=Mid_Value(a)
s=size(a); s=s(2);
for i=1:s-1
    for j=i+1:s
        if (a(i)>a(j))
            temp=a(i);
            a(i)=a(j);
            a(j)=temp;
        end
    end
end
mid=a(round(s/2));
