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

	use "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\03_clean\audio_screening_survey_pilot_output.dta", clear

/* Extract Data ________________________________________________________________*/

	gen id_village_uid = substr(id,1,6)
	gen uid = _n
	gen id_resp_n = resp_name

/* Set Seed ____________________________________________________________________*/

	set seed 1956
	
/* Keep Certain Variables ______________________________________________________*/

	*keep id_* kidssample* endline_as svy_enum rd_treat sample_rd_pull resp_female resp_age resp_muslim s20q1b id_village_uid id_village_n id_village_c id_ward_c id_ward_n id_ward_uid id_district_c id_district_n b_cases_subvillage_name b_s1q9_subvillage b_resp_hhh
	order id_* kidssample*
	
/* Select Closes Friend (Remove if Family Member) ______________________________*/

	keep if kidssample_kidnum > 0 & kidssample_kidnum != .	

	reshape long kidssample_fullname_ kidssample_gender_ kidssample_age_, j(kidnum) i(uid)

	egen id_kidresp_uid = concat(uid kidnum), punct("_")

	
	/* Drop Kids Too Young */
	drop if kidssample_age < 13 | kidssample_age > 18
	drop if kidssample_age == .

	/* Name in Finals */
	bys id_resp_n : egen kid_num = count(kidssample_kidnum)
	
	/* Randomize Order */	
	gen random_1 = runiform()
	gen random_2 = runiform()	
	sort random_1 random_2
	bys uid : gen kidrank = _n
	sort uid kidrank
	drop random_1 random_2

	drop kidssample_name*

	/* Reshape Wide 
	reshape wide kidssample_fullname_ kidssample_gender_ kidssample_age_, j(kidrank) i(uid)
	*/

	rename kidssample_*_ kidssample_* 
	order id_village_uid uid id_resp_n kidssample_consent id_* kidnum
	keep  id_kidresp_uid id_village_uid uid id_resp_n kidssample_consent kidssample_fullname* kidssample_gender* kidssample_age* kid_num id* kidnum
	
	/* Save
	save "${data_as}/pfm_kids_sample.dta", replace
	save "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\09_Kids\pfm_kids_sample.dta", replace
	export delimited using "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\09_Kids\pfm_kids_sample.csv", nolabel replace
	 */
/* Generate kids mobilization form */
keep id_resp_uid id_village_uid uid id_resp_n kidssample_fullname id_kidresp_uid kidssample_age kidssample_gender kidssample_consent
	order id_resp_uid uid id_resp_n id_kidresp_uid kidssample_fullname kidssample_age kidssample_gender kidssample_consent
	label variable id_village_uid "Village"
	label variable uid "Original Resp ID"
	label variable id_resp_n "Original Resp Name"
	label variable id_kidresp_uid "Kid ID"
	label variable kidssample_fullname "Kid Name"
	label variable kidssample_age "Age"
	label variable kidssample_gender "Gender"
	label variable kidssample_consent "Consent"

sort id_village_uid 

	/* Save */
	export excel using "X:\Box Sync\19_Community Media Endlines\07_Questionnaires & Data\07_AS\05_data_encrypted\02_survey\03_clean\audio_screening_survey_pilot_output_kids.xlsx", firstrow(varlabels) replace



		
