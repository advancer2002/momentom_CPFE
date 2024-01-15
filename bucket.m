function [value] = bucket(mom,momunder,momupper,n)

% This function is for dividing stocks into different portfolios by the
% break points.

if isnan(mom)
    value = 0;
elseif (mom>momunder) && (mom<=momupper)
    value = n;
else
    value = 0;
end