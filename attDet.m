function [sol, fval] = attDet(starEstData, starInertialData)

    v1B = starEstData(1,2:4)';
    v2B = starEstData(2,2:4)';

    v1N = starInertialData(:,1);
    v2N = starInertialData(:,2);

    BbarNg = triad(v1N,v2N,v1B,v2B);
    MRPg = C2MRP(BbarNg);

    Jg = costFunction(MRPg, starEstData(:,2:4)', starInertialData);

    opts = optimset('Display','off');
    [sol,fval] = fminunc(@(MRP) costFunction(MRP,starEstData(:,2:4)',starInertialData),MRPg,opts);

    %fprintf('Initial Guess: [%.12f %.12f %.12f]   Cost: %.12f\n',MRPg',Jg);
    %fprintf('fminunc:       [%.12f %.12f %.12f]   Cost: %.12f\n',sol',fval);

    %BbarQUEST = quest(starEstData(:,2:4)',starInertialData,ones(1,size(starInertialData,2)));
    %MRPQ = C2MRP(BbarQUEST);
    
    %fprintf('QUEST:         [%.12f %.12f %.12f]\n',MRPQ');

end

% Inputs:
%    sigmaBar   MRP representing estimated B/N attitude
%    stars_B    3xN stars measured from B frame
%    stars_N    3xN stars measured from N frame
% Outputs:
%    J          Scalar cost
function J = costFunction(sigmaBar, stars_B, stars_N)

    % Compute rotation matrix
    BbarN = MRP2C(sigmaBar);

    % Compute residuals
    residuals = (BbarN'*stars_B - stars_N);

    % Compute cost
    J = sum(sum(residuals.^2));
end
