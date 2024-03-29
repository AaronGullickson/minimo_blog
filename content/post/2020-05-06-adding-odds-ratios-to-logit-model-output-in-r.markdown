---
title: Adding Odds Ratios to Logit Model Output in R
author: Aaron Gullickson
date: '2020-05-06'
slug: adding-odds-ratios-to-logit-model-output-in-r
categories: []
tags:
  - R
subtitle: ''
summary: ''
authors: []
lastmod: '2020-05-06T13:49:04-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
mathjax: true
---

I recently received an email from an undergraduate student who had taken my statistics course. This student was working on their undergraduate thesis project in which they were running logit models in *R*. Their thesis adviser had asked them to produce odds ratios which is not reported in the `summary` command for a generalized linear model in *R*. Apparently, the advisor was used to programs like Stata that include the argument `or` to get odds ratios from logit models in the default output.

It is true that *R* does not give you odds ratios by default, but it is fairly easy to derive these values. As an example, I will use the [individual Titanic passenger data](https://github.com/AaronGullickson/combined_stats/tree/master/example_datasets/titanic) that I use for my classes.


```r
load(url("https://github.com/AaronGullickson/combined_stats/blob/master/example_datasets/titanic/titanic.RData?raw=true"))
head(titanic)
```

```
##   survival    sex     age agegroup pclass     fare family
## 1 Survived Female 29.0000    Adult  First 211.3375      0
## 2 Survived   Male  0.9167    Child  First 151.5500      3
## 3     Died Female  2.0000    Child  First 151.5500      3
## 4     Died   Male 30.0000    Adult  First 151.5500      3
## 5     Died Female 25.0000    Adult  First 151.5500      3
## 6 Survived   Male 48.0000    Adult  First  26.5500      0
```

Lets use a model that predicts survival by sex, age, and fare paid.


```r
model <- glm((survival=="Survived")~sex+age+fare, data=titanic, family=binomial)
summary(model)
```

```
## 
## Call:
## glm(formula = (survival == "Survived") ~ sex + age + fare, family = binomial, 
##     data = titanic)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -2.2761  -0.6282  -0.5885   0.8228   2.0294  
## 
## Coefficients:
##              Estimate Std. Error z value Pr(>|z|)    
## (Intercept)  0.859815   0.178120   4.827 1.38e-06 ***
## sex2        -2.325910   0.138566 -16.786  < 2e-16 ***
## age         -0.009065   0.005015  -1.807   0.0707 .  
## fare         0.010026   0.001713   5.854 4.80e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 1741.0  on 1308  degrees of freedom
## Residual deviance: 1323.6  on 1305  degrees of freedom
## AIC: 1331.6
## 
## Number of Fisher Scoring iterations: 4
```

The resulting coefficient estimates are in the form of log odds ratios rather than odds ratios. To convert to odds ratios (and baseline odds for the intercept), we just need to exponentiate the coefficients. We can pull the coefficients out of the model with `coef(model)` and then its just a simple matter to exponentiate them:


```r
exp(coef(model))
```

```
## (Intercept)        sex2         age        fare 
##  2.36272327  0.09769451  0.99097602  1.01007658
```

Holding constant fare and age, men (sex2) had 90% lower odds of surviving the Titanic than women. Holding constant sex and fare, a one year increase in age is associated with about a 1% reduction in the odds of survival. Similarly, holding constant age and sex, a one pound increase in fare paid is associated with a bout a 1% increase in the odds of survival.

I was pleased that my former student had actually figured out how to extract odds ratios using the technique above. However, what they really wanted was a method that included the odds ratio directly in the `summary` of the model. Although *R* does not do this by default, the ability to create custom functions makes it easy to build our own summary command that can do it. 


```r
summary_or <- function(m) {
  s <- summary(m)
  s$coefficients <- cbind(exp(s$coefficients[,1]), s$coefficients)
  colnames(s$coefficients)[1] <- "Odds Ratio"
  return(s)
}
```

This function is basically a wrapper function for the regular summary command. The coefficients object within the summary command is just a matrix of model output. I use the `cbind` command to add a new column at the front for the odds ratio and then use `colnames` to name this column. If I then call up this function instead of `summary` I get:


```r
summary_or(model)
```

```
## 
## Call:
## glm(formula = (survival == "Survived") ~ sex + age + fare, family = binomial, 
##     data = titanic)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -2.2761  -0.6282  -0.5885   0.8228   2.0294  
## 
## Coefficients:
##             Odds Ratio  Estimate Std. Error z value Pr(>|z|)    
## (Intercept)   2.362723  0.859815   0.178120   4.827 1.38e-06 ***
## sex2          0.097695 -2.325910   0.138566 -16.786  < 2e-16 ***
## age           0.990976 -0.009065   0.005015  -1.807   0.0707 .  
## fare          1.010077  0.010026   0.001713   5.854 4.80e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 1741.0  on 1308  degrees of freedom
## Residual deviance: 1323.6  on 1305  degrees of freedom
## AIC: 1331.6
## 
## Number of Fisher Scoring iterations: 4
```

So the lesson here is that while *R* sometimes does not have the easy pre-packaged arguments of other programs, it also empowers users to create their own custom output as they would like to have it. 

## Why you shouldn't report odds ratios anyway

I understand that my student just wants to do what their advisor asked, but personally I am not a big fan of reporting odds ratios rather than log odds ratios. Here is what I explained to the student in my response (along with the code to do it anyway):

> Personally, let me just say that I prefer to see the log-odds ratios for logistic regression models for a couple reasons. First, the sign on the log-odds ratio directly indicates a positive or negative relationship which is the first thing your brain is scanning for when you look at a table of regression coefficients. The extra cognitive work of remembering <1 means negative for an odds ratio is not worth it. Second, when the log-odds ratios are small the effect is easy to interpret as the percentage change. So a log-odds ratio of 0.07 is a 1.0725 odds ratio, so about a 7.25% increase in the odds. The 0.07 gives you a pretty good approximation of that. This logic breaks down when you get values above 0.25 or so, but makes it easy to get a general sense of the strength from the log odds ratio. Third, the standard error from the model is for the log-odds ratio not the odds ratio and you can’t convert it in any meaningful way, so its odd to report it with an odds ratio.
