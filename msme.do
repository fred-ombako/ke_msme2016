clear
set more off
use "G:\My Drive\2. Personal Projects\1. Research Projects\1. Data Resources\msme2016.dta"

*------------------------------------------------------------------------------
*--------- Gendered analysis of credit access by MSMEs in Kenya ---------
*------------------------------------------------------------------------------

// Cleaning and preparing the dataset

ds, has(type string)
foreach var of varlist `r(varlist)' {
    encode `var', generate(n_`var')
}
// Dropping all string variables
describe
ds, has(type string)
drop `r(varlist)'

// Generating variables

gen sex_ownership = .
replace sex_ownership = 1 if ej13 == 1 | ej13 == 3 
replace sex_ownership = 2 if ej13 == 2 | ej13 == 4
replace sex_ownership = 3 if ej13 == 5
label var sex_ownership "Gender of MSME owner(s)"
label define sex_own 1"Male" 2"Female" 3"Mixed"
label value sex_ownership sex_own
drop ej13

gen decision_maker = .
replace decision_maker = 1 if eb16_1 ==1
replace decision_maker = 2 if eb16_1 ==2
replace decision_maker = 3 if eb16_1 ==3
replace decision_maker = 4 if eb16_1 ==-96
label var decision_maker "Main decision maker for the business"
label define decision 1"Owner/co-owner" 2"Board/committee members" 3"Managers" 4"Other"
label value decision_maker decision
drop eb16_1

gen male_empl_start = ed01 
label var male_empl_start "Number of male employees at start"
drop ed01

gen female_empl_start = ed02 
label var female_empl_start "Number of female employees at start"
drop ed02

egen tot_empl_start = rowtotal(male_empl_start female_empl_start)
label var tot_empl_start "Total number of employees at start"

gen msme_cat_start = .
replace msme_cat_start = 1 if tot_empl_start<=9
replace msme_cat_start = 2 if tot_empl_start>=10 & tot_empl_start<=49
replace msme_cat_start = 3 if tot_empl_start>=50 & tot_empl_start<=99 
replace msme_cat_start = 4 if tot_empl_start>=100
label var msme_cat_start "MSME category at start"
label define msme_cat 1"Micro enterprise" 2"Small enterprise" 3"Medium enterprise" 4"Large enterprise"
label value msme_cat_start total_emply

rename total_males_emp male_empl_end
label var male_empl_end "Current number of male employees"

rename total_females_emp female_empl_end
label var female_empl_end "Current number of female employees" 

rename total_employees tot_empl_end 
label var tot_empl_end "Current total number of employees"

rename total_emply msme_cat_end 
label var msme_cat_end "Current MSME category"

gen monthly_inc = eh04_1
label var monthly_inc "Monthly income"
drop eh04_1

label var tot_exp "Total expenditure"

gen industry = .
replace industry = 1 if eb14_2>=45 | eb14_2<=47
replace industry = 2 if eb14_2<=43 | eb14_2>=49
label var industry "Main business activity" 
label define industry 1"Wholesale and retail" 2"Other activity"
label value industry industry
drop eb14_2

gen msme_perf = eh09 
label var msme_perf "Business performance"
label value msme_perf eh09
drop eh09

gen own_structure = .
replace own_structure = 1 if ej14==1 
replace own_structure = 2 if ej14==2
replace own_structure = 3 if ej14==3
replace own_structure = 4 if ej14==-96 | ej14>=4
label var own_structure "Ownership structure"
label define structure 1"Family" 2"Sole proprietor" 3"Partnership" 4"Other" 
label value own_structure structure
drop ej14

gen msme_reg = ej15
label var msme_reg "Business registration status"
label value msme_reg ej15
drop ej15

gen county = county11
label var county "County"
label value county county_label1
drop county11

gen credit_applied_3 = em01
label var credit_applied "Applied for credit in the last 3 years"
label value credit_applied em01
drop em01

gen credit_applied_amt = em02
label var credit_applied_amt "Amount of credit applied, in KES"
label value credit_applied_amt em02
drop em02

gen credit_received_amt = em03
label var credit_received_amt "Amount of credit received, in KES"
label value credit_received_amt em03
drop em03

gen credit_source = . if credit_applied_3==1  // for the sub-pop that applied for credit 
replace credit_source = 1 if em04==13 & credit_applied_3==1
replace credit_source = 2 if em04==2 & credit_applied_3==1
replace credit_source = 3 if em04==14 & credit_applied_3==1
replace credit_source = 4 if em04==5 & credit_applied_3==1
replace credit_source = 5 if em04<=1 |em04>=3 & em04<=12 | em04>=15 & credit_applied_3==1
label var credit_source "Source of credit"
label define source 1"Commercial banks" 2"Microfinance Institutions" 3"SACCOs" /*
*/ 4"Self-help groups" 5"Other"
label value credit_source source
drop em04

replace em05 = 7 if em05==-96

gen credit_purpose = em05
label var credit_purpose "Purpose of credit"
label define em05 1"Purchase inventory" 2"Working capital" 3"Refubishing business" /*
*/ 4"Pay debt" 5"Non-business purpose" 6"Starting another business" 7"Other", replace
label value credit_purpose em05
drop em05

gen credit_adeq = .
replace credit_adeq = 1 if em06a==1
replace credit_adeq = 0 if em06a==0
label var credit_adeq "Credit adequacy"
label define adeq 1"Yes" 0"No"
label value credit_adeq adeq
drop em06a

replace em06b = 4 if em06b==-96

gen credit_inadeq_reason = em06b 
label var credit_inadeq_reason "Reason for credit inadequacy"
label define em06b 1"Lack of collateral" 2"High interest rate" 3"Lender ceiling" 4"Other", replace
label value credit_inadeq_reason em06b
drop em06b

replace em07 = 5 if em07==-96

gen credit_info_source = em07
label var credit_info_source "Source of credit information"
label define em07 1"Print & electronic media" 2"Advertisements" 3"Brochures" 4"Billboards" 5"Other", replace
label value credit_info_source em07
drop em07

gen credit_applied_1 = em08a // last 12 months
label var credit_applied_1 "Applied for credit in the last 1 year"
label value credit_applied_1 em08a
drop em08a

gen credit_denied = . // of the people who applied for credit in the last 12 months
replace credit_denied = 0 if em08b==0
replace credit_denied = 1 if em08b==1
label var credit_denied "MSME was denied credit"
label define denied 1"Yes" 0"No"
label value credit_denied denied
drop em08b

gen credit_denied_by = . if credit_denied == 1   // of the people who were denied credit 
replace credit_denied_by = 1 if em09==1 & credit_denied == 1
replace credit_denied_by = 2 if em09==2 & credit_denied == 1
replace credit_denied_by = 3 if em09==5 & credit_denied == 1
replace credit_denied_by = 4 if em09==-96 | em09==3 | em09>=6 & credit_denied == 1
label var credit_denied_by "Institution denying credit"
label define em09 1"Commercial banks" 2"Microfinance Institutions" 3"SACCOs" /*
*/ 4"Other", replace
label value credit_denied_by em09
drop em09

replace em10_1 = . if em10_1==1 & credit_applied_3==0 | credit_applied_1==0 // last 1-3 years (both)

gen reason1_notborrow = .
replace reason1_notborrow = 0 if em10_1==0 & credit_applied_3==0 | credit_applied_1==0
replace reason1_notborrow = 1 if em10_1==3 & credit_applied_3==0 | credit_applied_1==0
replace reason1_notborrow = 2 if em10_1==6 & credit_applied_3==0 | credit_applied_1==0
replace reason1_notborrow = 3 if em10_1==5 & credit_applied_3==0 | credit_applied_1==0
replace reason1_notborrow = 4 if em10_1==4 & credit_applied_3==0 | credit_applied_1==0
replace reason1_notborrow = 5 if em10_1==-96 | em10_1==2 | em10_1>=7 & credit_applied_3==0 | credit_applied_1==0
label var reason1_notborrow "Most important reason for not borrowing"
label define notborrow1 0"No need" 1"Too expensive" 2"Do not like to be in debt" /*
*/ 3"Inadequate collateral" 4"Too much trouble" 5"Others"
label value reason1_notborrow notborrow1
drop em10_1

replace em10_2 = . if em10_2==1 & credit_applied_3==0 | credit_applied_1==0

gen reason2_notborrow = .
replace reason2_notborrow = 0 if em10_2==0 & credit_applied_3==0 | credit_applied_1==0
replace reason2_notborrow = 1 if em10_2==3 & credit_applied_3==0 | credit_applied_1==0
replace reason2_notborrow = 2 if em10_2==6 & credit_applied_3==0 | credit_applied_1==0
replace reason2_notborrow = 3 if em10_2==5 & credit_applied_3==0 | credit_applied_1==0
replace reason2_notborrow = 4 if em10_2==4 & credit_applied_3==0 | credit_applied_1==0
replace reason2_notborrow = 5 if em10_2==-96 | em10_2==2 | em10_2>=7 & credit_applied_3==0 | credit_applied_1==0
label var reason2_notborrow "2nd most important reason for not borrowing"
label define notborrow2 0"No need" 1"Too expensive" 2"Do not like to be in debt" /*
*/ 3"Inadequate collateral" 4"Too much trouble" 5"Others"
label value reason2_notborrow notborrow2
drop em10_2

replace em10_3 = . if em10_3==1 & credit_applied_3==0 | credit_applied_1==0

gen reason3_notborrow = .
replace reason3_notborrow = 0 if em10_3==0 & credit_applied_3==0 | credit_applied_1==0
replace reason3_notborrow = 1 if em10_3==3 & credit_applied_3==0 | credit_applied_1==0
replace reason3_notborrow = 2 if em10_3==6 & credit_applied_3==0 | credit_applied_1==0
replace reason3_notborrow = 3 if em10_3==5 & credit_applied_3==0 | credit_applied_1==0
replace reason3_notborrow = 4 if em10_3==4 & credit_applied_3==0 | credit_applied_1==0
replace reason3_notborrow = 5 if em10_3==-96 | em10_3==2 | em10_3>=7 & credit_applied_3==0 | credit_applied_1==0
label var reason3_notborrow "3rd most important reason for not borrowing"
label define notborrow3 0"No need" 1"Too expensive" 2"Do not like to be in debt" /*
*/ 3"Inadequate collateral" 4"Too much trouble" 5"Others"
label value reason3_notborrow notborrow3
drop em10_3

replace em11 = . if em11==-98 | em11==-99

gen account = em11
label var account "MSME runs business account"
label define account 1"Yes" 0"No" 
label value account account
drop em11

gen account_inst = . 
replace account_inst = 1 if em12==1
replace account_inst = 2 if em12==2
replace account_inst = 3 if em12==5
replace account_inst = 4 if em12==-96 | em12>=3 & em12<=4 | em12>=6
label define em12 1"Commercial banks" 2"Microfinance Institutions" 3"SACCOs" /*
*/ 4"Other", replace
label var account_inst "Business account's institution"
label value account_inst em12
drop em12

gen inst2 = account_inst if account==1
label var inst2 "Business account's institution"
label value inst2 em12

gen bus_const1 = .
replace bus_const1 = 0 if em13==0
replace bus_const1 = 1 if em13==6
replace bus_const1 = 2 if em13==8 | em13==9
replace bus_const1 = 3 if em13==3
replace bus_const1 = 4 if em13==-96 | em13>=1 & em13<=2 | em13>=4 & em13<=5 | em13==7 | em13>=10
label define bus_const 0"None" 1"Lack of markets" 2"Competition" 3"Licences" 4"Others"
label var bus_const1 "Most serious business constraint"
label value bus_const1 bus_const
drop em13

gen bus_const2 = .
replace bus_const2 = 0 if em14==0
replace bus_const2 = 1 if em14==6
replace bus_const2 = 2 if em14==8 | em14==9
replace bus_const2 = 3 if em14==3
replace bus_const2 = 4 if em14==-96 | em14>=1 & em14<=2 | em14>=4 & em14<=5 | em14==7 | em14>=10
label define bus_const2 0"None" 1"Lack of markets" 2"Competition" 3"Licences" 4"Others"
label var bus_const2 "2nd most serious business constraint"
label value bus_const2 bus_const2
drop em14


gen bus_const3 = .
replace bus_const3 = 0 if em15==0
replace bus_const3 = 1 if em15==6
replace bus_const3 = 2 if em15==8 | em15==9
replace bus_const3 = 3 if em15==3
replace bus_const3 = 4 if em15==-96 | em15>=1 & em15<=2 | em15>=4 & em15<=5 | em15==7 | em15>=10
label define bus_const3 0"None" 1"Lack of markets" 2"Competition" 3"Licences" 4"Others"
label var bus_const3 "3rd most serious business constraint"
label value bus_const3 bus_const3
drop em15

gen educ = .
replace educ = 0 if ee01>=0 & ee01<=3
replace educ = 1 if ee01>=4 & ee01<=11
replace educ = 2 if ee01>=13 & ee01<=18
replace educ = 3 if ee01==19
replace educ = 4 if ee01>=20 & ee01<=25
replace educ = 5 if ee01>=26 
replace educ = 6 if ee01==12 | ee01==-96
replace educ = 7 if ee01==-98
label var educ "Highest level of education"
label define educ 0"None or below primary" 1"Primary" 2"Secondary" /*
*/ 3"Mid-level college diploma/certificate" 4"Undergraduate degree" 5"Post-graduate degree" /*
*/ 6"Vocational/Youth polytechnic/Other" 7"Do not know"
label value educ educ
drop ee01

gen received_yes = 1 if credit_denied == 0
replace received_yes = 0 if credit_denied==1
label var received_yes "MSME received credit"

gen applied_no = 1 if credit_applied_3 == 0
replace applied_no = 0 if credit_applied_3==1
label var applied_no "Did not apply for credit in the last 3 years"

gen applied_no2 = 1 if credit_applied_1==0
replace applied_no2 = 0 if credit_applied_1==1
label var applied_no2 "Did not apply for credit in the last 12 months"

gen adequate_no = 1 if credit_adeq ==0
replace adequate_no = 0 if credit_adeq==1
label var adequate_no "Credit not adequate - bank rationing"

gen c_applied = .   // applied for credit, general 
replace c_applied = 1 if credit_applied_3==1 | credit_applied_1==1
replace c_applied = 0 if credit_applied_3==0 | credit_applied_1==0

gen credit_access = (credit_denied==0) if credit_applied_3==1 | credit_applied_1==1 // applied for and got credit 

gen is_male = 1 if sex_ownership==1
gen is_female = 1 if sex_ownership==2
gen is_mixed = 1 if sex_ownership==3

generate fin_gap = credit_applied_amt - credit_received_amt // financing gap
label var fin_gap "MSME Financing Gap"

// Data analysis 

* Descriptive and bivariate statistics 

tabulate msme_cat_start sex_ownership, col
tabulate msme_cat_end sex_ownership, col // change in MSME categories over time

tab credit_applied_3 sex_ownership, col
tab credit_applied_1 sex_ownership, col
tab credit_source sex_ownership, col
tab credit_purpose sex_ownership, col
tab credit_adeq sex_ownership, col
tab credit_inadeq_reason sex_ownership, col
tab credit_info_source sex_ownership, col
tab credit_denied sex_ownership, col
tab credit_denied_by sex_ownership, col
tab reason1 sex_ownership, col
tab reason2 sex_ownership, col
tab reason3 sex_ownership, col


bysort sex_ownership: sum monthly_inc if msme_cat_end ==1 // income if micro
bysort sex_ownership: sum monthly_inc if msme_cat_end ==2
bysort sex_ownership: sum monthly_inc if msme_cat_end ==3
bysort sex_ownership: sum monthly_inc if msme_cat_end ==4 // income if large
bysort sex_ownership: sum monthly_inc // monthly incomes by sex of owner/s
bysort msme_cat_end: sum monthly_inc // monthly incomes by msme category
bysort sex_ownership: sum tot_exp // total expenditure 
bysort sex_ownership: sum tot_empl_end // size of business 
bysort sex_ownership: sum credit_applied_amt
bysort sex_ownership: sum credit_received_amt 

* Mean differences 
global credit_access credit_applied_3 credit_access credit_applied_amt credit_received_amt credit_source credit_purpose /* 
*/ credit_adeq credit_inadeq_reason credit_info_source credit_applied_1 credit_denied credit_denied_by // credit access 

* Descriptive analysis for business and owner characteristics

tab sex_ownership
tab own_structure sex_ownership, col
tab educ sex_ownership, col
tab msme_reg sex_ownership, col
tab industry sex_ownership, col
tab msme_cat_end sex_ownership, col
bysort sex_ownership: sum tot_empl_end male_empl_end female_empl_end

* Descriptive analysis for business operations and constraints

tab decision_maker sex_ownership, col
tab account sex_ownership, col
tab inst2 sex_ownership, col 
tab bus_const1 sex_ownership, col
tab bus_const2 sex_ownership, col
tab bus_const3 sex_ownership, col

* Descriptive analysis for business performance

tab msme_perf sex_ownership, col
bysort sex_ownership: sum monthly_inc tot_exp 
sum monthly_inc tot_exp 
tab msme_cat_start msme_cat_end, row
bysort sex_ownership: tab msme_cat_start msme_cat_end, row
bysort sex_own: sum male_empl_start female_empl_start tot_empl_start male_empl_end female_empl_end tot_empl_end
sum male_empl_start female_empl_start tot_empl_start male_empl_end female_empl_end tot_empl_end

* Descriptive analysis for credit access
tab credit_applied_3 sex_ownership, col
tab credit_applied_1 sex_ownership, col
bysort sex_ownership: sum credit_applied_amt 
sum credit_applied_amt 					// credit demand
tab account sex_ownership if credit_applied_3==1, col nofreq
tab account_inst sex_ownership if credit_applied_3==1, col nofreq

bysort credit_source: sum credit_applied_amt
bysort credit_source: sum credit_applied_amt if sex_ownership==1
bysort credit_source: sum credit_applied_amt if sex_ownership==2
bysort credit_source: sum credit_applied_amt if sex_ownership==3	// size of credit applied by source

tab received_yes sex_ownership, col
bysort sex_ownership: sum credit_received_amt 
sum credit_received_amt
tab credit_adeq sex_ownership, col
tab credit_source sex_ownership, col
tab credit_purpose sex_ownership, col
tab credit_info_source sex_ownership, col	// credit access

bysort credit_source: sum credit_received_amt
bysort credit_source: sum credit_received_amt if sex_ownership==2
bysort credit_source: sum credit_received_amt if sex_ownership==3
bysort credit_source: sum credit_received_amt if sex_ownership==1 // size of credit received by source

* Descriptive analysis for credit rationing
tab applied_no sex_ownership, col
tab applied_no2 sex_ownership, col
tab credit_denied sex_ownership, col
tab credit_denied_by sex_ownership, col
tab reason1_notborrow sex_ownership, col
tab adequate_no sex_ownership, col
tab credit_inadeq_reason sex_ownership, col

tab credit_source sex_ownership if credit_denied==1, col nofreq
tab credit_source sex_ownership, col nofreq
tab credit_purpose sex_ownership if credit_denied==1, col nofreq
tab credit_purpose sex_ownership if credit_adeq==0, col nofreq
tab credit_source sex_ownership if credit_adeq==0, col nofreq
tab credit_source sex_ownership if credit_inadeq_reason==1, col nofreq
tab credit_source sex_ownership if credit_inadeq_reason==2, col nofreq
tab credit_source sex_ownership if credit_inadeq_reason==3, col nofreq
tab account_inst sex_ownership if credit_applied_3==0, col nofreq
tab account sex_ownership if credit_applied_3==0, col nofreq

* Descriptive analysis for financing gap
total credit_applied_amt
total credit_applied_amt if sex_ownership==1
total credit_applied_amt if sex_ownership==2
total credit_applied_amt if sex_ownership==3	// total credit demand, by gender

total credit_received_amt
total credit_received_amt if sex_ownership==1
total credit_received_amt if sex_ownership==2
total credit_received_amt if sex_ownership==3  	// total credit supply, by gender

total fin_gap						// total financing gap for all MSMEs
total fin_gap if sex_ownership==1
total fin_gap if sex_ownership==2
total fin_gap if sex_ownership==3   // financing gap by sex of ownership

total fin_gap if msme_cat_end==1
total fin_gap if msme_cat_end==2
total fin_gap if msme_cat_end==3
total fin_gap if msme_cat_end==4   // financing gap by MSME category

total fin_gap if msme_cat_end==1 & sex_ownership==1
total fin_gap if msme_cat_end==2 & sex_ownership==1
total fin_gap if msme_cat_end==3 & sex_ownership==1
total fin_gap if msme_cat_end==4 & sex_ownership==1  // financing gap for male, by MSME category

total fin_gap if msme_cat_end==1 & sex_ownership==2
total fin_gap if msme_cat_end==2 & sex_ownership==2
total fin_gap if msme_cat_end==3 & sex_ownership==2
total fin_gap if msme_cat_end==4 & sex_ownership==2   // financing gap for females, by MSME category

total fin_gap if msme_cat_end==1 & sex_ownership==3
total fin_gap if msme_cat_end==2 & sex_ownership==3
total fin_gap if msme_cat_end==3 & sex_ownership==3
total fin_gap if msme_cat_end==4 & sex_ownership==3   // financing gap for mixed, by MSME category

total fin_gap if account_inst==1
total fin_gap if account_inst==2
total fin_gap if account_inst==3
total fin_gap if account_inst==4			// financing gap by institution

total fin_gap if account_inst==1 & sex_ownership==1
total fin_gap if account_inst==2 & sex_ownership==1
total fin_gap if account_inst==3 & sex_ownership==1
total fin_gap if account_inst==4 & sex_ownership==1		// financing gap for male, by account institution

total fin_gap if account_inst==1 & sex_ownership==2
total fin_gap if account_inst==2 & sex_ownership==2
total fin_gap if account_inst==3 & sex_ownership==2
total fin_gap if account_inst==4 & sex_ownership==2		// financing gap for female, by account institution

total fin_gap if account_inst==1 & sex_ownership==3
total fin_gap if account_inst==2 & sex_ownership==3
total fin_gap if account_inst==3 & sex_ownership==3
total fin_gap if account_inst==4 & sex_ownership==3		// financing gap for mixed, by account institution

total fin_gap if credit_purpose==1
total fin_gap if credit_purpose==2
total fin_gap if credit_purpose==3
total fin_gap if credit_purpose==4
total fin_gap if credit_purpose==5
total fin_gap if credit_purpose==6
total fin_gap if credit_purpose==7					// financing gap by credit purpose

total fin_gap if credit_purpose==1 & sex_ownership==1
total fin_gap if credit_purpose==2 & sex_ownership==1
total fin_gap if credit_purpose==3 & sex_ownership==1
total fin_gap if credit_purpose==4 & sex_ownership==1
total fin_gap if credit_purpose==5 & sex_ownership==1
total fin_gap if credit_purpose==6 & sex_ownership==1
total fin_gap if credit_purpose==7 & sex_ownership==1		// financing gap for male, by credit purpose

total fin_gap if credit_purpose==1 & sex_ownership==2
total fin_gap if credit_purpose==2 & sex_ownership==2
total fin_gap if credit_purpose==3 & sex_ownership==2
total fin_gap if credit_purpose==4 & sex_ownership==2
total fin_gap if credit_purpose==5 & sex_ownership==2
total fin_gap if credit_purpose==6 & sex_ownership==2
total fin_gap if credit_purpose==7 & sex_ownership==2		// financing gap for female, by credit purpose

total fin_gap if credit_purpose==1 & sex_ownership==3
total fin_gap if credit_purpose==2 & sex_ownership==3
total fin_gap if credit_purpose==3 & sex_ownership==3
total fin_gap if credit_purpose==4 & sex_ownership==3
total fin_gap if credit_purpose==5 & sex_ownership==3
total fin_gap if credit_purpose==6 & sex_ownership==3
total fin_gap if credit_purpose==7 & sex_ownership==3		// financing gap for mixed, by credit purpose

* Testing mean differences by gender of MSME ownership 

global msme_folder "G:\My Drive\2. Personal Projects\1. Research Projects\1. Data Resources"

global business_features own_structure educ msme_reg industry msme_cat_end /*
*/ tot_empl_end male_empl_end female_empl_end // global var for owner and business characteristics

iebaltab $business_features, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/xtics_table1.xlsx") replace ftest rowvarlabel // t-test for business and owner characteristics

global operations_const decision_maker account inst2 /*
*/ bus_const1 bus_const2 bus_const3 // global var for business operations and constraints

iebaltab $operations_const, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/ops_table1.xlsx") replace ftest rowvarlabel // t-test for business operations and constraints

global performance monthly_inc tot_exp msme_perf // global var for business performance 

iebaltab $performance, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/perf_table1.xlsx") replace ftest rowvarlabel // t-test for business performance

global credit_demand credit_applied_3 credit_applied_1 credit_applied_amt	// global var for credit demand

iebaltab $credit_demand, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/demand_table1.xlsx") replace ftest rowvarlabel // t-test for credit demand

global credit_access received_yes credit_received_amt credit_adeq /*
*/ credit_source credit_purpose credit_info_source			// global var for credit access

iebaltab $credit_access, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/access_table1.xlsx") replace ftest rowvarlabel // t-test for credit access

global credit_rationing applied_no reason1_notborrow reason2_notborrow /*
*/ reason3_notborrow credit_denied credit_denied_by adequate_no /*
*/ credit_inadeq_reason			// global var for credit rationing

iebaltab credit_denied credit_denied_by, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/ration_table1a.xlsx") replace ftest rowvarlabel // t-test for credit rationing - part A

iebaltab applied_no applied_no2 reason1_notborrow reason2_notborrow /*
*/ reason3_notborrow adequate_no credit_inadeq_reason, grpvar(sex_ownership) vce(cluster county) /*
*/ savexlsx("$msme_folder/ration_table1b.xlsx") replace ftest rowvarlabel // t-test for credit rationing - part B

* Credit gender gap

tab county sex_ownership if credit_applied_1==1
tab county credit_applied_1 if credit_applied_1==1, col
tab county sex_ownership if credit_applied_3==1
tab county sex_ownership if credit_applied_1==1, row  // credit application by county and gender

tab county sex_ownership if credit_denied==0
tab county sex_ownership if credit_denied==0, row		// credit receipt by county and gender

* Gender gap by size of business
tab msme_cat_end sex_ownership if credit_applied_1==1	// credit applied by size and gender
tab msme_cat_end sex_ownership if credit_denied==0		// credit receipt by size and gender

* Gender gap by financial institutions
tab credit_source sex_ownership if credit_applied_1==1	// credit applied by source and gender
tab credit_source sex_ownership if credit_denied==0		// credit receipt by source and gender
