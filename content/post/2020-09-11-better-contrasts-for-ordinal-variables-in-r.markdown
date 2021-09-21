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

😮 WTF? What are all of these terms? They certainly are not what I was expecting. We can learn more by looking at the contrasts.


```r
contrasts(earnings$educ_ordered)
```

```
##              .L         .Q            .C         ^4
## [1,] -0.6324555  0.5345225 -3.162278e-01  0.1195229
## [2,] -0.3162278 -0.2672612  6.324555e-01 -0.4780914
## [3,]  0.0000000 -0.5345225 -4.095972e-16  0.7171372
## [4,]  0.3162278 -0.2672612 -6.324555e-01 -0.4780914
## [5,]  0.6324555  0.5345225  3.162278e-01  0.1195229
```

We are definitely not using dummy coding here! The default behavior in R for ordered factors is to treat them as equidistant scores and then estimate an orthogonal polynomial function. So the letters L, Q, and C above refer to linear, quadratic, and cubic terms. This default behavior was inherited from S and I would argue that it is ... not optimal. First, It is problematic to treat ordinal variables as equidistant scores without letting the researcher make that decision explicitly. Second, the parameter estimates from this approach are completely uninterpretable.

Luckily, it is not difficult to re-specify the contrasts for the education variable. R even provides some handy-dandy functions for common contrasts. In this case, we could re-code back to a standard dummy/indicator variable contrasts with `contr.treatment`, like so:


```r
contrasts(earnings$educ_ordered) <- contr.treatment(5)
model_ordinal2 <- lm(wages~educ_ordered, data=earnings)
knitr::kable(round(coef(model_ordinal2), 2), col.names="coefficients")
```



|              | coefficients|
|:-------------|------------:|
|(Intercept)   |        14.26|
|educ_ordered2 |         4.41|
|educ_ordered3 |         7.65|
|educ_ordered4 |        16.50|
|educ_ordered5 |        23.91|

## Use the stairstep contrast, tell a friend

However, since we have to re-specify our contrasts, why not take the time to think about better options? The standard dummy variable coding for ordinal variables is often not very informative. For example, I can see that individuals with a graduate degree make $23.91 more per hour than those with no high school diploma. That is a large difference, but I would have expected a large number here given that we are contrasting the poles of the distribution. A far more interesting question is how much more do those with graduate degrees make than those with only a bachelor's degree? In that case, we are comparing how much the predicted value of the dependent variable changes when you move to the next highest adjacent category. 

We can do this for all adjacent pairs by applying a `diff` to the vector of mean wages:


```r
diff(wage_means)
```

```
##       HS Diploma        AA Degree Bachelors Degree  Graduate Degree 
##         4.407462         3.242862         8.848246         7.410229
```

Every number gives us the increase in mean hourly wages when you move to that education level from the immediately preceding educational level. The biggest jump is between a Bachelor's degree and an AA degree, while the smallest jump is between a high school diploma and an AA degree. 

I can of course calculate these differences by hand from the results of my dummy variable coding. For example, by taking `\(23.91-16.50\)`, I will be able to see that the increase in expected hourly wages from a Bachelor's degree to a Graduate degree is 7.41. However, wouldn't it be nice if there was a contrast coding that would do this for me? It turns out there is! 

The contrast coding we want looks like a stairstep.


```r
cont <- matrix(0, 5, 4)
cont[col(cont)<row(cont)] <- 1
rownames(cont) <- c("LHS","HS","AA","BA","Grad")
colnames(cont) <- c("HS vs LHS", "AA vs HS", "BA vs AA", "Grad vs BA")
cont
```

```
##      HS vs LHS AA vs HS BA vs AA Grad vs BA
## LHS          0        0        0          0
## HS           1        0        0          0
## AA           1        1        0          0
## BA           1        1        1          0
## Grad         1        1        1          1
```

In this coding, each category gets a one if it is at or higher than the critical cut point for that contrast. The idea is that every category gets the effect of making that "jump" if they are at that level or higher. The result looks like a stairstep descending to the left. For this reason, I often call this approach *stairstep coding*.

Lets try out this stairstep contrast on education:


```r
contrasts(earnings$educ_ordered) <- cont
model_ordinal3 <- lm(wages~educ_ordered, data=earnings)
knitr::kable(round(coef(model_ordinal3), 2), col.names="coefficients") 
```



|                       | coefficients|
|:----------------------|------------:|
|(Intercept)            |        14.26|
|educ_orderedHS vs LHS  |         4.41|
|educ_orderedAA vs HS   |         3.24|
|educ_orderedBA vs AA   |         8.85|
|educ_orderedGrad vs BA |         7.41|

The contrasts behave exactly as expected. Each parameter estimate gives the mean difference between adjacent pairs of categories on the ordinal variable. We can get the mean differences between any non-adjacent pairs simply by adding up the values of all the intervening pairs. For example, to get the difference between an AA degree and a graduate degree I take the two values for BA vs. AA and Grad vs. AA and add them up for `\(8.85+7.41=16.26\)`.

Finally, since setting up this contrast is a hassle, why not put all of it into a function like a coding <svg viewBox="0 0 448 512" style="height:1em;position:relative;display:inline-block;top:.1em;" xmlns="http://www.w3.org/2000/svg">  <path d="M325.4 289.2L224 390.6 122.6 289.2C54 295.3 0 352.2 0 422.4V464c0 26.5 21.5 48 48 48h352c26.5 0 48-21.5 48-48v-41.6c0-70.2-54-127.1-122.6-133.2zM32 192c27.3 0 51.8-11.5 69.2-29.7 15.1 53.9 64 93.7 122.8 93.7 70.7 0 128-57.3 128-128S294.7 0 224 0c-50.4 0-93.6 29.4-114.5 71.8C92.1 47.8 64 32 32 32c0 33.4 17.1 62.8 43.1 80-26 17.2-43.1 46.6-43.1 80zm144-96h96c17.7 0 32 14.3 32 32H144c0-17.7 14.3-32 32-32z"></path></svg>? 


```r
ordered_factor <- function(fact_var) {
  ord_fact <- factor(fact_var, ordered=TRUE)
  categories <- levels(fact_var)
  n_cat <- length(categories)
  cont <- matrix(0, n_cat, n_cat-1)
  cont[col(cont)<row(cont)] <- 1
  rownames(cont) <- categories
  colnames(cont) <- paste(categories[2:n_cat], categories[1:(n_cat-1)],
                          sep=" vs. ")
  contrasts(ord_fact) <- cont
  return(ord_fact)
}
```

This function take a factor variable as input and returns an ordered factor with stairstep contrasts defined as well as intuitive labels. Now you can just apply this function to any existing factor variables to convert them to ordered factors with stairstep contrasts. Here it is in action.


```r
earnings$education <- ordered_factor(earnings$education)
contrasts(earnings$education)
```

```
##                  HS Diploma vs. No HS Diploma AA Degree vs. HS Diploma
## No HS Diploma                               0                        0
## HS Diploma                                  1                        0
## AA Degree                                   1                        1
## Bachelors Degree                            1                        1
## Graduate Degree                             1                        1
##                  Bachelors Degree vs. AA Degree
## No HS Diploma                                 0
## HS Diploma                                    0
## AA Degree                                     0
## Bachelors Degree                              1
## Graduate Degree                               1
##                  Graduate Degree vs. Bachelors Degree
## No HS Diploma                                       0
## HS Diploma                                          0
## AA Degree                                           0
## Bachelors Degree                                    0
## Graduate Degree                                     1
```

```r
model_final <- lm(wages~education, data=earnings)
knitr::kable(coef(model_final, 2), col.names="coefficients")
```



|                                              | coefficients|
|:---------------------------------------------|------------:|
|(Intercept)                                   |    14.261219|
|educationHS Diploma vs. No HS Diploma         |     4.407462|
|educationAA Degree vs. HS Diploma             |     3.242862|
|educationBachelors Degree vs. AA Degree       |     8.848246|
|educationGraduate Degree vs. Bachelors Degree |     7.410229|
