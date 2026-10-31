# Sound Change Simulations

This repository extends the simulations of Kirby and Sonderegger (2024) to examine how production bias, social weighting, and a categoricity prior influence sound change across generations.

The simulations are motivated by Labov's (1963) Martha's Vineyard study. Group A represents local speakers exhibiting greater centralization, while Group B represents speakers exhibiting less centralization. Social weighting allows learners to assign greater weight to Group A's speech.

## Simulation Conditions

The repository contains three simulation scripts:

| Script | Production Bias | Social Weighting | Categoricity Prior |
|---|---|---|---|
| `production_social.R` | ON | ON | OFF |
| `social_only.R` | OFF | ON | OFF |
| `categoricity_social.R` | OFF | ON | ON |

### `production_social.R`

Examines the combined effects of production bias and group-based social weighting without a categoricity prior. Learners estimate the phonetic shift parameter from observations scaled by normalized social weights, while production bias introduces a directional phonetic shift.

### `social_only.R`

Examines the effects of group-based social weighting alone, without production bias or a categoricity prior.

### `categoricity_social.R`

Examines the interaction between group-based social weighting and a quadratic categoricity prior, without production bias.

The two Gaussian distributions represent social groups rather than vowel categories. The quadratic categoricity prior favors parameter values corresponding to the endpoints of an F1-based vowel-height continuum, approximated by /ɑ/ (low vowel) and /i/ (high vowel), rather than intermediate realizations.

**Caveat:** The endpoints of the categoricity prior should not be equated with the preferred realizations of either social group. Social preference is encoded through group-specific weighting, whereas the categoricity prior is defined independently over the phonetic continuum.

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