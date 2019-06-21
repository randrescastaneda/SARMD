/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY	Afghanistan
** COUNTRY ISO CODE	AFG
** YEAR	2011
** SURVEY NAME	National Risk and Vulnerability Assessment 2007-2008
** SURVEY AGENCY	Central Statistics Organization
** SURVEY SOURCE	
** UNIT OF ANALYSIS	
** RESPONSIBLE	Triana Yentzen
** Created	05-04-2012
** Modified	16-04-2014
** NUMBER OF HOUSEHOLDS	20573
** NUMBER OF INDIVIDUALS	152265
** EXPANDED POPULATION	24926177
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
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2011_NRVA\AFG_2011_NRVA_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\AFG\AFG_2011_NRVA\AFG_2011_NRVA_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\AFG_2011_NRVA.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	
	* PREPARE DATASETS

	local filesh "F_22 F_23 M_1&2 M_04 M_05 M_06 M_07a M_07c M_09 M_10 M_11c M_13"
	local filesi "F_21 F_24 M_03 M_08 M_11a M_12"

	loca i=1
	foreach file in `filesh'{
	use "`input'\Data\Stata\\`file'", clear
	sort Household_Code
	tempfile h`i'
	qui compress
	save "`input'\Data\Other\h`i'", replace
	local i= `i'+1
	}

	loca i=1
	foreach file in `filesi'{
	use "`input'\Data\Stata\\`file'", clear
	sort Household_Code
	tempfile i`i'
	qui compress
	save "`input'\Data\Other\i`i'", replace
	local i= `i'+1
	}

	* MERGE DATASETS

	use "`input'\Data\Stata\Core individual.dta", clear
	merge m:1 Household_Code using "`input'\Data\Stata\Core Household.dta"
	qui drop if _merge==2

	drop _merge

	qui compress

	local i=1
	foreach file in `filesh'{
	merge m:1 Household_Code using "`input'\Data\Other\h`i'"
	qui drop if _merge==2
	drop _merge
	local i=`i'+1
	}

	local i=1
	foreach file in `filesi'{
	merge 1:1 Household_Code Unique_Mem_ID using "`input'\Data\Other\i`i'", force
	qui drop if _merge==2
	drop _merge
	local i=`i'+1
	}

	ren Household_Code hhid
	sort hhid
	merge m:1 hhid using "`input'\Data\Stata\poverty2011.dta" 

	drop Q_22* Q_23*
	drop Q_3_2
	qui compress

/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/
	
	
** COUNTRY
	gen str4 countrycode="AFG"
	label var countrycode "Country code"


** YEAR
	gen int year=2011
	label var year "Year of survey"

	
** INTERVIEW YEAR
	gen byte int_year=int_year_c
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte int_month=int_month_c
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"


** HOUSEHOLD IDENTIFICATION NUMBER
	gen str idh = hhid
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen idp= Unique_Mem_ID
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen double wgt=hh_weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=Province_Code
	replace strata=35 if Resident_Location_Code==3
	label var strata "Strata"


** PSU
	destring Con_Area_Enum_Code, gen(psu)
	label var psu "Primary sampling units"

** MASTER VERSION
	gen vermast="01"
	label var vermast "Master Version"
	
	
** ALTERATION VERSION
	gen veralt="01"
	label var veralt "Alteration Version"
	
	
/*****************************************************************************************************
*                                                                                                    *
                                   HOUSEHOLD CHARACTERISTICS MODULE
*                                                                                                    *
*****************************************************************************************************/


** LOCATION (URBAN/RURAL)

	* Kuchi replaced as missing
	recode Resident_Location_Code (2=0)(3=.), gen(urban)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


**REGIONAL AREAS

** REGIONAL AREA 2 DIGIT ADMN LEVEL
	recode Province_Code (17=14) (31=23) (9=16) (21=19) (10=32) (24=34) (33=25) (29=22) (11=6) (23=31) (30=27) (32=24) (28=20) (27=28) (14=9) (15=11) (19=17) (7=12) (6=10) (34=26) (16=13) (12=7) (13=8) (8=33) (20=18) (22=21) (18=15) (25=30) (26=29), gen(subnatid2)
	la de lblsubnatid2 1 "KABUL" 2 "KAPISA" 3 "PARWAN" 4 "WARDAK" 5 "LOGAR" 6 "GHAZNI" 7 "PAKTIKA" 8 "PAKTYA" 9 "KHOST" 10 "NANGARHAR" 11 "KUNARHA" 12 "LAGHMAN" 13 "NURISTAN" 14 "BADAKHSHAN" 15 "TAKHAR" 16 "BAGHLAN" 17 "KUNDUZ" 18 "SAMANGAN" 19 "BALKH" 20 "JAWZJAN" 21 "SAR-I-POUL" 22 "FARYAB" 23 "BADGHIS" 24 "HIRAT" 25 "FARAH" 26 "NIMROZ" 27 "HILMAND" 28 "KANDAHAR" 29 "ZABUL" 30 "URUZGAN" 31 "GHOR"32 "BAMYAN" 33 "PANJSHER" 34 "DAIKINDI"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	recode subnatid2 (1 2 3 4 5 33 = 1) (6/9=2) (10/13=3) (14/17=4) (18/22=5) (23/25=6) (26/30=7) (31 32 34=8), gen(subnatid1)
	la de lblsubnatid1 1 "Central" 2 "South" 3 "East" 4 "Northeast" 5 "North" 6 "West" 7 "Southwest" 8 "West-Central"
	label var subnatid1 "Region at 1 digit (ADMN1)"
	label values subnatid1 lblsubnatid1

	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	

** HOUSE OWNERSHIP
	gen byte ownhouse=.
	replace ownhouse=1 if inlist(Q_4_6,1,2,3,5,7)
	replace ownhouse=0 if inlist(Q_4_6,4,6,8,9)
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	recode Q_4_18 (8/9=1) (1/7=0) (10/14=0), gen(water)
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	recode Q_4_12_Electic_Grid (2=0), gen(electricity)
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	recode Q_4_16 (2/4=1) (1 5 6 7=0), gen(toilet)
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen byte landphone=.
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	recode Q_7_6_Mobile_Own (2/13=1), gen(cellphone)
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen byte computer=.
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


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
	rename hhsize hsize
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD
	gen byte relationharm=Q_3_3
	recode relationharm (6=4) (4 5 7 8 9 10=5) (11=6)
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=Q_3_3
	la var relationcs "Relationship to the head of household country/region specific"
	la define lblrelationcs 1 "Household head" 2 "Wife or husband" 3 "Son or daugher" 4 "Son/daughter-in-law" 5 "Grandchild" 6 "Father or mother" 7 "Nephew or niece" 8 "Brother or sister" 9 "Brother/sister-in-law" 10 "Other relative" 11 "Unrelated member"
	label values relationcs lblrelationcs

	
** GENDER
	gen byte male=Q_3_4
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen byte age=Q_3_5
	label var age "Individual age"


** SOCIAL GROUP
	gen byte soc=.
	label var soc "Social group"
	la de lblsoc 1 ""
	label values soc lblsoc


** MARITAL STATUS
	gen byte marital=Q_3_6
	recode marital (4 5=2) (2=4) (3= 5) 
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen byte ed_mod_age=6
	label var ed_mod_age "Education module application age"



** CURRENTLY AT SCHOOL
	gen byte atschool=Q_12_8
	recode atschool (2=0)
	replace atschool=0 if Q_12_5==2
	replace atschool = . if age < 6
	replace atschool = . if age > 18
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen byte literacy=Q_12_3
	recode literacy (2=0)
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen  educy = Q_12_7
	replace educy=3 if Q_12_6==8 | Q_12_6==10
	replace educy=13 if Q_12_6==9 & Q_12_7==0
	*** assign a zero to those who never attended school ***
	replace  educy = 0 if Q_12_5==2

	label var educy "Years of education"


** EDUCATION LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if Q_12_5==2
	replace educat7=2 if Q_12_6==1 & Q_12_7<6 &Q_12_7!=.
	replace educat7=3 if (Q_12_6==1 & Q_12_7==6 ) 
	replace educat7=4 if Q_12_6==2 | (Q_12_6==3 & Q_12_7<12 & Q_12_7!=.)
	replace educat7=5 if Q_12_6==3 & Q_12_7==12
	replace educat7=7 if Q_12_6>3 & Q_12_6!=.
	replace educat7=2 if Q_12_6==8 | Q_12_6==10
	replace educat7=6 if Q_12_6==4 | Q_12_6==7
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"

** EDUCATION LEVEL 5 CATEGORIES
	gen educat5=.
	replace educat5=1 if Q_12_5==2
	replace educat5=2 if Q_12_6==1 & Q_12_7<6 &Q_12_7!=.
	replace educat5=3 if (Q_12_6==1 & Q_12_7==6 ) | Q_12_6==2 | (Q_12_6==3 & Q_12_7<12 & Q_12_7!=.)
	replace educat5=4 if Q_12_6==3 & Q_12_7==3
	replace educat5=5 if Q_12_6>3 & Q_12_6!=.
	replace educat5=2 if Q_12_6==8 | Q_12_6==10
	label define lbleducat5 1 "No education" 2 "Primary incomplete" ///
	3 "Primary complete but secondary incomplete" 4 "Secondary complete" ///
	5 "Some tertiary/post-secondary"
	label values educat5 lbleducat5
	la var educat5 "Level of education 5 categories"


** EDUCATION LEVEL 4 CATEGORIES
	gen byte educat4=.
	replace educat4=1 if educat7==1
	replace educat4=2 if educat7>=2 & educat7<=3
	replace educat4=3 if educat7>=4 & educat7<=5
	replace educat4=4 if educat7>=6 & educat7<=7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4

** EVER ATTENDED SCHOOL
	gen byte everattend=Q_12_5
	replace everattend = 1 if atschool==1
	recode everattend (2=0)
	replace everattend = . if age < 6
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen byte lb_mod_age=16
	label var lb_mod_age "Labor module application age"


** LABOR STATUS

	gen lstatus=1 if Q_8_2==1
	replace lstatus=2 if Q_8_2==2
	replace lstatus=1 if Q_8_3==1
	replace lstatus=1 if Q_8_4>=1 & Q_8_4<=2
	replace lstatus=3 if Q_8_5==2 | Q_8_4==3
	replace lstatus=2 if Q_8_6==1 | Q_8_4==5 | Q_8_4==6
	replace lstatus=2 if Q_8_5==1 & lstatus!=1
	replace lstatus=. if age<16

	label var lstatus "Labor status"
	la de lbllstatus 1 "Employed" 2 "Unemployed" 3 "Non-LF"
	label values lstatus lbllstatus


** EMPLOYMENT STATUS
	recode Q_8_11 (1/3=1) (5=3) (6=2), gen(empstat)
	replace empstat=. if lstatus!=1
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee/Family worker" 3 "Employer" 4 "Self-employed" 5 "Other, not classificable"
	label values empstat lblempstat


** NUMBER OF ADDITIONAL JOBS
	gen byte njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen byte ocusec=1 if Q_8_11==3
	replace ocusec=2 if Q_8_11==2
	replace ocusec=. if lstatus!=1
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, NGO, government, army" 2 "Private"
	label values ocusec lblocusec


** REASONS NOT IN THE LABOR FORCE
	recode Q_8_7 (5=4) (6=1) (7 10/13=5) (8/9=.), gen(nlfreason)
	replace nlfreason=. if lstatus!=3
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason
	label var nlfreason "Reason not in the labor force"


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen byte unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen byte unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen byte industry=Q_8_9
	recode industry (1/2=1) (4=5) (5=6) (6=7) (7/9=9) (10/11=10)
	replace industry=. if lstatus!=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	recode Q_8_10 ( 10 11 =2) (3 12 13=5) (5 6 7=7) (8 9=8) (1 2 4=9)  (14=99), gen(occup)
	label var occup "1 digit occupational classification"
	la de lbloccup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup lbloccup


** FIRM SIZE
	gen byte firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen byte firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours = (Q_8_12 * Q_8_13)
	replace whours = . if lstatus != 1
	replace whours  = 96 if whours  > 96 & whours < .
	replace whours = . if whours  > 168
	label var whours "Hours of work in last week"


** WAGES
	gen double wage=.
	replace wage=. if lstatus!=1
	replace wage=0 if empstat==2 & wage!=.
	label var wage "Last wage payment"


** WAGES TIME UNIT
	gen byte unitwage=.
	replace unitwage=. if lstatus!=1 & empstat!=1
	replace unitwage=. if wage==.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Quarterly" 7 "Biannual" 8 "Annually" 9 "Hourly" 10 "Other"
	label values unitwage lblunitwage


** CONTRACT
	gen byte contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"
	label values contract lblcontract


** HEALTH INSURANCE
	gen byte healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"
	label values healthins lblhealthins


** SOCIAL SECURITY
	gen byte socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP
	gen byte union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/


** SPATIAL DEFLATOR
	gen spdef=.
	la var spdef "Spatial deflator"

	
** WELFARE
	gen welfare=pexnom_t
	la var welfare "Welfare aggregate"

	gen welfarenom=pexnom_t
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=pexadj_t
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=welfare
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfshprtype="CONS"
	label var welfshprtype "Welfare type for shared prosperity indicator (income, consumption or expenditure)"

	gen welfaretype="CONS"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=Q_9_9/hsize
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype="INC"
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"


/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


** POVERTY LINE (NATIONAL)
	ren pline_adj pline_nat
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT RATIO (NATIONAL)
	ren poor poor_nat
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not Poor" 1 "Poor"
	la values poor_nat poor_nat

/*****************************************************************************************************
*                                                                                                    *
                                   INTERNATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/


	local year=2011
	
** USE SARMD CPI AND PPP
	capture drop _merge
	gen urb=.
	merge m:1 countrycode year urb using "D:\SOUTH ASIA MICRO DATABASE\DOCS\CPI and PPP\cpi_ppp_sarmd.dta", ///
	keepusing(countrycode year urb syear cpi`year'_w ppp`year')
	drop urb
	drop if _merge!=3
	drop _merge
	
	
** CPI VARIABLE
	ren cpi`year'_w cpi
	label variable cpi "CPI (Base `year'=1)"
	
	
** PPP VARIABLE
	ren ppp`year' 	ppp
	label variable ppp "PPP `year'"

	
** CPI PERIOD
	gen cpiperiod=syear
	label var cpiperiod "Periodicity of CPI (year, year&month, year&quarter, weighted)"
	

** POVERTY LINE (POVCALNET)
	gen pline_int=1.90*cpi*ppp*365/12
	label variable pline_int "Poverty Line (Povcalnet)"
	
	
** HEADCOUNT RATIO (POVCALNET)
	gen poor_int=welfare<pline_int & welfare!=.
	la var poor_int "People below Poverty Line (Povcalnet)"
	la define poor_int 0 "Not Poor" 1 "Poor"
	la values poor_int poor_int


qui su ppp
if r(mean)==0{
replace pline_int=.
replace poor_int=.
}
	
/*****************************************************************************************************
*                                                                                                    *
                                   FINAL STEPS
*                                                                                                    *
*****************************************************************************************************/


** KEEP VARIABLES - ALL

	keep countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	     subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	     computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	     atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	     ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype

** ORDER VARIABLES

	order countrycode year idh idp wgt strata psu vermast veralt urban int_month int_year  ///
	      subnatid1 subnatid2 subnatid3 ownhouse water electricity toilet landphone cellphone ///
	      computer internet hsize relationharm relationcs male age soc marital ed_mod_age everattend ///
	      atschool electricity literacy educy educat4 educat5 educat7 lb_mod_age lstatus empstat njobs ///
	      ocusec nlfreason unempldur_l unempldur_u industry occup firmsize_l firmsize_u whours wage ///
		 unitwage contract healthins socialsec union pline_nat pline_int poor_nat poor_int spdef cpi ppp ///
		 cpiperiod welfare welfarenom welfaredef welfareother welfaretype welfareothertype
	
	compress

** DELETE MISSING VARIABLES

	local keep ""
	qui levelsof countrycode, local(cty)
	foreach var of varlist urban - welfareother {
	qui sum `var'
	scalar sclrc = r(mean)
	if sclrc==. {
	     display as txt "Variable " as result "`var'" as txt " for countrycode " as result `cty' as txt " contains all missing values -" as error " Variable Deleted"
	}
	else {
	     local keep `keep' `var'
	}
	}
	
	foreach w in welfare welfareother{
	qui su `w'
	if r(N)==0{
	drop `w'type
}
}
	keep countrycode year idh idp wgt strata psu vermast veralt `keep' *type

	compress

	saveold "`output'\Data\Harmonized\AFG_2011_NRVA_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\AFG_2011_NRVA_v01_M_v01_A_SARMD_IND.dta", replace version(13)


	log close


******************************  END OF DO-FILE  *****************************************************/
