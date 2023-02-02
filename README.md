# Statistical Verification of Traffic Systems with Expected Differential Privacy
This repository is for this conference paper.

## Abstract
Traffic systems are multi-agent cyber-physical systems whose performance is closely related to human welfare. They work in open environments and are subject to uncertainties from various sources, making their performance hard to verify by traditional model-based approaches. Alternatively, statistical model checking (SMC) can verify their performance by sequentially drawing sample data until the correctness of a performance specification can be inferred with desired statistical accuracy. This work aims to verify traffic systems with privacy, motivated by the fact that the data used may include personal information (e.g., daily itinerary) and get leaked unintendedly by observing the execution of the SMC algorithm. To formally capture data privacy in SMC, we introduce the concept of expected differential privacy (EDP), which constrains how much the algorithm execution can change in the expectation sense when data change. Accordingly, we introduce an exponential randomization mechanism for the SMC algorithm to achieve the EDP. Our case study on traffic intersections by Vissim simulation shows the high accuracy of SMC in traffic model verification without significantly sacrificing computing efficiency. The case study also shows EDP successfully bounding the algorithm outputs to guarantee privacy.

## How to Use This Code

### Required Dependencies

### 1. Run Vissim Traffic Simulation
First obtain the traffic data by running the simulation included in the [Vissim Simulator](../main/Vissim%20Simulator) folder.
