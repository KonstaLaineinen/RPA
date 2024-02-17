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

#Jokainen rivi käsittelyyn yksittäisenä elementtinä
    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n

#Poistetaan ensimmäinen ja/tai viimeinen TYHJÄ rivi
    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}


    

    FOR    ${element}    IN    @{headers}
        Log    ${element}
        
    END

    FOR    ${element}    IN    @{rows}
        Log    ${element}
        
    END

    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

# *** Test Cases ***
# Loop all invoice rows

#     FOR    ${element}    IN    @{rows}
#         Log    ${element}

#         @{items}=    Split String    ${element}    ;
#         ${rowInvoiceNumber}=    Set Variable    ${items}[7]

#         Log    ${rowInvoiceNumber}
#         Log    ${InvoiceNumber}
        
#     END    
    


    
   
     



