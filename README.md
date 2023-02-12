# Statistical Verification of Traffic Systems with Expected Differential Privacy
This repository is for this [conference paper](https://arxiv.org/abs/2302.01388).

## Abstract
Traffic systems are multi-agent cyber-physical systems whose performance is closely related to human welfare. They work in open environments and are subject to uncertainties from various sources, making their performance hard to verify by traditional model-based approaches. Alternatively, statistical model checking (SMC) can verify their performance by sequentially drawing sample data until the correctness of a performance specification can be inferred with desired statistical accuracy. This work aims to verify traffic systems with privacy, motivated by the fact that the data used may include personal information (e.g., daily itinerary) and get leaked unintendedly by observing the execution of the SMC algorithm. To formally capture data privacy in SMC, we introduce the concept of expected differential privacy (EDP), which constrains how much the algorithm execution can change in the expectation sense when data change. Accordingly, we introduce an exponential randomization mechanism for the SMC algorithm to achieve the EDP. Our case study on traffic intersections by Vissim simulation shows the high accuracy of SMC in traffic model verification without significantly sacrificing computing efficiency. The case study also shows EDP successfully bounding the algorithm outputs to guarantee privacy.

## How to Use This Repository

### 0. Required Dependencies

### 1. Run Vissim Traffic Simulation
First obtain the traffic data by running the simulation included in the [Vissim Simulator folder](../main/Vissim%20Simulator). The simulator will output `.att` data files. Convert these into `.xlsx` files and save them to a folder.

### 2. Reformat Data and Specify Seed
After obtaining the traffic data, use the script `Read_Data.m` to read the `.xlsx` files and convert them into `.mat` data files:
1. Specify the folder location for the variable `folder_path`.
2. Specify the `.xlsx` file names for the variables `file1`, `file2`, etc. Add as many as necessary.
3. Specify the number of files that the script needs to read in the variable `num_files`.
4. Specify the seed `rng` in section `%% Generate Seed Array` of the script.

This script will output the following three `.mat` files:
- `correctness_of_phi_table.mat`

### 3. Add more instructions here.

### Tips
Since a large amount of data will be saved into `.mat` files, be sure to turn on `save -v7.3` so that you can save variables that exceed 2GB. The instructions for navigating to this setting option can be found on the [MATLAB Help Center](https://www.mathworks.com/help/matlab/import_export/mat-file-versions.html).
