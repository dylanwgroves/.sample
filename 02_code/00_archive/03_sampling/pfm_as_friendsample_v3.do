	
/* Overview ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening
Purpose: Sampling Sheets for Mobilizers to mobilize friends
Author: beatrice montano, bm2955@columbia.edu
Date: 2020/01/21

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

	keep id_* resp_name comsample* ///
		 p_id_resp_uid p_resp_name_new ///
		 rd_treat emreject_pull emcount_pull ///
		 svy_phone svy_phone2
		 

/* Select Closes Friend (Remove if Family Member) ______________________________*/
			
	gen     relationship1_family = 0
	replace relationship1_family = 1 if 	comsample_1_rltn == 1  | comsample_1_rltn == 2  | ///
											comsample_1_rltn == 3  |  ///
											  comsample_1_rltn == 12 | ///
											comsample_1_rltn == 16 | comsample_1_rltn == 17 | comsample_1_rltn == 18
	
	gen relationship2_family = 0 
	replace relationship2_family = 1 if 	comsample_2_rltn == 1  | comsample_2_rltn == 2  | ///
											comsample_2_rltn == 3  |  ///
											 comsample_2_rltn == 12 | ///
											comsample_2_rltn == 16 | comsample_2_rltn == 17 | comsample_2_rltn == 18

	gen name1 = comsample_1_name 
	replace name1 = "" if relationship1_family == 1 
	
	gen relationship1 = comsample_1_rltn
	replace relationship1 = . if relationship1_family == 1 
	lab val relationship1 s33q2_r
	
	gen name2 = comsample_2_name
	replace name2 =  "" if relationship2_family == 1 

	gen relationship2 = comsample_2_rltn
	replace relationship2 = . if relationship2_family == 1 
	lab val relationship2 s33q2_r

	replace name1 = name2 if name1=="" & name2!=""
	replace relationship1 = relationship2 if name1 == name2
	replace name2 = "" if name1 == name2
	replace relationship2 = . if name2==""

/* Generate list of Original + Partner + Friends (maybe eligible) ______________*/
	
	decode relationship1, gen(relationship_1)
	decode relationship2, gen(relationship_2)

	replace relationship_1 = "A person who lives nearby" if relationship_1 == "A person who lives nearbye"
	replace relationship_2 = "A person who lives nearby" if relationship_2 == "A person who lives nearbye"

	local myvar id_village_n id_resp_n name1 relationship_1  name2  relationship_2
	foreach var of local myvar {
	local fmt: format `var'
	local fmt: subinstr local fmt "%" "%-"
	format `var' `fmt'
	}

	drop relationship1
	gen relationship1 = relationship_1 
	drop relationship2
	gen relationship2 = relationship_2 
	gen districtName = id_district_n 
	gen villageName = id_village_n 
	gen respondentID = id_resp_uid 
	gen respondentName = id_resp_n 
	gen partnerName = p_resp_name_new 

	replace relationship1 = "Friends" if relationship1 == "A friend you spend your free time with"
	replace relationship2 = "Friends" if relationship2 == "A friend you spend your free time with"
	
	replace relationship1 = "Neighbor" if relationship1 == "A person who lives nearby"
	replace relationship2 = "Neighbor" if relationship2 == "A person who lives nearby"

	replace relationship1 = "Friend of prayer" if relationship1 == "A friend you go to church/mosque with"	
	replace relationship2 = "Friend of prayer" if relationship2 == "A friend you go to church/mosque with"
	
	replace relationship1 = "Community leader" if relationship1 == "Your community leader"	
	replace relationship2 = "Community leader" if relationship2 == "Your community leader"	
	
	sort districtName villageName respondentID respondentName 

	/* Save overall list */
	preserve
	
	order districtName villageName respondentID respondentName partnerName name1 name2
	keep  villageName respondentID respondentName svy_phone svy_phone2 partnerName name1 name2
	
	rename name1 friend1 
	rename name2 friend2
	
	export excel using ///
				"${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_friends_helper.xls", ///
				firstrow(var) replace
	
	restore
	stop
/* Generate list of Respondents + empty columns for eligibility criteria _______*/
	preserve 
	
	replace name1 = ""
	rename name1 name
	
	gen age = ""

	replace relationship1 = ""
	rename relationship1 relationship
	
	gen talk = ""

	order  districtName villageName respondentID respondentName name age relationship talk
	keep   districtName villageName respondentID respondentName name age relationship talk
	
	sort districtName villageName respondentID respondentName 
	expand 3
	sort districtName villageName respondentID respondentName 
	
	drop districtName
	gen note = ""
	
	/* Save conditions list */
	export excel using ///
			     "${user}/Box Sync/19_Community Media Endlines/02_Project and Survey Management/02 Planning/Training Plan/Training Manual/Spillover/01_Friends/pfm_friends_master.xls" ///
				 , firstrow(var) replace

	restore
	*/
	
/* Generate Cases ______________________________________________________________*/


	** Generate Variables
	gen id_friend_uid = id_resp_uid + "_F"
	rename name1 friend1 
	rename name2 friend2
	gen rd_sample = (rd_treat == 1 | rd_treat == 2)
	encode id_ward_uid, gen(id_ward_uid_c)
	encode id_village_uid, gen(id_village_uid_c)
	
	
order id_village_uid id_resp_uid id_resp_n id_friend_uid friend1 friend2 id_region_c id_region_n id_district_c id_district_n id_ward_c id_ward_n id_village_c id_village_n rd_treat id_resp_c id_ward_uid id_objectid rd_sample id_pull id_re id_district_c id_ward_uid_c id_village_uid_c 

export delimited using "X:\Box Sync\19_Community Media Endlines\04_Research Design\04 Randomization & Sampling\08_Friends\pfm_friends_cases.csv", nolabel replace


	
	
