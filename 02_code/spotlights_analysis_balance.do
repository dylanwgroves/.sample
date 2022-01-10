
/* Basics ______________________________________________________________________

	Project: Wellspring Tanzania, Spotlight
	Purpose: Balance Test
	Author: dylan groves, dylanwgroves@gmail.com
	Date: 2021/08/02
________________________________________________________________________________*/


/* Introduction ________________________________________________________________*/
	
	clear all	
	clear matrix
	clear mata
	set more off
	global c_date = c(current_date)
	global spotlight "X:/Box Sync/Dissertation - Spotlight"
	set seed 1956

	
/* Tempfiles ___________________________________________________________________*/

	tempfile main

/* Run Prelim File _____________________________________________________________*/ // comment out if you dont need to rerun prelim cleaning	

	* Paths
	*do "${spotlight}/02 Code/spotlight_00_paths.do"
	
	* Import media
	*do "${spotlight_code}/spotlight_01_import_sample.do"


/* Load Data ___________________________________________________________________*/	

	insheet using "${spotlight}\01 Data\06 Final Data\spotlight_master_clean.csv", clear
		save `main'
		
	insheet using "${spotlight}\01 Data\06 Final Data\spotlight_sample_dist.csv", clear
		rename vllg_d village_uid
		merge 1:1 village_uid using `main'
	
/* Define Parameters ___________________________________________________*/

	#d ;
		
		/* set seed */
		set seed 			
							1956
							;
							
		/* rerandomization count */
		global rerandcount	
							100
							;
							
		/* control variables */
		global cov_always	
							i.station_n
							;
		
					
		/* Indices */			
		local index_list	
							village
							problem
							ward
							district
							distance	
							;
	#d cr


/* Run Do File _________________________________________________________________*/

	* One vs. two-sided tests
	do "${spotlight_code}/02_indices/spotlight_twosided.do"
		
	* Indices
	do "${spotlight_code}/02_indices/spotlight_indices_balance.do"

	
/* Run for Each Index __________________________________________________________*/

foreach index of local index_list {

	/* Drop Macros */
	macro drop lasso_ctls 
	macro drop lasso_ctls_num 
	macro drop lasso_ctls_int
	
	macro drop lasso_ctls_replacement
	macro drop lasso_ctls_num_replacement 
	macro drop lasso_ctls_int_replace
	
	macro drop helper_pval
	macro drop helper_ripval
	macro drop helper_lasso_pval
	macro drop helper_lasso_ripval
	
	macro drop test
	
	/* Define Matrix _______________________________________________________________*/
				
		/* Set Put Excel File Name */
		putexcel clear
		putexcel set "${spotlight_tables}/spotlight_balance.xlsx", sheet(`index', replace) modify
		
		qui putexcel A1 = ("variable")
		qui putexcel B1 = ("variablelabel")
		qui putexcel C1 = ("coef")
		qui putexcel D1 = ("se")
		qui putexcel E1 = ("pval")
		qui putexcel F1 = ("ripval")
		qui putexcel G1 = ("r2")
		qui putexcel H1 = ("N")
		qui putexcel I1 = ("lasso_coef")
		qui putexcel J1 = ("lasso_se")
		qui putexcel K1 = ("lasso_pval")
		qui putexcel L1 = ("lasso_ripval")
		qui putexcel M1 = ("lasso_r2")
		qui putexcel N1 = ("lasso_N")
		qui putexcel O1 = ("lasso_ctls")
		qui putexcel P1 = ("lasso_ctls_num")
		qui putexcel Q1 = ("treat_mean")
		qui putexcel R1 = ("treat_sd")
		qui putexcel S1 = ("ctl_mean")
		qui putexcel T1 = ("ctl_sd")
		qui putexcel U1 = ("vill_sd")
		qui putexcel V1 = ("min")
		qui putexcel W1 = ("max")
		qui putexcel X1 = ("test")

	
	/* Summary Stats ___________________________________________________________*/

		/* Set locals */
		local var_list ${`index'}												// Variables
		local row = 2															// Row for exporting to matrix
		foreach dv of local var_list  {
		
		/* variable */
		global dv `dv'
		
		/* set test */
		if strpos("$twosided", "`dv'") { 
			global test twosided	
		} 
			else {
				global test onesided
			}
		
		/* Variable name */
		qui ds `dv'
			global varname = "`r(varlist)'"  

		/* Variable label */
		global varlabel : var label `dv'
		
		/* Treatment mean */
		qui sum `dv' if treat == 0 
			global ctl_mean `r(mean)'
			global ctl_sd `r(sd)'

		/* Control mean */
		qui sum `dv' if treat == 1 
			global treat_mean `r(mean)'
			global treat_sd `r(sd)'
		
		/* Variable range */	
		qui sum `dv' 
			global min = r(min)
			global max = r(max)
			
			
	/* Basic Regression ________________________________________________________*/

		qui xi: reg `dv' treat i.block_uid ${cov_always}								// This is the core regression
			matrix table = r(table)
			
			/* Save values from regression */
			global coef = table[1,1]    	//beta
			global se 	= table[2,1]		//pval
			global t 	= table[3,1]		//pval
			global r2 	= `e(r2_a)' 		//r-squared
			global n 	= e(N) 				//N
			global df 	= e(df_r)
			
			/* Calculate pvalue */
			do "${spotlight_code}/01_helpers/spotlight_helper_pval.do"
			global pval = ${helper_pval}

			/* Calculate RI-pvalue */
			*do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_ri.do"
			*global ripval = ${helper_ripval}

	/* Lasso Regression  _______________________________________________________
	
		**FOR BALANCE WE ARE NOT INCLUDING LASSO REGRESSIONS 

		qui lasso linear `dv' ${cov_lasso}										// set this up as a separate do file
			global lasso_ctls = e(allvars_sel)										
			global lasso_ctls_num = e(k_nonzero_sel)

	
		if ${lasso_ctls_num} != 0 {												// If lassovars selected	
			qui regress `dv' treat ${cov_always} ${lasso_ctls}, cluster(id_village_n)
				matrix table = r(table)
			}
			
			else if ${lasso_ctls_num} == 0 {									// If no lassovars selected
				qui regress `dv' treat ${cov_always}, cluster(id_village_n)
					matrix table = r(table)
			}	
		
			/* Save Coefficient */
			local lasso_coef = table[1,1]
				
			/* Save values from regression */
			global lasso_coef 	= table[1,1]    	//beta
			global lasso_se 	= table[2,1]		//pval
			global lasso_t 		= table[3,1]		//pval
			global lasso_r2 	= `e(r2_a)' 		//r-squared
			global lasso_n 		= e(N) 				//N			
			global lasso_df 	= e(df_r)

			/* Calculate one-sided pvalue */				
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_lasso.do"
			global lasso_pval = ${helper_lasso_pval}
			
			/* Calculate Lasso RI-pvalue */
			do "${code}/pfm_audioscreening/01_helpers/pfm_helper_pval_ri_lasso.do"
			global lasso_ripval = ${helper_lasso_ripval}
	*/
		
	/* Export to Excel _________________________________________________________*/ 
		
		di "Variable is ${varname}, coefficient is ${coef}, pval is ${pval} / ripval is ${ripval}, N = ${n}"
		di "LASSO: Variable is ${varname}, coefficient is ${lasso_coef}, lasso pval is ${lasso_pval} / lasso ripval is ${lasso_ripval}, N = ${lasso_n}"
		di "LASSO vars were ${lasso_ctls}"

		qui putexcel A`row' = ("${varname}")
		qui putexcel B`row' = ("${varlabel}")
		qui putexcel C`row' = ("${coef}")
		qui putexcel D`row' = ("${se}")
		qui putexcel E`row' = ("${pval}")
		qui putexcel F`row' = ("${ripval}")
		qui putexcel G`row' = ("${r2}")
		qui putexcel H`row' = ("${n}")
		qui putexcel I`row' = ("${lasso_coef}")
		qui putexcel J`row' = ("${lasso_se}")
		qui putexcel K`row' = ("${lasso_pval}")
		qui putexcel L`row' = ("${lasso_ripval}")
		qui putexcel M`row' = ("${lasso_r2}")
		qui putexcel N`row' = ("${lasso_n}")
		qui putexcel O`row' = ("${lasso_ctls}")
		qui putexcel P`row' = ("${lasso_ctls_num}")
		qui putexcel Q`row' = ("${treat_mean}")
		qui putexcel R`row' = ("${treat_sd}")
		qui putexcel S`row' = ("${ctl_mean}")
		qui putexcel T`row' = ("${ctl_sd}")
		qui putexcel U`row' = ("${vill_sd}")
		qui putexcel V`row' = ("${min}")
		qui putexcel W`row' = ("${max}")
		qui putexcel X`row' = ("${test}")
		
		/* Update locals ___________________________________________________________*/
		
		local row = `row' + 1
		}
}



















