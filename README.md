# Statistical Verification of Traffic Systems with Expected Differential Privacy
This repository is for this [conference paper](https://arxiv.org/abs/2302.01388).

## Abstract
Traffic systems are multi-agent cyber-physical systems whose performance is closely related to human welfare. They work in open environments and are subject to uncertainties from various sources, making their performance hard to verify by traditional model-based approaches. Alternatively, statistical model checking (SMC) can verify their performance by sequentially drawing sample data until the correctness of a performance specification can be inferred with desired statistical accuracy. This work aims to verify traffic systems with privacy, motivated by the fact that the data used may include personal information (e.g., daily itinerary) and get leaked unintendedly by observing the execution of the SMC algorithm. To formally capture data privacy in SMC, we introduce the concept of expected differential privacy (EDP), which constrains how much the algorithm execution can change in the expectation sense when data change. Accordingly, we introduce an exponential randomization mechanism for the SMC algorithm to achieve the EDP. Our case study on traffic intersections by Vissim simulation shows the high accuracy of SMC in traffic model verification without significantly sacrificing computing efficiency. The case study also shows EDP successfully bounding the algorithm outputs to guarantee privacy.

## How to Use This Repository

### 0. Required Dependencies

### 1. Run Vissim Traffic Simulation
First obtain the traffic data by running the simulation included in the [Vissim Simulator folder](../main/Vissim%20Simulator). The simulator will output `.att` data files. Convert these into `.xlsx` files and save them to a folder. Vehicle data for the first 100,000 seeds have been collected in [this folder](https://uflorida-my.sharepoint.com/:f:/g/personal/markyen_ufl_edu/EjY9s00-IslOqTX94M0U3RkB93y-sh3-1arLXj_xGJBNwg?e=DG9YW1); they are located in the Excel sheets `1 - 70000.xlsx` and `70001 - 100000.xlsx`.

__Structure of Vehicle Data__
- `SIMRUN` refers to the simulation run. It matches with the seed value used during the simulation.

### 2. Reformat Data and Specify Seed
After obtaining the traffic data, use the script `Read_Data.m` to read the `.xlsx` files and convert them into `.mat` data files:
1. Specify the folder location for the variable `folder_path`.
2. Specify the `.xlsx` file names for the variables `file1`, `file2`, etc. Add as many as necessary.
3. Specify the number of files that the script needs to read in the variable `num_files`.
4. Specify the seed `rng` in section `%% Generate Seed Array` of the script.
5. Run the script.

This script will output the following three `.mat` files:
- `correctness_of_phi_table.mat`: This is an array of outputs from Equation 23 found in the [paper](https://arxiv.org/abs/2302.01388). `0` represents False and `1` represents True. Each column is a different route and a different driving decision (e.g., northbound on 13th St and turning right). Each row is a sample.
- `seed_sequences.mat`: This is an array of sample sequences for the script `main.m` to follow. Each row is one sequence of samples.
- `p_phi_data.mat`: This contains other information such as the satisfaction probability ![alt text](https://latex.codecogs.com/svg.image?p_\varphi).

### 3. Add more instructions here.

### Tips
Since a large amount of data will be saved into `.mat` files, be sure to turn on `save -v7.3` so that you can save variables that exceed 2GB. The instructions for navigating to this setting option can be found on the [MATLAB Help Center](https://www.mathworks.com/help/matlab/import_export/mat-file-versions.html).
