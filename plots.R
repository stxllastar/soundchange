
library(ggplot2)

## Functions to visualize results of runSim()

## Mean +/- 1.96 SD
meanSdPlot <- function(resultDf) {
  g <- ggplot(
    data = resultDf$summaryStatsDf,
    aes(x = t, y = mean,
        ymin = mean - 1.96 * sd,
        ymax = mean + 1.96 * sd)
  ) +
    geom_ribbon(alpha = 0.2) +
    geom_line(color = "blue", linewidth = 1) +
    xlab("Generation (t)") +
    ylab("Vowel raising (p): mean +/- 1.96 SD")

  return(g)
}

## Median and 5th-95th percentiles
spreadPlot <- function(resultDf) {
  g <- ggplot(
    data = resultDf$summaryStatsDf,
    aes(x = t, y = q50, ymin = q05, ymax = q95)
  ) +
    geom_ribbon(alpha = 0.2) +
    geom_line(color = "blue", linewidth = 1) +
    xlab("Generation (t)") +
    ylab("Vowel raising (p): 5th-95th percentiles")

  return(g)
}


## Group-specific probability density / cumulative distribution
densityPlot <- function(resultDf, type = "PDF", ylim = NULL) {

  type <- match.arg(type, c("PDF", "CDF"))

  df <- resultDf$densityDf

  if (!"group" %in% names(df)) {
    stop("densityDf must contain a 'group' column.")
  }

  if (type == "PDF") {
    g <- ggplot(df, aes(x = t, y = p, fill = probDist)) +
      geom_raster() +
      scale_fill_gradient(
        low = "white",
        high = "#4B3F99",
        name = "Probability density"
      )
  } else {
    g <- ggplot(df, aes(x = t, y = p, fill = cumDist)) +
      geom_raster() +
      scale_fill_gradient(
        low = "white",
        high = "#4B3F99",
        limits = c(0, 1),
        name = "Cumulative probability"
      )
  }

  g <- g +
    facet_wrap(~group) +
    xlab("Generation (t)") +
    ylab("Degree of vowel raising (p, Hz)") +
    theme_minimal()

  if (!is.null(ylim)) {
    g <- g + coord_cartesian(ylim = ylim)
  }

  return(g)
}



