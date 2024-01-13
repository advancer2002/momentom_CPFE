function cum_array = cumret(ret_array, K)

indexes = floor(length(ret_array) / K);
 

index_array = linspace(1,indexes,indexes);
index_array = repmat(index_array, K);
index_array = reshape(index_array,1,[]);
index_array = index_array(1:indexes * K);

if length(index_array) ~= length(ret_array)
    index_array = [index_array, repmat([indexes+1], 1,...
        (length(ret_array)-length(index_array)))];
end

t = table();
ret = ret_array + 1;
t.ret = ret;
t.index = index_array';

cumprod_ret = @(input) prod_new(input);

cum_array = splitapply(cumprod_ret, t.ret, index_array');

cum_array = cum_array(1:end-1);

end