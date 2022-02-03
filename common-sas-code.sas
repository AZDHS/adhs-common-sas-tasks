/**********************************************************************************************************************************
 Program:        Common SAS Tasks
 Description:    SAS code for common tasks like how to send an email from SAS, how to stop a SAS program if there is an error,
                 how to recode variables using arrays, etc.
 Created:        2-3-2022
 Updated:        2-3-2022
 Author:         Cymone Gates, MPH
 File Path:      GitHub
************************************************************************************************************************************/

/***************************************************************************
 SEND AN EMAIL FROM SAS
****************************************************************************/
options emailsys = smtp emailhost="[obtain from your IT]" emailport=25;

FILENAME mailbox email 
	from="[insert work email you want to send from]"
	to=("recipient_num_1@test.gov" "recipient_num_1@test.gov")
	cc="[insert email you want to cc]" /*this is optional - include if you want to cc someone*/
	attach="[insert file path]\Example_File_&sysdate..xlsx" /*this is optional - include if you want to attach files*/
	Subject="Case Data for [Insert County] - &sysdate" /*the &sysdate macro is a built-in SAS macro that will put the date the SAS program runs*/
	;

/*enter the message you want to show in the body of the email*/
data _null_;
	file mailbox;
	put "Your daily cases are attached. See attachment that starts with ‘Example_File'.";
	put " ";
	put " "; 
	put "This email was auto generated using SAS, however you can reply to this email with questions.";
	put " "; 
	put "Run &sysdate, &systime";
	put "[Insert name of your team or your name if desired]";
	run;



/***************************************************************************
 STOP A SAS PROGRAM FROM RUNNING IF THERE IS AN ERROR AND SEND AN ALERT EMAIL
****************************************************************************/
%macro check_for_errors;


*if SAS detects an error, do the following;
*if you want SAS to stop if detectings an error OR warning, change the 6 to 0;

%if &syserr > 6 %then %do; 

	options emailsys = smtp emailhost="[obtain from your IT]"  emailport=25;

	filename mailbox email 
	from="[insert work email you want to send from]"
	to=("recipient_num_1@test.gov" "recipient_num_1@test.gov")

	data _null_;
	file mailbox;
		p "The [insert name of program] program generated this error: &syserrortext.. Please resolve and rerun.";
		p " ";
		p "Thanks,";
		p "Automated SAS Program";
		p "Run &sysdate, &systime";
		p "[insert file path for SAS program]"
		p " ";
	RUN;


 %abort cancel; *abort program;

%end ;
%mend check_for_errors;


*execute macro;
%check_for_errors *<-----------You will need to execute this macro after each data step or procedure that you want to check for errors;


/***************************************************************************
 USE AN ARRAY TO MAKE THE SAME CHANGE TO MULTIPLE VARIABLES
****************************************************************************/

data practice;
set sashelp.cars(obs=100);

/********************
 Example 1
*********************/
*array to change character variables make, model, type and origin to all uppercase letters;
array miss make model type origin;
	do i=1 to dim(miss);
		miss[i]=upcase(miss[i]);
	end;drop i;

/********************
 Example 2
*********************/
*array to add 10 to numeric variables msrp, invoice and weight if they are not missing;
array up msrp invoice weight;
	do i=1 to dim(up);
		if up[i] ^=. then up[i]= up[i]+10;
	end;drop i;

/********************
 Example 3
*********************/
*array to multiply variables weight to length by 2;
array z weight -- length;
	do i=1 to dim(z);
		z[i]= z[i] * 2;
	end;drop i;

/********************
 Example 4
*********************/
*new variable for counting how many fiels have value greater than 3, per car;
var_cnt=0;

*array to count the number of fields with values greater than 3;
array r enginesize cylinders ;
	do i=1 to dim(r);
		if r[i] >3 then var_cnt+1;
	end; drop i;

/********************
 Example 5
*********************/

*array to recode all character fields with missing data to the word "Unknown"
*doing this to ALL of one type of variable could be very heavy on SAS processing so only do so if required;
array b _character_ ;
	do i=1 to dim(b);
		if b[i]="" then b[i]="Unknown";
	end; drop i;


run;

