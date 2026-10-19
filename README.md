# TSSAEA-DTC

MATLAB framework associated with the manuscript **Two-strategy surrogate-assisted evolutionary algorithm with dynamic transition criterion for production optimization**.

## Description

TSSAEA-DTC is a surrogate-assisted evolutionary optimization framework for computationally expensive reservoir production optimization. It coordinates two complementary search strategies within a unified exact-evaluation budget:

- **GSA-SLPSO** performs diversity-oriented global exploration using a global Gaussian radial basis function network (RBFN) trained with the evaluated database.
- **SA-MPDE** performs convergence-oriented local exploitation using the best evaluated samples and multiple population search mechanisms.
- **DTC** dynamically selects the search stage according to simulator-confirmed net present value (NPV) improvement and the remaining evaluation budget.

The framework integrates experimental configuration, evaluated-database management, surrogate modelling, strategy scheduling, exact reservoir simulation, dynamic transition, convergence recording, and result storage.

## Algorithm framework

1. Generate or load the initial Latin hypercube sampling database.
2. Construct the Gaussian RBFN surrogate model from simulator-evaluated samples.
3. Perform global exploration using GSA-SLPSO.
4. Evaluate selected production-control candidates using the reservoir simulator and update the database.
5. Apply the dynamic transition criterion to determine the subsequent search stage.
6. Perform local exploitation using SA-MPDE and update the surrogate model iteratively.
7. Continue the two-stage optimization until the exact-evaluation budget is exhausted.
8. Save the convergence history, best production controls, evaluated database, strategy labels, and computational time.

## Repository structure

```text
code/main/Run_ThreeChannel.m       Three-Channel experiment configuration
code/main/RUN_TSSAEA_DTC.m         Ten-run experiment driver and result storage
code/main/TSSAEA_DTC.m             TSSAEA-DTC optimization controller
code/main/algorithm_parameters.m   Algorithm parameters used in the manuscript
code/surrogate/                    Gaussian RBFN fitting and prediction
code/utilities/                    Distance calculation and LHS utilities
three_channel/                     ECLIPSE coupling and objective evaluation
three_channel/model/               Three-Channel reservoir model structure
```

## Usage

- Use MATLAB to open the repository directory.
- Configure the Three-Channel experiment in `code/main/Run_ThreeChannel.m`.
- Configure the ECLIPSE execution command and case directory for the local simulation environment.
- Run `code/main/Run_ThreeChannel.m` to start the ten independent optimization runs.
- The experiment driver stores the convergence histories, best control schemes, evaluated databases, strategy records, algorithm parameters, and computational time in a MATLAB result file.

## Manuscript parameters

- Initial evaluated LHS samples: 200
- Maximum simulator evaluations: 1000
- Independent runs: 10
- GSA-SLPSO population size: 100
- SA-MPDE population size: 50
- Local RBFN training samples: 50
- DE scaling factor and crossover rate: 0.5 and 0.5
- Comprehensive-crossover population size: 5
- Dynamic transition limits: `MinSFs = 3`, `MaxSFs = 20`

## Three-Channel case

The Three-Channel case contains nine producers and four injectors controlled over ten 180-day periods, giving 130 decision variables. Producer bottom-hole pressure is bounded by 3000 and 6000 psi, while injector rate is bounded by 0 and 1500 STB/day. The economic objective uses an oil revenue of 50 USD/STB, a produced-water cost of 5 USD/STB, an injection-water cost of 0 USD/STB, and a zero discount rate.

The reservoir evaluation workflow prepares the production-control schedule, executes the ECLIPSE simulation, reads the RSM summary, calculates NPV, and returns the objective value to the optimization controller. Negative NPV is used internally because the MATLAB controller formulates the problem as minimization.
