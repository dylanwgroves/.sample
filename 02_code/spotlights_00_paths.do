
/*______________________________________________________________________________
	
	Project: Spotlights
	Purpose: Set globals for Spotlight project		 
	Author: Dylan Groves, dylanwgroves@gmail.com 
	Date Created: 2021/08/01
	Date Edited: 2022/01/04											
________________________________________________________________________________*/


/* Stata Prep ___________________________________________________________________*/

	clear all 	
	clear matrix
	clear mata
	set more off 
	set maxvar 30000


/* Set Seed ___________________________________________________________*/

	set seed 1956

 
/* Set Globals _________________________________________________________*/

	foreach user in  "X:" {
					capture cd "`user'"
					if _rc == 0 macro def path `user'
				}
	local dir `c(pwd)'
	global user `dir'
	display "${user}"	
	
	
/* Main folders ________________________________________________________________*/

	/* Main */
	global spotlights_code "${user}/Documents/spotlights/02_code"
	global spotlights_data "${user}/Documents/spotlights/01_data"
	global spotlights_tables "${user}/Documents/spotlights/03_tables"
	global spotlights_figures "${user}/Documents/spotlights/04_figures"
	
	/* Clean */
	global spotlights_tables_clean "${user}/Dropbox/Apps/Overleaf/Spotlights/Tables"
	global spotlights_figures_clean "${user}/Dropbox/Apps/Overleaf/Spotlights/Figures"
	
	/* Pre-Analysis Plan */
	global spotlights_clean_tables_pap "${user}/Dropbox/Apps/Overleaf/Spotlight - Pre-Analysis Plan/Tables"
		
	
/* Set Date _____________________________________________________________________*/

	global date : di %tdDNCY daily("$S_DATE", "DMY")

	
/* Indicate whether the globals have been set __________________________________*/

	global globals_set "yes"

