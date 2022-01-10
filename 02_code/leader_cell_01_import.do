* import_spotlight_survey_cell_short.do
*
* 	Imports and aggregates "spotlight_survey_cell_short" (ID: spotlight_survey_cell_short) data.
*
*	Inputs:  "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_survey_cell_short_WIDE.csv"
*	Outputs: "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_cell_short.dta"
*
*	Output by SurveyCTO December 7, 2021 11:24 AM.

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
local csvfile "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_survey_cell_short_WIDE.csv"
local dtafile "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_cell_short.dta"
local corrfile "X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_survey_cell_short_corrections.csv"
local note_fields1 ""
local text_fields1 "deviceid subscriberid simid devicephonenum username caseid duration station_pull village_name_pull ward_name_pull district_name_pull region_name_pull problem problem_sw treat_pull enum_oth enum_name"
local text_fields2 "id id_re idcheck idcheck_region idcheck_district idcheck_ward idcheck_village vlcheck_name svy_phone svy_phone2 vlcheck_whynot_oth resp_profession resp_profession_oth prob_water prob_water_oth"
local text_fields3 "prob_health prob_health_oth prob_school prob_school_oth prob_roads prob_roads_oth prob_fishing prob_fishing_oth prob_electricity prob_electricity_oth prob_txt prob_other prob_oth_text"
local text_fields4 "govresp_actions_water govresp_actions_health govresp_actions_school govresp_actions_roads govresp_actions_fishing govresp_actions_electricity govresp_actions_other govresp_oth_wat visits_all"
local text_fields5 "visits_other_name visit_other finance_short finance_citizens finance_ngo finance_gov finance_gov_who finance_citizens_oth finance_ngos_oth finance_other_prob effort_citizens_oth"
local text_fields6 "effort_citizens_oth_oth aware_supportjourno_yes aware_supportjourno_no pressure_who pressure_vill pressure_vc pressure_wc pressure_mp conclusion_start conclusion_end conclusion_dur comments instanceid"
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

	label variable id "Village ID"
	note id: "Village ID"

	label variable id_re "Re-enter the village ID"
	note id_re: "Re-enter the village ID"

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

	label variable resp_target "Who is the targeted respondent for this survey?"
	note resp_target: "Who is the targeted respondent for this survey?"
	label define resp_target 1 "Village Chairperson / Mtaa Chairperson" 2 "Member of Village/Mtaa Council" 3 "Village Executive Officer (VEO)" 4 "Ward Councillor" 5 "Ward Executive Officer" 6 "Citizen" -222 "Other (specify)"
	label values resp_target resp_target

	label variable vlcheck_name "What is the name of the targeted respondent"
	note vlcheck_name: "What is the name of the targeted respondent"

	label variable svy_phone "What is the primary phone number of the targeted respondent?"
	note svy_phone: "What is the primary phone number of the targeted respondent?"

	label variable svy_phone2 "What is the alternative phone number of the targeted respondent?"
	note svy_phone2: "What is the alternative phone number of the targeted respondent?"

	label variable vlcheck_available "Is the targeted respondent available?"
	note vlcheck_available: "Is the targeted respondent available?"
	label define vlcheck_available 1 "Yes" 0 "No"
	label values vlcheck_available vlcheck_available

	label variable vlcheck_whynot "Why is the targeted respondent not available"
	note vlcheck_whynot: "Why is the targeted respondent not available"
	label define vlcheck_whynot 1 "Cannot be reached" 2 "Out of the village" 3 "Refuses to participate" 4 "Does not exist" 5 "Sick" 6 "Dead"
	label values vlcheck_whynot vlcheck_whynot

	label variable vlcheck_whynot_oth "Other reason (specify)"
	note vlcheck_whynot_oth: "Other reason (specify)"

	label variable consent "Did the respondent consent to the survey?"
	note consent: "Did the respondent consent to the survey?"
	label define consent 1 "Yes" 0 "No"
	label values consent consent

	label variable resp_female "Sex of the respondent"
	note resp_female: "Sex of the respondent"
	label define resp_female 0 "Male" 1 "Female"
	label values resp_female resp_female

	label variable resp_age "What is your age?"
	note resp_age: "What is your age?"

	label variable resp_religion "What is your religion?"
	note resp_religion: "What is your religion?"
	label define resp_religion 1 "Christian" 2 "Muslim" -222 "Other" -999 "Do not know" -888 "Refuse to answer"
	label values resp_religion resp_religion

	label variable resp_education "What is your highest education level?"
	note resp_education: "What is your highest education level?"
	label define resp_education 1 "Kindergarden" 2 "Standard 1" 3 "Standard 2" 4 "Standard 3" 5 "Standard 4" 6 "Standard 5" 7 "Standard 6" 8 "Standard 7" 9 "Form 1" 10 "Form 2" 11 "Form 3" 12 "Form 4" 13 "Form 5" 14 "Form 6" 15 "A-Level" 16 "O-Level" 17 "Professional Certificate" 18 "Diploma 1" 19 "Diploma 2" 20 "Bachelor's Degree" 21 "Masters Degree" 22 "Informal Training" 0 "None" -999 "Don't Know" -888 "Refuse to answer"
	label values resp_education resp_education

	label variable resp_profession "What do you do for a job outside of your role in government??"
	note resp_profession: "What do you do for a job outside of your role in government??"

	label variable resp_profession_oth "Other, specify"
	note resp_profession_oth: "Other, specify"

	label variable prob_water "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_water: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_water_oth "Other (specify)"
	note prob_water_oth: "Other (specify)"

	label variable prob_health "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_health: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_health_oth "Other (specify)"
	note prob_health_oth: "Other (specify)"

	label variable prob_school "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_school: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_school_oth "Other (specify)"
	note prob_school_oth: "Other (specify)"

	label variable prob_roads "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_roads: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_roads_oth "Other (specify)"
	note prob_roads_oth: "Other (specify)"

	label variable prob_fishing "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_fishing: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_fishing_oth "Other (specify)"
	note prob_fishing_oth: "Other (specify)"

	label variable prob_electricity "Can you please tell me about any \${problem} issues that your village/street has"
	note prob_electricity: "Can you please tell me about any \${problem} issues that your village/street has experiened in the past 7 months?"

	label variable prob_electricity_oth "Other (specify)"
	note prob_electricity_oth: "Other (specify)"

	label variable prob_time "When did the \${problem} problem begin in the village?"
	note prob_time: "When did the \${problem} problem begin in the village?"
	label define prob_time 1 "Just this year" 2 "Since last year" 3 "2-5 years" 4 "More than 5 years" 5 "More than 10 years"
	label values prob_time prob_time

	label variable prob_txt "Please add any addition information about the \${problem}"
	note prob_txt: "Please add any addition information about the \${problem}"

	label variable prob_other "Now I am going to read you a list of other problems that face villages/streets i"
	note prob_other: "Now I am going to read you a list of other problems that face villages/streets in Tanzania. For each problem, please tell me if your village has faced that issue in the past 7 months."

	label variable prob_oth_text "What are the other major problems have you experienced in this village?"
	note prob_oth_text: "What are the other major problems have you experienced in this village?"

	label variable govresp_actions_water "Now, I am going read you a list of actions that the government might have taken "
	note govresp_actions_water: "Now, I am going read you a list of actions that the government might have taken to solve the \${problem} problem, for each, please tell me if the government has taken the action in the last seven months, not taken the action in the last seven months, or you don’t know:"

	label variable govresp_actions_health "Now, I am going read you a list of actions that the government might have taken "
	note govresp_actions_health: "Now, I am going read you a list of actions that the government might have taken to solve the \${problem} problem, for each, please tell me if the government has taken the action in the last seven months, not taken the action in the last seven months, or you don’t know:"

	label variable govresp_actions_school "Now, I am going read you a list of steps that the government might have taken to"
	note govresp_actions_school: "Now, I am going read you a list of steps that the government might have taken to solve the \${problem} problem, for each, please tell me if the government have taken this action."

	label variable govresp_actions_roads "Now, I am going read you a list of steps that the government might have taken to"
	note govresp_actions_roads: "Now, I am going read you a list of steps that the government might have taken to solve the \${problem} problem, for each, please tell me if the government have taken this action."

	label variable govresp_actions_fishing "Now, I am going read you a list of steps that the government might have taken to"
	note govresp_actions_fishing: "Now, I am going read you a list of steps that the government might have taken to solve the \${problem} problem, for each, please tell me if the government have taken this action."

	label variable govresp_actions_electricity "Now, I am going read you a list of steps that the government might have taken to"
	note govresp_actions_electricity: "Now, I am going read you a list of steps that the government might have taken to solve the \${problem} problem, for each, please tell me if the government have taken this action."

	label variable govresp_actions_other "What other actions has the government taken to solve the problem?"
	note govresp_actions_other: "What other actions has the government taken to solve the problem?"

	label variable govresp_solved "To the best of your understanding, has the \${problem} problem been solved?"
	note govresp_solved: "To the best of your understanding, has the \${problem} problem been solved?"
	label define govresp_solved 1 "Yes" 0 "No"
	label values govresp_solved govresp_solved

	label variable govresp_solved_yes "Would you say \${problem} has been solved completely, or that the response to \$"
	note govresp_solved_yes: "Would you say \${problem} has been solved completely, or that the response to \${problem} is just beginning?"
	label define govresp_solved_yes 1 "Solved completely" 0 "Just beginning"
	label values govresp_solved_yes govresp_solved_yes

	label variable govresp_solved_yes_resp "Who do you think is primarily responsible for the \${problem} being solved?"
	note govresp_solved_yes_resp: "Who do you think is primarily responsible for the \${problem} being solved?"
	label define govresp_solved_yes_resp 0 "No one" 1 "VIllagers" 2 "Village Chairperson" 3 "Village Executive Officer" 4 "WC" 5 "WEO" 6 "Member of Parliament" 7 "NGO" 8 "District Officials (DED/DC)" 9 "District Officer (District Health Officer, District Medical Officer, District Ed" 10 "RC" 11 "Ministry Officials (RUWASA, TARUA, TANESCO)" 12 "CCM" 13 "Private citizens of businesses" -222 "Other (specify)" -999 "Don't know"
	label values govresp_solved_yes_resp govresp_solved_yes_resp

	label variable govresp_solved_no "Would you say that \${problem} is likely to be solved soon, or you don’t have mu"
	note govresp_solved_no: "Would you say that \${problem} is likely to be solved soon, or you don’t have much hope that \${problem} will ever be solved."
	label define govresp_solved_no 1 "you don’t have much hope that will ever be solved." 0 "Likely to be solved soon"
	label values govresp_solved_no govresp_solved_no

	label variable govresp_solved_no_resp "Who do you think is primarily responsible for the \${problem} NOT being solved"
	note govresp_solved_no_resp: "Who do you think is primarily responsible for the \${problem} NOT being solved"
	label define govresp_solved_no_resp 0 "No one" 1 "VIllagers" 2 "Village Chairperson" 3 "Village Executive Officer" 4 "WC" 5 "WEO" 6 "Member of Parliament" 7 "NGO" 8 "District Officials (DED/DC)" 9 "District Officer (District Health Officer, District Medical Officer, District Ed" 10 "RC" 11 "Ministry Officials (RUWASA, TARUA, TANESCO)" 12 "CCM" 13 "Private citizens of businesses" -222 "Other (specify)" -999 "Don't know"
	label values govresp_solved_no_resp govresp_solved_no_resp

	label variable govresp_oth_wat "Now, I am going to read you a list of other problems that villages/streets somet"
	note govresp_oth_wat: "Now, I am going to read you a list of other problems that villages/streets sometimes face. For each problem, tell me if the government has taken any actions to help with that issue in the past 7 months."

	cap label variable govres_oth_oth "Has the government taken action to solve any other issues in your community in t"
	cap note govres_oth_oth: "Has the government taken action to solve any other issues in your community in the last 7 months?"
	cap label define govres_oth_oth 1 "Yes" 0 "No"
	cap label values govres_oth_oth govres_oth_oth

	label variable meet_any "In your understanding have you had any meetings in your village/street in the pa"
	note meet_any: "In your understanding have you had any meetings in your village/street in the past 7 months to address the \${problem} problem?"
	label define meet_any 1 "Yes" 0 "No"
	label values meet_any meet_any

	label variable meet_number "How many meetings have you had in your village in the past 7 months to address t"
	note meet_number: "How many meetings have you had in your village in the past 7 months to address the \${problem} problem?"

	label variable meet_citizens "In your best understanding, what proportion of villagers have attended at least "
	note meet_citizens: "In your best understanding, what proportion of villagers have attended at least one meeting in your area in the past 7 months?"
	label define meet_citizens 0 "0" 10 "0-10%" 20 "10-20%" 30 "20-30%" 40 "30-40%" 50 "40-50%" 60 "50-60%" 70 "60-70%" 80 "70-80%" 90 "80-90%" 100 "90-100%"
	label values meet_citizens meet_citizens

	label variable visits_all "Now I am going to read you a list of different people and\\ government officials"
	note visits_all: "Now I am going to read you a list of different people and\\ government officials. Please tell me if they have visited the village/street to address the \${problem} problem in the past 7 months."

	label variable visits_other_name "What other government official visisted the village/street in the past 7 months?"
	note visits_other_name: "What other government official visisted the village/street in the past 7 months?"

	label variable visit_other "Now I am going to read the same list, please tell me if the individual has visit"
	note visit_other: "Now I am going to read the same list, please tell me if the individual has visited the village for any reason OTHER than the \${problem} problem."

	label variable finance_short "In the past seven months, did citizens, government, or non-governmental organiza"
	note finance_short: "In the past seven months, did citizens, government, or non-governmental organizations contribute money or in-kind donations to address the \${problem} problem?"

	label variable finance_citizens "How much did citizens contribute to solve the \${problem} in your village in the"
	note finance_citizens: "How much did citizens contribute to solve the \${problem} in your village in the last 7 months"

	label variable finance_ngo "How much did non-governmental organizations and citizens outside the village con"
	note finance_ngo: "How much did non-governmental organizations and citizens outside the village contribute (in cash or in kind) to solve the \${problem} in your village"

	label variable finance_gov "How much did the government contribute to solve the \${problem} in your village "
	note finance_gov: "How much did the government contribute to solve the \${problem} in your village in the last 7 months"

	label variable finance_gov_who "In your understanding, which government organization contributed funds or in-kin"
	note finance_gov_who: "In your understanding, which government organization contributed funds or in-kind contributions to address the \${problem} problem?"

	label variable finance_citizens_oth "What other problems have citizens made financial contributions to solve in the p"
	note finance_citizens_oth: "What other problems have citizens made financial contributions to solve in the past 7 months?"

	label variable finance_ngos_oth "What other problems have NGOs and citizens outside the village made financial co"
	note finance_ngos_oth: "What other problems have NGOs and citizens outside the village made financial contributions to solve in the past 7 months?"

	label variable finance_other_prob "What other problems has the government made contributions to solve in the past 7"
	note finance_other_prob: "What other problems has the government made contributions to solve in the past 7 months?"

	label variable effort_citizens "In your understanding have citizens contributed time and labor to solve \${probl"
	note effort_citizens: "In your understanding have citizens contributed time and labor to solve \${problem} problem for themselves in the past 7 months?"
	label define effort_citizens 1 "Yes" 0 "No"
	label values effort_citizens effort_citizens

	label variable effort_citizens_prop "In your understanding, what proportion of households contributed their time and "
	note effort_citizens_prop: "In your understanding, what proportion of households contributed their time and effort to solve the \${problem} problem in the past 7 months?"
	label define effort_citizens_prop 0 "0" 10 "0-10%" 20 "10-20%" 30 "20-30%" 40 "30-40%" 50 "40-50%" 60 "50-60%" 70 "60-70%" 80 "70-80%" 90 "80-90%" 100 "90-100%"
	label values effort_citizens_prop effort_citizens_prop

	label variable effort_citizens_oth "What other problems in the village/street have citizens taken actions to solve i"
	note effort_citizens_oth: "What other problems in the village/street have citizens taken actions to solve in the past 7 months?"

	label variable effort_citizens_oth_oth "Other (specify)"
	note effort_citizens_oth_oth: "Other (specify)"

	label variable aware_radio_listen "How often did you listen to the radio in the last two weeks?"
	note aware_radio_listen: "How often did you listen to the radio in the last two weeks?"
	label define aware_radio_listen 1 "Less than one hour a day" 2 "1-4 hours a day" 3 "More than 4 hours a day" 0 "Never" -999 "Don’t know" -888 "Refuse to answer"
	label values aware_radio_listen aware_radio_listen

	label variable aware_listen "Have you heard a radio report about an \${problem} problem in your village in th"
	note aware_listen: "Have you heard a radio report about an \${problem} problem in your village in the past 7 months?"
	label define aware_listen 1 "Yes" 0 "No"
	label values aware_listen aware_listen

	label variable aware_journolikely "How likely do you think it is that a journalist will visit your village/street i"
	note aware_journolikely: "How likely do you think it is that a journalist will visit your village/street if it has a development problem in the future?"
	label define aware_journolikely 0 "Not at all likely" 1 "Somewhat likely" 2 "Very likely"
	label values aware_journolikely aware_journolikely

	label variable aware_supportjourno "Do you agree or disagree with the following statement: if the problem in my vill"
	note aware_supportjourno: "Do you agree or disagree with the following statement: if the problem in my village is reported in the media, it may help to solve the problem?"
	label define aware_supportjourno 1 "Yes" 0 "No" -999 "Do not know"
	label values aware_supportjourno aware_supportjourno

	label variable aware_supportjourno_yes "Why do you think media report would help solve the problem?"
	note aware_supportjourno_yes: "Why do you think media report would help solve the problem?"

	label variable aware_supportjourno_no "Why don't you think a media report in your village would help solve the problem?"
	note aware_supportjourno_no: "Why don't you think a media report in your village would help solve the problem?"

	label variable pressure_who "Now I am going to give you another list of people. For each, please tell me whet"
	note pressure_who: "Now I am going to give you another list of people. For each, please tell me whether they have have asked or pushed OTHERS to take action to solve \${problem} problem in the past 7 months."

	label variable pressure_vill "In your understanding, who did the villagers push or request to resolve the \${p"
	note pressure_vill: "In your understanding, who did the villagers push or request to resolve the \${problem} problem in the village/street?"

	label variable pressure_vc "In your understanding, who did the village chairperson push or request to resolv"
	note pressure_vc: "In your understanding, who did the village chairperson push or request to resolve the \${problem} problem in the village/street?"

	label variable pressure_wc "In your understanding, who did the ward councillor push or request to resolve th"
	note pressure_wc: "In your understanding, who did the ward councillor push or request to resolve the \${problem} problem in the village/street?"

	label variable pressure_mp "In your understanding, who did the member of parliament push or request to resol"
	note pressure_mp: "In your understanding, who did the member of parliament push or request to resolve the \${problem} problem in the village/street?"

	label variable svy_followup "Would you be willing to participate in a follow-up survey that we may conduct th"
	note svy_followup: "Would you be willing to participate in a follow-up survey that we may conduct the future?"
	label define svy_followup 1 "Yes" 0 "No"
	label values svy_followup svy_followup

	label variable comments "Please leave your comments here"
	note comments: "Please leave your comments here"






	* append old, previously-imported data (if any)
	cap confirm file "`dtafile'"
	if _rc == 0 {
		* mark all new data before merging with old data
		gen new_data_row=1
		
		* pull in old data
		append using "`dtafile'", force 
		
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
*   Corrections file path and filename:  X:/Box Sync/Dissertation - Spotlight/01 Data/04 Raw Data/02_survey/spotlight_survey_cell_short_corrections.csv
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
