<#



#>

#Disable User AD Account and Reset Password to a random generated PW


#Create Folder for Archiving Details

#Remove AD Group Memberships and Document

#Add txt document with name of "Delete After mm-dd-yyyy" (7 years). For use with scheduled task to clean.

#Optional (Use SCCM and move User Data to Archive Folder from Primary Computer)

Function Term-ADUser
{
#Disable Account

#Reset Password
#Edit User Description
#Get AD Group Memberships and document to csv in Archive folder
#Get AD Account Details and document to csv in Archive Folder (General Details, Phone, SAM, UPN, Fax, Organization Details, SMTP, smtp Aliases, etc)
#Remove from all AD Group memberships
#Send Teams Message and Message to individuals Manager
}

Function Term-UserComputer
{
#Get 
}

