



/* Load Data ____________________________________________________________________*/

use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO.dta", clear
use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO.dta", clear // For NEEMA


append using "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_citizen_DO.dta", force


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
	
	replace station_pull = "Storm FM" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace ward_name_pull = "Bwanga" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace village_name_pull = "Nyarututu" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace district_name_pull = "Chato" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace region_name_pull = "Geita" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace problem = "Health" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	replace treat_pull = "Control" if key == "uuid:964a6c9d-b58f-40fc-9185-88e3ebd8466f"
	
	replace station_pull = "TK FM" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace ward_name_pull = "Bwembwera" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace village_name_pull = "Mianga" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace district_name_pull = "Muheza" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace region_name_pull = "Tanga" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace problem = "Water" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace treat_pull = "Treatment" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"
	replace id = "174" if key == "uuid:4ae0af14-fa52-41fa-a85e-ea52a81c7431"

	replace station_pull = "Storm FM" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace ward_name_pull = "Nyarugusu" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace village_name_pull = "Nyarugusu" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace district_name_pull = "Geita Urban" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace region_name_pull = "Geita" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace problem = "Mining" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace treat_pull = "Treatment" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	replace id = "160" if key == "uuid:e0b5f6b8-c15b-43c6-bcce-3868c3552429"
	
	replace station_pull = ""
	
	drop if treat_pull == "TEST"
	drop if enum == 14
	*drop if id == "204"

	replace current_score = 0 if id == "92" | id == "96"
	replace gov_score = 0 if id == "92" | id == "96"
	
	drop if id == "Nyamadoke"
	drop if id == "Nsumba"

	drop if key == "uuid:c6fb875d-7b91-4d36-a8c4-374c5706a64a" // Mswaha
	drop if key == "uuid:bf14fb0b-fc6c-476a-915c-c3120e32b6ee"
	drop if key == "uuid:11057c15-0ff0-4ed1-9e13-3a0d9a9cfe51"
	drop if key == "uuid:27605bed-c81a-40d0-9f42-6dc425f78119"
	drop if key == "uuid:173afae2-2fe7-4fff-bb24-08718cfb7489" // Accidentally interviewed Nyawilimilwa

	
		
/* Drop Based on Date __________________________________________________________*/

drop if startdate < td(01112021)



/* Cleaning ID's________________________________________________________________*/




/* Save ________________________________________________________________________*/

sort id
save "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO_clean.dta", replace 