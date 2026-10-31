# Sound Change Simulations

This repository extends the simulations of Kirby and Sonderegger (2024) to examine how production bias, social weighting, and a categoricity prior influence sound change across generations. The present simulations adapt the original framework to model F1-based diphthong onset raising rather than contextually conditioned coarticulation.

The simulations are motivated by Labov's (1963) Martha's Vineyard study. Group A represents local speakers exhibiting greater centralization, while Group B represents speakers exhibiting less centralization. Centralization is associated with local identity, motivating a social preference for Group A's speech.

## Simulation Conditions

The repository contains three simulation scripts:

| Script | Production Bias | Social Weighting | Categoricity Prior |
|---|---|---|---|
| `production_social.R` | ON | ON | OFF |
| `social_only.R` | OFF | ON | OFF |
| `categoricity_social.R` | OFF | ON | ON |

### `production_social.R`

Examines the combined effects of production bias and group-based social weighting without a categoricity prior. Learners estimate the phonetic shift parameter using the unconstrained naive learning algorithm, with normalized social weights applied to observed F1 values. Production bias introduces an additional directional shift in phonetic production.

### `social_only.R`

Examines the effects of group-based social weighting alone, without production bias or a categoricity prior. Learners use the same unconstrained estimation procedure as in `production_social.R`.

### `categoricity_social.R`

Examines the interaction between group-based social weighting and a quadratic categoricity prior, without production bias. Learners estimate the phonetic shift parameter through bounded maximum a posteriori (MAP) estimation using a 1-Hz grid search.

The quadratic prior favors the endpoints of an F1-based vowel-height continuum defined by a canonical low-vowel reference (730 Hz) and a high-vowel reference (300 Hz). These reference values determine the bounds of the shift parameter rather than separately modeled vowel categories. No additional preferred value is assigned to the intermediate vowel /e/.

## Model Parameters

Across all three configurations, the phonetic shift parameter \(p\) represents the degree of F1-based vowel raising, with expected F1 given by \(E[y\mid p]=\mu_A-p\).

The simulations use two social groups with different initial distributions of \(p\). Group A is initialized with a mean shift of 30 Hz and Group B with a mean shift of 10 Hz, both with a standard deviation of 10 Hz.

Both groups have a cross-group exposure probability of 0.2. Social weights are configured to favor Group A's speech, with `aWeight = 0.7` and `bWeight = 0.3`. These weights are normalized for each learner before being applied to the phonetic observations.

In the two configurations without a categoricity prior, `muCentral = 530` Hz is used solely to define the visualization interval. In the categoricity-prior configuration, `muI = 300` Hz defines the high-vowel F1 reference, yielding a bounded MAP search interval of 0–430 Hz.

## Running the Simulations

Each script can be executed independently from the terminal:

```bash
Rscript production_social.R
Rscript social_only.R
Rscript categoricity_social.R
```

Each simulation generates plots of the phonetic shift parameter distribution, mean and standard deviation, and quantile-based spread, saved in a condition-specific subdirectory under `plots/`.

## Plotting Functions

The scripts use `ksPlots_lsa2015.R`, available from the [original OSF repository](https://osf.io/b7sgq/overview). Download the file and place it in the same directory as the simulation scripts.

The following visualizations are generated:

- `densityPlot()`: Probability density of the phonetic shift parameter across generations.
- `meanSdPlot()`: Mean phonetic shift parameter ± 1.96 standard deviations.
- `spreadPlot()`: Median and 5th–95th percentile range.

For the latter two plots, Group A and Group B are displayed in separate panels using `facet_wrap(~group)`.

## References

Labov, W. (1963). The social motivation of a sound change. *Word, 19*(3), 273–309.

Kirby, J., & Sonderegger, M. (2024). Actuation without production bias.