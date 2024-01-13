function value = wavg(variable,weight)
%wavg Summary of this function goes here

real_weight = ~ismissing(variable);
value= sum(variable.*weight,'omitnan')/sum(real_weight);

end

