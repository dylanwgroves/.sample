	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Analysis Prelimenary Work
Author: dylan groves, dylanwgroves@gmail.com
Date: 2020/12/23l


	This mostly just subsets the data and does anything else necessary before
	running the analysis
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	
/* Tempfiles ___________________________________________________________________*/	

	tempfile temp_attend

	
/* Load Data ___________________________________________________________________*/	

	use "${data}/03_final_data/pfm_appended_prefix.dta", clear

/* Set Seed ____________________________________________________________________*/

	set seed 1956
	
/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* kidssample* endline_as svy_enum rd_treat sample_rd_pull resp_female resp_age resp_muslim s20q1b id_village_uid id_village_n id_village_c id_ward_c id_ward_n id_ward_uid id_district_c id_district_n b_cases_subvillage_name b_s1q9_subvillage
	order id_* kidssample* endline_as svy_enum 
	
/* Select Closes Friend (Remove if Family Member) ______________________________*/
	keep if endline_as == 1
	keep if kidssample_kidnum > 0 & kidssample_kidnum != .	

	reshape long kidssample_fullname_ kidssample_gender_ kidssample_age_, j(kidnum) i(id_resp_uid)

	egen id_kidresp_uid = concat(id_resp_uid kidnum), punct("_")

	
	/* Drop Kids Too Young */
	drop if kidssample_age < 13 | kidssample_age > 18
	drop if kidssample_age == .
stop
	/* Subvillage Name and Code */
	rename b_s1q9_subvillage id_subvillage_n 

	/* Create Unique Numeric Indicator */
	encode id_district_n, gen(id_district_uid_c)
	encode id_ward_uid, gen(id_ward_uid_c)
	encode id_village_uid, gen(id_village_uid_c)
	encode id_subvillage_n, gen(id_subvillage_uid_c)
	
	/* Name in Finals */
	bys id_resp_n : egen kid_num = count(kidssample_kidnum)
	
	/* Randomize Order */	
	gen random_1 = runiform()
	gen random_2 = runiform()	
	sort random_1 random_2
	bys id_resp_uid : gen kidrank = _n
	sort id_resp_uid kidrank
	drop random_1 random_2
	rename rd_treat rd_treat
	rename sample_rd_pull rd_sample

	drop kidssample_name*

	/* Reshape Wide 
	reshape wide kidssample_fullname_ kidssample_gender_ kidssample_age_, j(kidrank) i(id_resp_uid)
	*/

	rename kidssample_*_ kidssample_* 
	drop id_object id_pull id_re 
	order id_village_uid id_village_n id_resp_uid id_resp_n kidssample_consent id_* kidnum
	keep  id_kidresp_uid id_village_uid id_village_n id_resp_uid id_resp_n kidssample_consent kidssample_fullname* kidssample_gender* kidssample_age* kid_num id* kidnum rd_treat rd_sample
	
	/* Save */
	save "${data_as}/pfm_kids_sample.dta", replace
	save "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\09_Kids\pfm_kids_sample.dta", replace
	export delimited using "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\09_Kids\pfm_kids_sample.csv", nolabel replace

		
