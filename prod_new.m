function cum = prod_new(input)

c = cumprod(input,'omitnan');
cum = c(end) - 1;

end