function data = ExpectedDifferentialPrivacy_Algorithm1(...
    alpha, delta, epsilon, p, trajectories, seed_array, varargin)
%% INTRODUCTION
% This function implements Algorithm 1 for statistical model checking with
% expected differential privacy. During the case study, the computational
% efficiency was increased by sampling all the trajectories from the Vissim
% traffic simulator and saved to a lookup table. Prior to implementing
% Algorithm 1, the lookup table was shuffled. That way, this function only
% needs to extract data from the lookup table.

% In a real-world setting, running Algorithm 1 occurs concurrently with
% sampling trajectories from the system. This function takes the difference
% in computation time into account and reports the actual computation time.

% For the privacy analysis, must extract data in the same order.

% INPUTS:
% alpha                 = Scalar. Significance level. Confidence level is
%                           1 - alpha.
% delta                 = Scalar. Indifference parameter. This value should
%                           be less than satisfaction probability (p_phi)
%                           minus probability threshold (p).
% epsilon               = Scalar. Privacy parameter. The larger the value,
%                           the less "private" the data is.
% p                     = Scalar. Probability threshold. The value that
%                           Algorithm 1 should exceed.
% trajectories          = Array. Array of trajectories of either nx2 or nx1.
%                           n is the total number of different seeds
%                           sampled. 1st column is the correctness of phi
%                           (either 0 or 1) for the trajectory. 2nd column
%                           (if applicable) is the computation time spent
%                           in obtaining the trajectory.
% seed_array            = Array. Array of seeds that dictate the order of
%                           how Algorithm 1 samples the trajectory. Size
%                           jxk where j is the number of sets of seeds and
%                           k is the maximum number of seeds per set. Make
%                           sure k is sufficiently large that Algorithm 1
%                           will not reach the end. The order of sampling
%                           the data is important for the privacy analysis.
% varargin              = Variable argument inputs.
%                           These can include "combo" and "set" so that the
%                           algorithm can print out its progress.
%                           Also includes "record_time" which lets the
%                           algorithm know whether or not to record
%                           trajectories' computation time.
%                           For now, the inputs MUST be in this order:
%                           combo, set, record_time

% OUTPUTS:
% data                  = Structure. Includes all the information from a
%                           run such as alpha, epsilon, delta, B, L, etc.
%                           Go to the last section "Save the Information"
%                           to see all the kinds of information being
%                           saved.

%% Optional Argument Inputs
% Measure the length of the variable argument inputs.
numvarargs = length(varargin);

% Set defaults for optional inputs.
optargs = {false, false, true};

% If the user specified any optional arguments, then override the default
% values.
[optargs{1:numvarargs}] = varargin{:};

% Finalize the values for the variables.
[combo, set, record_time] = optargs{:};


%% Initialize Variables
% Initial arrays for the original data.
N = zeros(height(seed_array), 1);
K = N;
Lambda = N;
H = N;

% B is a constant that is dependent on alpha.
B = log((1 - alpha) / alpha);
% L is a random value sampled from an exponential distribution with mean (mu).
% In Algorithm 1, the equation for (lowercase lambda) is given as:
llambda = epsilon / (log( (p+delta)/(p-delta) ) + log( (1-p+delta)/(1-p-delta) ));
% Mean (mu) is the inverse of (lowercase lambda):
mu = 1 / llambda;
% Sample from the exponential distribution.
L = exprnd(mu);

% Initial arrays for the altered data.
% B and L will remain the same. Only N, K, and Lambda will be different.
N_prime = N;
K_prime = N;
Lambda_prime = N;
H_prime = N;

% Initialize array for recording trajectories' computational time.
calc_time = N;


%% Run Algorithm
for sequence = 1:height(seed_array)

    % Initialize booleans to run the while loop for the original data and/or the
    % altered data.
    run = true;
    run_prime = true;

    % Initialize a counter to keep track of seed index.
    seed = 1;

    % Begin timer.
    tic

    % Algorithm 1 Begin
    while run || run_prime
        %% Get Trajectory from System, Check Conformance, and Get Correctness of Phi
        % Get the (phi) and the (phi_prime).
        phi = trajectories(seed_array(sequence, seed), 1);
        phi_prime = phi;
        
        % In the paper, sigma_n is the altered data. In this function,
        % n = 5.
        if N(sequence) == 5
            phi = 1;
        end
        if N_prime(sequence) == 5
            phi_prime = 0;
        end


        %% Update Values
        if run
            % Update values for the original data if applicable.
            % This uses the UpdateValues function.
            [K(sequence), N(sequence), Lambda(sequence)] = ...
                UpdateValues(K(sequence), N(sequence), Lambda(sequence), phi, p, delta);
        end

        if run_prime
            % Update values for the altered data if applicable.
            % This uses the UpdateValues function.
            [K_prime(sequence), N_prime(sequence), Lambda_prime(sequence)] = ...
                UpdateValues(K_prime(sequence), N_prime(sequence), Lambda_prime(sequence), phi_prime, p, delta);
        end

        if record_time
            % Add up the times from the trajectories (if applicable).
            % These times are real-world times due to running Algorithm 1
            % and sampling trajectories at the same time.
            calc_time(sequence) = calc_time(sequence) + trajectories(seed_array(sequence, seed), 2);
        end

        
        %% Checking Hypothesis for Original Data
        if run
            if Lambda(sequence) >= B + L
                % H_null means that the probability of a trajectory satisfying a
                % condition is greater than a probability threshold.
                H(sequence) = 1;
                % Now get out of the while loop.
                run = false;

            elseif Lambda(sequence) <= -B-L
                % H_alt means that the probability of a trajectory satisfying a
                % condition is less than or equal to a probability threshold.
                H(sequence) = 0;
                % Get out of while loop.
                run = false;
            end
            % Otherwise, stay inside the while loop.
        end

        %% Checking Hypothesis for Altered Data
        if run_prime
            if Lambda_prime(sequence) >= B + L
                % H_null means that the probability of a trajectory satisfying a
                % condition is greater than a probability threshold.
                H_prime(sequence) = 1;
                % Now get out of the while loop.
                run_prime = false;

            elseif Lambda_prime(sequence) <= -B-L
                % H_alt means that the probability of a trajectory satisfying a
                % condition is less than or equal to a probability threshold.
                H_prime(sequence) = 0;
                % Get out of while loop.
                run_prime = false;

            end
            % Otherwise, stay inside the while loop.
        end

        if (combo ~= false) && (set ~= false)
            % If the user wants to print out progress, then run this line.
            fprintf('Alg2.....combo %f.....set %f.....sequence %f.....seed %f\n', combo, set, sequence, seed);
        end

        % Increase seed counter.
        seed = seed + 1;
    end

    % Add up the time from Algorithm 1 itself.
    calc_time(sequence) = calc_time(sequence) + toc;
end

%% Save the Information
% Save all the information as a structure.
data.alpha = alpha;
data.delta = delta;
data.epsilon = epsilon;
data.B = B;
data.L = L;

data.H = H;
data.H_avg = mean(H);
data.H_prime = H_prime;
data.H_prime_avg = mean(H_prime);

data.N = N;
data.N_avg = ceil(mean(N));
data.N_prime = N_prime;
data.N_prime_avg = ceil(mean(N_prime));

data.K = K;
data.K_prime = K_prime;

data.Lambda = Lambda;
data.Lambda_prime = Lambda_prime;

data.calc_time = calc_time;
data.calc_time_avg = mean(calc_time);
end