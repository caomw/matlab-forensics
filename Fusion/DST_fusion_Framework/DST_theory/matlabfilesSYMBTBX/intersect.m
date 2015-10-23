function[intersection] = intersect(string1, string2)
    if length(string1)~=length(string2)
        error('Cannot intersect strings of different length.');
    end
    nsets = length(string1);
    intersection(1:nsets)='0';
    for i=1:nsets
        intersection(i) = num2str(str2double(string1(i)) * str2double(string2(i)));
    end
end