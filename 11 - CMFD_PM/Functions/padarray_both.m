function mtx = padarray_both(mtx, padding , type)
% mtx = padarray_both(mtx, padding , type)
%  padding = [u l d r];
%
    mtx = padarray(mtx,[padding(1) padding(2)], type, 'pre');
    mtx = padarray(mtx,[padding(3) padding(4)], type, 'post');