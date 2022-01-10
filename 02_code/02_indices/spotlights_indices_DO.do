

/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Radio Distribution Globals
	Purpose: Analysis - Set Globals
	Author: dylan groves, dylanwgroves@gmail.com
	Date Created: 2021/08/01
	Date Edited: 2022/01/04
________________________________________________________________________________*/


/* Define Globals and globals ___________________________________________________*/

	#d ;
		/* Covariatesm Blocks, Clusters*/	
		global cov_always	i.block												// Covariates that are always included
							;	

		
		/* Attrition */
		global attrition	attrition
							;
							
		
		/* First Stage */
		global firststage	journo_visit
							journo_heard
							journo_any
							journo_likely 
							;
								
		/* Results */							
		global current		current_score
							current_win									
							current_dum
							;
							
		global gov			gov_score
							gov_win									
							gov_dum
							;
							
		global vill			vill_score
							vill_win									
							vill_dum
							;

		global oth			oth_score
							oth_win									
							oth_dum
							;
							
		global dept			wc_score 
							bur_score 
							mp_score 
							ministry_score
							;
							

	#d cr
