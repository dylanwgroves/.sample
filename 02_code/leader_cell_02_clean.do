



/* Load Data ____________________________________________________________________*/

use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_cell_short.dta", clear


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


/*Clean villages________________________________________________________________

	replace village_name_pull 	= "Kisangara" if vlcheck_name == "Sofia Ramadhani Potea"
	replace ward_name_pull = "Lembeni" if vlcheck_name == "Sofia Ramadhani Potea"
	replace district_name_pull = "Mwanga" if vlcheck_name == "Sofia Ramadhani Potea"
	replace id = "76" if vlcheck_name == "Sofia Ramadhani Potea"
	
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
*/	
	drop if village_name_pull == "Mswaha"
	
	drop if enum == 14
	
	
/* Clean survey responses ______________________________________________________*/

replace resp_target = 2 if vlcheck_name == "Saidi Makonya"

replace aware_journolikely = 2 if aware_journolikely == 3
	

/* Drop Based on Date __________________________________________________________*/

drop if startdate < td(01122021)



/* Cleaning ID's________________________________________________________________*/


/* Save ________________________________________________________________________*/

save "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_cell_clean.dta", replace 