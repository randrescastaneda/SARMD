/*****************************************************************************************************
******************************************************************************************************
**                                                                                                  **
**                       INTERNATIONAL INCOME DISTRIBUTION DATABASE (I2D2)                          **
**                                                                                                  **
** COUNTRY			BHUTAN
** COUNTRY ISO CODE	BTN
** YEAR				2007
** SURVEY NAME		BHUTAN LIVING STANDARD SURVEY (BLSS) 2007
** SURVEY AGENCY	NATIONAL STATISTICAL BUREAU
** RESPONSIBLE		Triana Yentzen
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
	set mem 500m

** DIRECTORY
	local input "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2007_BLSS\BTN_2007_BLSS_v01_M"
	local output "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\BTN\BTN_2007_BLSS\BTN_2007_BLSS_v01_M_v01_A_SARMD"

** LOG FILE
	log using "`input'\Doc\Technical\BTN_2007_BLSS.log",replace


/*****************************************************************************************************
*                                                                                                    *
                                   * ASSEMBLE DATABASE
*                                                                                                    *
*****************************************************************************************************/


** DATABASE ASSEMBLENT
	use "`input'\Data\Stata\DataOrig1-7_def.dta"

	
/*****************************************************************************************************
*                                                                                                    *
                                   * STANDARD SURVEY MODULE
*                                                                                                    *
*****************************************************************************************************/


** COUNTRY
	gen countrycode="BTN"
	label var countrycode "Country code"


** YEAR
	gen year=2007
	label var year "Year of survey"


** INTERVIEW YEAR
	gen byte int_year=.
	label var int_year "Year of the interview"
	
	
** INTERVIEW MONTH
	gen byte int_month=.
	la de lblint_month 1 "January" 2 "February" 3 "March" 4 "April" 5 "May" 6 "June" 7 "July" 8 "August" 9 "September" 10 "October" 11 "November" 12 "December"
	label value int_month lblint_month
	label var int_month "Month of the interview"

	

** HOUSEHOLD IDENTIFICATION NUMBER
	gen double idh=houseid
	tostring idh, replace
	label var idh "Household id"


** INDIVIDUAL IDENTIFICATION NUMBER
	gen str8 HID_str = string(houseid,"%08.0f")
	gen str2 pno= string(slnp,"%02.0f") 
	gen str15 indiv=HID_str+pno
	destring indiv, generate(idp)
	format idp %15.0f
	tostring idp, replace
	isid idp
	label var idp "Individual id"


** HOUSEHOLD WEIGHTS
	gen wgt=weight
	label var wgt "Household sampling weight"


** STRATA
	gen strata=.
	label var strata "Strata"


** PSU
	gen psu=.
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
	gen urban=area
	recode urban (2=0)
	label var urban "Urban/Rural"
	la de lblurban 1 "Urban" 0 "Rural"
	label values urban lblurban


** REGIONAL AREA 1 DIGIT ADMN LEVEL
	gen area01=dcode
	recode area01 (24 18 15 22 12  = 1) (20 14 29 13 28 = 2) (16 17 19 21 25 26 = 3) (11 23 27 30=4), gen(subnatid1)
	la de lblsubnatid1 1 "Western" 2 "Central" 3 "Eastern" 4 "Southern"
	label values subnatid1 lblsubnatid1
	label var subnatid1 "Region at 1 digit (ADMN1)"

** REGIONAL AREA 2 DIGIT ADMN LEVEL
	gen subnatid2=dcode
	recode subnatid2 11=21 12=11 13=44 14=16 15=12 16=31 17=32 18=13 19=35 20=15 21=36 22=41 23=42 24=14 25=33 26=34 27=22 28=43 29=17 30=23
	la de lblsubnatid2 11"Chukha" 12"Ha" 13"Paro" 14"Thimphu" 15"Punakha" 16"Gasa" ///
	17"Wangdi" 21"Bumthang" 22"Trongsa" 23"Zhemgang" 31"Lhuntshi" 32"Mongar" ///
	33"Trashigang" 34"Yangtse" 35"Pemagatshel" 36"Samdrup Jongkhar" 41"Samtse" ///
	42"Sarpang" 43"Tsirang" 44"Dagana"
	label var subnatid2 "Region at 2 digit (ADMN2)"
	label values subnatid2 lblsubnatid2
	
	
** REGIONAL AREA 3 DIGIT ADMN LEVEL
	gen byte subnatid3=.
	label var subnatid3 "Region at 3 digit (ADMN3)"
	label values subnatid3 lblsubnatid3
	

	
** HOUSE OWNERSHIP
	gen ownhouse=b2q2
	recode ownhouse 2=0
	label var ownhouse "House ownership"
	la de lblownhouse 0 "No" 1 "Yes"
	label values ownhouse lblownhouse


** WATER PUBLIC CONNECTION
	gen water=.
	replace water=0 if b2q12!=1
	replace water=1 if b2q12==1
	label var water "Water main source"
	la de lblwater 0 "No" 1 "Yes"
	label values water lblwater


** ELECTRICITY PUBLIC CONNECTION
	gen electricity=.
	replace electricity=0 if b2q18==1 | 3 | 4
	replace electricity=1 if b2q18==2
	label var electricity "Electricity main source"
	la de lblelectricity 0 "No" 1 "Yes"
	label values electricity lblelectricity


** TOILET PUBLIC CONNECTION
	gen toilet=b2q16==1
	label var toilet "Toilet facility"
	la de lbltoilet 0 "No" 1 "Yes"
	label values toilet lbltoilet


** LAND PHONE
	gen landphone=b2q11==1
	label var landphone "Phone availability"
	la de lbllandphone 0 "No" 1 "Yes"
	label values landphone lbllandphone


** CEL PHONE
	gen cellphone=b3q1mp==1 | b3q1mp==2
	label var cellphone "Cell phone"
	la de lblcellphone 0 "No" 1 "Yes"
	label values cellphone lblcellphone


** COMPUTER
	gen computer=b3q1cp==1 | b3q1cp==2
	label var computer "Computer availability"
	la de lblcomputer 0 "No" 1 "Yes"
	label values computer lblcomputer


** INTERNET
	gen internet=.
	label var internet "Internet connection"
	la de lblinternet 0 "No" 1 "Yes"
	label values internet lblinternet


/*****************************************************************************************************
*                                                                                                    *
                                   DEMOGRAPHIC MODULE
*                                                                                                    *
*****************************************************************************************************/


** HOUSEHOLD SIZE
	gen aux=1 if b11q2!=12 & b11q2!=13 & b11q2!=.
	bys idh: egen hsize=count (aux)
	label var hsize "Household size"


** RELATIONSHIP TO THE HEAD OF HOUSEHOLD

	gen relationharm=b11q2
	recode relationharm (5/11=5) (12/13=6)
	replace hsize=. if relationharm==6
	replace ownhouse=. if relationharm==6
	label var relationharm "Relationship to the head of household"
	la de lblrelationharm  1 "Head of household" 2 "Spouse" 3 "Children" 4 "Parents" 5 "Other relatives" 6 "Non-relatives"
	label values relationharm  lblrelationharm

	gen byte relationcs=b11q2
	la var relationcs "Relationship to the head of household country/region specific"
	label define lblrelationcs 1 "Self(head" 2 "Wife/Husband" 3 "Son/daughter" 4 "Father/Mother" 5 "Sister/Brother" 6 "Grandchild" 7 "Niece/nephew" 8 "Son-in-law/daughter-in-law" 9 "Brother-in-law/sister-in-law" 10 "Father-in-law/mother-in-law" 11 "Other family relative" 12 "Live-in-servant" 13 "Other-non-relative"
	label values relationcs lblrelationcs


** GENDER
	gen male=b11q1
	recode male (2=0)
	label var male "Sex of household member"
	la de lblmale 1 "Male" 0 "Female"
	label values male lblmale


** AGE
	gen age=b11q3
	replace age=98 if age>=98
	label var age "Individual age"


** SOCIAL GROUP
	gen soc=b11q5
	label var soc "Social group"
	la de lblsoc 1 "Bhutanese" 2 "Other"
	label values soc lblsoc


** MARITAL STATUS
	gen marital=b11q4
	recode marital (1=1) (6=3) (3 4=4) (2=2) (5=5)
	label var marital "Marital status"
	la de lblmarital 1 "Married" 2 "Never Married" 3 "Living Together" 4 "Divorced/separated" 5 "Widowed"
	label values marital lblmarital


/*****************************************************************************************************
*                                                                                                    *
                                   EDUCATION MODULE
*                                                                                                    *
*****************************************************************************************************/


** EDUCATION MODULE AGE
	gen ed_mod_age=3
	label var ed_mod_age "Education module application age"


** EVER ATTENDED SCHOOL
	gen everattend=1 if b12q11==1|b12q11==2
	recode everattend (.=0) if b12q11==3
	label var everattend "Ever attended school"
	la de lbleverattend 0 "No" 1 "Yes"
	label values everattend lbleverattend


** CURRENTLY AT SCHOOL
	gen atschool= b12q11==1
	replace atschool=. if age<ed_mod_age
	label var atschool "Attending school"
	la de lblatschool 0 "No" 1 "Yes"
	label values atschool  lblatschool


** CAN READ AND WRITE
	gen literacy=.
	replace literacy=0 if b12q10d==2 & b12q10e==2 & b12q10l==2 & b12q10o==2
	replace literacy=1 if b12q10d==1 | b12q10e==1 | b12q10l==1 | b12q10o==1
	replace literacy=. if age<ed_mod_age
	label var literacy "Can read & write"
	la de lblliteracy 0 "No" 1 "Yes"
	label values literacy lblliteracy


** YEARS OF EDUCATION COMPLETED
	gen educy1=.
	replace educy1=0 if b12q12==00 | b12q12==01 | b12q20==00

	replace educy1=1 if b12q12==02 | b12q20==01
	replace educy1=2 if b12q12==03 | b12q20==02
	replace educy1=3 if b12q12==04 | b12q20==03
	replace educy1=4 if b12q12==05 | b12q20==04
	replace educy1=5 if b12q12==06 | b12q20==05
	replace educy1=6 if b12q12==07 | b12q20==06
	replace educy1=7 if b12q12==08 | b12q20==07
	replace educy1=8 if b12q12==09 | b12q20==08
	replace educy1=9 if b12q12==10 | b12q20==09
	replace educy1=10 if b12q12==11 | b12q20==10
	replace educy1=11 if b12q12==12 | b12q20==11
	replace educy1=12 if b12q20==12
	replace educy1=14 if b12q20==13
	replace educy1=12 if b12q12==14 | b12q12==13 
	replace educy1=15 if b12q20==14
	replace educy=17 if b12q20==15
	replace educy=19 if b12q20==16
	replace educy=0 if b12q11==3
	gen CONEDYEARS=.
	replace CONEDYEARS=educy1

	local i = 1
	while `i'<25 {
	replace CONEDYEARS = `i' if age == (`i'+4) & educy1 > `i' & educy1~=.
	local i = `i'+1
	}
	ren CONEDYEARS educy
	replace educy=. if age<ed_mod_age
	label var educy "Years of education"


** EDUCATIONAL LEVEL 7 CATEGORIES
	gen educat7=.
	replace educat7=1 if educy==0
	replace educat7=2 if educy>0 & educy<8
	replace educat7=3 if educy==8
	replace educat7=4 if educy>8 & educy<12
	replace educat7=5 if educy==12
	replace educat7=7 if educy>12 & educy!=.
	replace educat7=. if age<ed_mod_age
	label define lbleducat7 1 "No education" 2 "Primary incomplete" 3 "Primary complete" ///
	4 "Secondary incomplete" 5 "Secondary complete" 6 "Higher than secondary but not university" /// 
	7 "University incomplete or complete" 8 "Other" 9 "Not classified"
	label values educat7 lbleducat7
	la var educat7 "Level of education 7 categories"

** EDUCATION LEVEL 5 CATEGORIES
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
	la var educat5 "Level of education 5 categories"


** EDUCATION LEVEL 4 CATEGORIES
	gen byte educat4=.
	replace educat4=1 if educat7==1
	replace educat4=2 if educat7==2 | educat7==3
	replace educat4=3 if educat7==4 | educat7==5
	replace educat4=4 if educat7==6 | educat7==7
	label var educat4 "Level of education 4 categories"
	label define lbleducat4 1 "No education" 2 "Primary (complete or incomplete)" ///
	3 "Secondary (complete or incomplete)" 4 "Tertiary (complete or incomplete)"
	label values educat4 lbleducat4
	
	/*
	*No info. on those that aren't currently being educated.
	replace EDLEVEL=0 if b12q11==3
	replace EDLEVEL=1 if (b12q12==0 | b12q12==1 | b12q12==2 | b12q12==3 | b12q12==4 | b12q12==5 | b12q12==6) & b12q11==1 
	replace EDLEVEL=1 if (b12q20==0 | b12q20==1 | b12q20==2 | b12q20==3 | b12q20==4 | b12q20==5) & b12q11==2
	replace EDLEVEL=2 if (b12q12==7 | b12q12==8 | b12q12==9 | b12q12==10) & b12q11==1
	replace EDLEVEL=2 if (b12q20==6 | b12q20==7 | b12q20==8 | b12q20==9) & b12q11==2 
	replace EDLEVEL=3 if (b12q12==11 | b12q12==12) & b12q11==1
	replace EDLEVEL=3 if (b12q20==10 | b12q20==11) & b12q11==2  
	replace EDLEVEL=4 if (b12q12==13 | b12q12==14 | b12q12==15  | b12q12==16) & b12q11==1
	replace EDLEVEL=4 if (b12q20==12 | b12q20==13 | b12q20==14 | b12q20==15 | b12q20==16) & b12q11==2  
	label define edlevelv 0 "No Education"
	label define edlevelv 1 "Some Education, less than Primary", add
	label define edlevelv 2 "Completed Primary, less than Lower Secondary", add
	label define edlevelv 3 "Completed Lower Secondary, less than Senior Secondary", add

	gen CONEDLEVEL=.
	replace CONEDLEVEL=EDLEVEL
	replace CONEDLEVEL = 1 if educy > 0 & educy <=5
	replace CONEDLEVEL = 2 if educy >=6 & educy <10
	replace CONEDLEVEL = 3 if educy >=10 & educy <12
	replace CONEDLEVEL = 4 if educy >=12 & educy <.
	recode CONEDLEVEL (0=1) (1 2=2) (3=3) (4=4),gen(edulevel2)
	*/


/*****************************************************************************************************
*                                                                                                    *
                                   LABOR MODULE
*                                                                                                    *
*****************************************************************************************************/


** LABOR MODULE AGE
	gen lb_mod_age=15
	label var lb_mod_age "Labor module application age"


** LABOR STATUS

	gen lstatus = .  
	replace lstatus = 1 if inlist(1, b14q37d,  b14q38d,  b14q39d)
	replace lstatus = 2 if  b14q40==1 & mi(lstatus)
	replace lstatus = 3 if b14q41!=.
	replace lstatus = . if age<15 

	label var lstatus "Labor status"
	label define lstatus 1"Employed" 2"Unemployed" 3"Not-in-labor-force"
	label values lstatus lstatus


** EMPLOYMENT STATUS
	gen empstat=b14q43
	recode empstat (1 2=1) (3=2) (5=3) (6=5)
	label var empstat "Employment status"
	la de lblempstat 1 "Paid employee" 2 "Non-paid employee" 3 "Employer" 4 "Self-employed" 5 "Other"
	label values empstat lblempstat
	replace empstat=. if lstatus!=1 | age<15


** NUMBER OF ADDITIONAL JOBS
	gen njobs=.
	label var njobs "Number of additional jobs"


** SECTOR OF ACTIVITY: PUBLIC - PRIVATE
	gen ocusec=b14q46
	recode ocusec (1 3=1) ( 2 4 5 6 7 8 9 =3)  (10=.)
	recode ocusec 3=2
	label var ocusec "Sector of activity"
	la de lblocusec 1 "Public, state owned, government, army" 2 "NGO" 3 "Private"
	label values ocusec lblocusec
	replace ocusec=. if lstatus!=1 | age<15


** REASONS NOT IN THE LABOR FORCE
	gen nlfreason=b14q41
	recode nlfreason (8=1) (7=2) (9=3) (1 10=4) (2/6 11=5)
	 replace nlfreason=. if lstatus~=3
	label var nlfreason "Reason not in the labor force"
	la de lblnlfreason 1 "Student" 2 "Housewife" 3 "Retired" 4 "Disable" 5 "Other"
	label values nlfreason lblnlfreason


** UNEMPLOYMENT DURATION: MONTHS LOOKING FOR A JOB
	gen unempldur_l=.
	label var unempldur_l "Unemployment duration (months) lower bracket"

	gen unempldur_u=.
	label var unempldur_u "Unemployment duration (months) upper bracket"


** INDUSTRY CLASSIFICATION
	gen industry=b14q45
	recode industry (11/50=1) (101/142=2) (151/372=3) (401/410=4) (451/455=5) (501/552=6) ///
	(601/642=7) (651/749=8) (751/752=9) (753/990=10)
	replace  industry =. if age<15 | industry==11
	replace industry=. if lstatus~=1
	label var industry "1 digit industry classification"
	la de lblindustry 1 "Agriculture" 2 "Mining" 3 "Manufacturing" 4 "Public utilities" 5 "Construction"  6 "Commerce" 7 "Transport and Comnunications" 8 "Financial and Business Services" 9 "Public Administration" 10 "Other Services, Unspecified"
	label values industry lblindustry


** OCCUPATION CLASSIFICATION
	gen occup=b14q44
	recode occup (1=10)
	recode occup (11/13=1) (21/24=2) (31/34=3) (41/42=4) (51/52=5) (61/62=6) (71/74=7) (81/88=8) (91/93=9) (97/98=99)
	label var occup "1 digit occupational classification"
	la de occup 1 "Senior officials" 2 "Professionals" 3 "Technicians" 4 "Clerks" 5 "Service and market sales workers" 6 "Skilled agricultural" 7 "Craft workers" 8 "Machine operators" 9 "Elementary occupations" 10 "Armed forces"  99 "Others"
	label values occup occup
	replace occup=. if lstatus!=1 | age<15


** FIRM SIZE
	gen firmsize_l=.
	label var firmsize_l "Firm size (lower bracket)"

	gen firmsize_u=.
	label var firmsize_u "Firm size (upper bracket)"


** HOURS WORKED LAST WEEK
	gen whours=b14q52m
	*infeasible weekly working hours reported - to be recoded to missing
	*histogram whours if whours<100
	replace whours=. if whours>98
	replace whours=. if lstatus!=1 | age<15
	label var whours "Hours of work in last week"



** WAGES
	gen wage=.

** WAGES TIME UNIT
	label var wage "Last wage payment"

	gen unitwage=.
	label var unitwage "Last wages time unit"
	la de lblunitwage 1 "Daily" 2 "Weekly" 3 "Every two weeks" 4 "Bimonthly"  5 "Monthly" 6 "Trimester" 7 "Biannual" 8 "Annually" 9 "Hourly"

** CONTRACT
	label values unitwage lblunitwage

	gen contract=.
	label var contract "Contract"
	la de lblcontract 0 "Without contract" 1 "With contract"

** HEALTH INSURANCE
	label values contract lblcontract

	gen healthins=.
	label var healthins "Health insurance"
	la de lblhealthins 0 "Without health insurance" 1 "With health insurance"

** SOCIAL SECURITY
	label values healthins lblhealthins

	gen socialsec=.
	label var socialsec "Social security"
	la de lblsocialsec 1 "With" 0 "Without"
	label values socialsec lblsocialsec


** UNION MEMBERSHIP


	gen union=.
	label var union "Union membership"
	la de lblunion 0 "No member" 1 "Member"
	label values union lblunion


/*****************************************************************************************************
*                                                                                                    *
                                   WELFARE MODULE
*                                                                                                    *
*****************************************************************************************************/

** SPATIAL DEFLATOR
	gen spdef=reg_deflator
	la var spdef "Spatial deflator"


** WELFARE
	gen welfare=pce_real
	la var welfare "Welfare aggregate"

	gen welfarenom=total_exp
	la var welfarenom "Welfare aggregate in nominal terms"

	gen welfaredef=pce_real
	la var welfaredef "Welfare aggregate spatially deflated"

	gen welfshprosperity=total_exp
	la var welfshprosperity "Welfare aggregate for shared prosperity"

	gen welfaretype="EXP"
	la var welfaretype "Type of welfare measure (income, consumption or expenditure) for welfare, welfarenom, welfaredef"

	gen welfareother=.
	la var welfareother "Welfare Aggregate if different welfare type is used from welfare, welfarenom, welfaredef"

	gen welfareothertype=""
	la var welfareothertype "Type of welfare measure (income, consumption or expenditure) for welfareother"



/*****************************************************************************************************
*                                                                                                    *
                                   NATIONAL POVERTY
*                                                                                                    *
*****************************************************************************************************/



** POVERTY LINE (NATIONAL)
	ren totpovline pline_nat
	label variable pline_nat "Poverty Line (National)"


** HEADCOUNT
	gen poor_nat=welfaredef<pline_nat if welfaredef!=.
	la var poor_nat "People below Poverty Line (National)"
	la define poor_nat 0 "Not-Poor" 1 "Poor"
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
	
	
	saveold "`output'\Data\Harmonized\BTN_2007_BLSS_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	saveold "D:\SOUTH ASIA MICRO DATABASE\SAR_DATABANK\__REGIONAL\Individual Files\BTN_2007_BLSS_v01_M_v01_A_SARMD_IND.dta", replace version(13)
	

	log close




******************************  END OF DO-FILE  *****************************************************/
