public with sharing class SharePointController {
    // Upload file to SharePoint
    @AuraEnabled
    public static String uploadToSharePoint(Id contentVersionId, String folderPath, Id recordId) {
        try {
            // Get file data directly from ContentVersion
            ContentVersion cv = [
                SELECT Title, VersionData, FileExtension, ContentDocumentId 
                FROM ContentVersion 
                WHERE Id = :contentVersionId 
                LIMIT 1
            ];
            
            // Prepare filename with extension
            String fileName = cv.Title + (String.isNotBlank(cv.FileExtension) ? '.' + cv.FileExtension : '');
            
            // Construct SharePoint endpoint
            String endpoint = 'callout:SharePoint_Named_Credential' + 
                            '/sites/SFTEST/drive/items/root:/' + 
                            EncodingUtil.urlEncode(folderPath, 'UTF-8') + 
                            '/' + EncodingUtil.urlEncode(fileName, 'UTF-8') + 
                            ':/content';
            
            // Prepare HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('PUT');
            req.setBodyAsBlob(cv.VersionData);
            req.setHeader('Content-Type', 'application/octet-stream');
            
            // Execute callout
            HttpResponse res = new Http().send(req);
            
            if(res.getStatusCode() == 201) {
                // Parse response
                Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                String webUrl = (String)responseMap.get('webUrl');
                String spId = (String)responseMap.get('id');
                
                // Create tracking record using your exact field names
                SharePoint_Document__c doc = new SharePoint_Document__c(
                    Name = fileName,
                    SharePoint_URL__c = webUrl,
                    SharePoint_Id__c = spId,
                    ContentVersion_Id__c = contentVersionId,
                    Is_Current_Version__c = true,
                    // Add any additional fields from your object
                    OwnerId = UserInfo.getUserId() // Set owner to current user
                );
                insert doc;
                
                return webUrl;
            } else {
                throw new AuraHandledException('Upload failed with status: ' + res.getStatusCode() + ' - ' + res.getBody());
            }
        } catch(Exception e) {
            throw new AuraHandledException('Error uploading to SharePoint: ' + e.getMessage());
        }
    }
    
    // Get documents for a record
    @AuraEnabled(cacheable=true)
    public static List<DocumentWrapper> getDocuments(Id recordId, String folderPath) {
        List<SharePoint_Document__c> docs = [
            SELECT Id, Name, SharePoint_URL__c, ContentVersion_Id__c, CreatedDate
            FROM SharePoint_Document__c 
            WHERE Is_Current_Version__c = true
            ORDER BY CreatedDate DESC
            LIMIT 100
        ];
        
        List<DocumentWrapper> results = new List<DocumentWrapper>();
        for(SharePoint_Document__c doc : docs) {
            results.add(new DocumentWrapper(
                doc.Name,
                doc.SharePoint_URL__c,
                doc.ContentVersion_Id__c,
                doc.Id
            ));
        }
        return results;
    }
    
    // Delete document (from SharePoint and Salesforce)
    @AuraEnabled
    public static void deleteDocument(Id documentId) {
        try {
            SharePoint_Document__c doc = [
                SELECT Id, SharePoint_Id__c 
                FROM SharePoint_Document__c 
                WHERE Id = :documentId
                LIMIT 1
            ];
            
            // First delete from SharePoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint('callout:SharePoint_Named_Credential' + 
                          '/sites/SFTEST/drive/items/' + doc.SharePoint_Id__c);
            req.setMethod('DELETE');
            
            HttpResponse res = new Http().send(req);
            
            if(res.getStatusCode() == 204) {
                // Then delete from Salesforce
                delete doc;
            } else {
                throw new AuraHandledException('Delete failed with status: ' + res.getStatusCode());
            }
        } catch(Exception e) {
            throw new AuraHandledException('Error deleting document: ' + e.getMessage());
        }
    }
    
    // Wrapper class for document data
    public class DocumentWrapper {
        @AuraEnabled public String name;
        @AuraEnabled public String url;
        @AuraEnabled public String contentVersionId;
        @AuraEnabled public String documentId;
        
        public DocumentWrapper(String n, String u, String cvi, String di) {
            name = n;
            url = u;
            contentVersionId = cvi;
            documentId = di;
        }
    }
}