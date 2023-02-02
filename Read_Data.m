%% Clear the Workspace and Add Folder Path
clc;clear;close all;
addpath('./Algorithm Data');

%% Read Excel Sheets
% There is no shortcut to this coding...
file1 = readtable('1 - 70000.xlsx');
file2 = readtable('70001 - 100000.xlsx');

% Total number of files to read.
num_files = 2;
% Initialize an empty cell.
big_data = cell(num_files,1);
% Initialize a variable to record the total number of simulations ran.
num_sim = 0;
% Convert the tables into cells for easier coding.
for ii = 1:num_files
    % 1) Convert index into string to form the variable name.
    % 2) Evaluate the variable name.
    % 3) Convert to cell and save.
    big_data{ii} = table2cell(eval('file' + string(ii)));

    % 4) Get the size of the file and add it together.
    % Divide by 12 to get the actual value because each
    % simulation has 12 entries.
    num_sim = num_sim + size(eval('file' + string(ii)), 1)/12;
end

%% Extract & Process Data from Cells
% First, extract the distance traveled. This is constant for all
% simulations. There are 12 different distances to extract.
% The distances are in meters.
% Convert cells to array for easier coding.
distance = cell2mat(big_data{2}(1:12, 6));

% The 12 different distances are the following:
% 1) Univ Ave West-bound Inbound Right Turn
% 2) Univ Ave West-bound Inbound Straight
% 3) Univ Ave West-bound Inbound Left Turn

% 4) 13 St South-bound Inbound Right Turn
% 5) 13 St South-bound Inbound Straight
% 6) 13 St South-bound Inbound Left Turn

% 7) Univ Ave East-bound Inbound Left Turn
% 8) Univ Ave East-bound Inbound Straight
% 9) Univ Ave East-bound Inbound Right Turn

% 10) 13 St North-bound Inbound Right Turn
% 11) 13 St North-bound Inbound Straight
% 12) 13 St North-bound Inbound Left Turn

% Due to small mistake in simulation setup, ignore 4) and 12). I will
% fix it later.

% Initialize a 2D array of zeros with:
% Number of rows = 12
% Number of cols = number of simulations
% This array will be for the average travel time in seconds.
travel_time = zeros(12, num_sim);

% Fill in the data using a for-loop.
% Initialize a counter.
counter = 1;
% For each cell...
for ii = 1:size(big_data, 1)

    % For every 12 rows...
    for jj = 1:12:size(big_data{ii}, 1)

        % Extract the travel time from the data and remember to
        % convert to array.
        travel_time(:, counter) = cell2mat(big_data{ii}(jj:jj+11, 5));

        % Increase counter by 1.
        counter = counter + 1;
    end
end

% Delete the NaNs from the data because they are useless.
% distance([4,12]) = [];
% travel_time([4,12], :) = [];

% Take the distance and convert from meters to kilometers.
distance = distance / 1000;
% Take the travel time and convert from seconds to hours.
travel_time = travel_time / 3600;

% Calculate km/hr
speed = distance ./ travel_time;

% Now transpose speed such that:
% number of rows = number of simulations
% number of cols = 12
speed = speed';

%% Calculate Speed Deviation Percentage
% Driving straight should have a mean of 50 km/h with std of 10 km/h.
% Right turns should have a mean of 13 km/h with std of 3 km/h.
% Left turns should have a mean of 15 km/h with std of 5 km/h.

% Make a copy of the speed array.
speed_deviation = speed;

% 2), 5), 8), and 11) are straight driving so calculate the deviation
% percentage accordingly.
speed_deviation(:, [2,5,8,11]) = (speed_deviation(:, [2,5,8,11]) - 50) / 50;

% 1), 4), 9), and 10) are right turns.
speed_deviation(:, [1,4,9,10]) = (speed_deviation(:, [1,4,9,10]) - 13) / 13;

% 3), 6), 7), and 12) are left turns.
speed_deviation(:, [3,6,7,12]) = (speed_deviation(:, [3,6,7,12]) - 15) / 15;

%% Calculate Correctness of Phi (0 or 1)
% If the magnitude of the speed deviation percentage is within a threshold
% c, then phi = 1. Otherwise, phi = 0.

% Initialize NaN array for phi.
% phi_array = NaN(num_sim, 12);
% For now, any NaN values will just be set to zero.
phi_array = zeros(num_sim, 12);

% Find all the linear indices where the magnitude of the speed deviation
% percentage is less than the threshold.
% Afterwards, set the corresponding elements equal to 1.
phi_array(find(abs(speed_deviation) < 0.2)) = 1;

% For the rest of the values, set the correctness of phi equal to 0.
% phi_array(find(abs(speed_deviation) >= 0.2)) = 0;

% Save the phi table.
fprintf('Saving phi data......');
save('./Algorithm Data/correctness_of_phi_table.mat', 'phi_array');
fprintf('Done!\n');


%% Generate Seed Array
% The order of the seed must be recorded for Algorithm 2 because the order
% of the seed for both (sigma) and (sigma_prime) must be the same.
% For each value of L, go through each set of seed sequence.
% Each Row = 1 set of seed sequence.
seed_sequences = randi(height(speed), 500, 1e6);

% Save the seed sequences.
fprintf('Saving seed sequence......');
save('./Algorithm Data/seed_sequences.mat', 'seed_sequences');
fprintf('Done!\n');

%% Generate Satisfaction Probability (p_phi)
% After obtaining many trajectories and correctness of phi,
% the satisfaction probability is the fraction of samples that remain inside
% the desired region. The value of (p) will be based on
% the satisfaction probability.

% First calculate the remainder after dividing the height of the table
% of trajectories by 100.
r = rem(num_sim, 100);

% Initialize an empty cell that is 12x1.
p_phi_data = cell(12,1);

% Use a for-loop to get the satisfaction probability for each column.
for ii = 1:12
    % Take the values of (phi) and reshape into many rows of 100.
    p_phi_data{ii}.CorrectnessOfPhi = reshape(phi_array(1 : (end-r), ii), [], 100);

    % Calculate the satisfaction probability (p_phi) for each row.
    p_phi_data{ii}.SatisfactionProbability = mean(p_phi_data{ii}.CorrectnessOfPhi, 2);

    % After obtaining the array of p_phi, calculate the mean and standard
    % deviation of p_phi. Finally, calculate the margin of error for p_phi.
    % This is needed to calculate the probability threshold (p).

    % Mean and standard deviation
    p_phi_data{ii}.Mean = mean(p_phi_data{ii}.SatisfactionProbability);
    p_phi_data{ii}.STD = std(p_phi_data{ii}.SatisfactionProbability);

    % To calculate margin of error, use 3 standard deviations.
    p_phi_data{ii}.Margin = 3 * p_phi_data{ii}.STD;

    % Calculate probability threshold (p).
    p_phi_data{ii}.ProbabilityThreshold = p_phi_data{ii}.Mean - p_phi_data{ii}.Margin;
end

% Save the satisfaction probabilities.
fprintf('Saving p_phi data......');
save('./Algorithm Data/p_phi_data.mat', 'p_phi_data');
fprintf('Done!\n');
