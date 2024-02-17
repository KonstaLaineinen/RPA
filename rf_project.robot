*** Settings ***

Library    DatabaseLibrary
Library    String
Library    Collections
Library    OperatingSystem

*** Variables ***

${PATH}    C:/Users/konst/Desktop/RPA/
@{ListToDB}
${InvoiceNumber}    empty

#Tietokannan apumuuttujat
${dbname}    rpakurssi
${dbuser}    konstalaineinen
${dbpass}    root
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}

*** Test Cases ***
Read CSV file to list
    Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv

    Log    ${outputHeader}
    Log    ${outputRows}

    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n

    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

*** Test Cases ***
Loop all invoice rows
    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        @{items}=    Split String    ${element}    ;
        ${rowInvoiceNumber}=    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}
    END

    


    
   
     



