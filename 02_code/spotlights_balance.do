/* Basics ______________________________________________________________________

Project: Wellspring Tanzania, Audio Screening Experiment
Purpose: Balance
Author: dylan groves, dylanwgroves@gmail.com
Date: 2021/04/01
________________________________________________________________________________*/



/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)


/* Run Prelim Do File __________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_covars.do"
	*do "${code}/pfm_.master/00_setup/pfm_paths_master.do"
	do "${code}/pfm_audioscreening_efm/pfm_as_prelim.do"

	
/* Load Data ___________________________________________________________________*/	

	use "${data_as}/pfm_as_analysis.dta", clear

	
/* Define Globals and Locals ____________________________________________________*/

	/* Set seed */
	set seed 			1956
	
	/* Set seed */
	global rerandcount 	2000

	/* Outcomes */
	#d ;
	local index_list	cov_lasso
						;
						
	local short_vars	resp_age 
						resp_female
						resp_muslim
						b_resp_standard7
						b_resp_married 
						b_asset_cell
						b_asset_radio_num
						b_ge_index
						;
	#d cr
	
/* Define Matrix _______________________________________________________________*/

foreach index of local index_list {
		
	/* Set Put Excel File Name */
	putexcel clear
	putexcel set "${as_tables}/pfm_as_balance_long.xlsx", sheet(`index_list', replace)  modify 
	
	putexcel A1 = ("variable")
	putexcel B1 = ("variablelabel")
	putexcel C1 = ("treatmean")
	putexcel D1 = ("treatsd")
	putexcel E1 = ("controlmean")
	putexcel F1 = ("controlsd")
	putexcel G1 = ("coef")
	putexcel H1 = ("pval")
	putexcel I1 = ("ripval")
	putexcel J1 = ("N")
	putexcel K1 = ("min")
	putexcel L1 = ("max")
	putexcel M1 = ("samplemean")
	
	
/* Run Prelim Do File __________________________________________________________*/

	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_labels.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_twosided.do"
	do "${code}/pfm_audioscreening_efm/02_indices/pfm_as_indices_main.do"

	
/* Export Regression ___________________________________________________________*/

	/* Set locals */
	local var_list ${`index'}													// Variables
	local row = 2																// Row for exporting to matrix
	
	/* Run for each variable */
	foreach dv of local var_list  {

		/* Set global */
		global dv `dv'

		/* Variable Name */
		qui ds `dv'
			global varname = "`r(varlist)'"  
			
		/* Variable Label */
		global varlabel : var label `dv'
			
		/* Treatment / Control Mean */
		qui sum `dv' if treat == 0 
			global control_mean `r(mean)'
			global control_sd `r(sd)'

		qui sum `dv' if treat == 1 
			global treat_mean `r(mean)'
			global treat_sd `r(sd)'
			
		qui sum `dv'
			global sample_mean `r(mean)'

		/* Variable Range */	
		qui sum `dv' 
			global min = r(min)
			global max = r(max)

		/* Regression  */
		xi: reg `dv' treat ${cov_always}, cluster(cluster_as)		
			matrix table = r(table)
				
			/* Save values from regression */
			global coef = table[1,1]    	//beta
			global pval = table[4,1]		//pval
			global r2 	= `e(r2_a)' 		//r-squared
			global n 	= e(N) 				//N
			
		/* RI */
		do "${code}/pfm_audioscreening_efm/01_helpers/pfm_helper_ri_balance.do"
		global ripval = ${helper_ripval}
			
			/* Put excel */
			putexcel A`row' = ("${varname}")
			cap putexcel B`row' = ("${varlabel}")
			putexcel C`row' = ("${treat_mean}")
			putexcel D`row' = ("${treat_sd}")
			putexcel E`row' = ("${control_mean}")
			putexcel F`row' = ("${control_sd}")
			putexcel G`row' = ("${coef}")
			putexcel H`row' = ("${pval}")
			putexcel I`row' = ("${ripval}")
			putexcel J`row' = ("${n}")
			putexcel K`row' = ("${min}")
			putexcel L`row' = ("${max}")
			putexcel M`row' = ("${sample_mean}")

	/* Keep track */
	di "`dv'"
	di "$helper_ripval"
	
	/* Update locals */
	local row = `row' + 1
	local i = `i' + 1 

}	
}

