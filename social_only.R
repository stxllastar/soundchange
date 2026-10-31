# social_only.R
# Production bias OFF + social weighting BY GROUP ON + categoricity prior OFF.

# Following the Martha's Vineyard case (Labov, 1963):
# Group A represents local speakers exhibiting greater centralization,
# while Group B represents speakers exhibiting less centralization.
# Centralization is associated with local identity, motivating
# a social preference for Group A's speech.

runSim <- function(nGens = 250, nExamples = 100, nLearners = 1000,
                   bProportion = 0.5, bWeight = 0.5, aWeight = 0.5,
                   aProb = 0, bProb = 0,
                   muA = 730, sigA = 50, muCentral = 530,
                   teachers = "all", initialDist = "gaussian",
                   distParams = list(pMuStart = 10, pSigStart = 10, pMuOffset = 0),
                   algorithm = "simple", storeIvl = 5, seed = NULL) {
  if (!is.null(seed)) set.seed(seed)
  stopifnot(nGens >= 1, nGens == as.integer(nGens),
            nExamples >= 1, nExamples == as.integer(nExamples),
            nLearners >= 2, nLearners == as.integer(nLearners),
            bProportion > 0, bProportion < 1,
            aProb >= 0, aProb <= 1, bProb >= 0, bProb <= 1,
            aWeight >= 0, aWeight <= 1, bWeight >= 0, bWeight <= 1,
            muA > muCentral, sigA > 0,
            teachers == "all", initialDist == "gaussian",
            algorithm == "simple", storeIvl >= 1,
            all(c("pMuStart", "pSigStart", "pMuOffset") %in% names(distParams)),
            distParams$pSigStart >= 0)

  bSize <- nLearners * bProportion
  aSize <- nLearners - bSize
  stopifnot(aSize == as.integer(aSize), bSize == as.integer(bSize),
            aSize >= 2, bSize >= 2)

  # p represents the degree of F1-based vowel raising in Hz:
  # E[y | p] = muA - p.
  # muCentral defines the upper limit of the visualization interval
  # for p through muA - muCentral.
  groupA <- rnorm(aSize, distParams$pMuStart, distParams$pSigStart)
  groupB <- rnorm(bSize, distParams$pMuStart + distParams$pMuOffset,
                  distParams$pSigStart)

  summarize <- function(p, t, group) {
    data.frame(t = t, group = group, mean = mean(p), sd = sd(p),
               q05 = unname(quantile(p, 0.05)),
               q25 = unname(quantile(p, 0.25)),
               q50 = unname(quantile(p, 0.50)),
               q75 = unname(quantile(p, 0.75)),
               q95 = unname(quantile(p, 0.95)))
  }
  get_density <- function(p, t) {
    d <- density(p, from = 0, to = muA - muCentral)
    data.frame(t = t, p = d$x, probDist = d$y)
  }

  summaries <- vector("list", nGens + 1L)
  densities <- list("0" = get_density(c(groupA, groupB), 0))
  summaries[[1]] <- rbind(summarize(groupA, 0, "A"),
                          summarize(groupB, 0, "B"))
  storeIts <- unique(c(seq.int(storeIvl, nGens, by = storeIvl), nGens))

  # Group-specific exposure and prestige follow sampleGroupA/B:
  # A learner: P(B source) = bProb, weights A=1-bWeight, B=bWeight.
  # B learner: P(A source) = aProb, weights A=aWeight, B=1-aWeight.
  learn_group <- function(nStudents, ownP, otherP, crossProb,
                          ownWeight, crossWeight) {
    vapply(seq_len(nStudents), function(j) {
      cross <- rbinom(nExamples, 1, crossProb) == 1L
      nCross <- sum(cross)
      nOwn <- nExamples - nCross
      examplePs <- c(sample(ownP, nOwn, replace = TRUE),
                     sample(otherP, nCross, replace = TRUE))
      wVec <- c(rep(ownWeight, nOwn), rep(crossWeight, nCross))
      y <- rnorm(nExamples, mean = muA - examplePs, sd = sigA)
 
    # No production bias or categoricity prior.
    # Following the naive learning algorithm, estimate p using
    # the unconstrained MLE with normalized social weights:
    #   p_hat = muA - mean(weights * y).
      if (sum(wVec) <= 0) stop("All sampled social weights are zero")
      weights <- length(y) * wVec / sum(wVec)
      y <- weights * y
      muA - mean(y)
    }, numeric(1))
  }

  for (t in seq_len(nGens)) {
    nextA <- learn_group(aSize, groupA, groupB, bProb,
                         1 - bWeight, bWeight)
    nextB <- learn_group(bSize, groupB, groupA, aProb,
                         1 - aWeight, aWeight)
    summaries[[t + 1L]] <- rbind(summarize(nextA, t, "A"),
                                  summarize(nextB, t, "B"))
    if (t %in% storeIts)
      densities[[as.character(t)]] <- get_density(c(nextA, nextB), t)
    groupA <- nextA
    groupB <- nextB
  }

  summaryStatsDf <- do.call(rbind, summaries)
  rownames(summaryStatsDf) <- NULL
  densityDf <- do.call(rbind, densities)
  rownames(densityDf) <- NULL
  densityDf$cumDist <- ave(densityDf$probDist, densityDf$t,
                            FUN = function(x) cumsum(x) / sum(x))
  simParamsDf <- data.frame(nGens, nExamples, nLearners, bProportion,
                            aProb, bProb, aWeight, bWeight,
                            muA, sigA, muCentral, teachers,
                            initialDist, algorithm, storeIvl,
                            pMuStart = distParams$pMuStart,
                            pSigStart = distParams$pSigStart,
                            pMuOffset = distParams$pMuOffset)
  list(summaryStatsDf = summaryStatsDf,
       densityDf = densityDf,
       simParamsDf = simParamsDf)
}

result <- runSim(
  nGens = 250,
  nLearners = 1000,
  aProb = 0.2,
  bProb = 0.2,
  aWeight = 0.7,
  bWeight = 0.3,
  distParams = list(
    pMuStart = 30,
    pSigStart = 10,
    pMuOffset = -20
  ),
  seed = 42
)

# Load original plotting functions.
source("ksPlots_lsa2015.R")


dir.create("plots/social_only", recursive = TRUE, showWarnings = FALSE)

ggplot2::ggsave("plots/social_only/density.png",
                densityPlot(result), width = 9, height = 5)

ggplot2::ggsave("plots/social_only/mean.png",
                meanSdPlot(result) + ggplot2::facet_wrap(~group),
                width = 9, height = 4)

ggplot2::ggsave("plots/social_only/spread.png",
                spreadPlot(result) + ggplot2::facet_wrap(~group),
                width = 9, height = 4)
