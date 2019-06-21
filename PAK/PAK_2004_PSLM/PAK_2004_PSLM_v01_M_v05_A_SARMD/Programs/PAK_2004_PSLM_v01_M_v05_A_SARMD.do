/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			PAKISTAN
** COUNTRY ISO CODE	PAK
** YEAR				2004
** SURVEY NAME		PAKISTAN SOCIAL AND LIVING STANDARDS  MEASUREMENT SURVEY (ROUND-1)
** SURVEY AGENCY	Government of Pakistan Statistics divisionFederal Statistics Bureau
** RESPONSIBLE		Triana Yentzen
** Modified by		Fernando Enrique Morales Velandia
** Date:			02/23/2018
**
******************************************************************************************************
*****************************************************************************************************/

/*****************************************************************************************************
*                                                                                                    *
                                   INITIAL COMMANDS
*                                                                                                    *
*****************************************************************************************************/


** INITIAL COMMANDS
	cap log close 
	clear
	set more off
	set mem 800m


** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2004_PSLM\PAK_2004_PSLM_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2004_PSLM\PAK_2004_PSLM_v01_M_v05_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\PAK"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\PAK_2004_PSLM_v01_M_v05_A.log",replace



/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT

	use "`input'\Data\Stata\pslmA.dta", clear
	duplicates list hhcode
	ren hhcode HID
	format HID %12.0f
	sort HID

	preserve

	use "`input'\Data\Stata\PLSMclean.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	tempfile wgt
	save `wgt'

	restore
	merge HID using `wgt'
	tab _
	drop _

	sort HID
	tempfile basic_info
	save `basic_info'

	use "`input'\Data\Stata\pslmB.dta", clear
	ren hhcode HID
	format HID %12.0f


	sort HID serialno
	tempfile temp
	save `temp'

	use "`input'\Data\Stata\pslmC.dta", clear
	ren hhcode HID
	format HID %12.0f
	duplicates examples HID serialno

	sort HID serialno
	merge HID serialno using `temp'
	tab _
	drop if _==1
	drop _
	duplicates examples HID serialno
	sort HID 
	save `temp', replace

	use "`input'\Data\Stata\pslmG.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID
	save `temp', replace

	use "`input'\Data\Stata\pslmH1_inc.dta", clear
	ren hhcode HID
	format HID %12.0f
	egen total_inc = rowtotal( inc1 inc2 inc3 inc4 inc5 inc6 inc7 inc8 inc9 inc10 inc11 inc12), missing
	sort HID
	merge HID using `temp'
	tab _m
	drop _m
	sort HID serialno
	save `temp', replace

	use "`input'\Data\Stata\pslmE.dta", clear
	ren hhcode HID
	format HID %12.0f
	sort HID serialno
	merge HID serialno using `temp'
	tab _m
	drop _m
	sort HID serialno
	merge HID using  `basic_info'
	drop _merge
	save `temp', replace

/*Assets*/
	use "`input'\Data\Stata\assets.dta", clear
	ren hhcode HID
	format HID %12.0f
	merge 1:m HID using `temp'
	drop if _merge==1
	drop _merge
	save `temp', replace

	
	/*
Consumption. 
*/
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	tempfile comp
	keep if year==2004
	keep hhcode nomexpend hhsizeM eqadultM peaexpM psupind new_pline texpend region weight
	ren hhcode HID

	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3
	drop _merge

	save `temp', replace
	use "`input'\Data\Stata\consumption (L1-3).dta"
	ren hhcode HID
	keep HID stratum substrat 
	duplicates drop stratum substrat HID, force
	
	merge 1:m HID using `temp'
	tab _merge
	keep if _merge==3

	
	
	notes _dta: "PAK 2004" for this round there is not information available for the identification of landholding, livestock assets, durables. This information comes from section F of the questionnaire.

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
*<_countrycode_>
	gen str4 countrycode="PAK"
	label var countrycode "Country code"
*</_countrycode_>


** YEAR
*<_year_>
	gen int year=2004
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="PSLM"
	label var survey "Survey Acronym"
*</_survey_>


	* There are many coding errors for the date of interview
	replace year1=2000+year1
	*replace month1=. 	if month1<9  & year1==2004 & month1!=.
	*replace month1=. 	if month1>=7 & year1==2005 & month1!=.
	*replace year1=. 	if month1<9  & year1==2004 & month1!=.
	*replace year1=. 	if month1>=7 & year1==2005 & month1!=.
	replace month1=. 	if year1!=2004 & year1!=2005
	replace year1=. 	if year1!=2004 & year1!=2005
	replace month1=. 	if month1>12 & month1!=.
	replace year1=. 	if month1>12 & month1!=.
	
** INTERVIEW YEAR
	gen int_year=year1
	label var int_year "Year of the interview"
*</_int_year_>

	
** INTERVIEW MONTH
	gen int_month=month1
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
*</_int_month_>
	
**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 

	
	
	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh=HID
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen double idp_= 100*idh+serialno
	gen idp=string(idp_,"%14.0g")
	tostring idh, replace
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=hweight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=.
	label var strata "Strata"
	notes strata: "PAK 2004" variable strata is not generated in this version although it comes from default raw-files.
*</_strata_>


** PSU
*<_psu_>
	drop psu
	gen psu= psucode
	label var psu "Primary sampling units"
*</_psu_>


** MASTER VERSION
*<_vermast_>

	gen vermast="01"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="05"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
	gen byte urban=urbrural
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"


** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=province
	la de lblsubnatid1 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid1_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=.
	replace ownhouse=1 if g01==1
	replace ownhouse=0 if inlist(g01,2,3,4)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if g01==1
   replace tenure=2 if g01==2
   replace tenure=3 if inrange(g01, 3,4)
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=.
   label var landholding "Household owns any land"
   la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding
*</_landholding_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=g05
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped into house/compound"
					 2 "Outdoor Tab"
					 3 "Hand pump" 
					 4 "Motorized pump"
					 5 "Covered well" 
				     6 "Unprotected well"
					 7 "River, Stream, Pond, Lake"
					 8 "Water tanker/truck or Vendor" 
			         9 "Others (specify)";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>


*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if g05==1 | g05==2 
replace piped_water=0 if inlist(g05,3,4,5,6,7,8,9)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
note piped_water: "PAK 2004" This variable is created if water is piped in hh or through a tab.
*</_piped_water_>



**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if inlist(g05,1)
replace water_jmp=2 if inlist(g05,2)
replace water_jmp=4 if inlist(g05,3,4)
replace water_jmp=5 if inlist(g05,5)
replace water_jmp=6 if inlist(g05,6)
replace water_jmp=12 if inlist(g05,7)
replace water_jmp=10 if inlist(g05,8)
replace water_jmp=14 if inlist(g05,9)

label var water_jmp "Source of drinking water-using Joint Monitoring Program categories"
#delimit
la de lblwater_jmp 1 "Piped into dwelling" 	
				   2 "Piped into compound, yard or plot" 
				   3 "Public tap / standpipe" 
				   4 "Tubewell, Borehole" 
				   5 "Protected well"
				   6 "Unprotected well"
				   7 "Protected spring"
				   8 "Unprotected spring"
				   9 "Rain water"
				   10 "Tanker-truck or other vendor"
				   11 "Cart with small tank / drum"
				   12 "Surface water (river, stream, dam, lake, pond)"
				   13 "Bottled water"
				   14 "Other";
#delimit cr
la values  water_jmp lblwater_jmp
 *</_water_jmp_>

  
 *SAR improved source of drinking water
*<_sar_improved_water_>
gen sar_improved_water=.
replace sar_improved_water=1 if inlist(water_jmp,1,2,3,4,5,7,9,13)
replace sar_improved_water=0 if inlist(water_jmp, 6,8,10,11,12,14)
la def lblsar_improved_water 1 "Improved" 0 "Unimproved"
la var sar_improved_water "Improved source of drinking water-using country-specific definitions"
la val sar_improved_water lblsar_improved_water
*</_sar_improved_water_>


*ORIGINAL WATER CATEGORIES
*<_water_original_>
clonevar j=g05
#delimit
la def lblwater_original 1 "Piped into house/compound"
						 2 "Outdoor Tab"
						 3 "Hand pump" 
						 4 "Motorized pump"
						 5 "Covered well" 
						 6 "Unprotected well"
						 7 "River, Stream, Pond, Lake"
						 8 "Water tanker/truck or Vendor" 
						 9 "Others (specify)";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if g05==1
		replace water_source=2 if g05==2
		replace water_source=4 if g05==3
		replace water_source=4 if g05==4
		replace water_source=5 if g05==5
		replace water_source=10 if g05==6
		replace water_source=13 if g05==7
		replace water_source=12 if g05==8
		replace water_source=14 if g05==9
		#delimit
			la de lblwater_source 1 "Piped water into dwelling" 	
								  2 "Piped water to yard/plot" 
								  3 "Public tap or standpipe" 
								  4 "Tubewell or borehole" 
								  5 "Protected dug well"
								  6 "Protected spring"
								  7 "Bottled water"
								  8 "Rainwater"
								  9 "Unprotected spring"
								  10 "Unprotected dug well"
								  11 "Cart with small tank/drum"
								  12 "Tanker-truck"
								  13 "Surface water"
								  14 "Other";
		#delimit cr
		la val water_source lblwater_source
		la var water_source "Sources of drinking water"
	*</_water_source_>

	
	** SAR IMPROVED SOURCE OF DRINKING WATER
	*<_improved_water_>
		gen improved_water=.
		replace improved_water=1 if inrange(water_source,1,8)
		replace improved_water=0 if inrange(water_source,9,14) // Asuming other is not improved water source
		la def lblimproved_water 1 "Improved" 0 "Unimproved"
		la val improved_water lblimproved_water
		la var improved_water "Improved access to drinking water"
	*</_improved_water_>



	** PIPED SOURCE OF WATER ACCESS
	*<_pipedwater_acc_>
		gen pipedwater_acc=0 if inrange(g05,3,9) // Asuming other is not piped water
		replace pipedwater_acc=1 if inlist(g05,1)
		replace pipedwater_acc=2 if inlist(g05,2)
		#delimit 
		la def lblpipedwater_acc	0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val pipedwater_acc lblpipedwater_acc
		la var pipedwater_acc "Household has access to piped water"
	*</_pipedwater_acc_>

	
	** WATER TYPE VARIABLE USED IN THE SURVEY
	*<_watertype_quest_>
		gen watertype_quest=1
		#delimit
		la def lblwaterquest_type	1 "Drinking water"
									2 "General water"
									3 "Both"
									4 "Others";
		#delimit cr
		la val watertype_quest lblwaterquest_type
		la var watertype_quest "Type of water questions used in the survey"
	*</_watertype_quest_>

	
 ** ELECTRICITY PUBLIC CONNECTION
*<_electricity_>
	gen byte electricity=.
	replace electricity=1 if g08==1
	replace electricity=0 if inlist(g08,2,3,4,5,6)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	note electricity: "PAK 2004" this variable is generated if hh main source of lighting is electricity. Take into account for comparability purposes with other rounds.
*</_electricity_>

*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=g06
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "None"
					  2 "Flush system (linked with sewerage line)"
					  3 "Flush (Linked with septic tank)"
					  4 "Flush (connected with open drain)"
					  5 "Raised Latrine (Khadi)"
					  6 "Pit latrine"
					  7 "Others";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=.
replace sewage_toilet=1 if g06==2
replace sewage_toilet=0 if inlist(g06,1,3,4,5,6,7)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>

**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=12 if toilet_orig==1
replace toilet_jmp=1 if toilet_orig==2
replace toilet_jmp=3 if toilet_orig==3
replace toilet_jmp=13 if inlist(toilet_orig, 4,5,6,7)
label var toilet_jmp "Access to sanitation facility-using Joint Monitoring Program categories"
#delimit 
la def lbltoilet_jmp 1 "Flush to piped sewer  system"
					2 "Flush to septic tank"
					3 "Flush to pit latrine"
					4 "Flush to somewhere else"
					5 "Flush, don't know where"
					6 "Ventilated improved pit latrine"
					7 "Pit latrine with slab"
					8 "Pit latrine without slab/open pit"
					9 "Composting toilet"
					10 "Bucket toilet"
					11 "Hanging toilet/hanging latrine"
					12 "No facility/bush/field"
					13 "Other";
#delimit cr
la val toilet_jmp lbltoilet_jmp
*</_toilet_jmp_>


*SAR improved type of toilet
*<_sar_improved_toilet_>
gen sar_improved_toilet=.
replace sar_improved_toilet=1 if inlist(toilet_jmp,1,2,3,6,7,9)
replace sar_improved_toilet=0 if inlist(toilet_jmp,4,5,8,10,11,12,13)

la def lblsar_improved_toilet 1 "Improved" 0 "Unimproved"
la var sar_improved_toilet "Improved type of sanitation facility-using country-specific definitions"
la val sar_improved_toilet lblsar_improved_toilet
*</_sar_improved_toilet_>


	** ORIGINAL SANITATION CATEGORIES 
	*<_sanitation_original_>
		clonevar j=g06
		#delimit
		la def lblsanitation_original   1 "None"
										2 "Flush system (linked with sewerage line)"
										3 "Flush (Linked with septic tank)"
										4 "Flush (connected with open drain)"
										5 "Raised Latrine (Khadi)"
										6 "Pit latrine"
										7 "Others";
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=13 if g06==1
		replace sanitation_source=2 if g06==2
		replace sanitation_source=3 if g06==3
		replace sanitation_source=14 if g06==4
		replace sanitation_source=14 if g06==5
		replace sanitation_source=14 if g06==6
		replace sanitation_source=14 if g06==7
		#delimit
		la def lblsanitation_source	1	"A flush toilet"
									2	"A piped sewer system"
									3	"A septic tank"
									4	"Pit latrine"
									5	"Ventilated improved pit latrine (VIP)"
									6	"Pit latrine with slab"
									7	"Composting toilet"
									8	"Special case"
									9	"A flush/pour flush to elsewhere"
									10	"A pit latrine without slab"
									11	"Bucket"
									12	"Hanging toilet or hanging latrine"
									13	"No facilities or bush or field"
									14	"Other";
		#delimit cr
		la val sanitation_source lblsanitation_source
		la var sanitation_source "Sources of sanitation facilities"
	*</_sanitation_source_>

	
	** SAR IMPROVED SANITATION 
	*<_improved_sanitation_>
		gen improved_sanitation=.
		replace improved_sanitation=1 if inlist(sanitation_source,1,2,3,4,5,6,7,8)
		replace improved_sanitation=0 if inlist(sanitation_source,9,10,11,12,13,14)
		la def lblimproved_sanitation 1 "Improved" 0 "Unimproved"
		la val improved_sanitation lblimproved_sanitation
		la var improved_sanitation "Improved type of sanitation facility-using country-specific definitions"
	*</_improved_sanitation_>
	

	** ACCESS TO FLUSH TOILET
	*<_toilet_acc_>
		gen toilet_acc=3 if improved_sanitation==1
		replace toilet_acc=0 if improved_sanitation==0 
		#delimit 
		la def lbltoilet_acc		0 "No"
									1 "Yes, in premise"
									2 "Yes, but not in premise"
									3 "Yes, unstated whether in or outside premise";
		#delimit cr
		la val toilet_acc lbltoilet_acc
		la var toilet_acc "Household has access to flushed toilet"
	*</_toilet_acc_>

	
** INTERNET
	gen byte internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
*<_hsize_>
	gen byte hsize=hhsizeM
	la var hsize "Household size"
*</_hsize_>

**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


	
** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>
	gen byte relationharm=rel
	recode relationharm (5=4) (4 6 7 8 9 = 5) (10 = 6) (0=.)

	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>
	label values relationharm  lblrelationharm
*</_relationharm_>

** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=rel
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Child" 4 "Grandchild" 5 "Parent" 6 "Brother/Sister" 7  "Son/Daughter-in-law" 8 "Father/Mother-in-law" 9 "Other relative" 10 "Not related"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male= sex
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	*gen byte age=age
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc
*</_soc_>

** MARITAL STATUS
*<_marital_>	*gen byte marital=marital
	recode marital (1=2) (2 5 =1) (4=5) (3=4)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital
*</_marital_>


*Replace as missing those out of household size and non-relatives from ownership of assets
foreach i in ownhouse tenure landholding{
replace `i'=. if relationharm==6 & hsize==.
}


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/
** EDUCATION MODULE AGE
*<_ed_mod_age_>
	gen byte ed_mod_age=4
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>

** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=.
	replace atschool=1 if c05==1
	replace atschool=0 if c05==2 | c03==2
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>

** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=.
	replace literacy=1 if c01==1
	replace literacy=0 if c01==2
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	notes literacy: "PAK 2004" literacy questions are only asked to individuals 10 years or older
	replace literacy=. if age<10
*</_literacy_>


** YEARS OF EDUCATION COMPLETED
*<_educy_>

/*
code	Name									  years
0		0											0	
1	Class 1											1
2	Class 2											2
3	Class 3											3
4	Class 4											4
5	Class 5											5
6	Class 6											6
7	Class 7											7
8	Class 8											8
9	Class 9											9
10	Class 10										10
11	F.A/F.Sc/C.Com/Diploma							12
12	B.A.B.Sc.(Except engineer,medical,compsci,Agri)	14
13	Degree in Engineering							16
15	Degree in Computer								16
16	Degree in Agriculture							16
17	M.A/M.Sc.										16
14	Degree in medicine								17
18	Mphil/Ph.D										19
19	Other											NA
*/

	gen byte educy=.
	replace educy=0 if c03==2
	replace educy = c04
	replace educy = 12 if c04 == 11 
	replace educy = 14 if c04 == 12 
	replace educy = 17 if c04 == 14
	replace educy = 16 if (c04 == 13 | c04 == 15 | c04 == 16 | c04 == 17)
	replace educy = 20 if c04 == 18
	replace educy = . if c04 == 19
	label var educy "Years of education"
*</_educy_>

	
** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>=1 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 & educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy!=.
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"
*</_educat7_>



** EDUCATION LEVEL 5 CATEGORIES
*<_educat5_>
	gen educat5=.
	replace educat5=1 if educat7==1
	replace educat5=2 if educat7==2
	replace educat5=3 if educat7==3 | educat7==4
	replace educat5=4 if educat7==5
	replace educat5=5 if educat7==6 | educat7==7
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
*</_educat5_>

	la var educat5 "Level of education 5 categories"

	
** EDUCATION LEVEL 4 CATEGORIES
*<_educat4_>
	gen byte educat4=.
	replace educat4=1 if educat7==1 
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
*</_educat4_>



** EVER ATTENDED SCHOOL
*<_everattend_>
	gen byte everattend=c03
	recode everattend (2=0)
	replace everattend=1 if atschool==1
	replace everattend=. if age<ed_mod_age & age!=.
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend
*</_everattend_>



	replace educy=0 	if everattend==0
	replace educat7=1 	if everattend==0
	replace educat5=1 	if everattend==0
	replace educat4=1 	if everattend==0
foreach var in atschool literacy educy everattend educat4 educat5 educat7{
replace `var'=. if age<ed_mod_age
}


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
*<_lb_mod_age_>

 gen byte lb_mod_age=10
	label var lb_mod_age "Labor module application age"
*</_lb_mod_age_>

** LABOR STATUS
*<_lstatus_>
	gen byte lstatus=.
	replace lstatus = 1 if e01== 1 | (e01 == 2 & e02 == 1) | (e01 == 2 & e03 == 1) | (e01 == 2 & e06 == 3) | (e01 == 2 & e06 == 4)
	replace lstatus = 2 if e01 == 2 & e02 == 2 & e03 == 2
	replace lstatus = 3 if e01 == 2 & e02 == 2 & e03 == 2 & inlist(e05,1,2,4,5,6,7,8,9)
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
	note lstatus: "PAK 2004" this round's labor status screening is weekly based. Take into account for comparability purposes.
*</_lstatus_>

** LABOR STATUS LAST YEAR
*<_lstatus_year_>
	gen byte lstatus_year=.
	replace lstatus_year=. if age<lb_mod_age & age!=.
	label var lstatus_year "Labor status during last year"
	la de lbllstatus_year 1 "Employed" 2 "Unemployed" 3 "Non-in-labor force"
	label values lstatus_year lbllstatus_year
*</_lstatus_year_>


** EMPLOYMENT STATUS
*<_empstat_>
	gen byte empstat=e07
	recode empstat (1=1) (2 3 4 5 8 = 4) (6=2)  (7=3)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed"
	label values empstat lblempstat
*</_empstat_>

** EMPLOYMENT STATUS LAST YEAR
*<_empstat_year_>
	gen byte empstat_year=.
	replace empstat_year=. if lstatus_year!=1
	label var empstat_year "Employment status during last year"
	la de lblempstat_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_year lblempstat_year
*</_empstat_year_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_njobs_>
	gen byte njobs=.
	label var njobs "Number of additional jobs"
*</_njobs_>


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=e08
	recode ocusec (1=1) (2 3 =2) (4=1) (5=.)
	replace  ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>

	gen byte nlfreason=.
	replace nlfreason=1 if e05==5
	replace nlfreason=2 if e05==6
	replace nlfreason=3 if e05==7
	replace nlfreason=4 if e05==1
	replace nlfreason=5 if inlist(e05,0,2,3,4,8,9)
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>


**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=e10
	label define lblindustry_orig 1 `"Agriculture, Forestry, Fishing"', modify
	label define lblindustry_orig 2 `"Mining & Quarrying"', modify
	label define lblindustry_orig 3 `"Manufacturing"', modify
	label define lblindustry_orig 4 `"Electricity"', modify
	label define lblindustry_orig 5 `"Construction"', modify
	label define lblindustry_orig 6 `"Wholesale & Retail Trade"', modify
	label define lblindustry_orig 7 `"Transport & Storage"', modify
	label define lblindustry_orig 8 `"Real Estate, Insurance"', modify
	label define lblindustry_orig 9 `"Social & Personal services"', modify
	label define lblindustry_orig 10 `"Others"', modify
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>

** INDUSTRY CLASSIFICATION
*<_industry_>
	gen byte industry=e10
	recode industry (9=10)
	label var industry "1 digit industry classification"

/*
Original data includes Public Administration in a bigger group called "Social & Personal services". It is coded as 10.
*/
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
	replace industry=. if lstatus!=1
*</_industry_>


**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=e09
	label define lbloccup_orig 1 `"Senior Officials & Managers"', modify
	label define lbloccup_orig 2 `"Professionals"', modify
	label define lbloccup_orig 3 `"Technicians & Associate Professional"', modify
	label define lbloccup_orig 4 `"Clerks"', modify
	label define lbloccup_orig 5 `"Service, Shop, Sale, Workers"', modify
	label define lbloccup_orig 6 `"Skilled agriculture, Fishery"', modify
	label define lbloccup_orig 7 `"Craft & Trade workers"', modify
	label define lbloccup_orig 8 `"Plant, Machinery operators"', modify
	label define lbloccup_orig 9 `"Elementry occupations"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>



** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=e09
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
	replace occup=. if lstatus!=1

*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=e13 if e13!=.
	replace wage=e16 if e16!=.
	replace wage=. if lstatus!=1
	label var wage "Last wage payment"
	notes wage: "PAK 2004" this variable is reported monthly and yearly

*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=2 if e13!=.
	replace unitwage=8 if e16!=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	notes unitwage: "PAK 2004" this variable is reported monthly and yearly
*</_wageunit_>

** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>


** EMPLOYMENT STATUS - SECOND JOB
*<_empstat_2_>
	gen byte empstat_2=.
	replace empstat_2=. if njobs==0 | njobs==.
	label var empstat_2 "Employment status - second job"
	la de lblempstat_2 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** EMPLOYMENT STATUS - SECOND JOB LAST YEAR
*<_empstat_2_year_>
	gen byte empstat_2_year=.
	replace empstat_2_year=. if njobs_year==0 | njobs_year==.
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2 lblempstat_2
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=.
	replace industry_2=. if njobs==0 | njobs==.
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=.
	replace industry_orig_2=. if njobs==0 | njobs==.
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=. if njobs==0 | njobs==.
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen double wage_2=.
	replace wage_2=. if njobs==0 | njobs==.
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen byte unitwage_2=.
	replace unitwage_2=. if njobs==0 | njobs==.
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>

** CONTRACT
*<_contract_>
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion
*</_union_>

foreach var in lstatus lstatus_year empstat empstat_year njobs njobs_year ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union{
replace `var'=. if age<lb_mod_age
}

/*****************************************************************************************************
*                                                                                                    *
                                   MIGRATION MODULE
*                                                                                                    *
*****************************************************************************************************/


**REGION OF BIRTH JURISDICTION
*<_rbirth_juris_>
	gen byte rbirth_juris=.
	label var rbirth_juris "Region of birth jurisdiction"
	la de lblrbirth_juris 1 "subnatid1" 2 "subnatid2" 3 "subnatid3" 4 "Other country"  9 "Other code"
	label values rbirth_juris lblrbirth_juris
*</_rbirth_juris_>

**REGION OF BIRTH
*<_rbirth_>
	gen byte rbirth=.
	label var rbirth "Region of Birth"
*</_rbirth_>

** REGION OF PREVIOUS RESIDENCE JURISDICTION
*<_rprevious_juris_>
	gen byte rprevious_juris=.
	label var rprevious_juris "Region of previous residence jurisdiction"
	la de lblrprevious_juris 1 "reg01" 2 "reg02" 3 "reg03" 4 "Other country"  9 "Other code"
	label values rprevious_juris lblrprevious_juris
*</_rprevious_juris_>

**REGION OF PREVIOUS RESIDENCE
*<_rprevious_>
	gen byte rprevious=.
	label var rprevious "Region of previous residence"
*</_rprevious_>

** YEAR OF MOST RECENT MOVE
*<_yrmove_>
	gen int yrmove=.
	label var yrmove "Year of most recent move"
*</_yrmove_>


/*****************************************************************************************************
*                                                                                                    *
                                            ASSETS 
*                                                                                                    *
*****************************************************************************************************/

** LAND PHONE
*<_landphone_>
	gen byte landphone=.
	*replace landphone=1 if g09==2 |  g09==4
	*replace landphone=0 if inlist(g09,1,3)
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	notes landphone: "PAK 2004" land and mobile phone connection is taken.
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen byte cellphone=.
	replace cellphone=1 if g09==3 | g09==4
	replace cellphone=0 if inlist(g09,1,2)
	label var cellphone "Household has Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone
*</_cellphone_>


** COMPUTER
*<_computer_>
	gen byte computer=.
	label var computer "Household has computer"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer
*</_computer_>

** RADIO
*<_radio_>
	gen radio=.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television=f11g
	recode television (2=0)
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan=f11b
	recode fa (2=0)
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=f11c
	recode sewingmachine 2=0
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine=. 
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator=f11i
	recode refrigerator (2=0) 
	label var refrigerator "Household has Refrigerator"
	la de lblrefrigerator 0 "No" 1 "Yes"
	label val refrigerator lblrefrigerator
*</_refrigerator>

** LAMP
*<_lamp_>
	gen lamp=.
	label var lamp "Household has Lamp"
	la de lbllamp 0 "No" 1 "Yes"
	label val lamp lbllamp
*</_lamp>

** BYCICLE
*<_bycicle_>
	gen bicycle=f11m
	recode bicycle (2=0)
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle=f11n
	recode motorcycle (2=0)
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar=f11o
	recode motorcar (2=0)
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	label var cow "Household has Cow"
	la de lblcow 0 "No" 1 "Yes"
	label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	label var buffalo "Household has Buffalo"
	la de lblbuffalo 0 "No" 1 "Yes"
	label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	label var chicken "Household has Chicken"
	la de lblchicken 0 "No" 1 "Yes"
	label val chicken lblchicken
*</_chicken>


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
*<_spdef_>
	gen spdef=psupind
	la var spdef "Spatial deflator"
*</_spdef_>


** WELFARE
*<_welfare_>
	gen welfare=nomexpend/hsize
	la var welfare "Welfare aggregate"
*</_welfare_>

*<_welfarenom_>
	gen welfarenom=nomexpend/hsize
	la var welfarenom "Welfare aggregate in nominal terms"
*</_welfarenom_>

*<_welfaredef_>
	gen welfaredef=texpend/hsize
	la var welfaredef "Welfare aggregate spatially deflated"
*</_welfaredef_>

*<_welfshprosperity_>
	gen welfshprosperity=welfare
	la var welfshprosperity "Welfare aggregate for shared prosperity"
*</_welfshprosperity_>

*<_welfaretype_>
	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"
*</_welfaretype_>

*<_welfareother_>
	gen welfareother=peaexpM
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"
*</_welfareother_>

*<_welfareothertype_>
	gen welfareothertype="CON"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"
*</_welfareothertype_>

*<_welfarenat_>
	gen welfarenat=peaexpM
	la var welfarenat "Welfare aggregate for national poverty"
*</_welfarenat_>

*QUINTILE, DECILE AND FOOD/NON-FOOD SHARES OF CONSUMPTION AGGREGATE
	levelsof year, loc(y)
	merge m:1 idh using "$shares\\PAK_fnf_`y'", keepusing (food_share nfood_share quintile_cons_aggregate decile_cons_aggregate) gen(_merge2)
	drop _merge2

/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/

	
**ADULT EQUIVALENCY
	gen eqadult=eqadultM
	label var eqadult "Adult Equivalent (Household)"


** POVERTY LINE (NATIONAL)
*<_pline_nat_>
	gen pline_nat=new_pline
	label variable pline_nat "Poverty Line (National)"
*</_pline_nat_>


** HEADCOUNT RATIO (NATIONAL)
*<_poor_nat_>
	gen poor_nat=welfarenat<pline_nat if welfarenat!=. & pline_nat!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
	la values poor_nat poor_nat
*</_poor_nat_>


/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
*<_cpi_>
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "$pricedata", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year'_w cpi
	label variable cpi "CPI (Base `year'=1)"
*</_cpi_>
	
	
** PPP VARIABLE
*<_ppp_>
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"
*</_ppp_>

	
** CPI PERIOD
*<_cpiperiod_>
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
*</_cpiperiod_>	
	
** POVERTY LINE (POVCALNET)
*<_pline_int_>
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
*</_pline_int_>
	
	
** HEADCOUNT RATIO (POVCALNET)
*<_poor_int_>
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int
*</_poor_int_>


/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/
** KEEP VARIABLES - ALL
	do "$fixlabels\fixlabels", nostop

	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water  electricity toilet_orig sewage_toilet toilet_jmp sar_improved_toilet  landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
		water_original water_source improved_water pipedwater_acc watertype_quest sanitation_original sanitation_source improved_sanitation toilet_acc ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef eqadult ///
		 welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet  sanitation_original sanitation_source improved_sanitation toilet_acc ///
		landphone cellphone computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec union rbirth_juris rbirth rprevious_juris rprevious yrmove ///
		 landphone cellphone computer radio television fan sewingmachine washingmachine refrigerator lamp bicycle motorcycle motorcar cow buffalo chicken  ///
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef eqadult ///
		 welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  

	compress
	
** DELETE MISSING VARIABLES

	glo keep=""
	qui levelsof countrycode, local(cty)
	foreach var of varlist countrycode - welfareothertype {
		capture assert mi(`var')
		if !_rc {
		
			 display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
			 
		}
		else {
		
			 glo keep = "$keep"+" "+"`var'"
			 
		}
	}
	
	foreach w in welfare welfareother {
	
		qui su `w'
		if r(N)==0 {
		
			drop `w'type
			
		}
	}
	
	keep countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt ${keep} *type
	compress

	saveold "`output'\Data\Harmonized\PAK_2004_PSLM_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2004_PSLM_v01_M_v05_A_SARMD-FULL_IND.dta", replace version(13)
	log close
	

*********************************************************************************************************************************	
******RENAME COMPARABLE VARIABLES AND SAVE THEM IN _SARMD. UNCOMPARABLE VARIALBES ACROSS TIME SHOULD BE FOUND IN _SARMD-FULL*****
*********************************************************************************************************************************
loc var lb_mod_age lstatus lstatus_year empstat empstat_year njobs njobs_year ///
	     ocusec nlfreason unempldur_l unempldur_u industry_orig industry occup_orig occup firmsize_l firmsize_u whours wage ///
		  unitwage empstat_2 empstat_2_year industry_2 industry_orig_2 occup_2 wage_2 unitwage_2 contract healthins socialsec piped_water water_jmp sar_improved_water 
		  

foreach i of loc var{

cap sum `i'

	if _rc==0{
	loc a: var label `i'
	la var `i' "`a'-old non-comparable version"
	cap rename `i' `i'_v2
	}
	else if _rc==111{
	dis as error "Variable `i' does not exist in data-base"
	}
	
}

	note _dta: "PAK 2004" Variables NAMED with "v2" are those not compatible with latest round (2013). ///
 These include the existing information from the particular survey, but the iformation should be used for comparability purposes  
	saveold "`output'\Data\Harmonized\PAK_2004_PSLM_v01_M_v05_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2004_PSLM_v01_M_v05_A_SARMD_IND.dta", replace version(13)




******************************  END OF DO-FILE  *****************************************************/
