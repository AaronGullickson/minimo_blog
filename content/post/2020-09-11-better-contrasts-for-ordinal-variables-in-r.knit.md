---
title: Better Contrasts for Ordinal Variables in R
author: Aaron Gullickson
date: '2020-09-11'
slug: better-contrasts-for-ordinal-variables-in-r
categories: []
tags:
  - R
subtitle: 'Use stairstep contrasts, tell a friend'
summary: ''
authors: []
lastmod: '2020-09-11T14:07:36-07:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
mathjax: true
---

Social scientists routinely use categorical variables in linear models. In order to do so, we must code these categorical variables into numeric quantities in some fashion. By far the most common method is the dummy/indicator variable approach. In this approach, we create 0/1 variables for each category where 1 indicates membership in the category. We leave out this coding for one category which becomes the reference category. The estimate for each parameter then gives the mean difference between the indicated category and the reference category, all else being equal. This approach is so ubiquitous that many researchers are probably unaware of the many alternatives that exist for how to code categorical variables. Here I want to highlight an alternative method in R for the case of ordinal variables that can be used to produce much more intuitive results.

To illustrate, I will use [data on hourly wages from the Current Population Survey in 2018](https://github.com/AaronGullickson/combined_stats/tree/master/example_datasets/earnings) that I use for my classes. Here is an excerpt of that data.


```r
load(url("https://github.com/AaronGullickson/combined_stats/blob/master/example_datasets/earnings/earnings.RData?raw=true"))
head(earnings[,1:6])
```

```
##   wages age gender  race            marstat        education
## 1 20.84  52 Female Black Divorced/Separated       HS Diploma
## 2 10.00  19 Female Black      Never Married       HS Diploma
## 3 25.00  56 Female Black Divorced/Separated Bachelors Degree
## 4  9.50  22 Female Black      Never Married       HS Diploma
## 5 17.00  48   Male White      Never Married       HS Diploma
## 6 20.00  59   Male Black      Never Married       HS Diploma
```

Lets say I want to examine the relationship between hourly wages and education. I could do this by just looking at the mean wages for each educational group. I like to use `tapply` for these sorts of operations.


```r
wage_means <- tapply(earnings$wages, earnings$education, mean)
knitr::kable(round(wage_means, 2), col.names="mean wages")
```



|                 | mean wages|
|:----------------|----------:|
|No HS Diploma    |      14.26|
|HS Diploma       |      18.67|
|AA Degree        |      21.91|
|Bachelors Degree |      30.76|
|Graduate Degree  |      38.17|

Alternatively, I could use a linear model structure to get the same information. 


```r
model_dummy <- lm(wages~education, data=earnings)
knitr::kable(round(coef(model_dummy), 2), col.names="coefficients")
```



|                          | coefficients|
|:-------------------------|------------:|
|(Intercept)               |        14.26|
|educationHS Diploma       |         4.41|
|educationAA Degree        |         7.65|
|educationBachelors Degree |        16.50|
|educationGraduate Degree  |        23.91|

Because education is coded as a factor variable, the `lm` command knows what to do with it. It has created four separate dummy variables, leaving out the no high school diploma group as my reference. As a result, the intercept is the mean wages for the no high school diploma group, and all of the other numbers give me the difference in mean wages of the given educational group relative to the no high school diploma group. I can see, for example, that individuals with a bachelor's degree make $16.50/hour more on average than those with no high school diploma. I can easily confirm this by looking back to the means I just calculated:


```r
round(wage_means[2:5]-wage_means[1], 2)
```

```
##       HS Diploma        AA Degree Bachelors Degree  Graduate Degree 
##             4.41             7.65            16.50            23.91
```

## How did R know what to do with the factor variable?

Underneath the surface, every factor variable in *R* comes with a a matrix of *contrasts*. This contrast matrix defines how such a factor variable should be converted into a set of variables for a linear model. You can see this contrast matrix with the `contrasts` command:


```r
contrasts(earnings$education)
```

```
##                  HS Diploma AA Degree Bachelors Degree Graduate Degree
## No HS Diploma             0         0                0               0
## HS Diploma                1         0                0               0
## AA Degree                 0         1                0               0
## Bachelors Degree          0         0                1               0
## Graduate Degree           0         0                0               1
```

The rows are the categories (or "levels" in R speak) of the factor variable and the columns are the variables that actually enter into the model. The matrix gives the numeric coding of these variables for each category. As you can see, the contrasts here just define a standard dummy/indicator variable coding. The no high school diploma category is my reference and has zero on all four variables. All of the other categories have a one for the relevant variable and a zero otherwise. 

When you create a factor variable, R will default to this dummy coding which in R is often called a *treatment contrast*. But, treatment contrasts are not the only contrasts available and you can create your own contrast as I will show below. 

To illustrate a change in contrast, I will change my regular factor variable to an ordered factor. The `factor` command has the option to make any factor ordered and thus recognize its underlying ordinal structure. I can do this very simply:


```r
earnings$educ_ordered <- factor(earnings$education, ordered=TRUE)
```

An ordered factor behaves very similarly to a regular factor but has one major advantage. I can now use greater than and less than operators on my factor in a logical way. For example, lets say I wanted to look at the mean difference in wages between all those with only a high school diploma or less and those with more schooling. Rather than code a whole new variable for this binary comparison, I can just:


```r
model_binary <- lm(wages~I(educ_ordered>"HS Diploma"), data=earnings)
knitr::kable(round(coef(model_binary), 2), col.names = "coefficients")
```



|                                   | coefficients|
|:----------------------------------|------------:|
|(Intercept)                        |        18.10|
|I(educ_ordered > "HS Diploma")TRUE |        12.62|

Being able to use these operators can be a real time saver if you have an ordinal variable with many categories because you can easily collapse categories for a variety of purposes. 

However, ordered factors come with one very annoying "feature" in R. Lets say I want to estimate the same linear model as before but now using my ordered factor. Lets try it out:


```r
model_ordinal1 <- lm(wages~educ_ordered, data=earnings)
knitr::kable(round(coef(model_ordinal1), 2), col.names="coefficients")
```



|               | coefficients|
|:--------------|------------:|
|(Intercept)    |        24.75|
|educ_ordered.L |        18.94|
|educ_ordered.Q |         3.10|
|educ_ordered.C |        -0.09|
|educ_ordered^4 |        -1.65|














