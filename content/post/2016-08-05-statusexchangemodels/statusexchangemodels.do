/***********************************************************************************************
# statusexchangemodels.do                    
# Aaron Gullickson
# UO Sociology
# 5/4/2015
# 
# The purpose of this program is to show the basic code needed to produce the status
# exchange models used in Gullickson and Torche (2014) and Gullickson (2006). The 
# code will produce market exchange and dyadic exchange terms for the data. It will also
# show how to incorporate geometric means terms to estimate the baseline expectation about 
# assortative mating for interracial couples. Finally, it will show why Rosenfeld's models
# of status exchange from his AJS article are overfit and thus bad models.
# PLEASE NOTE: You need to install the desmat library in order to run this do file
***********************************************************************************************/

/***********************************************************************************************
# THE DATA 
# The data used here is a 2x2x4x4 table (flattened) of husband's race by wife's race by 
# husband's education by wife's education. Race is white (1) and black (2). Education is
# less than high school (1), high school (2), some college (3), and college+ (4). The data 
# come from the US Census 1990, but PLEASE NOTE that I found this data lying around in
# and cannot vouch for its completeness or representativeness. It is being used for 
# demonstrative purposes and inferences and conclusions should not be drawn from it
***********************************************************************************************/
insheet using usmardata1990.csv
*do some renaming because stata stupidly changes the case on my variable names unlike R
rename hr HR
rename wr WR
rename he HE
rename we WE
rename freq Freq

/***********************************************************************************************
# DYADIC EXCHANGE TERMS
# I simply code a set of dummy variables for cases of non-homogamy among interracial couples. 
# This is coded separately by the gender combination of the couple (BM/WF vs. WM/BF) and whether
# it implies upward or downward marriage for the black partner (not the woman).
***********************************************************************************************/
generate SEBMWFUp = HE>WE & HR==2 & WR==1
generate SEBMWFDown = HE<WE & HR==2 & WR==1
generate SEWMBFUp = WE>HE & HR==1 & WR==2
generate SEWMBFDown = WE<HE & HR==1 & WR==2

*I also code symmetric terms, that assume the same upward and downward effect.
generate SEBMWF = 0
replace SEBMWF = 1 if HE>WE & HR==2 & WR==1
replace SEBMWF = -1 if HE<WE & HR==2 & WR==1
generate SEWMBF = 0
replace SEWMBF = 1 if HE<WE & HR==1 & WR==2
replace SEWMBF= -1 if HE>WE & HR==1 & WR==2

*Here is the most parsimonious term which assumes both directional symmetry
*and identical effects for BM/WF and WM/BF couples. 
generate SE = SEBMWF+SEWMBF

/***********************************************************************************************
# MARKET EXCHANGE TERMS
# These terms are synonomous with the educational boundary terms in Gullickson (2006) which are
# themselves very similar to the terms used by FU (2001). As I will show below these terms are 
# actually identical to fitting the three way HR*WR*HE and HR*WR*HE (and lower ordered HR*WE 
# and WR*HE) tables, but this particular coding scheme makes the results more interpretable. 
# I use "stairstep" coding here, such that each level of education gets the effect for that level
# PLUS the effect for lower levels. Using this technique means that each coefficient measures the 
# difference between adjacent levels of education (e.g. college vs. some college) rather than 
# between that level and a fixed reference (e.g. college vs. less than high school). I also
# included a commented out more traditional dummy formulation for users that prefer that style.
#
# Each term here can be thought of as the increase in the likelihood of interracial marriage
# when education increases by one level for each race-gender type (i.e. black men, black women, 
# white men, white women).
***********************************************************************************************/
generate EBBM1 = HE>1 & HR==2 & WR==1
generate EBBM2 = HE>2 & HR==2 & WR==1
generate EBBM3 = HE>3 & HR==2 & WR==1

generate EBWF1 = WE>1 & HR==2 & WR==1
generate EBWF2 = WE>2 & HR==2 & WR==1
generate EBWF3 = WE>3 & HR==2 & WR==1

generate EBWM1 = HE>1 & HR==1 & WR==2
generate EBWM2 = HE>2 & HR==1 & WR==2
generate EBWM3 = HE>3 & HR==1 & WR==2

generate EBBF1 = WE>1 & HR==1 & WR==2
generate EBBF2 = WE>2 & HR==1 & WR==2
generate EBBF3 = WE>3 & HR==1 & WR==2

*alternate coding by dummy approach (commented out by default)
/*
generate EBBM1 = HE==2 & HR==2 & WR==1
generate EBBM2 = HE==3 & HR==2 & WR==1
generate EBBM3 = HE==4 & HR==2 & WR==1

generate EBWF1 = WE==2 & HR==2 & WR==1
generate EBWF2 = WE==3 & HR==2 & WR==1
generate EBWF3 = WE==4 & HR==2 & WR==1

generate EBWM1 = HE==2 & HR==1 & WR==2
generate EBWM2 = HE==3 & HR==1 & WR==2
generate EBWM3 = HE==4 & HR==1 & WR==2

generate EBBF1 = WE==2 & HR==1 & WR==2
generate EBBF2 = WE==3 & HR==1 & WR==2
generate EBBF3 = WE==4 & HR==1 & WR==2
*/

/***********************************************************************************************
# GEOMETRIC MEAN OF HE*WE
# One of Rosenfeld's criticisms of prior research is that it did not correctly account for lower-order
# interaction terms when estimating the status exchange parameter. He argues that the status exchange term 
#is a parameterized coding of the HE*WE*HR*WR table and thus it is necessary to fit all the three-way and 
# two-way interactions. This includes HR*WR*HE, HR*WR*WE, HR*HE*WE, WR*HE*WE, HR*WE, and WR*HE. As the 
# appendix to Gullickson and Torche (2014) makes clear, Rosenfeld is wrong about the nature of the dyadic 
# status exchange term. It is actually a parameterized coding of the HE*WE*HR and HE*WE*WR tables. As a result, 
# when Rosenfeld includes these terms, his models are overfit, as I will show below. The HR*WR*HE and HR*WR*WE 
# tables are also identical to the market exchange terms coded here which can be thought of as an alternate way 
# of measuring exchange rather than a nuisance control term. For more details, see Gullickson and Torche (2014) 
# and the appendix, Gullickson and Fu (2010), and Kalmijn (2010). 
#
# Despite this inherent problems. Rosenfeld's criticism does reveal one potential shortcoming of the way these 
# models are estimated. When estimating how different the educational assorative mating is for interracial couples 
# (i.e. whether status exchange is occurring), interracial couples are implicitly being compared to the pooled 
# tabled for white and black endogamous couples. But if white and black couples themselves differ in their patterns 
# of ed assortative mating, then the results may be misleading. Probably the best way to handle this is that 
# suggested by Kalmijn (1993) in which the baseline assumption about the educational assortative mating of 
# black/white couples is taken as the geometric mean of the educational asortative mating (HE*WE) of white and 
# black endogamous couples. Gullickson and Torche (2014) discusses this in more detail (particularly the 
# appendix). Ultimately we found the results to be similar using the geometric mean (and a few other 
# specifications) as the more naive approach, but it is worth testing on a data set specific basis.
#
# The way of coding this geometric mean is a bit tedious. I fit dummies for each of the nine terms in the HE*WE 
# table separately for white endogmous and black endogamous couples and then allow interracial couples to be a 
# 0.5 on each dummy. 
***********************************************************************************************/
generate WWHEWE1 = (HR==1 & WR==1 & HE==2 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==2)
generate WWHEWE2 = (HR==1 & WR==1 & HE==2 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==3)
generate WWHEWE3 = (HR==1 & WR==1 & HE==2 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==4)
generate WWHEWE4 = (HR==1 & WR==1 & HE==3 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==2)
generate WWHEWE5 = (HR==1 & WR==1 & HE==3 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==3)
generate WWHEWE6 = (HR==1 & WR==1 & HE==3 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==4)
generate WWHEWE7 = (HR==1 & WR==1 & HE==4 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==2)
generate WWHEWE8 = (HR==1 & WR==1 & HE==4 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==3)
generate WWHEWE9 = (HR==1 & WR==1 & HE==4 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==4)

generate BBHEWE1 = (HR==2 & WR==2 & HE==2 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==2)
generate BBHEWE2 = (HR==2 & WR==2 & HE==2 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==3)
generate BBHEWE3 = (HR==2 & WR==2 & HE==2 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==2 & WE==4)
generate BBHEWE4 = (HR==2 & WR==2 & HE==3 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==2)
generate BBHEWE5 = (HR==2 & WR==2 & HE==3 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==3)
generate BBHEWE6 = (HR==2 & WR==2 & HE==3 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==3 & WE==4)
generate BBHEWE7 = (HR==2 & WR==2 & HE==4 & WE==2) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==2)
generate BBHEWE8 = (HR==2 & WR==2 & HE==4 & WE==3) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==3)
generate BBHEWE9 = (HR==2 & WR==2 & HE==4 & WE==4) + 0.5 * (((HR==1 & WR==2) | (HR==2 & WR==1))  & HE==4 & WE==4)

/***********************************************************************************************
# THE MODELS
# I first run a baseline model which just fits a general term for racial and educational
# homogamy (HR*WR and HE*WE) as well as account for the differential distribution of education by 
# race (HE*HR and WE*WR). This model also fits the four marginal terms themselves, of course.
# Then I fit separate dyadic and market exchange models, plus one that combines them both
# together. I also run a model with just the straight three way interactions of HR*WR*HE and 
# HR*WR*WE (model.compare) to show that this model is identical to the market exchange model. 
***********************************************************************************************/

*baseline model
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE, family(poisson) link(log)

*dyadic - full symmetry in terms of up/down and couple type
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @SE, family(poisson) link(log)

*dyadic - relax symmetry on couple type but not up/down
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @SEBMWF @SEWMBF, family(poisson) link(log)

*dyadic - full model allowing different up/down and couple type
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @SEBMWFUp @SEBMWFDown @SEWMBFUp @SEWMBFDown, family(poisson) link(log)

*market model
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @EBBM1 @EBBM2 @EBBM3 @EBWF1 @EBWF2 @EBWF3 ///
	@EBWM1 @EBWM2 @EBWM3 @EBBF1 @EBBF2 @EBBF3, family(poisson) link(log)

*this model just fits the three way interaction terms for HR*WR*HE and HR*WR*HE to show that it fits 
*identically to the market model. In other words, they are just different parameterizations of the same model.
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE HR*WR*HE HR*WR*WE, family(poisson) link(log)
 
*both dyadic and market
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @SEBMWFUp @SEBMWFDown @SEWMBFUp @SEWMBFDown ///
	@EBBM1 @EBBM2 @EBBM3 @EBWF1 @EBWF2 @EBWF3 @EBWM1 @EBWM2 @EBWM3 @EBBF1 @EBBF2 @EBBF3, family(poisson) link(log)

/***********************************************************************************************
# ROSENFELD MODELS
# I follow rosenfeld's protocol of adding in all of the missing two and three
# way tables and show that his method leads to collinearity such that terms are dropped from the 
# model. This happens because of collinearity between the HE*WE*HR and HE*WE*WR terms and the 
# dyadic exchange term.
***********************************************************************************************/

* NOTE: the collinearity is apparently not reported very well, but you can see it in that the HE*WE*WR 
* term has eight terms instead of the expected nine terms and the overall DF for the model is 9, rather than 8
* (the 9 DF remaining in the four way interaction term, minus the one used for the SE term). The R version of 
* this code does report the collinearity more clearly. 
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE HR*WR*HE HR*WR*WE HE*WE*HR HE*WE*WR @SE, family(poisson) link(log)

*the same holds for the other dyadic models but I don't show them for brevity

*now show that dropping out HE*WE*HR and HE*WE*WR resolves the problem. The resulting model is equivalent
* to a model with both a dyadic and market exchange term
desmat: glm Freq HR*WR HE*HR WE*WR HE*WE HR*WR*HE HR*WR*WE @SE, family(poisson) link(log)

desmat: glm Freq HR*WR HE*HR WE*WR HE*WE @SE @EBBM1 @EBBM2 @EBBM3 @EBWF1 @EBWF2 @EBWF3 @EBWM1 @EBWM2 @EBWM3 @EBBF1 @EBBF2 @EBBF3, /// 
	family(poisson) link(log)

/***********************************************************************************************
# GEOMETRIC MEAN MODELS
# Here I just rerun the dyadic and market exchange models with the geometric mean baseline rather
# than the pooled HE*WE baseline. The results are fairly consistent with what we had before for BM/WF
# couples, but not WM/BF couples.
***********************************************************************************************/
*baseline geo modelt
desmat: glm Freq HR*WR HE*HR WE*WR @WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)

*dyadic exchange, full symmetry
desmat: glm Freq HR*WR HE*HR WE*WR  @SE @WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)

*dyadic exchange, partial symmetry
desmat: glm Freq HR*WR HE*HR WE*WR @SEBMWF @SEWMBF @WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)

*dyadic exchange, full
desmat: glm Freq HR*WR HE*HR WE*WR @SEBMWFUp @SEBMWFDown @SEWMBFUp @SEWMBFDown ///
	@WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)

*market exchange
desmat: glm Freq HR*WR HE*HR WE*WR @EBBM1 @EBBM2 @EBBM3 @EBWF1 @EBWF2 @EBWF3 @EBWM1 @EBWM2 @EBWM3 @EBBF1 @EBBF2 @EBBF3 ///
	@WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)

*both
desmat: glm Freq HR*WR HE*HR WE*WR @SEBMWFUp @SEBMWFDown @SEWMBFUp @SEWMBFDown ///
	@EBBM1 @EBBM2 @EBBM3 @EBWF1 @EBWF2 @EBWF3 @EBWM1 @EBWM2 @EBWM3 @EBBF1 @EBBF2 @EBBF3 ///
	@WWHEWE1 @WWHEWE2 @WWHEWE3 @WWHEWE4 @WWHEWE5 @WWHEWE6 @WWHEWE7 @WWHEWE8 @WWHEWE9 ///
	@BBHEWE1 @BBHEWE2 @BBHEWE3 @BBHEWE4 @BBHEWE5 @BBHEWE6 @BBHEWE7 @BBHEWE8 @BBHEWE9, family(poisson) link(log)
