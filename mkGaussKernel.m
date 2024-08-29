function kernel = mkGaussKernel(kernelSize,sd)
%  kernel = mkGaussKernel(kernelSize,sd)
%
%	Create a (semi) Gaussian kernel the is filterSize x filterSize
%	using the numerical form  e(- ( (x - imageCenter)/sd)^2)
%	such that the sum of the filter entries sum to 1.0
%
% Useful for debugging.
% kernelSize = [9 3]
% sd = [3 1]

if length(kernelSize) == 1

    kernel = zeros(kernelSize,kernelSize);

    x = 1:kernelSize;
    g = exp(- ((x - (kernelSize/2) - 0.5) ./ sd) .^ 2); % Here, imageCenter=kernelSize/2+0.5,i.e. g=exp(-((x-imageCenter)./sd).^2)
    kernel = g'*g;

elseif length(kernelSize) == 2

    if length(sd) ~= 2
        error('We need 2 sd terms for this kernel')
    end

    kernel = zeros(kernelSize(1),kernelSize(2));

    x = 1:kernelSize(1);
    g1 = exp(- ((x - (kernelSize(1)/2) - 0.5) ./ sd(1)) .^ 2);

    x = 1:kernelSize(2);
    g2 = exp(- ((x - (kernelSize(2)/2) - 0.5) ./ sd(2)) .^ 2);

    kernel = g1'*g2;

end

s = sum(sum(kernel));

if s == 0
    error('The kernel has all zero entries.  No kernel computed.');
else
    kernel = kernel ./ s;
    return
end

