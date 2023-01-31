# SMC Toolbox
This toolbox contains two functions that are used by the main script: `ExpectedDifferentialPrivacy_Algorithm1` and `UpdateValues`.

## `ExpectedDifferentialPrivacy_Algorithm1`
This function is used directly by the main script and follows Algorithm 1 from the conference paper. This function implements Statistical Model Checking (SMC) with Expected Differential Privacy (EDP) to verify a system against a desired specification.

## `UpdateValues`
This function is used by the `ExpectedDifferentialPrivacy_Algorithm1` function to update *K*, *N*, and as ![alt text](https://latex.codecogs.com/svg.image?\phi)
