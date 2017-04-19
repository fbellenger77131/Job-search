public with sharing class New_Opportunity {

    private final Opportunity Oppty;
    private String OK;

    public String OpptyContact_FirstName { get; set; }
    public String OpptyContact_LastName { get; set; }
    public String CustomerContact_FirstName { get; set; }
    public String CustomerContact_LastName { get; set; }
    public String Account_Name { get; set; }
    public String Account_City { get; set; }
    public String Account_Country { get; set; }
    public String Customer_Name { get; set; }
    public String Customer_City { get; set; }
    public String Customer_Country { get; set; }
    
    public New_Opportunity(ApexPages.StandardController controller) {
        this.Oppty = (Opportunity )controller.getRecord();
    }

    public PageReference DoSave() {
        
        boolean Data_is_Valid =  Check_Account_Input() && Check_Customer_Input() &&
            Check_AccountContact_Input() && Check_CustomerContact_Input();
        
        if( Data_is_Valid ) {
            try {
                PerformSave(); 
            }           
            catch(DMLException e) {
                Oppty.AddError(e);
                return System.currentPageReference();
            }
        }
        
        // Send the user to the detail page for the new Opportunity.
        PageReference newOpptyPage = new ApexPages.StandardController(Oppty).view();
        newOpptyPage.setRedirect(true);
        return newOpptyPage;
    }
 
    private void PerformSave() {
        Account acct;
        Account customer;
        Contact acct_contact;
        Contact cust_contact;
      
        //-- Create Account record if not Lookedup - RecordType = 'Partner'
        if( Oppty.AccountId == null ) {
            acct = New Account( Name = Account_Name, BillingCity = Account_City, BillingCountry = Account_Country, RecordTypeId = '012A0000000zuTnIAI');
            insert acct;
            Oppty.AccountId = acct.id; 
        }

        //-- Create Account Contact record if not Lookedup - RecordType = Partner Contact
        if( Oppty.Oppty_Contact__c == null ) {
            acct_contact = New Contact( FirstName = OpptyContact_FirstName, LastName = OpptyContact_LastName, AccountId = Oppty.AccountId, RecordTypeId = '012A0000000zuU2IAI');
            insert acct_contact;
            Oppty.Oppty_Contact__c = acct_contact.id;
        }

        //-- Create Customer record if not Lookedup - RecordType = 'Customer'
        if( Oppty.Customer_Name__c == null && Customer_Name <> '') {
            customer = New Account( Name = Customer_Name, BillingCity = Customer_City, BillingCountry = Customer_Country, RecordTypeId = '012A0000000zuTsIAI');
            customer.Nature__c = 'Client final';
            insert customer;
            Oppty.Customer_Name__c = customer.id;
        }

        //-- Create Customer Contact record if not Lookedup - RecordType = Customer Contact
        if( Oppty.Customer_Contact__c == null && CustomerContact_LastName <> '') {
            cust_contact = New Contact( FirstName = CustomerContact_FirstName, LastName = CustomerContact_LastName, AccountId = Oppty.Customer_Name__c, RecordTypeId = '012A0000000zuU7IAI' );
            insert cust_contact; 
            Oppty.Customer_Contact__c = cust_contact.id; 
        }
            
        //-- Create Opportunity record with all Account and Contact informations and default values
        Oppty.Name = 'Will be set by Workflow';
        Oppty.StageName = 'Candidate / Application';
        Oppty.RecordTypeID = '012A0000000zetgIAA';
        insert Oppty;
    }
    
    private boolean Check_Account_Input() {
    
        //-- L'un des 2 champs Last Name ou Contact Existant doit être saisi
        if( Oppty.AccountId == null ) { 
            if( String.isEmpty(Account_Name) ) {
                Oppty.AddError('Error Account: please fill Existing Account or Name field'); 
                return false;
            }
        }
        
        //- Saisir seulemnt l'1 des 2 zones
        if( Oppty.AccountId <> null && !String.isEmpty(Account_Name) ) {
             Oppty.AddError('Error Account: Existing Account Name field can\'t  be present be simultaneously'); 
             return false;
        }
        
        return true;
    }
 
    private boolean Check_AccountContact_Input() {
    
        //-- L'un des 2 champs Last Name ou Contact Existant doit être saisi
        if( Oppty.Oppty_Contact__c == null ) { 
            if( String.isEmpty(OpptyContact_LastName) ) {
                Oppty.AddError('Error Account Contact: please fill Existing Contact or Last Name'); 
                return false;
            }
        }
        
        //- Saisir seulement l'1 des 2 zones Last Name ou Contact Existant
        if( Oppty.Oppty_Contact__c <> null && !String.isEmpty(OpptyContact_LastName) ) {
             Oppty.AddError('Error Account Contact: Existing Contact or Last Name can\'t  be present be simultaneously'); 
             return false;
        }
        
        return true;
    }

     private boolean Check_Customer_Input() {
    
        //- Saisir seulement l'1 des 2 zones Name ou Customer Existant
        if( Oppty.Customer_Name__c <> null && !String.isEmpty(Customer_Name) ) {
             Oppty.AddError('Error Customer: Existing Customer or Customer Name can\'t be present be simultaneously'); 
             return false;
        }
        
        return true;
    }
       
    private boolean Check_CustomerContact_Input() {
    
        //- Saisir seulement l'1 des 2 zones Last Name ou Customer Contact Existant
        if( Oppty.Customer_Contact__c <> null && !String.isEmpty(CustomerContact_LastName) ) {
             Oppty.AddError('Error Customer Contact: Existing Contact or Last Name can\'t  be present be simultaneously'); 
             return false;
        }
        
        return true;
    }
/*    
    private ID GetRecordTypeID( String sObjectName, String RecordTypeName ) {
        
        String SOQL_Query = 'SELECT ID FROM RecordType WHERE SobjectType = :sObjectName AND DeveloperName =:RecordTypeName LIMIT 1';
        
        RecordType rt;
        List<RecordType> rt_record;
        
        rt_record = rt.query(SOQL_Query);
        if (rt.getSize() > 0) {
            return rt[0].Id;
        }
    }
*/
}