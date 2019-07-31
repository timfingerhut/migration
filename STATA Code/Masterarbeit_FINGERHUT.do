* Tim Fingerhut (timfingerhut@gmail.com)
* Master Thesis 2019
* Freie Universität Berlin
* Last changed on: 31.07.2019
* Data: IAB-BAMF-SOEP Survey of Refugees in Germany - M3 Sample.


/* ============================================================================

Contents (Lines of Code in Do-File)

Part 1. Data Preparation: Recoding Variables (Lines 23 - 1093)
Part 2. Data Imputation (Lines 1094 - 1299)
Part 3. Data Normalization for DeepSurv (Lines 1300 - 1623)
Part 4. Data Analysis: Event History Method, including Kaplan-Meier Estimates, 
Cox Regressions and tests such as ttest, PH test (Lines 1624 - 1813)

=============================================================================*/ 


* ------------------------------------------------------------------------------

* Part 1 - Data Preparation: Recoding Variables 

* ------------------------------------------------------------------------------

* Select dataset from path on personal hard drive 

use "/Users/timfingerhut/Documents/FU Berlin 2019/0_Masterarbeit/Code/bgp_refugees_master.dta"

/* The two key dependent variables in event history analysis are time duration 
and so-called "failure". In this dataset, all surveyed people arrived in
Germany. Therefore, no cases were "right-censored". The event of interest 
(= arrival in Germany) took place for every surveyed individual. We therefore 
set the failure variable to 0 for all individauls. */

* Dependent variables: migration duration and right censoring 

gen dur = bgpr_l_27 if bgpr_l_27 > 0
gen fail_1 = 1 

* Explanatory variables (I consistenly numbered explanatory variables)

* 1) gender: Male will be coded as "0". Female is coded as "1". 

gen gender = bgpr_l_0101
recode gender 1 = 0
recode gender 2 = 1

label define gender 0 "Male" 1 "Female"
label values gender gender 

tab gender
* The dataset includes 2773 males and 1692 females. 

* 2) age: Calculated by year of birth 

gen birth_yr = bgpr_l_0103 if bgpr_l_0103 > 0
gen age = 2019 - birth_yr
* The youngest person in the dataset is 21 years old. The oldest 86. Mean age is 36,6 years. 

* 3) citizenship 

gen citizenship = bgpr0102

* 4) country_of_birth 

gen country_of_birth = bgpr_l_0201

clonevar birth_country = country_of_birth
label define birth_country 1 "Afghanistan" 2 "Albania" 4 "Armenia" 5 "Bosnia and Herzegowina" 6 "Eritrea" 7 "Gambia" 8 "Georgia" 9 "India" 10 "Iraq" 11 "Iran" 12 "Kosovo" 13 "Macedonia" 14 "Nigeria" 15 "Pakistan" 16 "Russian Federation" 17 "Serbia" 18 "Somalia" 19 "Syria" 20 "Ukraine" 21 "Other country"
label values birth_country birth_country

* I export the regional data for Afghanistan, Iraq, Eritrea and Syria, the
* most common countries of birth of people in the dataset. Only the regional
* variable for Syria will be used later in the analysis.

* 5) region_afghanistan

clonevar region_afghanistan = bgpr_l_0301

* 6) region_iraq

clonevar region_iraq = bgpr_l_0310

* 7) region_eritrea 

clonevar region_eritrea = bgpr_l_0306

* 8) region_syria 

clonevar region_syria = bgpr_l_0319
tab region_syria

* 9) immigration_country (1 = to Germany, 2 = other country) 

clonevar immigration_country = bgpr_l_06

* 10) return_year

clonevar return_year = bgpr_l01_0901
* only 1% of people in the dataset returned to their country of birth or another country. Most before 2015. 


* 11) exp_savings: sustained livelihood with savings 

clonevar exp_savings = bgpr_l_1701 
recode exp_savings -2 = 0


* 12) exp_income: sustained livelihood with work income 

clonevar exp_income = bgpr_l_1702
recode exp_income -2 = 0

* 13) exp_transfers: sustained livelihood with transfers

clonevar exp_transfers = bgpr_l_1703
recode exp_transfers -2 = 0

* 14) exp_fam: sustained livelihood through family 
clonevar exp_fam = bgpr_l_1704
recode exp_fam -2 = 0

* 15) exp_loan: sustained livelihood through loan
clonevar exp_loan = bgpr_l_1705
recode exp_loan -2 = 0

* 16) exp_other: sustained livelihood by other means
clonevar exp_other = bgpr_l_1706
recode exp_other -2 = 0

* 17) expulsion: left last country due to expulsion 
clonevar expulsion = bgpr_l_2501
recode expulsion -2 = 0

* 18) persecution: left last country due to persecution
clonevar persecution = bgpr_l_2502
recode persecution -2 = 0

* 19) discrimination: left last country due to discrimination
clonevar discrimination = bgpr_l_2503
recode discrimination -2 = 0

* 20) living_conditions: left last country due to personal living conditions
clonevar living_conditions = bgpr_l_2504
recode living_conditions -2 = 0

* 21) economic_situation: left last country due to economic situation
clonevar economic_situation = bgpr_l_2505
recode economic_situation -2 = 0

* 22) family_members: left last country to join family members
clonevar family_members = bgpr_l_2506
recode family_members -2 = 0

* 23) sent_by_family: left last country because he/she was sent by family
clonevar sent_by_family = bgpr_l_2507
recode sent_by_family -2 = 0

* 24) family_left: left last country because family left
clonevar family_left = bgpr_l_2508
recode family_left -2 = 0

* 25) friends_left: left last country because friends left
clonevar friends_left = bgpr_l_2509
recode friends_left -2 = 0

* 26) other_reasons: left last country due to other reasons 
clonevar other_reasons = bgpr_l_2510
recode other_reasons -2 = 0

* 27) answers_questions_experiences: people who answered questions about flight experiences - 0 "No" & 1 "Yes" 
clonevar answers_questions_experiences = bgpr_l_28
recode answers_questions_experiences 2 = 0
recode answers_questions_experiences -1 = .

label define answers 0 "No" 1 "Yes"
label values answers_questions_experiences answers
tab answers_questions_experiences 

* 28) car: used car as transportation 

/* The coding procedure is a little different here, because we have to recognize the fact that 1/3 of respondents
chose not to answer questions related to the negative experiences and modes of transport. Therefore, we have to 
distinguish the answer "not applicable" (coded -2) in the original dataset for those who answered the questions
and those who did not. For example, if someone answered the questions but the answer is not applicable, he or she
did not use "car" as a modes of transportation. If the answer is "not applicable" and the person chose not to
answer the questions about the flight experiences, then the person simply did not answer the question and therefore
one has to code this answer as a mising value.*/

gen car=.
replace car=0 if answers_questions_experiences == 1
replace car = bgpr_l_2801 if bgpr_l_2801 > 0

* 29) bus 

gen bus=.
replace bus=0 if answers_questions_experiences == 1
replace bus = bgpr_l_2802 if bgpr_l_2802 > 0

* 30) truck

gen truck=. 
replace truck=0 if answers_questions_experiences == 1
replace truck = bgpr_l_2803 if bgpr_l_2803 > 0

* 31) train

gen train=. 
replace train=0 if answers_questions_experiences == 1
replace train = bgpr_l_2804 if bgpr_l_2804 > 0

* 32) plane

gen plane=. 
replace plane=0 if answers_questions_experiences == 1
replace plane = bgpr_l_2805 if bgpr_l_2805 > 0

* 33) ferry

gen ferry=. 
replace ferry=0 if answers_questions_experiences == 1
replace ferry = bgpr_l_2806 if bgpr_l_2806 > 0

* 34) small_boat

gen small_boat=. 
replace small_boat=0 if answers_questions_experiences == 1
replace small_boat = bgpr_l_2807 if bgpr_l_2807 > 0

* 35) by_foot

gen by_foot=.
replace by_foot=0 if answers_questions_experiences == 1
replace by_foot = bgpr_l_2808 if bgpr_l_2808 > 0

* 36) transportation_other

gen transportation_other=.
replace transportation_other=0 if answers_questions_experiences == 1
replace transportation_other = bgpr_l_2809 if bgpr_l_2809 > 0

* 37) cost_all_transportation_euro

gen cost_all_transportation_euro=.
replace cost_all_transportation_euro = bgpr_l_2901 if bgpr_l_2901 > 0

* cost_transport_1000
gen cost_transport_1000 = cost_all_transportation_euro / 1000

* 38) cost_all_accomodation_euro

gen cost_all_accomodation_euro=. 
replace cost_all_accomodation_euro = bgpr_l_3001 if bgpr_l_3001 > 0

gen cost_accomodation_1000 = cost_all_accomodation_euro / 1000

* 39) cost_all_helper_smuggler_euro

gen cost_all_helper_smuggler_euro=.
replace cost_all_helper_smuggler_euro = bgpr_l_3101 if bgpr_l_3101 > 0

gen cost_smuggler_1000 = cost_all_helper_smuggler_euro / 1000

* km1000

gen km1000 = km / 1000

* 40) fin_savings: used savings to finance flight 
 
gen fin_savings=.
replace fin_savings=0 if answers_questions_experiences == 1
replace fin_savings = bgpr_l_3201 if bgpr_l_3201 > 0

* 41) fin_sold_assets: sold assets to finance flight 

gen fin_sold_assets=.
replace fin_sold_assets=0 if answers_questions_experiences == 1
replace fin_sold_assets = bgpr_l_3202 if bgpr_l_3202 > 0

* 42) fin_casual_work: accepted irregular and casual jobs to finance flight (German "Gelegenheitsjobs")

gen fin_casual_work=.
replace fin_casual_work=0 if answers_questions_experiences == 1
replace fin_casual_work = bgpr_l_3203 if bgpr_l_3203 > 0
 
* 43) fin_family: family financed flight

gen fin_family=.
replace fin_family=0 if answers_questions_experiences == 1
replace fin_family = bgpr_l_3204 if bgpr_l_3204 > 0

* 44) fin_friends: friends financed flight

gen fin_friends=.
replace fin_friends=0 if answers_questions_experiences == 1
replace fin_friends = bgpr_l_3205 if bgpr_l_3205 > 0

* 45) fin_credit: used credit to finance flight

gen fin_credit=.
replace fin_credit=0 if answers_questions_experiences == 1
replace fin_credit = bgpr_l_3206 if bgpr_l_3206 > 0

* 46) fin_other: used other means to finance flight

gen fin_other=.
replace fin_other=0 if answers_questions_experiences == 1
replace fin_other = bgpr_l_3207 if bgpr_l_3207 > 0

* 47) neg_fraud: person experienced negative experience 'fraud' during flight 

gen neg_fraud=.
replace neg_fraud=0 if answers_questions_experiences == 1
replace neg_fraud = bgpr_l_3301 if bgpr_l_3301 > 0

* 48) neg_sexual_harassment

gen neg_sexual_harassment=.
replace neg_sexual_harassment=0 if answers_questions_experiences == 1
replace neg_sexual_harassment = bgpr_l_3302 if bgpr_l_3302 > 0

* 49) neg_physical_abuse

gen neg_physical_abuse=.
replace neg_physical_abuse=0 if answers_questions_experiences == 1
replace neg_physical_abuse= bgpr_l_3303 if bgpr_l_3303 > 0

* 50) neg_shipwreck

gen neg_shipwreck=.
replace neg_shipwreck=0 if answers_questions_experiences == 1
replace neg_shipwreck= bgpr_l_3304 if bgpr_l_3304 > 0

* 51) neg_robbery

gen neg_robbery=.
replace neg_robbery=0 if answers_questions_experiences == 1
replace neg_robbery= bgpr_l_3305 if bgpr_l_3305 > 0

* 52) neg_blackmail

gen neg_blackmail=.
replace neg_blackmail=0 if answers_questions_experiences == 1
replace neg_blackmail= bgpr_l_3306 if bgpr_l_3306 > 0

* 53) neg_prison

gen neg_prison=.
replace neg_prison=0 if answers_questions_experiences == 1
replace neg_prison= bgpr_l_3307 if bgpr_l_3307 > 0

* 54) no_neg_dummy: if no negative experience, then this dummy is 1

gen no_neg_dummy=.
replace no_neg_dummy=0 if answers_questions_experiences == 1
replace no_neg_dummy= bgpr_l_3308 if bgpr_l_3308 > 0

* 55) neg_dummy: if at least one negative experience, then dummy will be 1

gen neg_dummy=.
replace neg_dummy=0 if no_neg_dummy == 1
replace neg_dummy=1 if no_neg_dummy == 0

* 56) neg_dummy_based_on_ind_answers 
* test whether dummy corresponds to indivdual answers about negative experiences
* the match is not perfect, so another dummy variable is created 

gen neg_dummy_test=.
replace neg_dummy_test=0 if answers_questions_experiences == 1
replace neg_dummy_test = neg_fraud if neg_fraud > 0
replace neg_dummy_test = neg_sexual_harassment if neg_sexual_harassment > 0
replace neg_dummy_test = neg_physical_abuse if neg_physical_abuse > 0
replace neg_dummy_test = neg_shipwreck if neg_shipwreck > 0
replace neg_dummy_test = neg_robbery if neg_robbery > 0
replace neg_dummy_test = neg_blackmail if neg_blackmail > 0
replace neg_dummy_test = neg_prison if neg_prison > 0
rename neg_dummy_test neg_dummy_based_on_ind_answers

tab2 no_neg_dummy neg_dummy_based_on_ind_answers
/* 39 persons did not report any of the listed negative experience categories, but also would not say that
they did not make any bad experience. Therefore, I adopt the neg_dummy variable as the better measure, because
it represents whether an individual thinks he or she has made dangerous negative experiences on the journey */


* NOTE: every respondents answered the following questions again 

* 57) year_arrival_germany 

gen year_arrival_germany = bgpr_l_3401 if bgpr_l_3401 > 0

* 58) month_arrival_germany

clonevar month_arrival_germany = bgpr_l_3402 if bgpr_l_3402 > 0

* 59) arrival_alone

clonevar arrival_alone = bgpr_l_3501
recode arrival_alone -2 = 0


* 60) arrival_with_family

clonevar arrival_with_family = bgpr_l_3502
recode arrival_with_family -2 = 0

* 61) arrival_with_friends

clonevar arrival_with_friends = bgpr_l_3503
recode arrival_with_friends -2 = 0

* 62) arrival_with_other_persons

clonevar arrival_with_other_persons = bgpr_l_3504
recode arrival_with_other_persons -2 = 0
recode arrival_with_other_persons -1 = 0

** reasons for leaving country of origin

* 63) reason_fear_of_war

clonevar reason_fear_of_war = bgpr_l_3601
recode reason_fear_of_war -2 = 0

* 64) reason_forced_recruitment

clonevar reason_forced_recruitment = bgpr_l_3602
recode reason_forced_recruitment -2 = 0

* 65) reason_persecution

clonevar reason_persecution = bgpr_l_3603
recode reason_persecution -2 = 0

* 66) reason_discrimination

clonevar reason_discrimination = bgpr_l_3604
recode reason_discrimination -2 = 0

* 67) reason_personal_conditions

clonevar reason_personal_conditions = bgpr_l_3605
recode reason_personal_conditions -2 = 0

* 68) reason_economic_situation 

clonevar reason_economic_situation = bgpr_l_3606
recode reason_economic_situation -2 = 0

* 69) reason_join_family

clonevar reason_join_family = bgpr_l_3607
recode reason_join_family -2 = 0

* 70) reason_family_sent_me

clonevar reason_family_sent_me = bgpr_l_3608
recode reason_family_sent_me -2 = 0

* 71) reason_family_left_country

clonevar reason_family_left_country = bgpr_l_3609
recode reason_family_left_country -2 = 0

* 72) reason_friends_left_country

clonevar reason_friends_left_country = bgpr_l_3610
recode reason_friends_left_country -2 = 0

* 73) reason_other

clonevar reason_other = bgpr_l_3611
recode reason_other -2 = 0

*+ reasons for choosing Germany

* 74) whyger_family

clonevar whyger_family = bgpr_l_3701
recode whyger_family -2 = 0

* 75) whyger_friends

clonevar whyger_friends = bgpr_l_3702
recode whyger_friends -2 = 0

* 76) whyger_fellow_citizens_here

clonevar whyger_fellow_citizens_here = bgpr_l_3703
recode whyger_fellow_citizens_here -2 = 0

* 77) whyger_economy

clonevar whyger_economy = bgpr_l_3704
recode whyger_economy -2 = 0

* 78) whyger_human_rights

clonevar whyger_human_rights = bgpr_l_3705
recode whyger_human_rights -2 = 0

* 79) whyger_education

clonevar whyger_education = bgpr_l_3706
recode whyger_education -2 = 0

* 80) whyger_welfare_state

clonevar whyger_welfare_state = bgpr_l_3707
recode whyger_welfare_state -2 = 0


* 81) whyger_welcome_culture : German "Willkommenskultur"

clonevar whyger_welcome_culture = bgpr_l_3708
recode whyger_welcome_culture -2 = 0

* 82) whyger_asylum_proc

clonevar whyger_asylum_proc = bgpr_l_3709
recode whyger_asylum_proc -2 = 0

* 83) whyger_coincidence

clonevar whyger_coincidence = bgpr_l_3710
recode whyger_coincidence -2 = 0

* 84) whyger_other_reasons

clonevar whyger_other_reasons = bgpr_l_3711
recode whyger_other_reasons -2 = 0

** the following variables indicate whether a person was supported by people who were already in Germany

* 85) support_family_friends_in_ger: 0 indicates no support, 1 indicates support by persons already in Germany
** most people had support by family (762 people), followed by friends (101 people) and both (39 people)
tab2 bgpr_l_3801 bgpr_l_3802

clonevar support_family_friends_in_ger = bgpr_l_3803
recode support_family_friends_in_ger 1 = 0
recode support_family_friends_in_ger -1 -2 = 1

* 86) mother_tongue 

clonevar mother_tongue = bgpr7201 if bgpr7201 > 0


* 87) english: it is considered that a person can speak English if response is "very good"/"good"/"okay" and that he
* or she cannot speak English if response is "rather bad" or "not at all" 

clonevar english = bgpr81 if bgpr81 > 0 
recode english 5 4 = 0
recode english 2 3 = 1

label define engl 0 "No" 1 "Yes"
label values english engl

* 88) french

clonevar french = bgpr84 if bgpr84 > 0 
recode french 5 4 = 0
recode french 2 3 = 1

label define engl 0 "No" 1 "Yes"
label values french engl


* 89) economic_sector: of the last job

clonevar economic_sector = bgpr_l_148 if bgpr_l_148 > 0

* 90) income_compared_to_others: scale from 1 to 5, the higher, the more income compared to others

clonevar income_compared_to_others = bgpr_l_153 if bgpr_l_153 > 0
recode income_compared_to_others 5 = 0
recode income_compared_to_others 1 = 10
recode income_compared_to_others 2 = 9
recode income_compared_to_others 4 = 1
recode income_compared_to_others 3 = 2
recode income_compared_to_others 9 = 3
recode income_compared_to_others 10 = 4

tab income_compared_to_others

label define inc 0 "Far below average" 1 "Below average" 2 "Average" 3 "Above Average" 4 "Far above average"
label values income_compared_to_others inc

* 91) satisfaction_with_income_then: scale from 0 "totally unsatisfied" to 10 "totally satisfied"

clonevar satisfaction_with_income_then = bgpr_l_154 if bgpr_l_154 > -1

* 92) satisfaction_professional_life

clonevar satisfaction_professional_life = bgpr_l_155 if bgpr_l_155 > -1

* 93) economic_sit_compared_to_others: scale from 1 to 5, the higher, the better the perceived situation 

clonevar economic_sit_compared_to_others = bgpr_l_157 if bgpr_l_157 > 0
recode economic_sit_compared_to_others 5 = 0
recode economic_sit_compared_to_others 1 = 10
recode economic_sit_compared_to_others 2 = 9
recode economic_sit_compared_to_others 4 = 1
recode economic_sit_compared_to_others 3 = 2
recode economic_sit_compared_to_others 9 = 3
recode economic_sit_compared_to_others 10 = 4

label values economic_sit_compared_to_others inc


* 94) satisfaction_housing: scale from 0 "totally unsatisfied" to 10 "totally satisfied" 

clonevar satisfaction_housing = bgpr_l_158 if bgpr_l_158 > -1

* 95) satisfaction_health: scale from 0 "totally unsatisfied" to 10 "totally satisfied" 

clonevar satisfaction_health = bgpr_l_159 if bgpr_l_159 > -1
rename satisfaction_health satisfaction_health_then

* 95) satisfaction_overall: scale from 0 "totally unsatisfied" to 10 "totally satisfied" 

clonevar satisfaction_overall = bgpr_l_160 if bgpr_l_160 > -1
rename satisfaction_overall satisfaction_overall_then

* 96) years_in_school

clonevar years_in_school = bgpr_l_228 if bgpr_l_228 > -1 

* 97) uni_apprentice_abroad: 1 "Yes" 0 "No"

clonevar uni_apprentice_abroad = bgpr_l_231 if bgpr_l_231 > 0
recode uni_apprentice_abroad 2 = 0

* 98) practical_uni

clonevar practical_uni = bgpr_l_23204 
recode practical_uni -2 = 0

* 99) theoretical_uni

clonevar theoretical_uni = bgpr_l_23205
recode theoretical_uni -2 = 0

* 100) phd

clonevar phd = bgpr_l_23206 
recode phd -2 = 0

* 101) psych_felt_welcomed: at arrival /scale from 1 to 5, the higher, the more a person felt welcomed)

clonevar psych_felt_welcomed = bgpr326 if bgpr326 > 0

recode psych_felt_welcomed 5 = 0
recode psych_felt_welcomed 1 = 10
recode psych_felt_welcomed 2 = 9
recode psych_felt_welcomed 4 = 1
recode psych_felt_welcomed 3 = 2
recode psych_felt_welcomed 9 = 3
recode psych_felt_welcomed 10 = 4

label define welc 0 "Not at all" 1 "Little" 2 "In some way" 3 "Mainly" 4 "Totally"
label values psych_felt_welcomed welc

* 102) psych_agency: my life depends on my actions. 1 "disagree totally" 7 "agree totally"

clonevar agency = bgpr328 if bgpr328 > 0
rename agency psych_agency

* 103) psych_unsatisfied_achievement: Statement "I did not achieve what I was meant to achieve compared to others".
* 1 means "disagree totally" and 7 means "agree totally" 

clonevar unsatisfied_with_achievement = bgpr329 if bgpr329 > 0
rename unsatisfied_with_achievement psych_unsatisfied_achievement

* 104) psych_dependent_on_luck : a person with a 7 totally thinks that achieving objectives depends on luck and fate 

clonevar dependent_on_luck = bgpr330 if bgpr330 > 0
rename dependent_on_luck psych_dependent_on_luck

* 105) psych_influence_society: belief that a person may influence society through social or political engagement 

clonevar influence_society = bgpr331 if bgpr331 > 0
rename influence_society psych_influence_society

* 106) psych_not_self_determined 

clonevar not_self_determined = bgpr332 if bgpr332 > 0
rename not_self_determined psych_not_self_determined

* 107) psych_succes_hard_work 

clonevar psych_success_hard_work = bgpr333 if bgpr333 > 0

* 108) psych_control_over_life

clonevar psych_control_over_life = bgpr337 if bgpr337 > 0

* 109) psych_conditions_shape_opp

clonevar psych_conditions_shape_opp = bgpr335 if bgpr335 > 0


* 110) psych_pos_self_image

clonevar psych_pos_self_image = bgpr344 if bgpr344 > 0

* 111) psych_risk: the higher, the more prepared a person is to take risks - scale from 0 to 10 

clonevar psych_risk = bgpr349 if bgpr349 > -1

* 112) religion_islam 

clonevar religion_islam = bgpr350
recode religion_islam 4 = 1 
recode religion_islam -1 5 6 7 = 0

* 113) religion_christianity 

clonevar religion_christianity = bgpr350
recode religion_christianity 7 = 1 
recode religion_christianity -1 5 6 4 = 0

* 114) married: whether a person is or has been married, thus includes widows and divorced peopld
* 0 includes all single people 

clonevar married = bgpr390 if bgpr390 > 0
recode married 1 = 0
recode married 2 4 6 = 1
tab married 

label define married 0 "Single" 1 "Married"
label values married married 

* 115) kids 

clonevar kids = bgpr_l_401 if bgpr_l_401 > 0
recode kids 2 = 0
label values kids answers

* 116) km: measures distance in kilometers from home province of a person 
* to Munich, Germany. Method: Graphhopper Maps - Travel by car to get 
* quickest "landroute" (includes ferries etc.). 

gen km = 0

* Afghanistan:

tab bgpr_l_0301
recode km (0 = 6088) if bgpr_l_0301==1
recode km (0 = 5679) if bgpr_l_0301==2
recode km (0 = 5852) if bgpr_l_0301==3
recode km (0 = 5725) if bgpr_l_0301==4
recode km (0 = 6160) if bgpr_l_0301==5
recode km (0 = 6455) if bgpr_l_0301==6
recode km (0 = 5731) if bgpr_l_0301==7
recode km (0 = 5959) if bgpr_l_0301==8
recode km (0 = 6448) if bgpr_l_0301==9
recode km (0 = 5865) if bgpr_l_0301==10
recode km (0 = 6061) if bgpr_l_0301==11
recode km (0 = 5531) if bgpr_l_0301==12
recode km (0 = 5636) if bgpr_l_0301==13
recode km (0 = 6076) if bgpr_l_0301==14
recode km (0 = 6099) if bgpr_l_0301==15
recode km (0 = 6079) if bgpr_l_0301==16
recode km (0 = 6649) if bgpr_l_0301==17
recode km (0 = 6295) if bgpr_l_0301==18
recode km (0 = 5848) if bgpr_l_0301==19
recode km (0 = 6194) if bgpr_l_0301==20
recode km (0 = 6568) if bgpr_l_0301==21
recode km (0 = 6231) if bgpr_l_0301==22
recode km (0 = 6275) if bgpr_l_0301==25
recode km (0 = 6564) if bgpr_l_0301==26
recode km (0 = 6587) if bgpr_l_0301==27
recode km (0 = 6075) if bgpr_l_0301==28
recode km (0 = 6039) if bgpr_l_0301==29
recode km (0 = 5822) if bgpr_l_0301==30
recode km (0 = 5915) if bgpr_l_0301==31
recode km (0 = 5923) if bgpr_l_0301==32
recode km (0 = 6166) if bgpr_l_0301==33
recode km (0 = 6261) if bgpr_l_0301==34

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 1 & km > 0
recode km (0 = 5992) if bgpr_l_0301==-1

* Albania:

tab bgpr_l_0302
recode km (0 = 1437) if bgpr_l_0302==1
recode km (0 = 1445) if bgpr_l_0302==2
recode km (0 = 1352) if bgpr_l_0302==3
recode km (0 = 1383) if bgpr_l_0302==4
recode km (0 = 1426) if bgpr_l_0302==5
recode km (0 = 1603) if bgpr_l_0302==7
recode km (0 = 1380) if bgpr_l_0302==8
recode km (0 = 1282) if bgpr_l_0302==9
recode km (0 = 1244) if bgpr_l_0302==10
recode km (0 = 1344) if bgpr_l_0302==11
recode km (0 = 1462) if bgpr_l_0302==12

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 2 & km > 0
recode km (0 = 1364) if bgpr_l_0302==-1

* Algeria:

tab bgpr_l_0303
recode km (0 = 2226) if bgpr_l_0303==4
recode km (0 = 2152) if bgpr_l_0303==32
recode km (0 = 2522) if bgpr_l_0303==35
recode km (0 = 2661) if bgpr_l_0303==38
recode km (0 = 2324) if bgpr_l_0303==47
recode km (0 = 2391) if bgpr_l_0303==48

* Armenia:

tab bgpr_l_0304
recode km (0 = 3551) if bgpr_l_0304==1
recode km (0 = 3487) if bgpr_l_0304==2
recode km (0 = 3530) if bgpr_l_0304==3
recode km (0 = 3501) if bgpr_l_0304==5
recode km (0 = 3506) if bgpr_l_0304==8

* Bosnia & Herzegowina:

tab bgpr_l_0305
recode km (0 = 1005) if bgpr_l_0305==2
recode km (0 = 860) if bgpr_l_0305==6
recode km (0 = 881) if bgpr_l_0305==9

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 6 & km > 0
recode km (0 = 887) if bgpr_l_0305==-1

* Eritrea:

tab bgpr_l_0306
recode km (0 = 6026) if bgpr_l_0306==1
recode km (0 = 6195) if bgpr_l_0306==2
recode km (0 = 6196) if bgpr_l_0306==3
recode km (0 = 6117) if bgpr_l_0306==4
recode km (0 = 6150) if bgpr_l_0306==5
recode km (0 = 6699) if bgpr_l_0306==6

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 5 & km > 0
recode km (0 = 6169) if bgpr_l_0306==-1

* Gambia: 

tab bgpr_l_0307
recode km (0 = 5799) if bgpr_l_0307==1
recode km (0 = 5960) if bgpr_l_0307==2
recode km (0 = 5940) if bgpr_l_0307==3
recode km (0 = 5794) if bgpr_l_0307==6
recode km (0 = 5831) if bgpr_l_0307==8

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 7 & km > 0
recode km (0 = 5874) if bgpr_l_0307==-1

* Georgia: 

tab bgpr_l_0308
recode km (0 = 3216) if bgpr_l_0308==1
recode km (0 = 3324) if bgpr_l_0308==2
recode km (0 = 3430) if bgpr_l_0308==3
recode km (0 = 3316) if bgpr_l_0308==5
recode km (0 = 3516) if bgpr_l_0308==10

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 8 & km > 0
recode km (0 = 3430) if bgpr_l_0308==-1

* India: 

tab bgpr_l_0309
recode km(0 = 7595) if bgpr_l_0309==12
recode km(0 = 7102) if bgpr_l_0309==15
recode km(0 = 7299) if bgpr_l_0309==28

* Iraq:

tab bgpr_l_0310
recode km (0 = 4132) if bgpr_l_0310==1
recode km (0 = 3814) if bgpr_l_0310==2
recode km (0 = 4007) if bgpr_l_0310==3
recode km (0 = 3957) if bgpr_l_0310==4
recode km (0 = 4457) if bgpr_l_0310==5
recode km (0 = 4284) if bgpr_l_0310==7
recode km (0 = 3605) if bgpr_l_0310==8
recode km (0 = 3721) if bgpr_l_0310==9
recode km (0 = 3950) if bgpr_l_0310==10
recode km (0 = 3934) if bgpr_l_0310==11
recode km (0 = 3763) if bgpr_l_0310==12
recode km (0 = 4319) if bgpr_l_0310==13
recode km (0 = 4353) if bgpr_l_0310==14
recode km (0 = 4091) if bgpr_l_0310==15
recode km (0 = 3610) if bgpr_l_0310==16
recode km (0 = 3823) if bgpr_l_0310==17
recode km (0 = 3964) if bgpr_l_0310==18
recode km (0 = 4122) if bgpr_l_0310==19

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 10 & km > 0
recode km (0 = 3790) if bgpr_l_0310==-1

* Iran: 

tab bgpr_l_0311
recode km (0 = 4262) if bgpr_l_0311==1
recode km (0 = 3796) if bgpr_l_0311==5
recode km (0 = 5096) if bgpr_l_0311==6
recode km (0 = 4104) if bgpr_l_0311==7
recode km (0 = 5450) if bgpr_l_0311==10
recode km (0 = 4601) if bgpr_l_0311==12
recode km (0 = 5211) if bgpr_l_0311==13
recode km (0 = 4138) if bgpr_l_0311==14
recode km (0 = 5189) if bgpr_l_0311==16
recode km (0 = 5668) if bgpr_l_0311==17
recode km (0 = 4516) if bgpr_l_0311==18
recode km (0 = 4188) if bgpr_l_0311==20
recode km (0 = 4308) if bgpr_l_0311==21
recode km (0 = 4391) if bgpr_l_0311==22
recode km (0 = 4497) if bgpr_l_0311==23
recode km (0 = 4328) if bgpr_l_0311==28

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 11 & km > 0
recode km (0 = 4591) if bgpr_l_0311==-1

* Kosovo:

tab bgpr_l_0312
recode km (0 = 1308) if bgpr_l_0312==1
recode km (0 = 1353) if bgpr_l_0312==2
recode km (0 = 1331) if bgpr_l_0312==3
recode km (0 = 1238) if bgpr_l_0312==4
recode km (0 = 1348) if bgpr_l_0312==5
recode km (0 = 1265) if bgpr_l_0312==6
recode km (0 = 1354) if bgpr_l_0312==7

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 12 & km > 0
recode km (0 = 1302) if bgpr_l_0312==-1

* Macedonia: 

tab bgpr_l_0313
recode km (0 = 1374) if bgpr_l_0313==5
recode km (0 = 1374) if bgpr_l_0313==-1

* Nigeria: 

tab bgpr_l_0314
recode km (0 = 6655) if bgpr_l_0314==1
recode km (0 = 6726) if bgpr_l_0314==6
recode km (0 = 6373) if bgpr_l_0314==7
recode km (0 = 6618) if bgpr_l_0314==10
recode km (0 = 6563) if bgpr_l_0314==11
recode km (0 = 6493) if bgpr_l_0314==12
recode km (0 = 6640) if bgpr_l_0314==17
recode km (0 = 5725) if bgpr_l_0314==20
recode km (0 = 6568) if bgpr_l_0314==25

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 14 & km > 0
recode km (0 = 6517) if bgpr_l_0314==-1

* Pakistan: 

tab bgpr_l_0315
recode km (0 = 6614) if bgpr_l_0315==1
recode km (0 = 6336) if bgpr_l_0315==2
recode km (0 = 6856) if bgpr_l_0315==4
recode km (0 = 6500) if bgpr_l_0315==5
recode km (0 = 6419) if bgpr_l_0315==6
recode km (0 = 6961) if bgpr_l_0315==7
recode km (0 = 6879) if bgpr_l_0315==8

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 15 & km > 0
recode km (0 = 6890) if bgpr_l_0315==-1

* Russia: 

tab bgpr_l_0316
recode km (0 = 3249) if bgpr_l_0316==3
recode km (0 = 5588) if bgpr_l_0316==5
recode km (0 = 2936) if bgpr_l_0316==6
recode km (0 = 5220) if bgpr_l_0316==7
recode km (0 = 3293) if bgpr_l_0316==8
recode km (0 = 2314) if bgpr_l_0316==9

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 16 & km > 0
recode km (0 = 3329) if bgpr_l_0316==-1

* Serbia

tab bgpr_l_0317
recode km (0 = 942) if bgpr_l_0317==1
recode km (0 = 1305) if bgpr_l_0317==2
recode km (0 = 1177) if bgpr_l_0317==3
recode km (0 = 1039) if bgpr_l_0317==4
recode km (0 = 940) if bgpr_l_0317==5

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 17 & km > 0
recode km (0 = 1013) if bgpr_l_0317==-1

* Somalia

tab bgpr_l_0318
recode km (0 = 8323) if bgpr_l_0318==3
recode km (0 = 7990) if bgpr_l_0318==8
recode km (0 = 8667) if bgpr_l_0318==9
recode km (0 = 8414) if bgpr_l_0318==10
recode km (0 = 8624) if bgpr_l_0318==11
recode km (0 = 8270) if bgpr_l_0318==12
recode km (0 = 8153) if bgpr_l_0318==13
recode km (0 = 7963) if bgpr_l_0318==15
recode km (0 = 7427) if bgpr_l_0318==18

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 18 & km > 0
recode km (0 = 8309) if bgpr_l_0318==-1

* Syria

tab bpgr_l_0319
recode km (0 = 3087) if bgpr_l_0319==1
recode km (0 = 3423) if bgpr_l_0319==2
recode km (0 = 3281) if bgpr_l_0319==3
recode km (0 = 3488) if bgpr_l_0319==4
recode km (0 = 3387) if bgpr_l_0319==5
recode km (0 = 3499) if bgpr_l_0319==6
recode km (0 = 3411) if bgpr_l_0319==7
recode km (0 = 3174) if bgpr_l_0319==8
recode km (0 = 3223) if bgpr_l_0319==9
recode km (0 = 3074) if bgpr_l_0319==10
recode km (0 = 3111) if bgpr_l_0319==11
recode km (0 = 3453) if bgpr_l_0319==12
recode km (0 = 3417) if bgpr_l_0319==13
recode km (0 = 3201) if bgpr_l_0319==14

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 19 & km > 0
recode km (0 = 3288) if bgpr_l_0319==-1

* Ukraine

tab bgpr_l_0320
recode km (0 = 2146) if bgpr_l_0320==5
recode km (0 = 2417) if bgpr_l_0320==6
recode km (0 = 1729) if bgpr_l_0320==8
recode km (0 = 1895) if bgpr_l_0320==9
recode km (0 = 1194) if bgpr_l_0320==11
recode km (0 = 2015) if bgpr_l_0320==12
recode km (0 = 1823) if bgpr_l_0320==13
recode km (0 = 2208) if bgpr_l_0320==16
recode km (0 = 1331) if bgpr_l_0320==19
recode km (0 = 985) if bgpr_l_0320==20

* for those from country who answered "Keine Angabe" / "no answer"
sum km if bgpr_l_0201 == 20 & km > 0
recode km (0 = 1824) if bgpr_l_0320==-1

* for remaining data (n=285), no region of origin is available. We thus
* replace the 0 and indiciate that the value is missing for these observations. 

recode km (0 = .) if km==0


* 117) km_per_day: kilometers from home region divided by duration of journey
* in days 

gen km_per_day = km / dur

sum km_per_day, d

*** creating dummies for variables such as citizenship 

tab citizenship, gen(citizen)

tab country_of_birth, gen(country)

tab economic_sector, gen(econ_sector_imp)

tab mother_tongue, gen(mother_tongue_imp)

* -----------------------------------------------------------------------------------------------------

* Part 2 - Data Imputation

* -----------------------------------------------------------------------------------------------------

* Drop if no answer to duration question

drop if dur == "."

* missing values were replaced by the median value for real-valued features and by the mode for categorical features

* why median and not mean? to not give too much weight to extreme observations.
* For example, maximum cost of transportation is 35000€, but median is 2500€. 
* The mean of 4800€ would give too much weight to extreme observations at the top of the range. 

sum age, d
replace age = 37 if missing(age) 
* one change made 

tab car
replace car = 1 if missing(car)
* 849 changes made 

tab bus
replace bus = 1 if missing(bus)
* 849 changes made 

tab truck
replace truck = 0 if missing(truck)
* 849 changes made

tab train 
replace train = 0 if missing(train)
* 849 changes made

tab plane 
replace plane = 0 if missing(plane)
* 849 changes made

tab ferry
replace ferry = 0 if missing(ferry)
* 849 changes made

tab small_boat
replace small_boat = 1 if missing(small_boat)
* 849 changes made

tab by_foot
replace by_foot = 1 if missing(by_foot)
* 849 changes made

tab transportation_other
replace transportation_other = 0 if missing(transportation_other)
* 849 changes made

sum cost_all_transportation_euro, d
replace cost_all_transportation_euro = 2500 if missing(cost_all_transportation_euro)
* 1879 changes made

sum cost_all_accomodation_euro, d
replace cost_all_accomodation_euro = 500 if missing(cost_all_accomodation_euro)
* 2298 changes made 

sum cost_all_helper_smuggler_euro, d
replace cost_all_helper_smuggler_euro = 4000 if missing(cost_all_helper_smuggler_euro)
* 2108 changes made 

tab fin_savings
replace fin_savings = 0 if missing(fin_savings) 
* 849 changes made

tab fin_sold_assets
replace fin_sold_assets = 1 if missing(fin_sold_assets)
* 849 changes made

tab fin_casual_work
replace fin_casual_work = 0 if missing(fin_casual_work)
* 849 changes made

tab fin_family
replace fin_family = 0 if missing(fin_family)
* 849 changes made

tab fin_friends
replace fin_friends = 0 if missing(fin_friends)
* 849 changes made

tab fin_credit
replace fin_credit = 0 if missing(fin_credit)
* 849 changes made

tab fin_other
replace fin_other = 0 if missing(fin_other)
* 849 changes made

tab neg_fraud
replace neg_fraud = 0 if missing(neg_fraud)
* 849 changes made

tab neg_sexual_harassment
replace neg_sexual_harassment = 0 if missing(neg_sexual_harassment)
* 849 changes made

tab neg_physical_abuse
replace neg_physical_abuse = 0 if missing(neg_physical_abuse)
* 849 changes made

tab neg_shipwreck
replace neg_shipwreck = 0 if missing(neg_shipwreck)
* 849 changes made

tab neg_robbery
replace neg_robbery = 0 if missing(neg_robbery)
* 849 changes made

tab neg_blackmail
replace neg_blackmail = 0 if missing(neg_blackmail)
* 849 changes made

tab neg_prison
replace neg_prison = 0 if missing(neg_prison)
* 849 changes made

tab no_neg_dummy
replace no_neg_dummy =  1 if missing(no_neg_dummy)
* 849 changes made

tab neg_dummy
replace neg_dummy = 1 if missing(neg_dummy)
* 849 changes made

tab neg_dummy_based_on_ind_answers
replace neg_dummy_based_on_ind_answers = 0 if missing(neg_dummy_based_on_ind_answers)
* 849 changes made

tab mother_tongue 
replace mother_tongue = 2 if missing(mother_tongue)
* 2 changes made 


tab english, nolabel
replace english = 0 if missing(english)
* 21 changes made

tab french, nolabel
replace french = 0 if missing(french)
* 17 changes made

tab economic_sector 
replace economic_sector = 21 if missing(economic_sector)
* 921 changes made 

sum income_compared_to_others, d
replace income_compared_to_others = 2 if missing(income_compared_to_others)
* 968 changes made

sum satisfaction_with_income_then, d
replace satisfaction_with_income_then = 5 if missing(satisfaction_with_income_then)
* 930 changes made

sum satisfaction_professional_life, d
replace satisfaction_professional_life = 7 if missing(satisfaction_professional_life)
* 921 changes made 

sum economic_sit_compared_to_others, d
replace economic_sit_compared_to_others = 2 if missing(economic_sit_compared_to_others)
* 148 changes made 

sum satisfaction_housing, d
replace satisfaction_housing = 8 if missing(satisfaction_housing)
* 56 changes made

sum satisfaction_health_then, d 
replace satisfaction_health_then = 9 if missing(satisfaction_health_then)
* 43 changes made 

sum satisfaction_overall_then, d
replace satisfaction_overall_then = 7 if missing(satisfaction_overall_then)
* 54 changes made

sum years_in_school, d
replace years_in_school = 11 if missing(years_in_school)
* 464 changes made 

tab uni_apprentice_abroad
replace uni_apprentice_abroad = 0 if missing(uni_apprentice_abroad)
* 26 changes made

tab practical_uni
replace practical_uni = 0 if missing(practical_uni)
* 0 changes made 

tab married 
replace married = 1 if missing(married)
* 22 changes made

tab kids
replace kids = 1 if missing(kids)
* 30 changes made

sum km, d
replace km = 3423 if missing(km)
* 139 changes made 


* ------------------------------------------------------------------------------

* Part 3 - Data Normalization for DeepSurv 

* ------------------------------------------------------------------------------

* Install the "norm" package for STATA 

ssc install norm 

* 119) mmx_age: normalized age 

norm age, method(mmx)

* 120) mmx_cost_transport: normalized transportation

clonevar cost_transport = cost_all_transportation_euro
norm cost_transport, method(mmx)

* 121) mmx_cost_accomodation

clonevar cost_accomodation = cost_all_accomodation_euro
norm cost_accomodation, method(mmx)

* 122) mmx_cost_smuggler

clonevar cost_smuggler = cost_all_helper_smuggler_euro
norm cost_smuggler, method (mmx)

* 123) mmx_year_arrival_germany 

norm year_arrival_germany, method(mmx)

* 124) mmx_month_arrival_germany

norm month_arrival_germany, method(mmx)

* 125) mmx_income_comp

clonevar income_com = income_compared_to_others
norm income_com, method(mmx)

* 126) mmx_satisfaction_income

clonevar satisfaction_income = satisfaction_with_income_then
norm satisfaction_income, method(mmx)

* 127) mmx_satisfaction_prof

clonevar satisfaction_prof = satisfaction_professional_life
norm satisfaction_prof, method(mmx)

* 128) mmx_economic_sit

clonevar economic_sit = economic_sit_compared_to_others 
norm economic_sit, method(mmx)

* 129) mmx_satisfaction_housing

norm satisfaction_housing, method(mmx)


* 130) mmx_satisfaction_health

norm satisfaction_health, method(mmx)

* 131) mmx_satisfaction_overall

norm satisfaction_overall, method(mmx)

* 132) mmx_years_in_school

norm years_in_school, method(mmx)

* 133) mmx_psych_felt_welcomed

norm psych_felt_welcomed, method(mmx)

* 134) mmx_psych_agency

norm psych_agency, method(mmx)

* 135) mmx_psych_achievement

clonevar psych_achievement = psych_unsatisfied_achievement
norm psych_achievement, method(mmx)

* 136) mmx_psych_dependent_on_luck

norm psych_dependent_on_luck, method(mmx)

* 137) mmx_psych_influence_society

norm psych_influence_society, method(mmx)

* 138) mmx_psych_notselfdet

clonevar psych_notselfdet = psych_not_self_determined
norm psych_notselfdet, method(mmx)

* 139) mmx_psych_success_hard_work

norm psych_success_hard_work, method(mmx)

* 140) mmx_psych_control_over_life 

norm psych_control_over_life, method(mmx)

* 141) mmx_psych_condshapeopp

clonevar psych_condshapeopp = psych_conditions_shape_opp
norm psych_condshapeopp, method(mmx)

* 142) mmx_psych_pos_self_image

norm psych_pos_self_image, method(mmx)

* 143) mmx_psych_risk

norm psych_risk, method(mmx)

* 144) mmx_km

norm km, method(mmx)

* 145) mmx_km_per_day

norm km_per_day, method(mmx)

* 146) satisfaction_health_now & mmx_satisfaction_health_now

tab bgpr298
clonevar satisfaction_health_now = bgpr298 if bgpr298 > -1
norm satisfaction_health_now, method(mmx)

* 147) satisfaction_overall_now & mmx_satisfaction_overall_now 

tab bgpr457
clonevar satisfaction_overall_now = bgpr457 if bgpr457 > -1
rename satisfaction_overall_now satisfaction_now
norm satisfaction_now, method(mmx)


* Normalize variables after data imputation

* 148) mmx_age_imp: normalized age 

clonevar age_imp = age
norm age_imp, method(mmx)

* 149) mmx_cost_transport_imp

clonevar cost_transport_imp = cost_all_transportation_euro
norm cost_transport_imp, method(mmx)

* 150) mmx_cost_accomodation_imp

clonevar cost_accomodation_imp = cost_all_accomodation_euro
norm cost_accomodation_imp, method(mmx)

* 151) mmx_cost_smuggler_imp

clonevar cost_smuggler_imp = cost_all_helper_smuggler_euro
norm cost_smuggler_imp, method (mmx)

* 152) mmx_income_comp_imp

clonevar income_comp_imp = income_compared_to_others
norm income_comp_imp, method(mmx)

* 153) mmx_satisfaction_income_imp

clonevar satisfaction_income_imp = satisfaction_with_income_then
norm satisfaction_income_imp, method(mmx)

* 154) mmx_satisfaction_prof_imp

clonevar satisfaction_prof_imp = satisfaction_professional_life
norm satisfaction_prof_imp, method(mmx)

* 155) mmx_economic_sit_imp

clonevar economic_sit_imp = economic_sit_compared_to_others 
norm economic_sit_imp, method(mmx)

* 156) mmx_satisfaction_housing_imp

clonevar satisfaction_housing_imp = satisfaction_housing
norm satisfaction_housing, method(mmx)

* 157) mmx_sat_healththenimp

clonevar sat_healththenimp = satisfaction_health_then
norm sat_healththenimp, method(mmx)

* 158) mmx_satisfaction_overall

clonevar sat_overallthenimp = satisfaction_overall_then
norm sat_overallthenimp, method(mmx)

* 159) mmx_yearsinschool_imp

clonevar yearsinschool_imp = years_in_school
norm yearsinschool_imp, method(mmx)

* 160) mmx_psychwelcomed_imp 

replace married = 4 if missing(psych_felt_welcomed)
* 53 changes made 
clonevar psychwelcomed_imp = psych_felt_welcomed
norm psychwelcomed_imp, method(mmx)

* 161) mmx_psychagency_imp

replace psych_agency = 7 if missing(psych_agency)
* 290 changes made
clonevar psychagency_imp = psych_agency
norm psychagency_imp, method(mmx)

* 162) mmx_psychachieve_imp


replace psych_achievement = 5 if missing(psych_achievement)
* 388 changes made 
clonevar psychachieve_imp = psych_achievement

norm psychachieve_imp, method(mmx)

* 163) mmx_psychluck_imp 

replace psych_dependent_on_luck = 5 if missing(psych_dependent_on_luck)
* 247 changes made 
clonevar psychluck_imp = psych_dependent_on_luck
norm psychluck_imp, method(mmx)

* 164) mmx_psychinfluencesoc_imp

replace psych_influence_society = 6 if missing(psych_influence_society)
* 436 changes made 

clonevar psychinfluencesoc_imp = psych_influence_society
norm psychinfluencesoc_imp, method(mmx)

* 165) mmx_psychnotselfdet_imp

replace psych_notselfdet = 2 if missing(psych_notselfdet)
* 251 changes made 

clonevar psych_notselfdet_imp = psych_notselfdet
norm psych_notselfdet_imp, method(mmx)

* 166) mmx_psychsuccesswork_imp

replace psych_success_hard_work = 7 if missing(psych_success_hard_work)
* 135 changes made

clonevar psychsuccesswork_imp = psych_success_hard_work

norm psychsuccesswork_imp, method(mmx)

* 167) mmx_psych_control_over_life 

replace psych_control_over_life  = 4 if missing(psych_control_over_life)

clonevar psychcontrol_imp = psych_control_over_life
norm psychcontrol_imp, method(mmx)

* 168) mmx_psych_condshapeopp_imp

replace psych_condshapeopp = 5 if missing(psych_condshapeopp)
* 387 changes made 

clonevar psych_condshapeopp_imp = psych_condshapeopp
norm psych_condshapeopp_imp, method(mmx)

* 169) mmx_psychposimage_imp

replace psych_pos_self_image = 7 if missing(psych_pos_self_image)
* 206 changes made 

clonevar psychposimage_imp = psych_pos_self_image
norm psychposimage_imp, method(mmx)

* 170) mmx_psych_risk_imp

replace psych_risk = 5 if missing(psych_risk)
* 163 changes made 

clonevar psych_risk_imp = psych_risk
norm psych_risk_imp, method(mmx)

* 171) mmx_km_imp

clonevar km_imp = km
norm km_imp, method(mmx)

* 172) mmx_kmperday_imp 

replace km_per_day = 170.55 if missing(km_per_day)
* 139 changes made 

clonevar kmperday_imp = km_per_day
norm kmperday_imp, method(mmx)

* 173) satisfaction_health_now & mmx_satisfaction_health_now

tab bgpr298
clonevar satisfaction_health_now = bgpr298 if bgpr298 > -1
norm satisfaction_health_now, method(mmx)

* 174) satisfaction_overall_now & mmx_satisfaction_overall_now 

tab bgpr457
clonevar satisfaction_overall_now = bgpr457 if bgpr457 > -1
rename satisfaction_overall_now satisfaction_now
norm satisfaction_now, method(mmx)


* create csv sheet for Machine Learning Models using Stata "Export" option
** change end of "export delimited" line to appropriate path on personal computer

export delimited dur fail_1 country1 country2 country3 country4 country5 country6 country7 country8 country9 country10 country11 country12 country13 country14 country15 country16 country17 country18 country19 country20 country21 mmx_km_imp car bus truck train plane ferry small_boat by_foot transportation_other mmx_cost_transport_imp mmx_cost_accomodation_imp mmx_cost_smuggler_imp fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy mmx_age_imp english french mmx_yearsinschool_imp uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity using "/Users/timfingerhut/Documents/FU Berlin 2019/0_Masterarbeit/Code/master_norm1.csv", nolabel replace


* -----------------------------------------------------------------------------------------------------

* Part 4 - Data Analysis: Event History Analysis

* -----------------------------------------------------------------------------------------------------

* Declare the data to be survival data

stset dur fail_1

* Get key descriptive statistics 

stsum 
stdes 

* List and graph Kaplan-Meier nonparametric estimates

sts list 
sts graph, bgcolor(white) graphregion(color(white))

sts graph, tmax(365) bgcolor(white) graphregion(color(white))

sts graph, tmax(20) bgcolor(white) graphregion(color(white))

* Graphing Kaplan-Meier estimates to see group differences

sts graph, by(gender)
sts graph, by(plane) tmax(365) bgcolor(white) graphregion(color(white))

* rename country 19 to Syria

rename country19 Syrian

sts graph, by(Syrian) tmax(365) bgcolor(white) graphregion(color(white))

* Test the equality of the survivor functions for key groups

sts test support_family_friends_in_ger 
sts test country19

* Get the hazard ratio for parametric models (to compare to Cox model) 

streg, d(e)

* Get the hazard ratio for Cox model 

stcox, estimate 
* above is the null model

stcox gender
stphtest, d

* PH Test for Fraud and Train Variables

stphtest

* Graphing hazarad curve

stcurve, haz bgcolor(white) graphregion(color(white))
stcurve, haz at1(plane = 0) at2(plane = 1)

stcox gender, tvc(gender)
* gender interacts linearly with time 

* fit cox regression  

stcox gender age i.country_of_birth car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger english french income_compared_to_others practical_uni theoretical_uni phd religion_islam religion_christianity married kids km

* get concordance index

estat concordance



placeholder

* fit cox regression 

stcox gender age i.country_of_birth car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity married kids km 

stphtest, d


* 27.05.19

stcox gender age i.birth_country car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity married km support_family_friends_in_ger 

* 07.06.19

stcox i.birth_country km car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  

* with transport, km, smuggler, accomodation on 1000€ sclae

stcox i.birth_country km1000 car bus truck train plane ferry small_boat by_foot transportation_other cost_transport_1000 cost_accomodation_1000 cost_smuggler_1000 fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  


* check for violations of the PH assumption

stphtest, d

stphtest, plot(car) bgcolor(white) graphregion(color(white))
stphtest, plot(by_foot) bgcolor(white) graphregion(color(white))
stphtest, plot(train) bgcolor(white) graphregion(color(white))
stphtest, plot(neg_fraud) bgcolor(white) graphregion(color(white))

* Check whether variables indeed seriously violate PH assumption 

stcox i.birth_country km car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity, tvc(country6 car train by_foot cost_all_transportation_euro)  

* with km, transport, smuggler and accomodation on 1000 scale 

stcox i.birth_country km1000 car bus truck train plane ferry small_boat by_foot transportation_other cost_transport_1000 cost_accomodation_1000 cost_smuggler_1000 fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity, tvc(country6 car train by_foot cost_transport_1000)  


/* Lilelihood ratio test

The standard way to use lrtest is to do the following:
1. Fit either the restricted model or the unrestricted model 
by using one of Stata’s estimation commands and then store the results using estimates 
store name.
2. Fit the alternative model (the unrestricted or restricted model) and then type 
‘lrtest name .’. lrtest determines for itself which of the two models is the restricted 
model by comparing the degrees of freedom.
*/

estimates store no_tvc

lrtest no_tvc


* Check the consistency of conclusions by specifying additional models:
*`1) Excluding top outliers

* drop top 5% of outliers --> all those with journey duration over 160 days

sum dur, d
drop if dur > 160

* 129 observations deleted

stcox i.birth_country km car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  

outreg2 using regression_results, eform append excel dec(3) 


* 2) Excluding 5% of overall outliers, then keeping check geographical conclusions for Syrians 

drop if dur > 160

keep if birth_country == 19 

stcox i.birth_country km car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  

outreg2 using regression_results, eform append excel dec(3) 

* 3) Excluding those who travelled by plane from Syrian sample

drop if plane == 1

* run regression as usual 
outreg2 using regression_results2, eform replace excel dec(3)

* 4) control for home region in Syria 

drop if region_syria == -1 

stcox i.region_syria km car bus truck train plane ferry small_boat by_foot transportation_other cost_all_transportation_euro cost_all_accomodation_euro cost_all_helper_smuggler_euro fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  

* home region syria with 1000 scale for km, transport, smuggling and accomodation

stcox i.region_syria km1000 car bus truck train plane ferry small_boat by_foot transportation_other cost_transport_1000 cost_accomodation_1000 cost_smuggler_1000 fin_savings fin_sold_assets fin_casual_work fin_family fin_friends fin_credit fin_other arrival_alone arrival_with_family arrival_with_friends arrival_with_other_persons support_family_friends_in_ger married gender neg_fraud neg_sexual_harassment neg_physical_abuse neg_shipwreck neg_robbery neg_blackmail neg_prison no_neg_dummy age english french years_in_school uni_apprentice_abroad practical_uni theoretical_uni phd religion_islam religion_christianity  

* ttest for equality of means for transportation euros by (no) negative experience

ttest cost_all_transportation_euro, by(no_neg_dummy)

ttest dur, by(train)

ttest dur, by(arrival_with_family)

** add ", nohr" for exponentiated coefficients 

* Outreg2 for regression table outputs
ssc install outreg2
outreg2 using regression_results, eform replace excel dec(3)
outreg2 using regression_results, eform append excel dec(3) 

outreg2 using regression_results1607, eform append excel dec(3)


* -----------------------------------------------------------------------------------------------------
