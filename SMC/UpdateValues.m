function [K_new, N_new, Lambda_new] = UpdateValues(K_old, N_old, Lambda_old, phi, p, delta)
%% INTRODUCTION
% This is used by the ExpectedDifferentialPrivacy_Algorithm1 function.
% It's main purpose is to update values: K, N, and Lambda. The definition
% for these values can be found in Algorithm1 of the paper. This function
% was created to keep the ExpectedDifferentialPrivacy_Algorithm1 function
% cleaner.

% INPUTS:
% K_old                 = Scalar. Old K value that needs to be updated.
% N_old                 = Scalar. Old N value that needs to be updated.
% Lambda_old            = Scalar. Old Lambda value that needs to be
%                           updated.
% phi                   = Scalar. Whether or not a trajectory satisfies a
%                           specification. Either 0 or 1.
% p                     = Scalar. Probability threshold. The value that
%                           Algorithm 1 should exceed.
% delta                 = Scalar. Indifference parameter. This value should
%                           be less than satisfaction probability (p_phi)
%                           minus probability threshold (p).

% OUTPUTS:
% K_new                 = Scalar. New K value.
% N_new                 = Scalar. New N value.
% Lambda_new            = Scalar. New Lambda value.


%% Calculations
% Update the K value.
K_new = K_old + phi;

% Update the N value.
N_new = N_old + 1;

% Update the Lambda value.
Lambda_new = Lambda_old + log(( (p + delta)^phi * (1 - p - delta)^(1 - phi) ) /...
            ( (p - delta)^phi * (1 - p + delta)^(1 - phi) ));
end