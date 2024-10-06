**Load Dataset
	import delimited "C:\Users\ashvi\OneDrive\Desktop\San Diego Taxpayer\police_pac.csv",clear
	
**Inspect the dataset
	describe
	list in 1/10
**Create null = 0 for total_amount
	replace total_amount = "0" if total_amount == "NA"
	destring total_amount, replace

**gen city number for regression
	encode city, gen(city_num)

**Calculate the median using bysort and egen
	bysort city year: egen median_realwages = median(real_totalwages)

**rename confusing variables
	rename total_amount total_contribution

**gen pac column
	gen has_pac = (total_contribution != 0)
	
**Create Visualizations
	*Distribution of Salaires
	histogram real_totalwages, bin(50) frequency
	graph box real_totalwages
	*Boxplot of salaries for employees with or without PAC contributions
	label define pac_lbl 0 "No PAC" 1 "Has PAC"
	label values has_pac pac_lbl
	graph box real_totalwages, over(has_pac)
	*Scatter plot Year and Real Wages
	twoway (scatter real_totalwages year), ///
    title("Scatterplot of Real Wages by Year") ///
    xtitle("Year") ///
    ytitle("Real Wage")
	*Scatter plot Year and contributions
	twoway (scatter total_contribution year), ///
    title("Scatterplot of Real Wages by Year") ///
    xtitle("Year") ///
    ytitle("PAC contributions")
	*Scatter plot 
	twoway (scatter median_realwages year)
	title("Scatterplot of Median Wages by Year") ///
    xtitle("Year") ///
    ytitle("PAC contributions")
	*Correlation really weak
	pwcorr median_realwages total_amount year
	
**Prepare to run regression of pac contributions on median wages
	*Keep an observation per year per city
	bysort city year: keep if _n == 1
	*Keep important variables for regression
	keep year city department total_contribution median_realwages has_pac city_num

**Regression analyst
	*median wage on total pac contribution
	reg median_realwages total_contribution, robust
	*median wage on total pac contribution controlling for time effects
	reg median_realwages total_contribution i.year, robust
	*median wage on total pac controlling for location
	reg median_realwages total_contribution i.city_num, robust
	*median wage on total pac controlling for time effects and location
	reg median_realwages total_contribution i.year i.city_num
	
