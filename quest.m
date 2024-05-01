% Inputs:
%      VB     3xN body frame measurements
%      VN     3xN 
%       w     1xN weights
% Outputs:
%   BbarN     3x3 DCM
function BbarN = quest(VB,VN,w)
    
% Normalize measurement vectors
    VBnorm = vecnorm(VB);
    VB = VB./repmat(VBnorm,3,1);
    VNnorm = vecnorm(VN);
    VN = VN./repmat(VNnorm,3,1);

% Set up fs(s) and dfds(s) functions, following:
% https://en.wikipedia.org/wiki/Quaternion_estimator_algorithm
    B = zeros(3);
    N = length(w);
    for i=1:N
        B = B + w(i)*VB(:,i)*(VN(:,i)');
    end

    S = B+B';
    Z = [B(2,3)-B(3,2) B(3,1)-B(1,3) B(1,2)-B(2,1)]';
    
    sigma = 0.5*trace(S);
    k = trace(adjoint(S));
    delta = det(S);

    a = sigma^2-k;
    b = sigma^2 + Z'*Z;
    c = delta + Z'*S*Z;
    d = Z'*S^2*Z;

    fs = @(s) s^4 - (a+b)*s^2 - c*s + (a*b + c*sigma - d);
    dfds = @(s) 4*s^3 - 2*(a+b)*s - c;

% Initial lambda guess
    l_opt = sum(w);

% Iterate using NR method
    err = fs(l_opt);
    iter = 0;
    while (err > 1.e-12) && (iter < 20)

        l_opt = l_opt - err/dfds(l_opt);
        err = fs(l_opt);
        iter = iter+1;

    end

% Find optimal CRP set, convert to DCM
    qbar = ((l_opt+sigma)*eye(3) - S)\Z;
    BbarN = Gibbs2C(qbar);

end