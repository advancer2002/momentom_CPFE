function [value] = bucket(mom,volunder,volupper,n)

% This function is for dividing stocks into different portfolios by the
% break points.

if isnan(mom)
    value = 0;
elseif (mom>volunder) && (mom<=volupper)
    value = n;
else
    value = 0;
end