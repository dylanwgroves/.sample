* import_spotlight_citizen_DO.do
*
* 	Imports and aggregates "spotlight_citizen_DO" (ID: spotlight_citizen_DO) data.
*
*	Inputs:  "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_citizen_DO_WIDE.csv"
*	Outputs: "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_citizen_DO.dta"
*
*	Output by SurveyCTO December 1, 2021 8:41 AM.

* initialize Stata
clear all
set more off
set mem 100m

* initialize workflow-specific parameters
*	Set overwrite_old_data to 1 if you use the review and correction
*	workflow and allow un-approving of submissions. If you do this,
*	incoming data will overwrite old data, so you won't want to make
*	changes to data in your local .dta file (such changes can be
*	overwritten with each new import).
local overwrite_old_data 0

* initialize form-specific parameters
local csvfile "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_citizen_DO_WIDE.csv"
local dtafile "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_citizen_DO.dta"
local corrfile "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_citizen_DO_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum username caseid duration station_pull village_name_pull ward_name_pull district_name_pull region_name_pull problem problem_sw treat_pull enum_oth enum_name"
local text_fields2 "id id_re idcheck idcheck_region idcheck_district idcheck_ward idcheck_village prob_overview_text prob_overview_audio prob_text_* prob_audio_* prob_image_* prob_video_* vill_overview_text"
local text_fields3 "vill_overview_audio vill_text_* vill_audio_* vill_image_* vill_video_* gov_overview_text gov_overview_audio gov_text_* gov_audio_* gov_image_* gov_video_* oth_overview_text oth_overview_audio"
local text_fields4 "oth_text_* oth_audio_* oth_image_* oth_video_* other_audio other_text comments instanceid"
local date_fields1 ""
local datetime_fields1 "submissiondate startime endtime"

disp
disp "Starting import of: `csvfile'"
disp

* import data from primary .csv file
insheet using "`csvfile'", names clear

* drop extra table-list columns
cap drop reserved_name_for_field_*
cap drop generated_table_list_lab*

* continue only if there's at least one row of data to import
if _N>0 {
	* drop note fields (since they don't contain any real data)
	forvalues i = 1/100 {
		if "`note_fields`i''" ~= "" {
			drop `note_fields`i''
		}
	}
	
	* format date and date/time fields
	forvalues i = 1/100 {
		if "`datetime_fields`i''" ~= "" {
			foreach dtvarlist in `datetime_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=clock(`tempdtvar',"MDYhms",2025)
						* automatically try without seconds, just in case
						cap replace `dtvar'=clock(`tempdtvar',"MDYhm",2025) if `dtvar'==. & `tempdtvar'~=""
						format %tc `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
		if "`date_fields`i''" ~= "" {
			foreach dtvarlist in `date_fields`i'' {
				cap unab dtvarlist : `dtvarlist'
				if _rc==0 {
					foreach dtvar in `dtvarlist' {
						tempvar tempdtvar
						rename `dtvar' `tempdtvar'
						gen double `dtvar'=.
						cap replace `dtvar'=date(`tempdtvar',"MDY",2025)
						format %td `dtvar'
						drop `tempdtvar'
					}
				}
			}
		}
	}

	* ensure that text fields are always imported as strings (with "" for missing values)
	* (note that we treat "calculate" fields as text; you can destring later if you wish)
	tempvar ismissingvar
	quietly: gen `ismissingvar'=.
	forvalues i = 1/100 {
		if "`text_fields`i''" ~= "" {
			foreach svarlist in `text_fields`i'' {
				cap unab svarlist : `svarlist'
				if _rc==0 {
					foreach stringvar in `svarlist' {
						quietly: replace `ismissingvar'=.
						quietly: cap replace `ismissingvar'=1 if `stringvar'==.
						cap tostring `stringvar', format(%100.0g) replace
						cap replace `stringvar'="" if `ismissingvar'==1
					}
				}
			}
		}
	}
	quietly: drop `ismissingvar'


	* consolidate unique ID into "key" variable
	replace key=instanceid if key==""
	drop instanceid


	* label variables
	label variable key "Unique submission ID"
	cap label variable submissiondate "Date/time submitted"
	cap label variable formdef_version "Form version used on device"
	cap label variable review_status "Review status"
	cap label variable review_comments "Comments made during review"
	cap label variable review_corrections "Corrections made during review"


	label variable enum "Enumerator Name"
	note enum: "Enumerator Name"
	label define enum 1 "Dylan Groves" 2 "Lusekelo Andrew" 3 "Erick Lutahakama" 4 "Silvana Karia" 5 "Rashid Seif" 6 "Imelda Tesha" 7 "Omben Eliapenda" 8 "Husna Majura" 9 "Imaculate Kessy" 10 "Cassim Abdallah" 11 "Jackson Bukuru" 12 "Leonard Masolwa" 13 "Mafwiri, Magiri Vicent" 14 "Mashaka Kadashi Peter" 15 "Sheila Mlaki" 16 "Hamza Mtinangi" 17 "Neema Msechu"
	label values enum enum

	label variable enum_oth "Other, specify"
	note enum_oth: "Other, specify"

	label variable id "Village/Street ID"
	note id: "Village/Street ID"

	label variable id_re "Re-enter the village/street ID"
	note id_re: "Re-enter the village/street ID"

	label variable idcheck "ENUMERATOR confirm if the information about the village is correct. Region Name:"
	note idcheck: "ENUMERATOR confirm if the information about the village is correct. Region Name: \${region_name_pull} District Name: \${district_name_pull} Ward name: \${ward_name_pull} Village name: \${village_name_pull}"

	label variable idcheck_region "What is the correct Region?"
	note idcheck_region: "What is the correct Region?"

	label variable idcheck_district "What is the correct District?"
	note idcheck_district: "What is the correct District?"

	label variable idcheck_ward "What is the correct Ward?"
	note idcheck_ward: "What is the correct Ward?"

	label variable idcheck_village "What is the correct Village?"
	note idcheck_village: "What is the correct Village?"

	label variable problemcheck "ENUMERATOR confirm that the problem in this village is correct. THIS IS VERY IMP"
	note problemcheck: "ENUMERATOR confirm that the problem in this village is correct. THIS IS VERY IMPORTANT! Specific Problem in Village: \${problem}"
	label define problemcheck 1 "Yes" 0 "No"
	label values problemcheck problemcheck

	label variable prob_score "First, on a score of 0 (no problem) to 10 (severe problem), how bad was the ORIG"
	note prob_score: "First, on a score of 0 (no problem) to 10 (severe problem), how bad was the ORIGINAL PROBLEM 7 months ago?"
	label define prob_score 0 "0" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "10"
	label values prob_score prob_score

	label variable current_score "First, on a score of -10 (much worse) to 10 (fully solved), how would you say th"
	note current_score: "First, on a score of -10 (much worse) to 10 (fully solved), how would you say the \${problem} problem has changed from 7 months ago to today?"
	label define current_score -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values current_score current_score

	label variable prob_overview_text "In full detail, please describe the ORIGINAL PROBLEM 7 months ago and THE OVERAL"
	note prob_overview_text: "In full detail, please describe the ORIGINAL PROBLEM 7 months ago and THE OVERALL RESPONSE to the \${problem} problem in the last 7 months. Make sure you describe the CURRENT SITUATION."

	label variable prob_overview_audio "In full detail, please record audio describing the ORIGINAL PROBLEM 7 months ago"
	note prob_overview_audio: "In full detail, please record audio describing the ORIGINAL PROBLEM 7 months ago and THE OVERALL RESPONSE to the \${problem} problem in the last 7 months. Make sure you describe the CURRENT SITUATION."

	label variable prob_any "Do you have any EVIDENCE to submit to share about the ORIGINAL PROBLEM and the C"
	note prob_any: "Do you have any EVIDENCE to submit to share about the ORIGINAL PROBLEM and the CURRENT SITUATION?"
	label define prob_any 1 "Yes" 0 "No"
	label values prob_any prob_any

	label variable vill_score "First, on a score of -10 (made things much worse) to 10 (totally solved the prob"
	note vill_score: "First, on a score of -10 (made things much worse) to 10 (totally solved the problem), how would you score the OVERALL response by VILLAGERS to the \${problem} problem?"
	label define vill_score -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values vill_score vill_score

	label variable vill_overview_text "Please write text describing your view of the VILLAGER response to the \${proble"
	note vill_overview_text: "Please write text describing your view of the VILLAGER response to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable vill_overview_audio "Please record audio describing your view of the VILLAGER response to the \${prob"
	note vill_overview_audio: "Please record audio describing your view of the VILLAGER response to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable vill_score_other "On a score of -10 to 10, how wuld you score VILLAGERS' actions to address OTHER "
	note vill_score_other: "On a score of -10 to 10, how wuld you score VILLAGERS' actions to address OTHER problems in their village (NOT \${problem}) in the past 7 months?"
	label define vill_score_other -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values vill_score_other vill_score_other

	label variable vill_any "Do you have any EVIDENCE to submit to share about the VILLAGER RESPONSE to the \"
	note vill_any: "Do you have any EVIDENCE to submit to share about the VILLAGER RESPONSE to the \${problem} problem in the last 7 months?"
	label define vill_any 1 "Yes" 0 "No"
	label values vill_any vill_any

	label variable gov_score "First, on a score of -10 (made things much worse) to 10 (totally solved the prob"
	note gov_score: "First, on a score of -10 (made things much worse) to 10 (totally solved the problem), how would you score the OVERALL response by the GOVERNMENT to the \${problem} problem?"
	label define gov_score -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score gov_score

	label variable gov_overview_text "Please write text describing your view of the GOVERNMENT response to the \${prob"
	note gov_overview_text: "Please write text describing your view of the GOVERNMENT response to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable gov_overview_audio "Please record audio describing your view of the GOVERNMENT response to the \${pr"
	note gov_overview_audio: "Please record audio describing your view of the GOVERNMENT response to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable gov_score_vc "How do you score the mwenyekiti's response?"
	note gov_score_vc: "How do you score the mwenyekiti's response?"
	label define gov_score_vc -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_vc gov_score_vc

	label variable gov_score_wc "How would you score the diwani's response?"
	note gov_score_wc: "How would you score the diwani's response?"
	label define gov_score_wc -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_wc gov_score_wc

	label variable gov_score_bur "How would you score the VEO/WEO response?"
	note gov_score_bur: "How would you score the VEO/WEO response?"
	label define gov_score_bur -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_bur gov_score_bur

	label variable gov_score_district "How would you score the response by the district (examples: DC/DED/DHO/DMO)?"
	note gov_score_district: "How would you score the response by the district (examples: DC/DED/DHO/DMO)?"
	label define gov_score_district -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_district gov_score_district

	label variable gov_score_mp "How would you socre the response by the MP?"
	note gov_score_mp: "How would you socre the response by the MP?"
	label define gov_score_mp -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_mp gov_score_mp

	label variable gov_score_ministry "How would you score the response by the Ministry (examples: TARURA, TANESCO, RUW"
	note gov_score_ministry: "How would you score the response by the Ministry (examples: TARURA, TANESCO, RUWASA)?"
	label define gov_score_ministry -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_ministry gov_score_ministry

	label variable gov_score_rc "How would you score the response by Regional Commissioner or other other Regiona"
	note gov_score_rc: "How would you score the response by Regional Commissioner or other other Regional Officials?"
	label define gov_score_rc -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_rc gov_score_rc

	label variable gov_score_other "On a score of -10 to 10, how wuld you score the GOVERNMENT'S actions to address "
	note gov_score_other: "On a score of -10 to 10, how wuld you score the GOVERNMENT'S actions to address OTHER problems in their village (NOT \${problem}) in the past 7 months?"
	label define gov_score_other -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values gov_score_other gov_score_other

	label variable gov_any "Do you have any EVIDENCE to submit to share about the GOVERNMENT RESPONSE to the"
	note gov_any: "Do you have any EVIDENCE to submit to share about the GOVERNMENT RESPONSE to the \${problem} problem in the last 7 months?"
	label define gov_any 1 "Yes" 0 "No"
	label values gov_any gov_any

	label variable oth_score "First, on a score of -10 (made things much worse) to 10 (totally solved the prob"
	note oth_score: "First, on a score of -10 (made things much worse) to 10 (totally solved the problem), how would you score the OVERALL response by the OTHERS (NGOs, businesses, and private citizens) to the \${problem} problem?"
	label define oth_score -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values oth_score oth_score

	label variable oth_overview_text "Please write text describing your view of the response by OTHERS (NGOs, business"
	note oth_overview_text: "Please write text describing your view of the response by OTHERS (NGOs, businesses, and private citizens) to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable oth_overview_audio "Please record audio describing your view of the response by OTHERS (NGOs, busine"
	note oth_overview_audio: "Please record audio describing your view of the response by OTHERS (NGOs, businesses, and private citizens) to the \${problem} problem in the village/mtaa in the last 7 months"

	label variable oth_score_ngo "How do you score the response by NGOs?"
	note oth_score_ngo: "How do you score the response by NGOs?"
	label define oth_score_ngo -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values oth_score_ngo oth_score_ngo

	label variable oth_score_privatebiz "How would you score the response by businesses?"
	note oth_score_privatebiz: "How would you score the response by businesses?"
	label define oth_score_privatebiz -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values oth_score_privatebiz oth_score_privatebiz

	label variable oth_score_othctz "How would you score the response by citizens from OUTSIDE the village or local c"
	note oth_score_othctz: "How would you score the response by citizens from OUTSIDE the village or local citizens?"
	label define oth_score_othctz -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values oth_score_othctz oth_score_othctz

	label variable oth_score_other "On a score of -10 to 10, how would you score the OTHERS (NGOs, businesses, and p"
	note oth_score_other: "On a score of -10 to 10, how would you score the OTHERS (NGOs, businesses, and private citizens) actions to address OTHER problems in their village (NOT \${problem}) in the past 7 months?"
	label define oth_score_other -10 "Made much worse" -9 "-9" -8 "-8" -7 "-7" -6 "-6" -5 "-5" -4 "-4" -3 "-3" -2 "-2" -1 "-1" 0 "Did nothing" 1 "1" 2 "2" 3 "3" 4 "4" 5 "5" 6 "6" 7 "7" 8 "8" 9 "9" 10 "Solved compeltely"
	label values oth_score_other oth_score_other

	label variable oth_any "Do you have any EVIDENCE to submit to share about the RESPONSE by NGO/PRIVATE BU"
	note oth_any: "Do you have any EVIDENCE to submit to share about the RESPONSE by NGO/PRIVATE BUSINESSES/OTHER CITIZENS to the \${problem} problem in the last 7 months?"
	label define oth_any 1 "Yes" 0 "No"
	label values oth_any oth_any

	label variable other_audio "Please record any other important information about the village for the report c"
	note other_audio: "Please record any other important information about the village for the report card"

	label variable other_text "Please write any other important information about the village for the report ca"
	note other_text: "Please write any other important information about the village for the report card"

	label variable comments "Please leave your comments here"
	note comments: "Please leave your comments here"



	capture {
		foreach rgvar of varlist prob_type_* {
			label variable `rgvar' "Is this piece of evidence text, audio, picture, or video?"
			note `rgvar': "Is this piece of evidence text, audio, picture, or video?"
			label define `rgvar' 1 "Text" 2 "Audio" 3 "Picture" 4 "Video" 0 "None"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist prob_text_* {
			label variable `rgvar' "Please write the evidence about the ORIGINAL PROBLEM or CURRENT SITUTION"
			note `rgvar': "Please write the evidence about the ORIGINAL PROBLEM or CURRENT SITUTION"
		}
	}

	capture {
		foreach rgvar of varlist prob_audio_* {
			label variable `rgvar' "Please record audio evidence about the ORIGINAL PROBLEM or CURRENT SITUTION"
			note `rgvar': "Please record audio evidence about the ORIGINAL PROBLEM or CURRENT SITUTION"
		}
	}

	capture {
		foreach rgvar of varlist prob_image_* {
			label variable `rgvar' "Please take or load a picture about the ORIGINAL PROBLEM or CURRENT SITUTION"
			note `rgvar': "Please take or load a picture about the ORIGINAL PROBLEM or CURRENT SITUTION"
		}
	}

	capture {
		foreach rgvar of varlist prob_video_* {
			label variable `rgvar' "Please record or load a video about the ORIGINAL PROBLEM or CURRENT SITUTION"
			note `rgvar': "Please record or load a video about the ORIGINAL PROBLEM or CURRENT SITUTION"
		}
	}

	capture {
		foreach rgvar of varlist vill_type_* {
			label variable `rgvar' "Is this piece of evidence text, audio, picture, or video?"
			note `rgvar': "Is this piece of evidence text, audio, picture, or video?"
			label define `rgvar' 1 "Text" 2 "Audio" 3 "Picture" 4 "Video" 0 "None"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist vill_text_* {
			label variable `rgvar' "Please write the evidence about the current \${problem} situation"
			note `rgvar': "Please write the evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist vill_audio_* {
			label variable `rgvar' "Please record audio evidence about the current \${problem} situation"
			note `rgvar': "Please record audio evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist vill_image_* {
			label variable `rgvar' "Please take or load a picture about the current \${problem} situation"
			note `rgvar': "Please take or load a picture about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist vill_video_* {
			label variable `rgvar' "Please record or load a video about the current \${problem} situation"
			note `rgvar': "Please record or load a video about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist gov_type_* {
			label variable `rgvar' "Is this piece of evidence text, audio, picture, or video?"
			note `rgvar': "Is this piece of evidence text, audio, picture, or video?"
			label define `rgvar' 1 "Text" 2 "Audio" 3 "Picture" 4 "Video" 0 "None"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist gov_text_* {
			label variable `rgvar' "Please write the evidence about the current \${problem} situation"
			note `rgvar': "Please write the evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist gov_audio_* {
			label variable `rgvar' "Please record audio evidence about the current \${problem} situation"
			note `rgvar': "Please record audio evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist gov_image_* {
			label variable `rgvar' "Please take or load a picture about the current \${problem} situation"
			note `rgvar': "Please take or load a picture about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist gov_video_* {
			label variable `rgvar' "Please record or load a video about the current \${problem} situation"
			note `rgvar': "Please record or load a video about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist oth_type_* {
			label variable `rgvar' "Is this piece of evidence text, audio, picture, or video?"
			note `rgvar': "Is this piece of evidence text, audio, picture, or video?"
			label define `rgvar' 1 "Text" 2 "Audio" 3 "Picture" 4 "Video" 0 "None"
			label values `rgvar' `rgvar'
		}
	}

	capture {
		foreach rgvar of varlist oth_text_* {
			label variable `rgvar' "Please write the evidence about the current \${problem} situation"
			note `rgvar': "Please write the evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist oth_audio_* {
			label variable `rgvar' "Please record audio evidence about the current \${problem} situation"
			note `rgvar': "Please record audio evidence about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist oth_image_* {
			label variable `rgvar' "Please take or load a picture about the current \${problem} situation"
			note `rgvar': "Please take or load a picture about the current \${problem} situation"
		}
	}

	capture {
		foreach rgvar of varlist oth_video_* {
			label variable `rgvar' "Please record or load a video about the current \${problem} situation"
			note `rgvar': "Please record or load a video about the current \${problem} situation"
		}
	}




	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'"
		
		* drop duplicates in favor of old, previously-imported data if overwrite_old_data is 0
		* (alternatively drop in favor of new data if overwrite_old_data is 1)
		sort key
		by key: gen num_for_key = _N
		drop if num_for_key > 1 & ((`overwrite_old_data' == 0 & new_data_row == 1) | (`overwrite_old_data' == 1 & new_data_row ~= 1))
		drop num_for_key

		* drop new-data flag
		drop new_data_row
	}
	
	* save data to Stata format
	save "`dtafile'", replace

	* show codebook and notes
	codebook
	notes list
}

disp
disp "Finished import of: `csvfile'"
disp

* OPTIONAL: LOCALLY-APPLIED STATA CORRECTIONS
*
* Rather than using SurveyCTO's review and correction workflow, the code below can apply a list of corrections
* listed in a local .csv file. Feel free to use, ignore, or delete this code.
*
*   Corrections file path and filename:  X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_citizen_DO_corrections.csv
*
*   Corrections file columns (in order): key, fieldname, value, notes

capture confirm file "`corrfile'"
if _rc==0 {
	disp
	disp "Starting application of corrections in: `corrfile'"
	disp

	* save primary data in memory
	preserve

	* load corrections
	insheet using "`corrfile'", names clear
	
	if _N>0 {
		* number all rows (with +1 offset so that it matches row numbers in Excel)
		gen rownum=_n+1
		
		* drop notes field (for information only)
		drop notes
		
		* make sure that all values are in string format to start
		gen origvalue=value
		tostring value, format(%100.0g) replace
		cap replace value="" if origvalue==.
		drop origvalue
		replace value=trim(value)
		
		* correct field names to match Stata field names (lowercase, drop -'s and .'s)
		replace fieldname=lower(subinstr(subinstr(fieldname,"-","",.),".","",.))
		
		* format date and date/time fields (taking account of possible wildcards for repeat groups)
		forvalues i = 1/100 {
			if "`datetime_fields`i''" ~= "" {
				foreach dtvar in `datetime_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						gen origvalue=value
						replace value=string(clock(value,"MDYhms",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
						* allow for cases where seconds haven't been specified
						replace value=string(clock(origvalue,"MDYhm",2025),"%25.0g") if strmatch(fieldname,"`dtvar'") & value=="." & origvalue~="."
						drop origvalue
					}
				}
			}
			if "`date_fields`i''" ~= "" {
				foreach dtvar in `date_fields`i'' {
					* skip fields that aren't yet in the data
					cap unab dtvarignore : `dtvar'
					if _rc==0 {
						replace value=string(clock(value,"MDY",2025),"%25.0g") if strmatch(fieldname,"`dtvar'")
					}
				}
			}
		}

		* write out a temp file with the commands necessary to apply each correction
		tempfile tempdo
		file open dofile using "`tempdo'", write replace
		local N = _N
		forvalues i = 1/`N' {
			local fieldnameval=fieldname[`i']
			local valueval=value[`i']
			local keyval=key[`i']
			local rownumval=rownum[`i']
			file write dofile `"cap replace `fieldnameval'="`valueval'" if key=="`keyval'""' _n
			file write dofile `"if _rc ~= 0 {"' _n
			if "`valueval'" == "" {
				file write dofile _tab `"cap replace `fieldnameval'=. if key=="`keyval'""' _n
			}
			else {
				file write dofile _tab `"cap replace `fieldnameval'=`valueval' if key=="`keyval'""' _n
			}
			file write dofile _tab `"if _rc ~= 0 {"' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab _tab `"disp "CAN'T APPLY CORRECTION IN ROW #`rownumval'""' _n
			file write dofile _tab _tab `"disp"' _n
			file write dofile _tab `"}"' _n
			file write dofile `"}"' _n
		}
		file close dofile
	
		* restore primary data
		restore
		
		* execute the .do file to actually apply all corrections
		do "`tempdo'"

		* re-save data
		save "`dtafile'", replace
	}
	else {
		* restore primary data		
		restore
	}

	disp
	disp "Finished applying corrections in: `corrfile'"
	disp
}


