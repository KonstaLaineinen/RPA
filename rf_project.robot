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
Add Row Data to List
    [Arguments]    ${items}

    @{AddInvoiceRowData}    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}


*** Keywords ***
Add Invoice Header To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}

    
    ${insertStmt}    Set Variable    INSERT INTO invoiceheader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoiceStatus_id, comments) VALUES ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', 0, '');
    Execute Sql String    ${insertStmt}


*** Keywords ***
Add invoice Row To DB
    [Arguments]    ${items}
    Make Connection    ${dbname}

    
    ${insertStmt}    Set Variable    INSERT INTO invoicerow (invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, total) VALUES ('${items}[7]', '${items}[8]', '${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]');
    Execute Sql String    ${insertStmt}

*** Test Cases ***
Read CSV file to list
    Make Connection    ${dbname}
    ${outputHeader}    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}    Get File    ${PATH}InvoiceRowData.csv

    Log    ${outputHeader}
    Log    ${outputRows}
    
    
    @{headers}    Split String    ${outputHeader}    \n
    @{rows}    Split String    ${outputRows}    \n 
    
    
    ${length}    Get Length    ${headers}
    ${length}    Evaluate    ${length}-1
    ${index}    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}
    
    
    ${length}    Get Length    ${rows}
    ${length}    Evaluate    ${length}-1

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
Loop through all invoicerows
    
    
     FOR    ${element}    IN    @{rows}
        Log    ${element}
        
        
        @{items}    Split String    ${element}    ,
        

        
        ${rowInvoiceNumber}    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}

        
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Lisätään rivejä

           
            Add Row Data to List    ${items}
        
        ELSE
            Log    Onko rivitietoja
            ${length}    Get Length    ${ListToDB}
            IF    ${length} == ${0}
                Log    Eka case

                
                ${InvoiceNumber}    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                
                Add Row Data to List    ${items}
            ELSE
                Log    Lasku muuttunut

                 
                FOR    ${headerElement}    IN    @{headers}
                    ${headerItems}    Split String    ${headerElement}    ,
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    Lasku löytyi

                        

                        
                        Add Invoice Header To DB    ${headerItems}

                        
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add invoice Row To DB    ${rowElement}
                            
                        END

                    END
                    
                END
                

                
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}
                
                
                Add Row Data to List    ${items}
            END
            
        END
        
    END


    
    ${length}    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    Laskun käsittely
        
        
        FOR    ${headerElement}    IN    @{headers}
            ${headerItems}    Split String    ${headerElement}    ,
            IF    '${headerItems}[0]' == '${InvoiceNumber}'
                Log    Lasku löyty

                

                
                Add Invoice Header To DB    ${headerItems}

                
                FOR    ${rowElement}    IN    @{ListToDB}
                    Add invoice Row To DB    ${rowElement}
                    
                END

            END
            
        END
    END
    

    
    
   
     



