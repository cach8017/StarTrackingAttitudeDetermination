% Probability that a randomly chosen value falls within 
% bounds [x0 x1], given mean (xb) and std (sigma)

function prob = probInRange(x0,x1,xb,sigma)
    f = @(x) exp((-(x-xb).^2)./(2.*sigma.^2));
    prob = 1/(sigma*sqrt(2*pi)) * integral(f,x0,x1);
end