Welcome! This repository contains documents related to my Master Thesis: 

*"Models of Migration Time and Refugee Well-being - Applying Causal Inference, Event History Analysis and Deep Learning to the IAB-BAMF-SOEP Survey of Refugees in Germany"*. 

If you have any questions or would like to read my thesis, please send me an email: timfingerhut@gmail.com. 

What you can and cannot find here: 

1) **Data**: Due to contractual obligations with the German Institute for Economic Research (DIW), I am not allowed to share the data from the IAB-BAMF-SOEP Survey of Refugees in Germany. If you want to work with the same dataset, you can apply for access through the [DIW/SOEP website](https://www.diw.de/en/diw_01.c.357906.en/soep_order_form_mod.html). 

2) **Figures**: This path contains all figures in high resolution.

3) **DeepSurv**: You can find the Python notebook used for the DeepSurv application on this path. I also uploaded the PDF output for convenience. 

4) **Hyperparameter Tuning**: As described in the thesis, I followed a four-step manual hyperparameter tuning procedure. Files on this path document the hyperparameter tuning. For an example of an implemented random hyperparameter search for DeepSurv, please have a look at [Jared Lee Katzman's DeepSurv repository](https://github.com/jaredleekatzman/DeepSurv/tree/master/hyperparam_search). 

5) **Map Data**: I created Map 1 using [Heatmapper](http://www2.heatmapper.ca). I uploaded the raw data of the number of Syrian respondents by region to the Map Data folder. 

6) **STATA Code**: This path contains the STATA Do-File with the code for Kaplan-Meier estimates, Cox regressions, data preprocessing and normalization as well as the various statistical tests implemented in the thesis.

7) **Abstract**: 

The number of forcibly displaced people exceeded 70 million in 2018, but there is little systematic evidence on their journeys. This thesis studies the duration of refugees’ journeys to Germany based on a representative survey conducted in 2016. The median journey duration is 20 days. The fastest decile of refugees arrives in Germany within one day, while the slowest decile travels longer than three months. Theoretical hypotheses are evaluated using event history analysis. National origin strongly influences journey duration. Travelling by plane or with one’s family, support by persons in Germany and avoiding negative experiences such as imprisonment shorten journey duration. Contrary to theoretical expectations, the evidence further suggests that male gender, shorter geographical distance and high smuggling costs do not speed up journeys. Beyond this substantive examination of refugee journeys, the predictive accuracy of the event history method is further compared to DeepSurv, a Cox proportional hazards deep neural network. DeepSurv sharply outperforms traditional models and surpasses their range of typical values. This exemplifies the potential of machine learning for social science. Deep learning could enable a trend towards personalized public policy akin to the way that personalized care is transforming medicine.
