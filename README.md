# TSSAEA-DTC

MATLAB code associated with the manuscript **Two-strategy surrogate-assisted
evolutionary algorithm with dynamic transition criterion for production
optimization**.

## Description

TSSAEA-DTC coordinates two complementary reservoir-production search
strategies. GSA-SLPSO performs diversity-oriented global exploration using a
global Gaussian RBFN trained with all simulator-evaluated samples. SA-MPDE
performs convergence-oriented local exploitation using the top 50 evaluated
samples and three population update mechanisms. A dynamic transition
criterion switches between the strategies according to simulator-confirmed
NPV improvement and the remaining exact-evaluation budget.

The public controller contains the evaluated database, exact-evaluation
accounting, result recording, and dynamic transition criterion. The
GSA-SLPSO and SA-MPDE strategy operators are connected through the following
method interfaces:

```matlab
[candidateBatch, state] = GSA_SLPSO_core( ...
    historyX, historyF, lowerBound, upperBound, state, ...
    parameters.global, remainingBudget)

[candidateBatch, state] = SA_MPDE_core( ...
    historyX, historyF, lowerBound, upperBound, state, ...
    parameters.local, remainingBudget)
```

## Repository structure

```text
code/main/Run_ThreeChannel.m       Three-Channel experiment configuration
code/main/RUN_TSSAEA_DTC.m         Ten-run experiment driver
code/main/TSSAEA_DTC.m             TSSAEA-DTC controller
code/main/algorithm_parameters.m   Parameters reported in the manuscript
code/surrogate/                    Gaussian RBFN fitting and prediction
code/utilities/                    Distance and LHS utilities
three_channel/                     ECLIPSE objective and result interfaces
three_channel/model/               Three-Channel deck structure
```

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

The case contains nine producers and four injectors controlled over ten
180-day periods, giving 130 decision variables. Producer bottom-hole pressure
is bounded by 3000 and 6000 psi, and injector rate is bounded by 0 and 1500
STB/day. The economic objective uses oil revenue of 50 USD/STB, produced-water
cost of 5 USD/STB, injection-water cost of 0 USD/STB, and a zero discount rate.

`evaluate_three_channel_npv.m` connects the project-specific schedule writer,
the ECLIPSE launcher, and the RSM reader. It returns negative NPV because the
MATLAB optimization controller uses minimization. Place the strategy modules,
schedule writer, evaluated initial databases, and complete simulator case
files on the MATLAB path before running `code/main/Run_ThreeChannel.m`.
