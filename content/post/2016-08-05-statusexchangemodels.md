---
title: Measuring Status Exchange
author: Aaron Gullickson
date: '2016-08-05'
slug: statusexchangemodels
categories: []
tags: [status exchange, modeling, intermarriage, R]
subtitle: ''
summary: 'Code for measuring status exchange in R'
lastmod: '2016-08-05T11:17:18-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
---

There has been a lot of interest in the log-linear methods used to measure exchange in [my 2006 Demography article](http://link.springer.com/article/10.1353/dem.2006.0033#page-1) and in my [2014 Demography article](http://link.springer.com/article/10.1007/s13524-014-0300-2) with [Florencia Torche](https://sociology.stanford.edu/people/florencia-torche). However, many people have expressed that the methods seem complex. In an effort to help people understand these models, I am providing here some basic code written in R that sets up the "market" and "dyadic" exchange models that we fit in Gullickson and Torche (2014).

I run the models on some [1990 census data](/other/usmardata1990.csv) that I had lying around, although I can't verify how representative that data is, so the results here should not be used to draw conclusions. I also include some models to show that Rosenfeld's proposed model corrections (namely conrtrolling for all two and three-way interaction terms) lead to perfect collinearity and are therefore bad models. I also show how to do the geometric mean models we discussed in the [appendix](/other/intermar_appendix.pdf) to the the Gullickson and Torche paper.

For those who prefer Stata, I also provide some commented [Stata code](/other/statusexchangemodels.do) that will do the same thing. The Stata code requires the installation of the desmat library to deal with all the interaction terms. Personally, I recommend the R code if you know R, but they should produce the same results.

# The Data

The data used here is a 2x2x4x4 table (flattened) of husband's race (HR) by wife's race (WR) by  husband's education (HE) by wife's education (WE). Race is white (1) and black (2). Education is less than high school (1), high school (2), some college (3), and college+ (4). The data come from the US Census 1990, but PLEASE NOTE that I found this data lying around in and cannot vouch for its completeness or representativeness. It is being used for demonstrative purposes and inferences and conclusions should not be drawn from it


```r
mardata <- read.csv("usmardata1990.csv")
```

# Dyadic Exchange Terms

I simply code a set of dummy variables for cases of non-homogamy among interracial couples.  This is coded separately by the gender combination of the couple (BM/WF vs. WM/BF) and whether it implies upward or downward marriage for the black partner (not the woman).


```r
mardata$SEBMWFUp <- mardata$HE>mardata$WE & mardata$HR==2 & mardata$WR==1
mardata$SEBMWFDown <- mardata$HE<mardata$WE & mardata$HR==2 & mardata$WR==1
mardata$SEWMBFUp <- mardata$WE>mardata$HE & mardata$HR==1 & mardata$WR==2
mardata$SEWMBFDown <- mardata$WE<mardata$HE & mardata$HR==1 & mardata$WR==2
```

I also code symmetric terms, that assume the same upward and downward effect.


```r
mardata$SEBMWF <- 0
mardata$SEBMWF[mardata$HE>mardata$WE & mardata$HR==2 & mardata$WR==1] <- 1
mardata$SEBMWF[mardata$HE<mardata$WE & mardata$HR==2 & mardata$WR==1] <- -1
mardata$SEWMBF <- 0
mardata$SEWMBF[mardata$HE<mardata$WE & mardata$HR==1 & mardata$WR==2] <- 1
mardata$SEWMBF[mardata$HE>mardata$WE & mardata$HR==1 & mardata$WR==2] <- -1
```

Here is the most parsimonious term which assumes both directional symmetry and identical effects for BM/WF and WM/BF couples.


```r
mardata$SE <- mardata$SEBMWF+mardata$SEWMBF
```

# Market Exchange Terms

These terms are synonomous with the educational boundary terms in Gullickson (2006) which are themselves very similar to the terms used by [Fu (2001)](http://link.springer.com/article/10.1353/dem.2001.0011). As I will show below these terms are  actually identical to fitting the three way HRxWRxHE and HRxWRxHE (and lower ordered HRxWE and WRxHE) tables, but this particular coding scheme makes the results more interpretable.I use "stairstep" coding here, such that each level of education gets the effect for that level PLUS the effect for lower levels. Using this technique means that each coefficient measures the difference between adjacent levels of education (e.g. college vs. some college) rather than between that level and a fixed reference (e.g. college vs. less than high school). I also included a commented out more traditional dummy formulation for users that prefer that style.

Each term here can be thought of as the increase in the likelihood of interracial marriage when education increases by one level for each race-gender type (i.e. black men, black women,white men, white women).


```r
mardata$EBBM1 <- mardata$HE>1 & mardata$HR==2 & mardata$WR==1
mardata$EBBM2 <- mardata$HE>2 & mardata$HR==2 & mardata$WR==1
mardata$EBBM3 <- mardata$HE>3 & mardata$HR==2 & mardata$WR==1

mardata$EBWF1 <- mardata$WE>1 & mardata$HR==2 & mardata$WR==1
mardata$EBWF2 <- mardata$WE>2 & mardata$HR==2 & mardata$WR==1
mardata$EBWF3 <- mardata$WE>3 & mardata$HR==2 & mardata$WR==1

mardata$EBWM1 <- mardata$HE>1 & mardata$HR==1 & mardata$WR==2
mardata$EBWM2 <- mardata$HE>2 & mardata$HR==1 & mardata$WR==2
mardata$EBWM3 <- mardata$HE>3 & mardata$HR==1 & mardata$WR==2

mardata$EBBF1 <- mardata$WE>1 & mardata$HR==1 & mardata$WR==2
mardata$EBBF2 <- mardata$WE>2 & mardata$HR==1 & mardata$WR==2
mardata$EBBF3 <- mardata$WE>3 & mardata$HR==1 & mardata$WR==2
```

# Geometric mean of HExWE

One of Rosenfeld's criticisms of prior research is that it did not correctly account for lower-order interaction terms when estimating the status exchange parameter. He argues that the status exchange term is a parameterized coding of the HExWExHRxWR table and thus it is necessary to fit all the three-way and two-way interactions. This includes HRxWRxHE, HRxWRxWE, HRxHExWE, WRxHExWE, HRxWE, and WRxHE. As the appendix to Gullickson and Torche (2014) makes clear, Rosenfeld is wrong about the nature of the dyadic status exchange term. It is actually a parameterized coding of the HExWExHR and HExWExWR tables. As a result, when Rosenfeld includes these terms, his models are overfit, as I will show below. The HRxWRxHE and HRxWRxWE tables are also identical to the market exchange terms coded here which can be thought of as an alternate way of measuring exchange rather than a nuisance control term. For more details, see Gullickson and Torche (2014) and the appendix, [Gullickson and Fu (2010)](http://www.jstor.org/stable/10.1086/649049), and [Kalmijn (2010)](http://www.jstor.org/stable/10.1086/649050?seq=1#page_scan_tab_contents).

Despite this inherent problems. Rosenfeld's criticism does reveal one potential shortcoming of the way thesemodels are estimated. When estimating how different the educational assorative mating is for interracial couples (i.e. whether status exchange is occurring), interracial couples are implicitly being compared to the pooled tabled for white and black endogamous couples. But if white and black couples themselves differ in their patterns of ed assortative mating, then the results may be misleading. Probably the best way to handle this is that suggested by [Kalmijn (1993)](http://sf.oxfordjournals.org/content/72/1/119.short) in which the baseline assumption about the educational assortative mating of black/white couples is taken as the geometric mean of the educational asortative mating (HExWE) of white and black endogamous couples. Gullickson and Torche (2014) discusses this in more detail (particularly the appendix). Ultimately we found the results to be similar using the geometric mean (and a few other specifications) as the more naive approach, but it is worth testing on a data set specific basis.

The way of coding this geometric mean is a bit tedious. I fit dummies for each of the nine terms in the HExWE table separately for white endogmous and black endogamous couples and then allow interracial couples to be a 0.5 on each dummy.


```r
mardata$WWHEWE1 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==2 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==2)
mardata$WWHEWE2 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==2 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==3)
mardata$WWHEWE3 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==2 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==4)
mardata$WWHEWE4 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==3 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==2)
mardata$WWHEWE5 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==3 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==3)
mardata$WWHEWE6 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==3 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==4)
mardata$WWHEWE7 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==4 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==2)
mardata$WWHEWE8 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==4 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==3)
mardata$WWHEWE9 <- (mardata$HR==1 & mardata $WR==1 & mardata $HE==4 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==4)

mardata$BBHEWE1 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==2 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==2)
mardata$BBHEWE2 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==2 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==3)
mardata$BBHEWE3 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==2 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==2 & mardata $WE==4)
mardata$BBHEWE4 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==3 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==2)
mardata$BBHEWE5 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==3 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==3)
mardata$BBHEWE6 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==3 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==3 & mardata $WE==4)
mardata$BBHEWE7 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==4 & mardata $WE==2) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==2)
mardata$BBHEWE8 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==4 & mardata $WE==3) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==3)
mardata$BBHEWE9 <- (mardata$HR==2 & mardata $WR==2 & mardata $HE==4 & mardata $WE==4) + 0.5 * (((mardata $HR==1 & mardata $WR==2) | (mardata $HR==2 & mardata $WR==1))  & mardata $HE==4 & mardata $WE==4)
```

Make sure R treats these as categories and not numbers:


```r
mardata$HE <- as.factor(mardata$HE)
mardata$WE <- as.factor(mardata$WE)
mardata$HR <- as.factor(mardata$HR)
mardata$WR <- as.factor(mardata$WR)
```

# The Models

I first run a baseline model which just fits a general term for racial and educational homogamy (HRxWR and HExWE) as well as account for the differential distribution of education by  race (HExHR and WExWR). This model also fits the four marginal terms themselves, of course. Then I fit separate dyadic and market exchange models, plus one that combines them both together. I also run a model with just the straight three way interactions of HRxWRxHE and  HRxWRxWE (model.compare) to show that this model is identical to the market exchange model.


```r
model.base <- glm(Freq~HR*WR+HE*HR+WE*WR+HE*WE, family=poisson, data=mardata)

#dyadic - full symmetry in terms of up/down and couple type
model.dyadic.symmetry <- update(model.base, .~.+SE)
round(summary(model.dyadic.symmetry)$coef["SE",],3)
```

```
##   Estimate Std. Error    z value   Pr(>|z|)
##      0.181      0.029      6.281      0.000
```

```r
#dyadic - relax symmetry on couple type but not up/down
model.dyadic.partialsym <- update(model.base, .~.+SEBMWF+SEWMBF)
round(summary(model.dyadic.partialsym)$coef[c("SEBMWF","SEWMBF"),],3)
```

```
##        Estimate Std. Error z value Pr(>|z|)
## SEBMWF    0.206      0.034   6.130    0.000
## SEWMBF    0.111      0.056   1.967    0.049
```

```r
#dyadic - full model allowing different up/down and couple type
model.dyadic.full <- update(model.base, .~.+SEBMWFUp+SEBMWFDown+SEWMBFUp+SEWMBFDown)
round(summary(model.dyadic.full)$coef[c("SEBMWFUpTRUE","SEBMWFDownTRUE","SEWMBFUpTRUE","SEWMBFDownTRUE"),],3)
```

```
##                Estimate Std. Error z value Pr(>|z|)
## SEBMWFUpTRUE      0.311      0.055   5.605    0.000
## SEBMWFDownTRUE   -0.095      0.057  -1.664    0.096
## SEWMBFUpTRUE      0.035      0.092   0.382    0.703
## SEWMBFDownTRUE   -0.197      0.101  -1.948    0.051
```

```r
model.market<- update(model.base, .~.+EBBM1+EBBM2+EBBM3+EBWF1+EBWF2+EBWF3
									 +EBWM1+EBWM2+EBWM3+EBBF1+EBBF2+EBBF3)
round(summary(model.market)$coef[paste("EBBM",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBBM1TRUE    0.065      0.092   0.706    0.480
## EBBM2TRUE    0.475      0.057   8.275    0.000
## EBBM3TRUE    0.156      0.075   2.076    0.038
```

```r
round(summary(model.market)$coef[paste("EBWF",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBWF1TRUE   -0.327      0.086  -3.825    0.000
## EBWF2TRUE    0.062      0.057   1.093    0.274
## EBWF3TRUE   -0.118      0.072  -1.645    0.100
```

```r
round(summary(model.market)$coef[paste("EBWM",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBWM1TRUE   -0.108      0.162  -0.668    0.504
## EBWM2TRUE    0.290      0.098   2.963    0.003
## EBWM3TRUE   -0.386      0.110  -3.511    0.000
```

```r
round(summary(model.market)$coef[paste("EBBF",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBBF1TRUE   -0.039      0.182  -0.214    0.831
## EBBF2TRUE    0.283      0.100   2.834    0.005
## EBBF3TRUE    0.080      0.109   0.737    0.461
```

It can be shown that the market exchange model is just a re-parameterized version of a model with the three-way tables
of HWxWRxHE and HRxWRxWE:


```r
model.compare <- update(model.base, .~.+HR*WR*HE+HR*WR*WE)

#models are the same
anova(model.market, model.compare)
```

```
## Analysis of Deviance Table
##
## Model 1: Freq ~ HR + WR + HE + WE + EBBM1 + EBBM2 + EBBM3 + EBWF1 + EBWF2 +
##     EBWF3 + EBWM1 + EBWM2 + EBWM3 + EBBF1 + EBBF2 + EBBF3 + HR:WR +
##     HR:HE + WR:WE + HE:WE
## Model 2: Freq ~ HR + WR + HE + WE + HR:WR + HR:HE + WR:WE + HE:WE + WR:HE +
##     HR:WE + HR:WR:HE + HR:WR:WE
##   Resid. Df Resid. Dev Df   Deviance
## 1        27     129.31
## 2        27     129.31  0 4.6612e-12
```

I also run a model with both, I think this model is too complex and multicollinear to estimate well for the size of the US data


```r
model.both <- update(model.market, .~.+SEBMWFUp+SEBMWFDown+SEWMBFUp+SEWMBFDown)
summary(model.both)
```

```
##
## Call:
## glm(formula = Freq ~ HR + WR + HE + WE + EBBM1 + EBBM2 + EBBM3 +
##     EBWF1 + EBWF2 + EBWF3 + EBWM1 + EBWM2 + EBWM3 + EBBF1 + EBBF2 +
##     EBBF3 + SEBMWFUp + SEBMWFDown + SEWMBFUp + SEWMBFDown + HR:WR +
##     HR:HE + WR:WE + HE:WE, family = poisson, data = mardata)
##
## Deviance Residuals:
##     Min       1Q   Median       3Q      Max
## -4.2687  -0.6727  -0.0512   0.8401   3.5696
##
## Coefficients:
##                 Estimate Std. Error  z value Pr(>|z|)
## (Intercept)     9.433917   0.008771 1075.539  < 2e-16 ***
## HR2            -5.248402   0.097723  -53.707  < 2e-16 ***
## WR2            -6.592480   0.189743  -34.744  < 2e-16 ***
## HE2             0.123694   0.011866   10.424  < 2e-16 ***
## HE3            -1.107176   0.017309  -63.964  < 2e-16 ***
## HE4            -3.064602   0.041522  -73.806  < 2e-16 ***
## WE2             0.298178   0.011448   26.046  < 2e-16 ***
## WE3            -0.757925   0.015195  -49.880  < 2e-16 ***
## WE4            -2.791104   0.035573  -78.460  < 2e-16 ***
## EBBM1TRUE       0.044220   0.120767    0.366  0.71424
## EBBM2TRUE       0.440828   0.100567    4.383 1.17e-05 ***
## EBBM3TRUE       0.132652   0.110613    1.199  0.23043
## EBWF1TRUE      -0.286336   0.114631   -2.498  0.01249 *
## EBWF2TRUE       0.095140   0.101745    0.935  0.34975
## EBWF3TRUE      -0.092201   0.107721   -0.856  0.39204
## EBWM1TRUE       0.037637   0.207485    0.181  0.85606
## EBWM2TRUE       0.463988   0.177990    2.607  0.00914 **
## EBWM3TRUE      -0.199226   0.188281   -1.058  0.29000
## EBBF1TRUE      -0.205636   0.225675   -0.911  0.36219
## EBBF2TRUE       0.106623   0.176812    0.603  0.54649
## EBBF3TRUE      -0.104977   0.186340   -0.563  0.57319
## SEBMWFUpTRUE    0.129040   0.113272    1.139  0.25462
## SEBMWFDownTRUE  0.054126   0.115582    0.468  0.63958
## SEWMBFUpTRUE    0.166370   0.199566    0.834  0.40447
## SEWMBFDownTRUE -0.290923   0.204039   -1.426  0.15392
## HR2:WR2         9.415216   0.214532   43.887  < 2e-16 ***
## HR2:HE2        -0.009614   0.020975   -0.458  0.64671
## HR2:HE3        -0.161524   0.022436   -7.199 6.05e-13 ***
## HR2:HE4        -0.946840   0.027690  -34.194  < 2e-16 ***
## WR2:WE2        -0.003369   0.023034   -0.146  0.88372
## WR2:WE3         0.215772   0.023881    9.035  < 2e-16 ***
## WR2:WE4         0.052217   0.028100    1.858  0.06313 .
## HE2:WE2         1.493872   0.014242  104.892  < 2e-16 ***
## HE3:WE2         1.914786   0.019376   98.825  < 2e-16 ***
## HE4:WE2         2.599609   0.043212   60.159  < 2e-16 ***
## HE2:WE3         1.804567   0.017698  101.967  < 2e-16 ***
## HE3:WE3         3.460550   0.021548  160.597  < 2e-16 ***
## HE4:WE3         4.710513   0.043668  107.871  < 2e-16 ***
## HE2:WE4         2.392793   0.037683   63.499  < 2e-16 ***
## HE3:WE4         4.417645   0.039069  113.073  < 2e-16 ***
## HE4:WE4         7.437631   0.054080  137.529  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for poisson family taken to be 1)
##
##     Null deviance: 1359384.24  on 63  degrees of freedom
## Residual deviance:     123.07  on 23  degrees of freedom
## AIC: 696.5
##
## Number of Fisher Scoring iterations: 4
```


# Rosenfeld Models

I follow rosenfeld's protocol of adding in all of the missing two and three way tables and show that his method leads to collinearity such that terms are dropped from the model. This happens because of collinearity between the HExWExHR and HExWExWR terms and the dyadic exchange term.


```r
model.dyadic.symmetry.rosen <- update(model.dyadic.symmetry, .~.+SE+HR*WR*HE+HR*WR*WE+HE*WE*HR+HE*WE*WR)
summary(model.dyadic.symmetry.rosen)
```

```
##
## Call:
## glm(formula = Freq ~ HR + WR + HE + WE + SE + HR:WR + HR:HE +
##     WR:WE + HE:WE + WR:HE + HR:WE + HR:WR:HE + HR:WR:WE + HR:HE:WE +
##     WR:HE:WE, family = poisson, data = mardata)
##
## Deviance Residuals:
##      Min        1Q    Median        3Q       Max
## -2.00114  -0.11134   0.00007   0.09103   0.86440
##
## Coefficients: (1 not defined because of singularities)
##              Estimate Std. Error  z value Pr(>|z|)
## (Intercept)  9.442819   0.008901 1060.919  < 2e-16 ***
## HR2         -5.515703   0.132445  -41.645  < 2e-16 ***
## WR2         -6.459140   0.189711  -34.047  < 2e-16 ***
## HE2          0.110730   0.012251    9.038  < 2e-16 ***
## HE3         -1.124848   0.017972  -62.588  < 2e-16 ***
## HE4         -3.105487   0.042970  -72.272  < 2e-16 ***
## WE2          0.286471   0.011776   24.327  < 2e-16 ***
## WE3         -0.773848   0.015838  -48.860  < 2e-16 ***
## WE4         -2.831289   0.037708  -75.084  < 2e-16 ***
## SE          -0.238405   0.513277   -0.464 0.642306
## HR2:WR2      9.445999   0.205511   45.963  < 2e-16 ***
## HR2:HE2      0.799361   0.513035    1.558 0.119209
## HR2:HE3      1.024105   0.482226    2.124 0.033695 *
## HR2:HE4      0.728863   0.695441    1.048 0.294611
## WR2:WE2     -0.067885   0.574681   -0.118 0.905968
## WR2:WE3      0.278550   0.584551    0.477 0.633704
## WR2:WE4      0.952901   0.977790    0.975 0.329786
## HE2:WE2      1.508189   0.014876  101.383  < 2e-16 ***
## HE3:WE2      1.941309   0.020216   96.028  < 2e-16 ***
## HE4:WE2      2.637738   0.044730   58.971  < 2e-16 ***
## HE2:WE3      1.828234   0.018611   98.234  < 2e-16 ***
## HE3:WE3      3.484150   0.022600  154.163  < 2e-16 ***
## HE4:WE3      4.757091   0.045287  105.044  < 2e-16 ***
## HE2:WE4      2.440390   0.039969   61.057  < 2e-16 ***
## HE3:WE4      4.460603   0.041393  107.762  < 2e-16 ***
## HE4:WE4      7.511727   0.056616  132.678  < 2e-16 ***
## WR2:HE2     -0.740162   0.517347   -1.431 0.152520
## WR2:HE3     -0.279076   0.479371   -0.582 0.560452
## WR2:HE4     -0.453587   0.710676   -0.638 0.523313
## HR2:WE2     -0.090518   0.566985   -0.160 0.873158
## HR2:WE3      0.148923   0.578828    0.257 0.796959
## HR2:WE4     -0.467346   0.976898   -0.478 0.632367
## HR2:WR2:HE2  0.075881   0.190844    0.398 0.690921
## HR2:WR2:HE3 -0.688182   0.194748   -3.534 0.000410 ***
## HR2:WR2:HE4 -0.465144   0.217321   -2.140 0.032326 *
## HR2:WR2:WE2  0.288773   0.206524    1.398 0.162037
## HR2:WR2:WE3 -0.049173   0.209064   -0.235 0.814048
## HR2:WR2:WE4 -0.018368   0.230452   -0.080 0.936474
## HR2:HE2:WE2 -0.687546   0.191297   -3.594 0.000325 ***
## HR2:HE3:WE2 -0.316237   0.625629   -0.505 0.613229
## HR2:HE4:WE2 -0.571651   0.752693   -0.759 0.447569
## HR2:HE2:WE3 -1.112013   0.534309   -2.081 0.037414 *
## HR2:HE3:WE3 -0.740565   0.252233   -2.936 0.003324 **
## HR2:HE4:WE3 -0.797097   0.751690   -1.060 0.288960
## HR2:HE2:WE4 -0.439894   0.267458   -1.645 0.100027
## HR2:HE3:WE4 -0.451155   0.128731   -3.505 0.000457 ***
## HR2:HE4:WE4 -0.602608   0.680483   -0.886 0.375855
## WR2:HE2:WE2  0.529706   0.194919    2.718 0.006576 **
## WR2:HE3:WE2 -0.019024   0.632898   -0.030 0.976020
## WR2:HE4:WE2 -0.062874   0.765853   -0.082 0.934570
## WR2:HE2:WE3  0.873657   0.534613    1.634 0.102220
## WR2:HE3:WE3  0.473865   0.258185    1.835 0.066451 .
## WR2:HE4:WE3  0.012654   0.764538    0.017 0.986794
## WR2:HE2:WE4 -0.060050   0.244462   -0.246 0.805960
## WR2:HE3:WE4        NA         NA       NA       NA
## WR2:HE4:WE4 -0.521754   0.692958   -0.753 0.451488
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for poisson family taken to be 1)
##
##     Null deviance: 1.3594e+06  on 63  degrees of freedom
## Residual deviance: 1.5464e+01  on  9  degrees of freedom
## AIC: 616.89
##
## Number of Fisher Scoring iterations: 4
```

The same holds for the other dyadic models but I don't show them for brevity

I show that dropping out HExWExHR and HExWExWR resolves the problem.


```r
model.dyadic.symmetry2 <- update(model.dyadic.symmetry.rosen, .~.-HE*WE*HR-HE*WE*WR+HE*WE+HR*HE+WR*WE)
summary(model.dyadic.symmetry2)
```

```
##
## Call:
## glm(formula = Freq ~ SE + HE + WE + HR + WR + HR:WR + HE:WE +
##     HR:HE + WR:WE + HR:WR:HE + HR:WR:WE, family = poisson, data = mardata)
##
## Deviance Residuals:
##     Min       1Q   Median       3Q      Max
## -4.2768  -0.6448  -0.0025   0.9059   3.5663
##
## Coefficients:
##               Estimate Std. Error  z value Pr(>|z|)
## (Intercept)  9.4336620  0.0087707 1075.582   <2e-16 ***
## SE           0.0896727  0.0921363    0.973   0.3304
## HE2          0.1240076  0.0118625   10.454   <2e-16 ***
## HE3         -1.1064333  0.0173026  -63.946   <2e-16 ***
## HE4         -3.0637522  0.0415174  -73.794   <2e-16 ***
## WE2          0.2986655  0.0114452   26.095   <2e-16 ***
## WE3         -0.7577437  0.0151914  -49.880   <2e-16 ***
## WE4         -2.7912246  0.0355690  -78.473   <2e-16 ***
## HR2         -5.1859816  0.0913501  -56.770   <2e-16 ***
## WR2         -6.6378141  0.1833072  -36.211   <2e-16 ***
## HR2:WR2      9.3981456  0.2059242   45.639   <2e-16 ***
## HE2:WE2      1.4931995  0.0142350  104.896   <2e-16 ***
## HE3:WE2      1.9139129  0.0193652   98.832   <2e-16 ***
## HE4:WE2      2.5988140  0.0432090   60.145   <2e-16 ***
## HE2:WE3      1.8045918  0.0176897  102.014   <2e-16 ***
## HE3:WE3      3.4596951  0.0215402  160.616   <2e-16 ***
## HE4:WE3      4.7097796  0.0436655  107.861   <2e-16 ***
## HE2:WE4      2.3927802  0.0376795   63.503   <2e-16 ***
## HE3:WE4      4.4175471  0.0390664  113.078   <2e-16 ***
## HE4:WE4      7.4370806  0.0540787  137.523   <2e-16 ***
## HE2:HR2     -0.0116255  0.1134661   -0.102   0.9184
## HE3:HR2      0.2408140  0.1694825    1.421   0.1554
## HE4:HR2     -0.4581314  0.2400019   -1.909   0.0563 .
## WE2:WR2     -0.1067811  0.1921746   -0.556   0.5785
## WE3:WR2      0.3248699  0.2278745    1.426   0.1540
## WE4:WR2      0.1699295  0.2906272    0.585   0.5587
## HE2:HR1:WR2 -0.0480788  0.1739408   -0.276   0.7822
## HE3:HR1:WR2  0.3128585  0.2135509    1.465   0.1429
## HE4:HR1:WR2  0.0006849  0.2793518    0.002   0.9980
## HE2:HR2:WR2  0.0020019  0.1150646    0.017   0.9861
## HE3:HR2:WR2 -0.4022965  0.1707187   -2.356   0.0184 *
## HE4:HR2:WR2 -0.4886577  0.2413877   -2.024   0.0429 *
## WE2:HR2:WR1 -0.2614800  0.1092373   -2.394   0.0167 *
## WE3:HR2:WR1 -0.1269414  0.1681540   -0.755   0.4503
## WE4:HR2:WR1 -0.1754218  0.2377134   -0.738   0.4605
## WE2:HR2:WR2  0.1034074  0.1933343    0.535   0.5927
## WE3:HR2:WR2 -0.1091439  0.2289138   -0.477   0.6335
## WE4:HR2:WR2 -0.1178039  0.2917812   -0.404   0.6864
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for poisson family taken to be 1)
##
##     Null deviance: 1359384.24  on 63  degrees of freedom
## Residual deviance:     128.37  on 26  degrees of freedom
## AIC: 695.79
##
## Number of Fisher Scoring iterations: 4
```

The resulting model is equivalent to a model with both a dyadic and market exchange term


```r
model.equivalent <- update(model.market, .~.+SE)

#models are the same
anova(model.dyadic.symmetry2, model.equivalent)
```

```
## Analysis of Deviance Table
##
## Model 1: Freq ~ SE + HE + WE + HR + WR + HR:WR + HE:WE + HR:HE + WR:WE +
##     HR:WR:HE + HR:WR:WE
## Model 2: Freq ~ HR + WR + HE + WE + EBBM1 + EBBM2 + EBBM3 + EBWF1 + EBWF2 +
##     EBWF3 + EBWM1 + EBWM2 + EBWM3 + EBBF1 + EBBF2 + EBBF3 + SE +
##     HR:WR + HR:HE + WR:WE + HE:WE
##   Resid. Df Resid. Dev Df   Deviance
## 1        26     128.37
## 2        26     128.37  0 1.0829e-11
```


# Geometric Mean Models

Here I just rerun the dyadic and market exchange models with the geometric mean baseline rather than the pooled HE*WE baseline. The results are fairly consistent with what we had before for BM/WF couples, but not WM/BF couples.


```r
model.base.geo <- glm(Freq~HR*WR+HE*HR+WE*WR
			 	      +WWHEWE1+WWHEWE2+WWHEWE3+WWHEWE4+WWHEWE5+WWHEWE6+WWHEWE7+WWHEWE8+WWHEWE9
			 	      +BBHEWE1+BBHEWE2+BBHEWE3+BBHEWE4+BBHEWE5+BBHEWE6+BBHEWE7+BBHEWE8+BBHEWE9,
			 		family=poisson, data=mardata)

model.dyadic.symmetry.geo <- update(model.base.geo, .~.+SE)
round(summary(model.dyadic.symmetry.geo)$coef["SE",],3)
```

```
##   Estimate Std. Error    z value   Pr(>|z|)
##      0.094      0.032      2.909      0.004
```

```r
model.dyadic.partialsym.geo <- update(model.base.geo, .~.+SEBMWF+SEWMBF)
round(summary(model.dyadic.partialsym.geo)$coef[c("SEBMWF","SEWMBF"),],3)
```

```
##        Estimate Std. Error z value Pr(>|z|)
## SEBMWF    0.127      0.037   3.462    0.001
## SEWMBF    0.002      0.059   0.026    0.979
```

```r
model.dyadic.full.geo <- update(model.base.geo, .~.+SEBMWFUp+SEBMWFDown+SEWMBFUp+SEWMBFDown)
round(summary(model.dyadic.full.geo)$coef[c("SEBMWFUpTRUE","SEBMWFDownTRUE","SEWMBFUpTRUE","SEWMBFDownTRUE"),],3)
```

```
##                Estimate Std. Error z value Pr(>|z|)
## SEBMWFUpTRUE      0.228      0.058   3.955    0.000
## SEBMWFDownTRUE   -0.021      0.059  -0.349    0.727
## SEWMBFUpTRUE     -0.084      0.094  -0.889    0.374
## SEWMBFDownTRUE   -0.099      0.103  -0.966    0.334
```

```r
model.market.geo <- update(model.base.geo, .~.+EBBM1+EBBM2+EBBM3+EBWF1+EBWF2+EBWF3
									 +EBWM1+EBWM2+EBWM3+EBBF1+EBBF2+EBBF3)
round(summary(model.market.geo)$coef[paste("EBBM",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBBM1TRUE   -0.023      0.094  -0.245    0.807
## EBBM2TRUE    0.443      0.066   6.758    0.000
## EBBM3TRUE   -0.117      0.115  -1.020    0.308
```

```r
round(summary(model.market.geo)$coef[paste("EBWF",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBWF1TRUE   -0.246      0.087  -2.820    0.005
## EBWF2TRUE    0.072      0.062   1.175    0.240
## EBWF3TRUE    0.012      0.092   0.127    0.899
```

```r
round(summary(model.market.geo)$coef[paste("EBWM",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBWM1TRUE   -0.029      0.163  -0.181    0.856
## EBWM2TRUE    0.321      0.103   3.124    0.002
## EBWM3TRUE   -0.112      0.140  -0.798    0.425
```

```r
round(summary(model.market.geo)$coef[paste("EBBF",1:3,"TRUE", sep=""),],3)
```

```
##           Estimate Std. Error z value Pr(>|z|)
## EBBF1TRUE   -0.105      0.182  -0.576    0.565
## EBBF2TRUE    0.264      0.103   2.574    0.010
## EBBF3TRUE   -0.036      0.122  -0.297    0.767
```

```r
model.both.geo <- update(model.market.geo, .~.+SEBMWFUp+SEBMWFDown+SEWMBFUp+SEWMBFDown)
summary(model.both.geo)
```

```
##
## Call:
## glm(formula = Freq ~ HR + WR + HE + WE + WWHEWE1 + WWHEWE2 +
##     WWHEWE3 + WWHEWE4 + WWHEWE5 + WWHEWE6 + WWHEWE7 + WWHEWE8 +
##     WWHEWE9 + BBHEWE1 + BBHEWE2 + BBHEWE3 + BBHEWE4 + BBHEWE5 +
##     BBHEWE6 + BBHEWE7 + BBHEWE8 + BBHEWE9 + EBBM1 + EBBM2 + EBBM3 +
##     EBWF1 + EBWF2 + EBWF3 + EBWM1 + EBWM2 + EBWM3 + EBBF1 + EBBF2 +
##     EBBF3 + SEBMWFUp + SEBMWFDown + SEWMBFUp + SEWMBFDown + HR:WR +
##     HR:HE + WR:WE, family = poisson, data = mardata)
##
## Deviance Residuals:
##      Min        1Q    Median        3Q       Max
## -2.04068  -0.15854  -0.00307   0.08040   1.29960
##
## Coefficients:
##                  Estimate Std. Error  z value Pr(>|z|)
## (Intercept)     9.4424651  0.0089015 1060.771  < 2e-16 ***
## HR2            -5.2992451  0.0992333  -53.402  < 2e-16 ***
## WR2            -6.6419054  0.1916985  -34.648  < 2e-16 ***
## HE2             0.1113715  0.0122500    9.092  < 2e-16 ***
## HE3            -1.1244246  0.0179676  -62.581  < 2e-16 ***
## HE4            -3.1048894  0.0429522  -72.287  < 2e-16 ***
## WE2             0.2869685  0.0117756   24.370  < 2e-16 ***
## WE3            -0.7731030  0.0158353  -48.821  < 2e-16 ***
## WE4            -2.8312119  0.0377131  -75.072  < 2e-16 ***
## WWHEWE1         1.5073958  0.0148737  101.346  < 2e-16 ***
## WWHEWE2         1.8270943  0.0186076   98.191  < 2e-16 ***
## WWHEWE3         2.4401371  0.0399709   61.048  < 2e-16 ***
## WWHEWE4         1.9407072  0.0202114   96.021  < 2e-16 ***
## WWHEWE5         3.4833896  0.0225929  154.181  < 2e-16 ***
## WWHEWE6         4.4603494  0.0413926  107.757  < 2e-16 ***
## WWHEWE7         2.6369640  0.0447113   58.978  < 2e-16 ***
## WWHEWE8         4.7560636  0.0452671  105.067  < 2e-16 ***
## WWHEWE9         7.5114299  0.0566029  132.704  < 2e-16 ***
## BBHEWE1         1.3410881  0.0502215   26.703  < 2e-16 ***
## BBHEWE2         1.5779047  0.0585859   26.933  < 2e-16 ***
## BBHEWE3         1.9362962  0.1155999   16.750  < 2e-16 ***
## BBHEWE4         1.5986861  0.0694740   23.011  < 2e-16 ***
## BBHEWE5         3.2093970  0.0736196   43.594  < 2e-16 ***
## BBHEWE6         4.0051074  0.1216050   32.935  < 2e-16 ***
## BBHEWE7         1.9926851  0.1731084   11.511  < 2e-16 ***
## BBHEWE8         3.9602726  0.1708851   23.175  < 2e-16 ***
## BBHEWE9         6.3820746  0.1947376   32.773  < 2e-16 ***
## EBBM1TRUE      -0.0768475  0.1208813   -0.636 0.524955
## EBBM2TRUE       0.3702178  0.1052368    3.518 0.000435 ***
## EBBM3TRUE      -0.1798681  0.1407477   -1.278 0.201268
## EBWF1TRUE      -0.1700799  0.1153182   -1.475 0.140246
## EBWF2TRUE       0.1432551  0.1023114    1.400 0.161458
## EBWF3TRUE       0.0741508  0.1208766    0.613 0.539584
## EBWM1TRUE       0.0836009  0.2055211    0.407 0.684173
## EBWM2TRUE       0.4612129  0.1771260    2.604 0.009218 **
## EBWM3TRUE       0.0421616  0.2045247    0.206 0.836678
## EBBF1TRUE      -0.2424182  0.2239950   -1.082 0.279142
## EBBF2TRUE       0.1226603  0.1755297    0.699 0.484677
## EBBF3TRUE      -0.1889397  0.1926369   -0.981 0.326688
## SEBMWFUpTRUE    0.1713216  0.1123854    1.524 0.127406
## SEBMWFDownTRUE -0.0002799  0.1147010   -0.002 0.998053
## SEWMBFUpTRUE    0.1163524  0.1968910    0.591 0.554555
## SEWMBFDownTRUE -0.2600328  0.2019226   -1.288 0.197821
## HR2:WR2         9.4082094  0.2166726   43.421  < 2e-16 ***
## HR2:HE2         0.1420302  0.0436537    3.254 0.001140 **
## HR2:HE3         0.0616976  0.0644029    0.958 0.338065
## HR2:HE4        -0.1823256  0.1702354   -1.071 0.284160
## WR2:WE2         0.1358971  0.0421421    3.225 0.001261 **
## WR2:WE3         0.3853543  0.0519410    7.419 1.18e-13 ***
## WR2:WE4         0.4693778  0.1136058    4.132 3.60e-05 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
##
## (Dispersion parameter for poisson family taken to be 1)
##
##     Null deviance: 1.3594e+06  on 63  degrees of freedom
## Residual deviance: 2.6313e+01  on 14  degrees of freedom
## AIC: 617.74
##
## Number of Fisher Scoring iterations: 4
```
