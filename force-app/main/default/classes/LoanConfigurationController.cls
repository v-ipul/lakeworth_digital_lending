public with sharing class LoanConfigurationController {
    @AuraEnabled(cacheable=true)
    public static List<Loan_Configuration__mdt> getLoanConfigurations() {
        // Query the custom metadata
        List<Loan_Configuration__mdt> loanConfigs = [SELECT MasterLabel, Loan_Type__c, Annual_Rate__c, SBA_Fees__c FROM Loan_Configuration__mdt];
        return loanConfigs;
    }
}