public class FINS_MOCK_ScoringCtrl {
    
    @AuraEnabled
    public static Map<String,Object> getScoreData(String recordId, String parentObjectType){
        FINS_MOCK_Score__c score = new FINS_MOCK_Score__c();
        List<FINS_MOCK_Score_Reason__c> scoreReasons = new List<FINS_MOCK_Score_Reason__c>();
        Map<String, Object> returnVal = new Map<String, Object>();
        Boolean hasData = [SELECT count() 
                           FROM FINS_MOCK_Score__c 
                           WHERE Lead__c = :recordId OR Opportunity__c = :recordId] > 0 ? true : false;
        try {
            if(hasData){
                score = [SELECT Id, Score__c, Default__c, Opportunity__c, Lead__c
                         FROM FINS_MOCK_Score__c
                         Where Lead__c = :recordId OR Opportunity__c = :recordId
                         ORDER BY LastModifiedDate DESC
                         LIMIT 1];
            } else {
                score = [SELECT Id, Score__c, Default__c, Opportunity__c, Lead__c
                         FROM FINS_MOCK_Score__c
                         WHERE Default__c = true 
                         AND Parent_Object_Type__c = :parentObjectType
                         LIMIT 1];
            }
            
            if(score != null && score.Id != null){
                scoreReasons = [SELECT Id, Reason__c, Confidence__c 
                                FROM FINS_MOCK_Score_Reason__c 
                                WHERE Score__c = :score.Id
                                ORDER BY Confidence__c DESC
                                LIMIT 5];
                
                returnVal.put('score', score);
                returnVal.put('scoreReasons', scoreReasons);
                return returnVal;
            } else {
                returnVal.put('score',  new FINS_MOCK_Score__c(Score__c = 0, Default__c = false));
                returnVal.put('scoreReasons', new List<FINS_MOCK_Score_Reason__c>());
                return returnVal;
            }
        } catch(Exception e){
            returnVal.put('score', new FINS_MOCK_Score__c(Score__c = 0));
            returnVal.put('scoreReasons', new List<FINS_MOCK_Score_Reason__c>());
            return returnVal;
        }
    }
    
    @AuraEnabled
    public static String saveScore(String score){
        FINS_MOCK_Score__c scoreRecord = (FINS_MOCK_Score__c)JSON.deserialize(score, FINS_MOCK_Score__c.class);
        upsert scoreRecord;
        return scoreRecord.Id;
    }
    
    @AuraEnabled
    public static List<FINS_MOCK_Score_Reason__c> saveScoreReasons(String scoreId, String sReasons){
        try {
            List<FINS_MOCK_Score_Reason__c> reasons = (List<FINS_MOCK_Score_Reason__c>)JSON.deserialize(sReasons, List<FINS_MOCK_Score_Reason__c>.class);
            for(FINS_MOCK_Score_Reason__c reason: reasons ){
                reason.Score__c = scoreId;
            }
            
            upsert reasons;
            return reasons;
        } catch(Exception e){
            return new List<FINS_MOCK_Score_Reason__c>();
        }
    }
    
    @AuraEnabled
    public static Boolean deleteReasonDB(String scoreReasonId){
        try {
            FINS_MOCK_Score_Reason__c deletingReason = new FINS_MOCK_Score_Reason__c();
            deletingReason.Id = scoreReasonId;
            delete deletingReason;
            return true;
        } catch(Exception e){
            return false;
        }
    }
}