public class SharePointIntegration {
    public static final String POWER_AUTOMATE_URL = 'https://prod-xx.logic.azure.com:443/workflows/your-flow-id/triggers/manual/paths/invoke?...';

    @future(callout=true)
    public static void sendToPowerAutomate(List<Id> opportunityIds) {
        List<Opportunity> opportunities = [
            SELECT Id, Name FROM Opportunity WHERE Id IN :opportunityIds
        ];

        for (Opportunity opp : opportunities) {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(POWER_AUTOMATE_URL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');

            Map<String, Object> payload = new Map<String, Object>();
            payload.put('opportunityId', opp.Id);
            payload.put('opportunityName', opp.Name);

            req.setBody(JSON.serialize(payload));

            Http http = new Http();
            try {
                HttpResponse res = http.send(req);
                System.debug('Response: ' + res.getBody());
            } catch (Exception ex) {
                System.debug('Callout error: ' + ex.getMessage());
            }
        }
    }
}