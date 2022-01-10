	
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

/* Subset Data _________________________________________________________________*/	
	
	/* Get correct sample */
	keep if sample == "as"
	drop ne_*
	rename as_* *																// Get rid of prefix
	
	
/* Keep Certain Variables ______________________________________________________*/

	keep id_* comsample* s33q2_oth_r endline_as svy_enum s33q3_b_oth svy_enum rd_treat sample_rd_pull m_resp_phone1 m_resp_phone2 resp_female resp_age resp_muslim s20q1b
	

/* Select Closes Friend (Remove if Family Member) ______________________________*/

	
	gen id_friend_n = comsample_1_name if comsample_1_fam == 0 
	gen friend_rltn = comsample_1_rltn if comsample_1_fam == 0 

		replace id_friend_n = comsample_2_name if comsample_1_fam == 1 | comsample_1_name == "" | comsample_1_fam == 2
		replace friend_rltn = comsample_2_rltn if comsample_1_fam == 1 | comsample_1_name == "" | comsample_1_fam == 2
		gen friend_second = 1 if comsample_1_fam == 1
		
	lab val friend_rltn s33q2_r
	
	gen friend_rltn_fam = 1 if 		friend_rltn == 1 | friend_rltn == 2 | ///
									friend_rltn == 3 | friend_rltn == 4 | ///
									friend_rltn == 5 
	
	gen id_friend_uid = id_resp_uid + "_" + "F"
	
/* New Variables _______________________________________________________________*/

	/* Radio Distribution Treatments */
	rename rd_treat rd_treat
	rename sample_rd_pull rd_sample
	
	/* District Codes */
	encode id_district_n, gen(id_district_uid_c)
	encode id_ward_uid, gen(id_ward_uid_c)
	encode id_village_uid, gen(id_village_uid_c)
	
/* Order and Keep ______________________________________________________________*/

	order id_village_uid id_resp_uid id_resp_n id_friend_uid id_friend_n friend_rltn friend_rltn_fam comsample*
	sort id_village_uid id_resp_uid 
	keep id_village_uid id_resp_uid id_resp_n id_friend_uid id_friend_n friend_rltn friend_rltn_fam id* rd_treat rd_sample comsample*

	
	
/* Save ________________________________________________________________________*/

	save "${data_as}/pfm_friends_sample.dta", replace
	save "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\08_Friends\pfm_friends_sample.dta", replace
	export delimited using "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\08_Friends\pfm_friends_sample.csv", nolabel replace


	