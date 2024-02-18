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

*** Keywords ***
Add row data to list
    [Arguments]    ${items}

    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[5]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Add invoice header to db
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoiceheader(invoicenumber,companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat,vat,totalamount, invoicestatus_id, comments) values ('${items}[0]','${items}[1]','${items}[5]','${items}[2]', '2000-01-01', '2000-01-01','${items}[6]',0,0,0,0,'');
    Execute Sql String    ${insertStmt}

*** Keywords ***
Add Invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}
    ${insertStmt}=    Set Variable    insert into invoicerow(invoicenumber,rownumber, description, quantity, unit, unitprice, vatpercent, vat, total,) values ('${items}[0]','${items}[1]','${items}[2]','${items}[3]','${items}[4]','${items}[5]','${items}[6]','${items}[7]','${items}[8]');
    Execute Sql String    ${insertStmt}

*** Test Cases ***
Read CSV file to list
    #Make Connection    ${dbname}
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

 
*** Test Cases ***
Loop all invoicerows
    #Käydään läpi kaikki laskurivit
    FOR    ${element}    IN    @{rows}
        Log    ${element}

        # jaetaan rivin data omiksi elementeiksi
        @{items}=    Split String    ${element}    ;

        #haetaan käsiteltävän rivin laskunumero
        ${rowInvoiceNumber}=    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}
    
        IF    "${rowInvoiceNumber}" == "${InvoiceNumber}"
            
            Log    Lisätään rivejä laskulle

            Add Row Data To List    ${items}

        ELSE
            Log    Pitää tutkia onko tietokantalistassa jo rivejä
            ${length}=    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    Ensimmäisen laskun tapaus
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                

                Add row data to list    ${items}
            ELSE
                Log    Lasku vaihtuu

                # Etsi laskun otsikkorivi
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}=    Split String    ${headerElement}    ;
                    IF    "${headerItems}[0]" == "${InvoiceNumber}"
                        Log  Lasku löytyi
                        #Validointi

                         # Syötä laskun otsikkorivi tietokantaan
                         Add invoice header to db    ${headerItems}
                        # Syötä laskun rivit tietokantaan
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add Invoice Row To DB    ${rowElement}
                                
                        END

                    END
                    
                END

                

                

                

                # Valmista prosessi seuraavaan laskuun
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Variable    ${InvoiceNumber}

                Add row data to list    $items
            
            END
        END

        
    END

    #Viimeisen laskun tapaus

    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        # Etsi laskun otsikkorivi
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}=    Split String    ${headerElement}    ;
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                            Log    Lasku löytyi
                            #Validointi

                            # Syötä laskun otsikkorivi tietokantaan
                            Add invoice header to db    ${headerItems}
                            # Syötä laskun rivit tietokantaan
                            FOR    ${rowElement}    IN    @{ListToDB}
                                Add Invoice Row To DB    ${rowElement}
                                
                            END

                    END
                    
                END
        
    END
    

    
    
   
     



