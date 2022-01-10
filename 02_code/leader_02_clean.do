



/* Load Data ____________________________________________________________________*/

use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_leader.dta", clear



/* Format Date _________________________________________________________________*/
	
	rename startime starttime
	gen startdate = dofc(starttime) 
	order startdate, after(starttime)
	format %td startdate
	
	rename submissiondate submissiontime
	gen submissiondate = dofc(submissiontime) 
	order submissiondate, after(submissiontime)
	format %td submissiondate
	
	generate start_date_txt = string(startdate, "%td")	
	generate date_txt = string(submissiondate, "%td")

	gen enddate = dofc(endtime) 
	order enddate, after(endtime)
	format %td enddate
	
	generate double survey_length = endtime - starttime
	replace survey_length = round(survey_length / (1000*60), 1) // in minutes */

	
/* Drop Duplicates______________________________________________________________*/ 


/*Clean villages________________________________________________________________*/

	*drop if village_name_pull == "Mswaha"
	drop if enum == 14
		
/* Drop Based on Date __________________________________________________________*/

drop if startdate < td(01122021)



/* Cleaning ID's________________________________________________________________*/

replace aware_supportjourno = 0 if key == "uuid:42df3c6d-0479-4c0b-aaba-98b54a2ce958"
replace aware_supportjourno = 0 if key == "uuid:75d391b5-063a-4845-9a82-b4f209e307c6"
replace aware_supportjourno = 0 if key == "uuid:762abc02-3fb3-4de4-8fa6-00946edb6278"
replace aware_supportjourno = 0 if key == "uuid:a3dd2731-9db5-4d0b-8687-3df2e33b6429"

replace aware_journolikely = . if aware_journolikely > 2


/* Save ________________________________________________________________________*/

save "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_leader_clean.dta", replace 