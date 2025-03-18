report 70148 "AGTTAsk12march"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './salesOrderReport17marchtask2.rdl';
    Caption = 'salesorder_RP2';

    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            column(Sales_Order_No; "No.") { }
            column(Order_Date; "Order Date") { }
            column(Sell_to_Customer_Name; "Sell-to Customer Name") { }
            column(Sell_to_Customer_Address; "Sell-to Address") { }
            column(Sell_to_Customer_City; "Sell-to City") { }
            column(Tax_Area_Code; "Tax Area Code") { }
            column(Sell_to_Post_Code; "Sell-to Post Code") { }
            column(customerCountryName; customerCountryName) { }

            column(logoOfCompany; comapnyInfomation.Picture) { }
            column(companyName; companydata[1]) { }
            column(companyAddress; companydata[2]) { }
            column(companyAddress2; companydata[3]) { }
            column(companyTaxAreaCode; companydata[4]) { }
            column(companyPostcode; companydata[5]) { }
            column(companyCountryName; companyCountryName) { }

            column(External_Document_No_; "External Document No.") { }
            column(salesPersonName; salesPersonName) { }
            column(Quote_No_; "Quote No.") { }
            column(Shipment_Method_Code; "Shipment Method Code") { }

            column(companyPhoneNo; companydata[7]) { }
            column(companyEmail; companydata[8]) { }
            column(companyBankName; companydata[9]) { }
            column(companyBankBranchNo; companydata[10]) { }
            column(companyBankAccountNo; companydata[11]) { }
            column(companyIBAN; companydata[12]) { }
            column(companyGiroNo; companydata[13]) { }

            dataitem("Sales Line"; "Sales Line")
            {
                DataItemLink = "Document Type" = field("Document Type"),
                   "Document No." = field("No.");

                column(Item_No; "No.") { }
                column(Total_Quantity; Quantity) { }
                column(Unit_Price; "Unit Price") { }


                column(Quantity_To_Ship; QtyToShip) { }
                column(Quantity_To_Invoice; QtyToInvoice) { }
                column(Total_Shipped_Amount; TotalShippedAmount) { }
                column(Total_Invoiced_Amount; TotalInvoicedAmount) { }

                trigger OnAfterGetRecord()
                var
                    SalesShipmentLine: Record "Sales Shipment Line";
                    SalesInvoiceLine: Record "Sales Invoice Line";
                begin

                    QtyToShip := 0;
                    QtyToInvoice := 0;
                    TotalShippedAmount := 0;
                    TotalInvoicedAmount := 0;

                    SalesShipmentLine.Reset();
                    SalesShipmentLine.SetRange("Order No.", "Sales Line"."Document No.");
                    SalesShipmentLine.SetRange("No.", "Sales Line"."No.");

                    if SalesShipmentLine.FindFirst() then begin
                        repeat
                            QtyToShip += SalesShipmentLine.Quantity;
                            TotalShippedAmount += SalesShipmentLine."Unit Cost";
                        until SalesShipmentLine.Next() = 0;
                    end;

                    // Check Sales Invoice Line data
                    SalesInvoiceLine.Reset();
                    SalesInvoiceLine.SetRange("Order No.", "Sales Line"."Document No.");
                    SalesInvoiceLine.SetRange("No.", "Sales Line"."No.");

                    if SalesInvoiceLine.FindFirst() then begin
                        repeat
                            QtyToInvoice += SalesInvoiceLine.Quantity;
                            TotalInvoicedAmount += SalesInvoiceLine."Unit Cost";

                        until SalesInvoiceLine.Next() = 0;
                    end
                end;


            }

            trigger OnPreDataItem()
            begin
                if orderNo <> '' then begin
                    "Sales Header".SetRange("No.", orderNo);
                end
                else
                    Error('Please Give Your Sales order Number');
            end;

            trigger OnAfterGetRecord()
            var
                conuntryRegionOfCustomer: record "Country/Region";
                salesPersontable: Record "Salesperson/Purchaser";
            begin
                if (conuntryRegionOfCustomer.Get("Sell-to Country/Region Code")) then begin
                    customerCountryName := conuntryRegionOfCustomer.Name;
                end;

                if (salesPersontable.Get("Salesperson Code")) then begin
                    salesPersonName := salesPersontable.Name;
                end;
            end;
        }
    }

    requestpage
    {
        AboutTitle = 'Teaching tip title';
        AboutText = 'Teaching tip content';

        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    field(orderNo; orderNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Sales Order No.';
                        TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
                action(LayoutName)
                {

                }
            }
        }
    }

    trigger OnPreReport()
    begin
        comapnyInfomation.Get();
        comapnyInfomation.CalcFields(Picture);

        if comapnyInfomation.Picture.HasValue then begin
            comapnyInfomation.Picture.CreateInStream(companyinStream);
        end;

        companydata[1] := comapnyInfomation.Name;
        companydata[2] := comapnyInfomation.Address;
        companydata[3] := comapnyInfomation."Address 2";
        companydata[4] := comapnyInfomation."Tax Area Code";
        companydata[5] := comapnyInfomation."Post Code";
        companydata[6] := comapnyInfomation."Country/Region Code";

        conuntryRegionOfCompany.Get(companydata[6]);
        companyCountryName := conuntryRegionOfCompany.Name;

        companydata[7] := comapnyInfomation."Phone No.";
        companydata[8] := comapnyInfomation."E-Mail";
        companydata[9] := comapnyInfomation."Bank Name";
        companydata[10] := comapnyInfomation."Bank Branch No.";
        companydata[11] := comapnyInfomation."Bank Account No.";
        companydata[12] := comapnyInfomation.IBAN;
        companydata[13] := comapnyInfomation."Giro No.";
    end;

    var
        orderNo: Code[50];
        comapnyInfomation: record "Company Information";
        companyinStream: InStream;
        companydata: array[20] of Text;
        conuntryRegionOfCompany: record "Country/Region";
        companyCountryName: Text[50];
        customerCountryName: Text[50];
        salesPersonName: Text[30];
        QtyToShip: Decimal;
        QtyToInvoice: Decimal;
        TotalShippedAmount: Decimal;
        TotalInvoicedAmount: Decimal;
}
