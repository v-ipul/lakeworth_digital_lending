public with sharing class SharePointFileController {

    @AuraEnabled(cacheable=true)
public static List<FileMetadata> getSharePointFiles() {
    String endpoint = '/sites/atmanconsultant.sharepoint.com:/sites/SFTEST:/drive/root:/SalesforceDrive:/children';
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint('callout:SharePoint_Named_Credential' + endpoint);
    req.setMethod('GET');
    req.setHeader('Accept', 'application/json');

    Http http = new Http();
    HttpResponse res = http.send(req);

    List<FileMetadata> files = new List<FileMetadata>();
    if (res.getStatusCode() == 200) {
        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> values = (List<Object>) result.get('value');
        for (Object item : values) {
            Map<String, Object> file = (Map<String, Object>) item;
            files.add(new FileMetadata(
                (String) file.get('id'),
                (String) file.get('name')
            ));
        }
    } else {
        System.debug('Error from SharePoint: ' + res.getBody());
    }
    return files;
}

    @AuraEnabled
    public static void uploadSharePointFile(String fileId, Id recordId) {
        String endpoint = '/sites/atmanconsultant.sharepoint.com:/sites/SFTEST:/drive/root:/SalesforceDrive:/children';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SharePoint_Named_Credential' + endpoint);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/octet-stream');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Blob fileBlob = res.getBodyAsBlob();
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Uploaded from SharePoint';
            cv.PathOnClient = 'SharePointFile';
            cv.VersionData = fileBlob;
            insert cv;

            Id contentDocId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDocId;
            cdl.LinkedEntityId = recordId;
            cdl.ShareType = 'V';
            insert cdl;
        } else {
            throw new AuraHandledException('Failed to download file from SharePoint');
        }
    }

    public class FileMetadata {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        public FileMetadata(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }
}