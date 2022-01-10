

/* Load Data ____________________________________________________________________*/

cap use "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO_clean.dta", clear

	
/* Locals ______________________________________________________________________*/

global source "X:\Box Sync\Dissertation - Spotlight\01 Data\04 Raw Data\02_survey\media"

global reportcards "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards"

global destination_overview "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\01_overview"
global destination_overview_ev "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\01_overview\01_evidence"

global destination_villagers "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\02_villagers"
global destination_villagers_ev "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\02_villagers\01_evidence"
	
global destination_government "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\03_governments"
global destination_government_ev "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\03_governments\01_evidence"

global destination_other "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\04_other"
global destination_other_ev "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\01_reportcards\media\04_other\01_evidence"


/* Survey Information __________________________________________________________*/

	rename station_pull svy_station 
	rename village_name_pull svy_village_n 
	rename ward_name_pull svy_ward_n 
	rename district_name_pull svy_district_n 
	rename region_name_pull svy_region_n 
	rename problem svy_problem 
	encode treat_pull, gen(sb_treat)
		recode sb_treat (2 = 1 "Treat")(1 = 0 "Control"), gen(treat) 
	rename enum svy_enum 
	rename enum_name svy_enum_n 
	rename id svy_village_uid
	gen resp_target = 0 
	gen resp_target_txt = "0"
	
	gen uid = svy_village_uid + "_" + resp_target_txt
		drop resp_target_txt
		
		
/* Drop Unecessary Variables ___________________________________________________*/

	drop if startdate == td(30112021) & svy_enum != 2 & resp_target == 0 
	
/* Overview ____________________________________________________________________*/

	count
	local num = r(N)
	
	* rename some villages
	clonevar villname = svy_village_n 
		replace villname = "Itewe" if svy_village_uid == "28"
		replace villname = "Kaskazini" if svy_village_uid == "61"
		replace villname = "Lurwa" if svy_village_uid == "30"
		replace villname = "Mkizi" if svy_village_uid == "179"
		replace villname = "Lugawa" if svy_village_uid == "13"
		
	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof svy_village_uid, local(sb_uid)
				global uid `sb_uid'
			levelsof villname, local(sb_vill)
				global vill `sb_vill'
				
				di ${uid}

			* make folders	
			cap mkdir "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}"
	
			* Remove the meda\ so we jsut have the file name

			*generate globals of all the relevant stuff so we can use it for copying
			foreach type of varlist prob_overview_audio ///
									gov_overview_audio ///
									vill_overview_audio ///
									oth_overview_audio ///
									prob_audio_* {
												
				global type `type'
			
				replace `type' = subinstr(`type', "media\", "", .)
				
				*capture original file name
				levelsof `type', local(sb_file)
				global file `sb_file'
				
				* capture the type fo file so we can use it for saving
				cap split `type', p(.) limit(2)
				cap rename `type'2 filetype
				
				cap levelsof filetype, local(sb_filetype)
				cap local typefile `sb_filetype'
				
				cap copy 	"X:\Box Sync\Dissertation - Spotlight\01 Data\04 Raw Data\02_survey\media/${file}" ///
							"X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_${type}.`typefile'"
							
				macro drop type
				macro drop file
				macro drop typefile 
			}
					
			keep svy_village_uid svy_village_n prob_overview_text prob_text_* gov_overview_text gov_text_* vill_overview_text vill_text_* oth_overview_text oth_text_* 
			export excel using "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_text.xls", firstrow(variables) replace
	
	macro drop uid vill 
	di "** DONE ${uid} ${vill} **"
	restore 
	}
	
	
	** IMAGES 
	
	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof svy_village_uid, local(sb_uid)
				global uid `sb_uid'
			levelsof villname, local(sb_vill)
				global vill `sb_vill'

			* make folders	
			cap mkdir "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}"
			
			* Remove the meda\ so we jsut have the file name

			*generate globals of all the relevant stuff so we can use it for copying
			drop gov_image_12
			foreach type of varlist prob_image_* vill_image_* gov_image_* oth_image_* {
												
				global type `type'
			
				cap replace `type' = subinstr(`type', "media\", "", .)
				
				*capture original file name
				cap levelsof `type', local(sb_file)
				cap global file `sb_file'
				
				* capture the type fo file so we can use it for saving
				cap split `type', p(.) limit(2)
				cap rename `type'2 filetype
				
				cap levelsof filetype, local(sb_filetype)
				cap local typefile `sb_filetype'
				
				cap copy 	"X:\Box Sync\Dissertation - Spotlight\01 Data\04 Raw Data\02_survey\media/${file}" ///
							"X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_${type}.`typefile'"
							
				macro drop type
				macro drop file
				macro drop typefile 
			}
					
			keep svy_village_uid svy_village_n prob_overview_text prob_text_* gov_overview_text gov_text_* vill_overview_text vill_text_* oth_overview_text oth_text_* 
			export excel using "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_text.xls", firstrow(variables) replace
	
	macro drop uid vill 
	di "** DONE ${uid} ${vill} **"
	restore 
	}
	

	** VIDEOS
	
	forvalues x = 1/`num' {

		preserve
		
			keep if _n == `x'
			
			levelsof svy_village_uid, local(sb_uid)
				global uid `sb_uid'
			levelsof villname, local(sb_vill)
				global vill `sb_vill'

			* make folders	
			cap mkdir "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}"
			
			* Remove the meda\ so we jsut have the file name

			*generate globals of all the relevant stuff so we can use it for copying
			drop gov_video_12
			drop gov_video_22
			foreach type of varlist prob_video_* vill_video_* gov_video_* oth_video_* {
												
				global type `type'
			
				replace `type' = subinstr(`type', "media\", "", .)
				
				*capture original file name
				levelsof `type', local(sb_file)
				global file `sb_file'
				
				* capture the type fo file so we can use it for saving
				cap split `type', p(.) limit(2)
				cap rename `type'2 filetype
				
				cap levelsof filetype, local(sb_filetype)
				cap local typefile `sb_filetype'
				
				cap copy 	"X:\Box Sync\Dissertation - Spotlight\01 Data\04 Raw Data\02_survey\media/${file}" ///
							"X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_${type}.`typefile'"
							
				macro drop type
				macro drop file
				macro drop typefile 
			}
					
			keep svy_village_uid svy_village_n prob_overview_text prob_text_* gov_overview_text gov_text_* vill_overview_text vill_text_* oth_overview_text oth_text_* 
			export excel using "X:\Box Sync\Dissertation - Spotlight\01 Data\06 Final Data\02_do/${uid}_${vill}/${uid}_text.xls", firstrow(variables) replace
	
	macro drop uid vill 
	di "** DONE ${uid} ${vill} **"
	restore 
	}
	


/* Rename Some Stuff ___________________________________________________________*/

rename * do_* 
rename do_uid uid 
rename do_svy_* svy_* 
rename do_resp_* resp_* 
rename do_date_* date_* 

save "X:/Box Sync/Dissertation - Spotlight/01 Data/05 Mid Data/spotlight_survey_DO_format.dta", replace 

sort svy_village_uid
order svy_village_uid