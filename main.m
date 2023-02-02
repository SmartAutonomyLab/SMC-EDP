%% Clean the Workspace & Load Data
clc;clear;close all;
addpath('./Algorithm Data');
addpath('./SMC');
load('correctness_of_phi_table.mat');
load('p_phi_data.mat');
load('seed_sequences.mat');


%% Parameters & Setup
alpha = 0.05;
epsilon = 0.01;
% Design (delta) around (p) and (P_phi). Want (P_phi) > (p + delta).
delta = 0.01;

% Initialize counter
ii = 0;

% Set the desired number of sets to work with.
num_sets = 1e4 - 2811;


%% Run Algorithm 1
% Run Algorithm 1 for each traffic route.
for route = 3
    % Extract some data for cleaner code.
    % Probability threshold
    p = p_phi_data{route}.ProbabilityThreshold;
    % Correctness of phi for trajectories
    trajectories = phi_array(:, route);
    
    % Run Algorithm 1 for each combination of alpha, delta, and epsilon.
    for ii_a = 1 : length(alpha)
        % Extract the alpha here for cleaner code.
        aa = alpha(ii_a);
        
        for ii_d = 1 : length(delta)
            % Extract the delta here for cleaner code.
            dd = delta(ii_d);
            
            for ii_e = 1 : length(epsilon)
                % Extract the epsilon here for cleaner code.
                ee = epsilon(ii_e);
                
                % Increase counter
                ii = ii + 1;
                
                % For each combination of alpha, delta, and epsilon, run
                % Algorithm 1 for many sets. Each set contains (N) number of
                % seeds.
                for set = 1:num_sets
                    % Run Algorithm 1!
                    data(ii, set) = ExpectedDifferentialPrivacy_Algorithm1(...
                        aa, dd, ee, p, ...
                        trajectories, seed_sequences, ii, set, false);
                    
                    % Just to make sure the code is running correctly.
                    % Save some variables that can be accessed by another
                    % computer to make sure the code is running well.
                    %data_size = size(data);
                    %save('temp_check.mat', 'data_size', 'route');
                    
                    if (set < 1000) || (rem(set, 200) == 0) || (set == num_sets)
                        % Save/overwrite the data. This will make the for-loop
                        % slower but the computer has been crashing too often.
                        % This is necessary to avoid losing time.
                        save('big_data_r3_a5_e1_d1_2811to10000.mat', 'data');
                    end
                end
            end
        end
    end
end
fprintf('Done with Algorithm 1!\n');


%% Analyze Data
% This is a temporary line.
clc;clear;close all;addpath('Completed Data'); load('big_data_r3.mat');

% Create arrays to hold number of average samples N for the "original" data
% and the "altered" data.
% rows = the combination of alpha, delta, and epsilon.
% cols = the N value for each set.
N_avg = zeros(height(data), length(data));
N_prime_avg = N_avg;

% Create an array to hold computation time.
time = N_avg;

% Create an array to hold the sum of average number of null hypotheses.
% Col 1 = for original data
% Col 2 = for altered data
H_array = zeros(height(data), 2);

for ii = 1:height(data)
    for set = 1:length(data)
        % Average (N) for original data.
        N_avg(ii, set) = data(ii, set).N_avg;
        % Average (N) for altered data.
        N_prime_avg(ii, set) = data(ii, set).N_prime_avg;

        % Sum of average (H_null) for original data.
        H_array(ii, 1) = H_array(ii, 1) + data(ii, set).H_avg;
        % Sum of average (H_null) for altered data.
        H_array(ii, 2) = H_array(ii, 2) + data(ii, set).H_prime_avg;

        % Average computation time per set per sequence.
        % Include the computation time related to sampling from the traffic
        % simulation.
        % Convert from seconds to minutes.
        time(ii, set) = (data(ii, set).calc_time_avg + 4 * N_avg(ii, set)) / 60;
    end
end

% Compute the mean of the average number of samples for the original data.
N_mean = mean(N_avg, 2);

% Due to the central limit theorem, the distribution will tend towards a
% Gaussian distribution even though it began as an exponential
% distribution.
% Calculate the standard deviation.
N_std = std(N_avg, 0, 2);
% Use a z-score of 2.33 to calculate the margin of error with a 99%
% confidence level.
N_margin = 2.33 * N_std / sqrt(length(N_avg));

% Compute the mean of the average computation time per set per sequence.
time_mean = mean(time, 2);
% Calculate the standard deviation.
time_std = std(time, 0, 2);
% Use a z-score of 2.33 to calculate the margin of error with a 99%
% confidence level.
time_margin = 2.33 * time_std / sqrt(length(time));

% Save data
save('r3_results.mat', 'N_avg', 'N_prime_avg', 'N_mean', 'N_std', 'N_margin', 'H_array', 'time', 'time_mean', 'time_std', 'time_margin');
fprintf('done with extracting data!\n');


%% Probability Mass Plot
% After saving all the important data, run this section just to generate
% histogram plots.
close all;

for ii = 4
    % Get the number of occurances (N) and the bin edge values for both the
    % original and altered data.
    [N1, edges1] = histcounts(N_avg(ii,:), 'BinWidth', 130, 'Normalization', 'probability');
    
    % Create a new figure and first plot the altered data.
    % Use the bin edges from the original data.
    figure
    h2 = histogram(N_prime_avg(ii,:), edges1, 'Normalization','probability', 'EdgeColor', '#000000', 'FaceColor','#4DBEEE');
    hold on
    
    % Calculate the upper bound for the acceptable range.
    y_upper = N1 * exp(data(ii,1).epsilon);
    
    % Calculate the lower bound for the acceptable range.
    y_lower = N1 / exp(data(ii,1).epsilon);
    
    % Plot the histogram for the original data. Plot only the outline.
    h1 = histogram(N_avg(ii,:), edges1, 'Normalization','probability', ...
        'DisplayStyle','stairs', ...
        'LineWidth',1, ...
        'EdgeColor','m');

    % Plotting the upper/lower bounds as error bars instead of as dashed
    % bounds.
    upper_error = y_upper - N1;
    lower_error = N1 - y_lower;
    % Need the midpoint of each edge.
    midpoint = (edges1(1:(end-1)) + edges1(2:end)) / 2;
    % Now plot error bars.
    errorbar(midpoint, N1, lower_error, upper_error, '.m', 'CapSize',12, 'LineWidth', 1.25)


    % Make the axes, set legends, etc.
    font = 13;
    legend('$\varphi(\sigma_{n}'')=0$', '$\varphi(\sigma_{n})=1$', '','Interpreter','latex','FontSize',font);
    xlabel('ATT','Interpreter','latex', 'FontSize',font);
    ylabel('Probability Mass','Interpreter','latex', 'FontSize',font);
    title({'Probability mass plot of average termination time over $M$', 'pairs of sequences (ATT) for PTV Vissim simulation', 'of driving straight through intersection'},'Interpreter','latex', 'FontSize',font);
    subtitle(['$\alpha=$ ' num2str(data(ii,1).alpha) ', $\delta=$ ' num2str(data(ii,1).delta) ', $\varepsilon=$ ' num2str(data(ii,1).epsilon)],'Interpreter','latex', 'FontSize',font)
    exportgraphics(gcf, ['PMF_', int2str(ii), '.png'], 'Resolution',300)
%     saveas(gcf, ['PMF_', int2str(ii)],'png');

    
end

% figure
% [f, x] = ecdf(N_avg);
% ecdf(N_avg);
% hold on
% ecdf(N_prime_avg);
% f_upper = f * exp(0.05);
% plot(x, f_upper);
% f_lower = f / exp(0.05);
% plot(x, f_lower)
% legend('N_avg', 'N_prime', "upper", 'lower')