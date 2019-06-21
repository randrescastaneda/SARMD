/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                                   SOUTH ASIA MICRO DATABASE                                      **
**                                                                                                  **
** COUNTRY			Pakistan
** COUNTRY ISO CODE	PAK
** YEAR				2005
** SURVEY NAME		Pakistan 
** SURVEY AGENCY	PAKISTAN SOCIAL AND LIVING STANDARDS  MEASUREMENT SURVEY (ROUND-3)
** SURVEY SOURCE	Government of Pakistan Statistics divisionFederal Statistics Bureau
** RESPONSIBLE		Julian Eduardo Diaz Gutierrez
** Modified by		Fernando Enrique Morales Velandia
** Date:			02/23/2018
**                                                                                                  **
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2005_PSLM\PAK_2005_PSLM_v02_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\PAK\PAK_2005_PSLM\PAK_2005_PSLM_v02_M_v02_A_SARMD"
	glo pricedata "D:\SOUTH ASIA MICRO DATABASE\CPI\cpi_ppp_sarmd_weighted.dta"
	glo shares "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Food and non-food shares\PAK"
	glo fixlabels "D:\SOUTH ASIA MICRO DATABASE\APPS\DATA CHECK\Label fixing"

** LOG FILE
	log using "`output'\Doc\Technical\PAK_2005_PSLM.log",replace

** DATABASE ASSEMBLENT
	tempfile aux
	use "`input'\Data\Stata\roster with weights", clear
	duplicates report hhcode idc
	/*No duplicates in ID of HH and individual*/
	save `aux'
	
	
**Add employment and income

	use "`input'\Data\Stata\sec 1b", clear
	duplicates report hhcode idc
	isid hhcode idc
	merge m:1 hhcode idc using `aux'
	drop if _merge==1
	tab _merge
	drop _merge
	save `aux', replace
	
**Add literacy and formal education
	use "`input'\Data\Stata\sec 2a", clear
	duplicates tag hhcode province region psu idc, gen(tag)
	drop if tag!=0 & s2bq19c==.
	merge 1:m hhcode idc using `aux'
	drop if _merge==1
	tab _merge
	drop _merge
	save `aux', replace


**Add housing
	use "`input'\Data\Stata\sec 5", clear
	merge 1:m hhcode using `aux'
	ta _merge
	drop _merge
	save `aux', replace

**Add consumption
	use "`input'\Data\Stata\Consumption Master File with CPI.dta"
	ren year yearn
	keep if yearn==2005
	drop intmonth intyear
	merge 1:m hhcode using `aux'
	drop _merge
	save `aux', replace
	
**Add durables
	use "`input'\Data\Stata\sec7m.dta",clear
	keep hhcode itc s7mq02
	ren itc serialno
	
		#delimit;
	lab def code
	 700 "total"
	 701 "Refrigerator"
	 702 "Freezer"
	 703 "Air conditioner"
	 704 `"Air cooler"'
	 705 "Fan (Ceiling, Table, Pedestal, Exhaust)"
	 706 "Geyser (Gas, Electric)"
	 707 "Washing machine/dryer"
	 708 "Camera  (Still)"
	 709 "Camera (Movie )"
	 710  "Cooking stove"
	 711 "Cooking Range, Microwave oven"
	 712 "Heater"
	 713 "Bicycle"
	 714  "Car / Vehicle"
	 715  "Motorcycle/scooter"
	 716  "tv"
	 717  "VCR, VCP, Receiver, De-coder"
	 718  "Radio / cassette player"
	 719  "Compact disk player"
	 720  "Vacuum cleaner"
	 721  "Sewing/Knitting Machine"
	 722  "Personal Computer"
	 723  "Other";
	 #delimit cr
	
	label values serialno .
	label values serialno code
	decode serialno, gen(itc)
	replace itc=strtoname(itc)
	replace itc=substr(itc, 1,15)
	egen itc2= concat(itc serialno)
	keep hhcode s7mq02 itc2
	ren s7mq02 numdur
	reshape wide numdur, i(hhcode) j(itc2) strin
	tempfile durables
	save `durables'

/***Add livestock assets
	
	use "`input'\Data\Stata\sec 10b",clear
	#delimit;
	la def cattle
	151 "Cattle"
	152 "Buffalo"
	159 "Poultry";
	#delimit cr
	la val code .
	la values codes cattle
	ren codes serialno
	decode serialno, gen(itc)
	egen itc2=concat(itc serialno )
	ren s10ba numlivestock 
	duplicates drop hhcode itc2, force
	keep hhcode itc2 numlivestock
	reshape wide numlivestock, i( hhcode ) j( itc2 ) strin
	tempfile agric
	save `agric'*/

use "`input'\Data\Stata\interview_month", clear
ren year year1
tempfile inter
save `inter'
	
	
*Add landholding information

	use "`input'\Data\Stata\sec 9a", clear
	keep hhcode code s9aq01
	reshape wide s9aq01, i( hhcode ) j( code )
	tempfile landholding
	save `landholding'
	
	use `aux', clear
	foreach s in landholding durables inter{
	merge m:1 hhcode using ``s''
	drop if _merge==2
	drop _merge
	}

	
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
	gen int year=2005
	label var year "Year of survey"
*</_year_>

** SURVEY NAME 
*<_survey_>
	gen str survey="PSLM"
	label var survey "Survey Acronym"
*</_survey_>


** INTERVIEW YEAR
	gen int_year=year1
	label var int_year "Year of the interview"
	notes int_year: "PAK 2005" unlike previous data version, this variable has no problem in range (<05 | >06)
	notes int_year: "PAK 2005" information comes from consumption data
*</_int_year_>

	
** INTERVIEW MONTH
	gen int_month=month
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"
	notes int_month: "PAK 2005" information comes from consumption data
*</_int_month_>

**FIELD WORKD***
*<_fieldwork_> 
gen fieldwork=ym(int_year, int_month)
format %tm fieldwork
la var fieldwork "Date of fieldwork"
*<_/fieldwork_> 

	
	
** HOUSEHOLD IDENTIFICATION NUMBER
*<_idh_>
	gen double idh=hhcode
	label var idh "Household id"
*</_idh_>


** INDIVIDUAL IDENTIFICATION NUMBER
*<_idp_>

	gen double idp_=idh*100+idc
	tostring idh, replace
	gen idp=string(idp_,"%14.0g")
	tostring idh, replace
	label var idp "Individual id"
*</_idp_>


** HOUSEHOLD WEIGHTS
*<_wgt_>
	gen double wgt=weight
	label var wgt "Household sampling weight"
*</_wgt_>


** STRATA
*<_strata_>
	gen strata=.
	label var strata "Strata"
	notes strata: "PAK 2005" Variable is available but there is no clear info about what variable should be used.
*</_strata_>


** PSU
*<_psu_>
	label var psu "Primary sampling units"
	destring psu, replace
*</_psu_>


** MASTER VERSION
*<_vermast_>
	gen vermast="02"
	label var vermast "Master Version"
*</_vermast_>
	
	
** ALTERATION VERSION
*<_veralt_>

	gen veralt="02"
	label var veralt "Alteration Version"
*</_veralt_>	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)
*<_urban_>
/*
Checked replicating data 
*/
	gen byte urban=region
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban
*</_urban_>


** REGIONAL AREA 2 DIGIT ADMN LEVEL
*<_subnatid2_>
	gen byte subnatid2=.
	label var subnatid2 "Region at 2 digit (ADMN2)"

/*
*The universe of this survey consists of all urban and rural areas of the four
provinces and Islamabad excluding military restricted areas.
*/

** REGIONAL AREA 1 DIGIT ADMN LEVEL
*<_subnatid1_>
	gen byte subnatid1=province
	la de lblsubnatid1 1 "Punjab" 2 "Sindh" 3 "Khyber Pakhtunkhwa" 4 "Balochistan"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1
*</_subnatid2_>

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
*<_subnatid3_>
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
*</_subnatid3_>


** HOUSE OWNERSHIP
*<_ownhouse_>
	gen byte ownhouse=1 if s5q02==1 | s5q02==2
	replace ownhouse = 0 if s5q02!=. & ownhouse==.
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse
*</_ownhouse_>


** TENURE OF DWELLING
*<_tenure_>
   gen tenure=.
   replace tenure=1 if s5q02==1 | s5q02==2
   replace tenure=2 if s5q02==3
   replace tenure=3 if s5q02==4 | s5q02==5 
   label var tenure "Tenure of Dwelling"
   la de lbltenure 1 "Owner" 2"Renter" 3"Other"
   la val tenure lbltenure
*</_tenure_>	


** LANDHOLDING
*<_lanholding_>
   gen landholding=inlist(1, s9aq01901, s9aq01902, s9aq01903, s9aq01904) if !mi(s9aq01901, s9aq01902, s9aq01903, s9aq01904)
   la def a 1 ".a", replace
   label var landholding "Household owns any land"
   	la de lbllandholding 0 "No" 1 "Yes"
   la val landholding lbllandholding

*</_landholding_>	


*ORIGINAL WATER CATEGORIES
*<_water_orig_>
gen water_orig=s5q05
la var water_orig "Source of Drinking Water-Original from raw file"
#delimit
la def lblwater_orig 1 "Piped water"   
					 2 "Hand pump" 
					 3  "Motorized pumping / Tube well" 
					 4	"Open well"  
					 5	"Closed well"  
					 6	"Pond"  
					 7	"Canal / River / Stream"  
					 8	"Spring"  
					 9	"Other";
#delimit cr
la val water_orig lblwater_orig
*</_water_orig_>

*PIPED SOURCE OF WATER
*<_piped_water_>
gen piped_water=.
replace piped_water=1 if s5q05==1
replace piped_water=0 if inlist(s5q05,2,3,4,5,6,7,8,9)
la var piped_water "Household has access to piped water"
la def lblpiped_water 1 "Yes" 0 "No"
la val piped_water lblpiped_water
*</_piped_water_>

**INTERNATIONAL WATER COMPARISON (Joint Monitoring Program)
*<_water_jmp_>
gen water_jmp=.
replace water_jmp=1 if inlist(s5q05,1)
replace water_jmp=4 if inlist(s5q05,2,3)
replace water_jmp=6 if inlist(s5q05,4)
replace water_jmp=5 if inlist(s5q05,5)
replace water_jmp=12 if inlist(s5q05,6,7)
replace water_jmp=14 if inlist(s5q05,8,9)
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
note water_jmp: "PAK 2005" Category 'Spring' from raw data is coded as OTHER, given that it is an ambigous category to 'protected spring' 'unprotected spring'
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
clonevar j=s5q05
#delimit
la def lblwater_original 	1 "Piped water"   
							2 "Hand pump" 
							3 "Motorized pumping / Tube well" 
							4 "Open well"  
							5 "Closed well"  
							6 "Pond"  
							7 "Canal / River / Stream"  
							8 "Spring"  
							9 "Other";
#delimit cr
la val j lblwater_original		
decode j, gen(water_original)
drop j
la var water_original "Source of Drinking Water-Original from raw file"
*</_water_original_>


	** WATER SOURCE
	*<_water_source_>
		gen water_source=.
		replace water_source=1 if s5q05==1
		replace water_source=4 if s5q05==2
		replace water_source=4 if s5q05==3
		replace water_source=10 if s5q05==4
		replace water_source=5 if s5q05==5
		replace water_source=13 if s5q05==6
		replace water_source=13 if s5q05==7
		replace water_source=14 if s5q05==8
		replace water_source=14 if s5q05==9
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
		gen pipedwater_acc=0 if inrange(s5q05,2,11) // Asuming other is not piped water
		replace pipedwater_acc=3 if inlist(s5q05,1)
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

	*gen byte electricity=0 if s5q4a==3 
	*replace electricity=1 if s5q4a==1 | s5q4a==2 
	recode s5q4c (1 2=1) (3=0), gen (electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity
	notes electricity: "PAK 2005" this variable is generated if hh has electrical connection and extension.
	notes electricity: "PAK 2005" variable is labeled and named wrong in raw-files. We use s5q4c where it should have been s5q4a
*</_electricity_>


*ORIGINAL TOILET CATEGORIES
*<_toilet_orig_>
gen toilet_orig=s5q14
la var toilet_orig "Access to sanitation facility-Original from raw file"
#delimit
la def lbltoilet_orig 1 "Flush connected to public sewerage" 
					  2	 "Flush connected to pit" 
					  3	 "Flush conn. to open drain"  
					  4	 "Dry raised latrine"   
					  5  "Dry pit latrine" 
					  6	 "No toilet in the household";
#delimit cr
la val toilet_orig lbltoilet_orig
*</_toilet_orig_>


*SEWAGE TOILET
*<_sewage_toilet_>
gen sewage_toilet=s5q14
recode sewage_toilet (1=1)(2=0)(3=0)(4=0)(5=0)(6=0)
la var sewage_toilet "Household has access to sewage toilet"
la def lblsewage_toilet 1 "Yes" 0 "No"
la val sewage_toilet lblsewage_toilet
*</_sewage_toilet_>



**INTERNATIONAL SANITATION COMPARISON (Joint Monitoring Program)
*<_toilet_jmp_>
gen toilet_jmp=.
replace toilet_jmp=1 if toilet_orig==1
replace toilet_jmp=3 if toilet_orig==2
replace toilet_jmp=4 if toilet_orig==3
replace toilet_jmp=12 if toilet_orig==6
replace toilet_jmp=13 if inlist(toilet_orig,4,5)
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
		clonevar j=s5q14
		#delimit
		la def lblsanitation_original   1 "Flush connected to public sewerage"
										2 "Flush connected to pit"
										3 "Flush connected to open drain"
										4 "Dry raised latrine"
										5 "Dry pit latrine"
										6 "No toilet in the household" ;
		#delimit cr
		la val j lblsanitation_original
		decode j, gen(sanitation_original)
		drop j
		la var sanitation_original "Access to sanitation facility-Original from raw file"
	*</_sanitation_original_>


	** SANITATION SOURCE
	*<_sanitation_source_>
		gen sanitation_source=.
		replace sanitation_source=2 if s5q14==1
		replace sanitation_source=4 if s5q14==2
		replace sanitation_source=9 if s5q14==3
		replace sanitation_source=6 if s5q14==4
		replace sanitation_source=4 if s5q14==5
		replace sanitation_source=13 if s5q14==6
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
	g aux=1
	egen hsize2=sum(aux) if hsize==., by(idh)
	sort idh idp
	replace hsize=hsize2 if hsize==. 
*</_hsize_>


**POPULATION WEIGHT
*<_pop_wgt_>
	gen pop_wgt=wgt*hsize
	la var pop_wgt "Population weight"
*</_pop_wgt_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationharm_>

	gen byte relationharm=s1aq02
	recode relationharm (4 6 7 8 9 10=5) (5=4) (11 12 = 6)
	gen x=1 if relationharm==1
/*Fix those with no value for hh relation*/
	egen y=sum(x), by(idh)
	bys idh: egen max_age=max(age)
	replace s1aq02=1 		if y==0 & age==max_age
	replace relationharm=1 	if y==0 & age==max_age
	drop max_age
	replace s1aq02=2 		if y==2 & s1aq03==2
	replace relationharm=2 	if y==2 & s1aq03==2
	*drop if y!=1
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm
*</_relationharm_>


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
*<_relationcs_>

	gen byte relationcs=s1aq02
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Head" 2 "Spouse" 3 "Son/Daughter" 4 "Grandchild" 5 "Father/Mother" 6 "Brother/Sister" 7  "Nephew/Niece" 8 "Son/Daughter-in-law" 9 "Brother/Sister-in-law" 10 "Father/Mother-in-law" 11 "Servant/their relatives" 12 "Other"
	label values relationcs lblrelationcs
*</_relationcs_>


** GENDER
*<_male_>
	gen byte male=s1aq03
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale
*</_male_>


** AGE
*<_age_>
	label var age "Age of individual"
	replace age=98 if age>=98 & age!=.
*</_age_>


** SOCIAL GROUP
*<_soc_>
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 "Muslim" 2 "Christian" 3 "Others"
	label values soc lblsoc
*</_soc_>


** MARITAL STATUS
*<_marital_>
	gen byte marital=1 if s1aq06==2 | s1aq06==5
	replace marital=4 if s1aq06==4
	replace marital=5 if s1aq06==3
	replace marital=2 if s1aq06==1
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

/*
Literacy rate is asked only to individuals 10 years and older.
*/
	gen byte ed_mod_age=4
	label var ed_mod_age "Education module application age"
*</_ed_mod_age_>


** CURRENTLY AT SCHOOL
*<_atschool_>
	gen byte atschool=1 if s2bq01==3
	replace atschool=0 if s2bq01==1 | s2bq01==2
	replace atschool=. if age<ed_mod_age & age!=.
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool
*</_atschool_>


** CAN READ AND WRITE
*<_literacy_>
	gen byte literacy=1 if s2aq01==1 & s2aq02==1
	replace literacy=0 if s2aq01==2 | s2aq01==2
	replace literacy=. if age<ed_mod_age & age!=.
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy
	notes literacy: "PAK 2005" literacy questions are only asked to individuals 10 years or older
	replace literacy=. if age<10
*</_literacy_>

** YEARS OF EDUCATION COMPLETED
*<_educy_>

			/*
			===========================================
			code	level						years
			===========================================
			1		class 1						1
			2		class 2						2
			3		class 3						3
			4		class 4						4
			5		class 5						5
			6		class 6						6
			7		class 7						7
			8		class 8						8
			9		class 9						9
			10		class 10					10
			11		class 11					11
			12		class 12					12
			13		class 13					13
			17		diploma						13
			14		b.a/b.sc.					14
			15		class 15					15
			16		post graduate (m.a/m.sc.)	16
			18		degree in engineering		16
			20		degree in agriculture		16
			21		degree in law				16
			19		degree in medicine			17
			22		m. phil, ph.d				19
			23		other						NA
			=============================================
			*/	
	
	recode s2bq05 (17=13) (14=14) (18=16) (19=17) (20=16) (16=16) (21=16) (22=19) (23=.), gen(educy1)
	*Substract 1 year to those currently studying before highschool
	gen educy2=s2bq14
	replace educy2=s2bq14-1 if s2bq05==. & s2bq14<=12
	replace educy2=0 if educy2<0 
	*Substract 1 year to those currently attending after secondary
	recode educy2 (17=12) (14=13) (18=15) (19=16) (20=15) (16=15) (21=15) (22=18) (23=.) if  s2bq05==. & s2bq14!=.
	gen educy=.
	replace educy=educy1 if educy2==.
	replace educy=educy2 if educy1==.
	label var educy "Years of education"
	replace educy=. if educy>age+1 & educy<. & age!=.
	replace educy=. if age<ed_mod_age & age!=.
*</_educy_>


** EDUCATION LEVEL 7 CATEGORIES
*<_educat7_>
	gen byte educat7=1 if educy==0
	replace educat7=2 if educy >0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 &  educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy<=22
	replace educat7=8 if s2bq05==23 | s2bq14==23 
	replace educat7=. if age<ed_mod_age & age!=.
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
	gen byte everattend=1 if s2bq01==3 | s2bq01==2
	replace everattend=0 if s2bq01==1
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

/*
Question is asked in a monthly basis.
*/
	gen lstatus=.
	replace lstatus=1 if s1bq01==1
	replace lstatus=1 if s1bq03==1
	replace lstatus=2 if s1bq01==2 & s1bq03==2
	replace lstatus=3 if s1bq01==2 & s1bq03==3
	replace lstatus=. if age<lb_mod_age & age!=.
	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus
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
	gen byte empstat=1 if s1bq06==4 
	replace empstat=2 if s1bq06==5 
	replace empstat=3 if s1bq06==1 | s1bq06==2 
	replace empstat=4 if s1bq06==3 | s1bq06>=6 & s1bq06<=9 
	replace empstat=. if lstatus!=1 
	label var empstat "Employment status" 
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classificable by status" // 4
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


** NUMBER OF ADDITIONAL JOBS
*<_njobs_>
	gen byte  njobs=.
	replace njobs=. if lstatus!=1
	label var njobs "Number of additional jobs"
*</_njobs_>


** NUMBER OF ADDITIONAL JOBS LAST YEAR
*<_njobs_year_>
	gen byte njobs_year=.
	replace njobs_year=. if lstatus_year!=1
	label var njobs_year "Number of additional jobs during last year"
*</_njobs_year_>



** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
*<_ocusec_>
	gen byte ocusec=.
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army, NGO" 2 "Private"
	label values ocusec lblocusec
*</_ocusec_>


** REASONS NOT IN THE LABOR FORCE
*<_nlfreason_>
	gen byte nlfreason=.
	replace nlfreason=. if lstatus!=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
*</_nlfreason_>

** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
*<_unempldur_l_>
	gen byte unempldur_l=.
	replace unempldur_l=. if lstatus!=2
	label var unempldur_l "Unemployment duration (months) lower bracket"
*</_unempldur_l_>

*<_unempldur_u_>

	gen byte unempldur_u=.
	replace unempldur_u=. if lstatus!=2
	label var unempldur_u "Unemployment duration (months) upper bracket"
*</_unempldur_u_>



**ORIGINAL INDUSTRY CLASSIFICATION
*<_industry_orig_>
	gen industry_orig=s1bq05
	label define lblindustry_orig 0 `"activities not adequately defined"', modify
	label define lblindustry_orig 11 `"agriculture, livestock and hunting"', modify
	label define lblindustry_orig 12 `"forestry and logging"', modify
	label define lblindustry_orig 13 `"fishing"', modify
	label define lblindustry_orig 21 `"coal mining"', modify
	label define lblindustry_orig 22 `"crude petroleum and natural gas"', modify
	label define lblindustry_orig 23 `"crude metal or mining"', modify
	label define lblindustry_orig 29 `"other mining"', modify
	label define lblindustry_orig 31 `"manufacture of food, beverages"', modify
	label define lblindustry_orig 32 `"manufacture of textile,"', modify
	label define lblindustry_orig 33 `"manufacture of wood products, including furniture"', modify
	label define lblindustry_orig 34 `"manufacture of paper"', modify
	label define lblindustry_orig 35 `"manufacture of chemicals"', modify
	label define lblindustry_orig 36 `"manufacture of non-metallic mineral"', modify
	label define lblindustry_orig 37 `"basic metal industries"', modify
	label define lblindustry_orig 38 `"manufacture of fabricated metal"', modify
	label define lblindustry_orig 39 `"other manufacturing industries"', modify
	label define lblindustry_orig 41 `"electricity, gas and steam"', modify
	label define lblindustry_orig 42 `"water work and supplies"', modify
	label define lblindustry_orig 51 `"building construction"', modify
	label define lblindustry_orig 52 `"construction,repair,maintenance of streets"', modify
	label define lblindustry_orig 53 `"construction,repair,maintenance of irrigation"', modify
	label define lblindustry_orig 54 `"construction,repair,maintenance of docks"', modify
	label define lblindustry_orig 55 `"construction, repair, maintenance of sports"', modify
	label define lblindustry_orig 56 `"construction, repair, maintenance of sewerage"', modify
	label define lblindustry_orig 57 `"construction, repair, maintenance of pipe line"', modify
	label define lblindustry_orig 59 `"construction project n.e.c"', modify
	label define lblindustry_orig 61 `"wholesale trade"', modify
	label define lblindustry_orig 62 `"retail trade"', modify
	label define lblindustry_orig 63 `"restaurants and hotels"', modify
	label define lblindustry_orig 71 `"transport and storage"', modify
	label define lblindustry_orig 72 `"communication"', modify
	label define lblindustry_orig 81 `"financial institutions"', modify
	label define lblindustry_orig 82 `"insurance"', modify
	label define lblindustry_orig 83 `"real estate and business"', modify
	label define lblindustry_orig 91 `"public administration and defense services"', modify
	label define lblindustry_orig 92 `"sanitary and similar services"', modify
	label define lblindustry_orig 93 `"social and related community services"', modify
	label define lblindustry_orig 94 `"recreational and cultural services"', modify
	label define lblindustry_orig 95 `"personal and household services"', modify
	label define lblindustry_orig 96 `"international and other"', modify
	la val industry_orig lblindustry_orig
	replace industry_orig=. if lstatus!=1
	la var industry_orig "Original industry code"
*</_industry_orig_>


** INDUSTRY CLASSIFICATION
*<_industry_> 
	gen byte industry=.
	replace industry=1 if s1bq05>=11 & s1bq05<=13
	replace industry=2 if s1bq05>=21 & s1bq05<=29
	replace industry=3 if s1bq05>=31 & s1bq05<=39
	replace industry=4 if s1bq05>=41 & s1bq05<=42
	replace industry=5 if s1bq05>=51 & s1bq05<=59
	replace industry=6 if s1bq05>=61 & s1bq05<=63
	replace industry=7 if s1bq05>=71 & s1bq05<=72
	replace industry=8 if s1bq05>=81 & s1bq05<=83
	replace industry=9 if s1bq05==91
	replace industry=10 if s1bq05>=92 & s1bq05<=96
	replace industry=10 if s1bq05==00

	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry
*</_industry_>


**ORIGINAL OCCUPATION CLASSIFICATION
*<_occup_orig_>
	gen occup_orig=s1bq04
	label define lbloccup_orig 1 `"armed forces"', modify
	label define lbloccup_orig 11 `"legislators and senior officials"', modify
	label define lbloccup_orig 12 `"cooperate managers"', modify
	label define lbloccup_orig 13 `"general managers"', modify
	label define lbloccup_orig 21 `"physical, mathematical"', modify
	label define lbloccup_orig 22 `"life science and health"', modify
	label define lbloccup_orig 23 `"teaching professionals"', modify
	label define lbloccup_orig 24 `"other professionals"', modify
	label define lbloccup_orig 31 `"physical and engineering science"', modify
	label define lbloccup_orig 32 `"life science and health associate"', modify
	label define lbloccup_orig 33 `"teaching associate professionals"', modify
	label define lbloccup_orig 34 `"other associate professionals"', modify
	label define lbloccup_orig 41 `"office clerks"', modify
	label define lbloccup_orig 42 `"customer services clerks"', modify
	label define lbloccup_orig 51 `"personal and protective"', modify
	label define lbloccup_orig 52 `"models, salespersons"', modify
	label define lbloccup_orig 61 `"market-oriented skilled agricultural"', modify
	label define lbloccup_orig 62 `"subsistence agricultural"', modify
	label define lbloccup_orig 71 `"extraction and building"', modify
	label define lbloccup_orig 72 `"Metal, Machinery And Related Trades Workers ( Metal Moulders, Welders, Sheet-Metal Workers,Structural-Metal, etc)"', modify 
	label define lbloccup_orig 73 `"precision, handicraft, printing"', modify
	label define lbloccup_orig 74 `"other craft and related trades workers"', modify
	label define lbloccup_orig 81 `"stationary-plant and related operators"', modify
	label define lbloccup_orig 82 `"machine operators and assemblers"', modify
	label define lbloccup_orig 83 `"drivers and mobile-plant operators"', modify
	label define lbloccup_orig 91 `"sales and services elementary"', modify
	label define lbloccup_orig 92 `"agricultural, fishery and related labourers"', modify
	label define lbloccup_orig 93 `"labourers in mining, construction,"', modify
	la val occup_orig lbloccup_orig
	replace occup_orig=. if lstatus!=1
	la var occup_orig "Original occupation code"
*</_occup_orig_>

** OCCUPATION CLASSIFICATION
*<_occup_>
	gen byte occup=.
	replace occup=10 if s1bq04==0
	replace occup=1 if s1bq04>=11 & s1bq04<=13
	replace occup=2 if s1bq04>=21 & s1bq04<=24
	replace occup=3 if s1bq04>=31 & s1bq04<=34
	replace occup=4 if s1bq04>=41 & s1bq04<=42
	replace occup=5 if s1bq04>=51 & s1bq04<=52
	replace occup=6 if s1bq04>=61 & s1bq04<=62
	replace occup=7 if s1bq04>=71 & s1bq04<=74
	replace occup=8 if s1bq04>=81 & s1bq04<=83
	replace occup=9 if s1bq04>=91 & s1bq04<=93
	replace occup=. if lstatus!=1
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup
*</_occup_>


** FIRM SIZE
*<_firmsize_l_>
	gen byte firmsize_l=.
	replace firmsize_l=. if lstatus!=1
	label var firmsize_l "Firm size (lower bracket)"
*</_firmsize_l_>

*<_firmsize_u_>

	gen byte firmsize_u=.
	replace firmsize_u=. if lstatus!=1
	label var firmsize_u "Firm size (upper bracket)"

*</_firmsize_u_>


** HOURS WORKED LAST WEEK
*<_whours_>
	gen whours=.
	replace whours=. if lstatus!=1
	label var whours "Hours of work in last week"
*</_whours_>


** WAGES
*<_wage_>
	gen double wage=.
	replace wage=s1bq08 if s1bq08!=.
	replace wage=s1bq10 if s1bq10!=.
	replace wage=. if lstatus!=1
	replace wage=0 if wage>0 & empstat==2 & wage!=.
	label var wage "Last wage payment"
	notes wage: "PAK 2005" this variable is reported monthly and yearly
*</_wage_>


** WAGES TIME UNIT
*<_unitwage_>
	gen byte unitwage=.
	replace unitwage=5 if s1bq08!=.
	replace unitwage=8 if s1bq10!=.
	replace unitwage=. if lstatus!=1
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage
	notes unitwage: "PAK 2005" this variable is reported monthly and yearly
*</_wageunit_>

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
	gen byte empstat_2_year=1 if s1bq14==4 
	replace empstat_2_year=2 if s1bq14==5 
	replace empstat_2_year=3 if s1bq14==1 | s1bq14==2 
	replace empstat_2_year=4 if s1bq14==3 | s1bq14>=6 & s1bq14<=9 
	replace empstat_2_year=. if s1bq11!=1
	label var empstat_2_year "Employment status - second job"
	la de lblempstat_2_year 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other, workers not classifiable by status"
	label values empstat_2_year lblempstat_2_year
*</_empstat_2_>

** INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_2_>
	gen byte industry_2=.
	replace industry_2=1 if s1bq13>=11 & s1bq13<=13
	replace industry_2=2 if s1bq13>=21 & s1bq13<=29
	replace industry_2=3 if s1bq13>=31 & s1bq13<=39
	replace industry_2=4 if s1bq13>=41 & s1bq13<=42
	replace industry_2=5 if s1bq13>=51 & s1bq13<=59
	replace industry_2=6 if s1bq13>=61 & s1bq13<=63
	replace industry_2=7 if s1bq13>=71 & s1bq13<=72
	replace industry_2=8 if s1bq13>=81 & s1bq13<=83
	replace industry_2=9 if s1bq13==91
	replace industry_2=10 if s1bq13>=92 & s1bq13<=96
	replace industry_2=10 if s1bq13==00
	replace industry_2=. if s1bq11!=1
	label var industry_2 "1 digit industry classification - second job"
	la de lblindustry_2 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry_2 lblindustry_2
*<_industry_2_>


**SURVEY SPECIFIC INDUSTRY CLASSIFICATION - SECOND JOB
*<_industry_orig_2_>
	gen industry_orig_2=s1bq13
	replace industry_orig_2=. if s1bq11!=1
	label var industry_orig_2 "Original Industry Codes - Second job"
	la de lblindustry_orig_2 1""
	label values industry_orig_2 lblindustry_orig_2
*</_industry_orig_2>


** OCCUPATION CLASSIFICATION - SECOND JOB
*<_occup_2_>
	gen byte occup_2=.
	replace occup_2=10 if s1bq12==0
	replace occup_2=1 if s1bq12>=11 & s1bq12<=13
	replace occup_2=2 if s1bq12>=21 & s1bq12<=24
	replace occup_2=3 if s1bq12>=31 & s1bq12<=34
	replace occup_2=4 if s1bq12>=41 & s1bq12<=42
	replace occup_2=5 if s1bq12>=51 & s1bq12<=52
	replace occup_2=6 if s1bq12>=61 & s1bq12<=62
	replace occup_2=7 if s1bq12>=71 & s1bq12<=74
	replace occup_2=8 if s1bq12>=81 & s1bq12<=83
	replace occup_2=9 if s1bq12>=91 & s1bq12<=93
	replace occup_2=. if s1bq11!=1
	label var occup_2 "1 digit occupational classification - second job"
	la de lbloccup_2 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup_2 lbloccup_2
*</_occup_2_>


** WAGES - SECOND JOB
*<_wage_2_>
	gen  wage_2=s1bq15
	replace wage_2=. if s1bq11!=1
	label var wage_2 "Last wage payment - Second job"
*</_wage_2_>


** WAGES TIME UNIT - SECOND JOB
*<_unitwage_2_>
	gen  unitwage_2=8 if wage_2!=.
	replace unitwage_2=. if s1bq11!=1
	label var unitwage_2 "Last wages time unit - Second job"
	la de lblunitwage_2 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Every two months"  5 "Monthly" 6 "Quarterly" 7 "Every six months" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage_2 lblunitwage_2
*</_unitwage_2_>

** CONTRACT
*<_contract_>
	gen byte contract=.
	replace contract=. if lstatus!=1
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract
*</_contract_>


** HEALTH INSURANCE
*<_healthins_>
	gen byte healthins=.
	replace healthins=. if lstatus!=1
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins
*</_healthins_>


** SOCIAL SECURITY
*<_socialsec_>
	gen byte socialsec=.
	replace socialsec=. if lstatus!=1
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec
*</_socialsec_>


** UNION MEMBERSHIP
*<_union_>
	gen byte union=.
	replace union=. if lstatus!=1
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
notes _dta: "PAK 2005" information on assets comes from durables list, which states the number of items owned by hh at present
notes _dta: "PAK 2005" The relevant question from module 10B only provides information on exepected values from owned animals, not quantities. This would hinder comparability of measurement with other countries.  


** LAND PHONE
*<_landphone_>
	gen byte landphone=.
	*replace landphone=1 if s5q4c==1 | s5q4c==2
	*replace landphone=0 if s5q4c==3
	label var landphone "Household has landphone"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone
	notes landphone: "PAK 2005" variable is generated if hh has connection or extention of telephone.
*</_landphone_>


** CEL PHONE
*<_cellphone_>
	gen byte cellphone=.
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
	gen radio=numdurRadio___cassett718>0 & numdurRadio___cassett718<.
	label var radio "Household has radio"
	la de lblradio 0 "No" 1 "Yes"
	label val radio lblradio
*</_radio_>

** TELEVISION
*<_television_>
	gen television= numdurtv716>0 & numdurtv716<.
	label var television "Household has Television"
	la de lbltelevision 0 "No" 1 "Yes"
	label val television lbltelevision
*</_television>

** FAN
*<_fan_>
	gen fan= numdurFan__Ceiling__T705>0 & numdurFan__Ceiling__T705<.
	label var fan "Household has Fan"
	la de lblfan 0 "No" 1 "Yes"
	label val fan lblfan
*</_fan>

** SEWING MACHINE
*<_sewingmachine_>
	gen sewingmachine=numdurSewing_Knitting721>0 & numdurSewing_Knitting721<.
	label var sewingmachine "Household has Sewing machine"
	la de lblsewingmachine 0 "No" 1 "Yes"
	label val sewingmachine lblsewingmachine
*</_sewingmachine>

** WASHING MACHINE
*<_washingmachine_>
	gen washingmachine= numdurWashing_machine707>0 & numdurWashing_machine707<.
	label var washingmachine "Household has Washing machine"
	la de lblwashingmachine 0 "No" 1 "Yes"
	label val washingmachine lblwashingmachine
*</_washingmachine>

** REFRIGERATOR
*<_refrigerator_>
	gen refrigerator= numdurRefrigerator701>0 & numdurRefrigerator701<.
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
	gen bicycle= numdurBicycle713>0 & numdurBicycle713<.
	label var bicycle "Household has Bicycle"
	la de lblbycicle 0 "No" 1 "Yes"
	label val bicycle lblbycicle
*</_bycicle>

** MOTORCYCLE
*<_motorcycle_>
	gen motorcycle= numdurMotorcycle_scoo715>0 &  numdurMotorcycle_scoo715<.
	label var motorcycle "Household has Motorcycle"
	la de lblmotorcycle 0 "No" 1 "Yes"
	label val motorcycle lblmotorcycle
*</_motorcycle>

** MOTOR CAR
*<_motorcar_>
	gen motorcar= numdurCar___Vehicle714>0 & numdurCar___Vehicle714<.
	label var motorcar "Household has Motor car"
	la de lblmotorcar 0 "No" 1 "Yes"
	label val motorcar lblmotorcar
*</_motorcar>

** COW
*<_cow_>
	gen cow=.
	la val cow a
	label var cow "Household has Cow"
	*la de lblcow 0 "No" 1 "Yes"
	*label val cow lblcow
*</_cow>

** BUFFALO
*<_buffalo_>
	gen buffalo=.
	la val buffalo a
	label var buffalo "Household has Buffalo"
	*la de lblbuffalo 0 "No" 1 "Yes"
	*label val buffalo lblbuffalo
*</_buffalo>

** CHICKEN
*<_chicken_>
	gen chicken=.
	la val chicken a
	label var chicken "Household has Chicken"
	*la de lblchicken 0 "No" 1 "Yes"
	*label val chicken lblchicken
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
	sort idh idp relationharm
	*bys idh: egen hhsize=count(year)
	gen dif=hhsize-hsize if hsize!=.
	bys idh: gen n=_n
	replace pline_nat=. if dif!=. & n>hsize & n!=.
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
		 pline_nat pline_int poor_nat poor_int spdef cpi ppp cpiperiod welfare welfshprosperity welfarenom welfaredef ///
		 eqadult welfarenat food_share nfood_share quintile_cons_aggregate decile_cons_aggregate welfareother welfaretype welfareothertype  
		 
** ORDER VARIABLES

	order countrycode year survey idh idp wgt pop_wgt strata psu vermast veralt urban int_month int_year fieldwork  ///
		subnatid1 subnatid2 subnatid3 ownhouse landholding tenure water_orig piped_water water_jmp sar_improved_water ///
		water_original water_source improved_water pipedwater_acc watertype_quest electricity toilet_orig sewage_toilet ///
		toilet_jmp sar_improved_toilet sanitation_original sanitation_source improved_sanitation toilet_acc ///
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
	
	saveold "`output'\Data\Harmonized\PAK_2005_PSLM_v02_M_v02_A_SARMD_IND.dta", replace version(12)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\PAK_2005_PSLM_v02_M_v02_A_SARMD_IND.dta", replace version(13)


	log close

/* Household's not in consumption aggregate
. tab idh subnatid2 if welfare==.

 Household |          Region at 2 digit (ADMN2)
        id |    Punjab      Sindh  Khyber Pa  Balochist |     Total
-----------+--------------------------------------------+----------
1011010106 |         9          0          0          0 |         9 
1041010411 |         2          0          0          0 |         2 
1242030108 |         1          0          0          0 |         1 
1242030110 |         1          0          0          0 |         1 
2021030308 |         0         12          0          0 |        12 
2051210206 |         0          1          0          0 |         1 
2062010302 |         0          5          0          0 |         5 
2112030209 |         0          2          0          0 |         2 
3102040106 |         0          0          8          0 |         8 
3132040116 |         0          0         18          0 |        18 
4012040405 |         0          0          0         17 |        17 
4022030306 |         0          0          0          6 |         6 
4052020301 |         0          0          0         12 |        12 
4071330104 |         0          0          0          1 |         1 
-----------+--------------------------------------------+----------
     Total |        13         20         26         36 |        95 


There shouldn't be any from Punjab
*/


******************************  END OF DO-FILE  *****************************************************/


