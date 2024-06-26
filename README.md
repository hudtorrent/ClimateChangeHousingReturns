# IS CLIMATE CHANGE RELEVANT FOR THE REAL ESTATE MARKET? A MACHINE LEARNING APPROACH

This is the repository of the paper (work in progress): Is Climate Change Relevant For The Real Estate Market? A Machine Learning Approach

## Authors

- Bruno Tag Sales
- Hudson S. Torrent
- Rangan Gupta

## ABSTRACT

Climate change, a pressing global challenge, has wide-ranging implications for various aspects of our lives, including housing prices. This paper delves into the intricate relationship between climate change and housing prices in the United States. Using a comprehensive dataset and employing machine learning techniques, we analyze the relevance of climate variables for housing prices. Our findings suggest that climate change variables can influence housing prices, particularly in the long term. Understanding these dynamics is crucial for informed decision-making, sustainable urban development and climate risk mitigation.

## EMPIRICAL ANALYSIS

In brief, the study analyzes data spanning several decades, incorporating climate-related variables such as anomalies in temperature, precipitation, and drought. To model housing returns, the paper utilizes stepwise boosting, an iterative algorithm that gradually integrates variables to balance model complexity and mitigate the risk of overfitting.

In assessing how climate change variables contribute to predictive performance, multiple models were tested, incorporating macroeconomic factors, financial factors, non-economic factors, non-financial factors, and measures of uncertainties. Finally, the study also examines the relevance of climate-related variables in housing return modeling, particularly by analyzing their selection rates within the boosting algorithm.

## DATA

**Dependent Variable:** Overall Real Housing Returns - FHFA Index Returns

**Group 1:** Macro&Financial Factors

- From Ludvigson and Ng (2009)
- Available at https://www.sydneyludvigson.com/

**Group 2:** Macro&Financial Uncertainty Factors

- From Ludvigson et al. (2021)
- Available at https://www.sydneyludvigson.com/
  
**Group 3:** Non-Macro&Financial Uncertainty Factors

- From Ludvigson et al. (2021)
- Available at https://www.sydneyludvigson.com/
  
**Group 4:** Climate Factors from National Center for Environmental Information

- Average Temperature
- Maximum Temperature
- Minimum Temperature
- Precipitation
- Cooling Degree Days
- Heating Degree Days
- Palmer Drought Severity Index (PDSI)
- Palmer Hydrological Drought Index (PHDI)
- Palmer Modified Drought Index (PMDI)
- Palmer Z-Index

**Group 5:** Climate Change Volatility
