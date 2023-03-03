public with sharing class ShippingRateController {
    @AuraEnabled(cacheable=true)
    public static List<ShippingRate> getShippingRates(String originZipCode, String destinationZipCode, String weight) {
        
        system.debug('****** 1 '+originZipCode.isNumeric());
        system.debug('****** 2 '+destinationZipCode.isNumeric());
        system.debug('****** 3 '+weight.isNumeric());
        String token = getAccessToken();
        ResponseShipmentWrapper response;
        
        if(!token.containsIgnoreCase('Error')){
        //Step 2 hit the rates API
        response = getFedexRates(token, Integer.valueof(originZipCode), Integer.valueof(destinationZipCode), Integer.valueof(weight));
        }
        
        List<ShippingRate> rates = new List<ShippingRate>();
        if(response.error == null){
        // Call FedEx Rates API here and parse response to create ShippingRate objects
        System.debug('***** '+response);
        rates.add(new ShippingRate(response.output.rateReplyDetails[0].serviceType, response.output.rateReplyDetails[0].ratedShipmentDetails[0].totalNetCharge,''));
        rates.add(new ShippingRate(response.output.rateReplyDetails[0].serviceType, response.output.rateReplyDetails[0].ratedShipmentDetails[0].totalNetCharge,''));
        rates.add(new ShippingRate(response.output.rateReplyDetails[0].serviceType, response.output.rateReplyDetails[0].ratedShipmentDetails[0].totalNetCharge,''));
        }
        else{
          rates.add(new ShippingRate('', null,response.error));  
        }
        
        system.debug('&&&&&&& '+rates);
        return rates;
    }
    
    public static string getAccessToken(){
        
        String endpoint = label.Fedex_end_point+ '/oauth/token';
        String clientId = label.Fedex_client_ID ;
        String clientSecret = label.Client_Secret ;
        String grantType = 'client_credentials';
        String scope = '[your-scope]';
        
        String requestBody = 'grant_type='+grantType+'&client_id='+clientId+'&client_secret='+clientSecret;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        //req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(clientId + ':' + clientSecret)));
        req.setBody(requestBody);
        
        Http http = new Http();
        HTTPResponse res = http.send(req);
        
        String accessToken = '';
        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            accessToken = (String)responseMap.get('access_token');
            return accessToken;
        }else if(res.getStatusCode() == 401){
            //Error Handling
            return 'Error  Unauthorized';
        }
        else if(res.getStatusCode() == 500){
            //Error Handling
            return 'Error  Reach out to admin';
        }
        else if(res.getStatusCode() == 503){
            //Error Handling
            return 'Error  Service unavailable';
        }
        
        return accessToken;
    }
    
    public static ResponseShipmentWrapper getFedexRates(String accessToken, Integer originZip, Integer destinationZip, Integer weight){
        String endpoint = label.Fedex_end_point+'/rate/v1/rates/quotes';
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        req.setHeader('Content-Type', 'application/json');
        
        RequestShipmentWrapper requestBody = new RequestShipmentWrapper();
        
        requestBody.accountNumber = new RequestShipmentWrapper.AccountNumber();
        requestBody.requestedShipment = new RequestShipmentWrapper.RequestedShipment();
        requestBody.requestedShipment.shipper = new RequestShipmentWrapper.Shipper();
        requestBody.requestedShipment.shipper.address = new RequestShipmentWrapper.Address();
        requestBody.requestedShipment.recipient = new RequestShipmentWrapper.Shipper();
        requestBody.requestedShipment.recipient.address = new RequestShipmentWrapper.Address();
        requestBody.accountNumber.value = '740561073';
        requestBody.requestedShipment.shipper.address.postalCode = originZip;
        requestBody.requestedShipment.shipper.address.countryCode = 'us';
        requestBody.requestedShipment.recipient.address.postalCode = destinationZip;
        requestBody.requestedShipment.recipient.address.countryCode = 'us';
        requestBody.requestedShipment.pickupType = 'DROPOFF_AT_FEDEX_LOCATION'; 
        requestBody.requestedShipment.rateRequestType = new list<String>{'ACCOUNT','LIST' };
            
           RequestShipmentWrapper.Weight w = new  RequestShipmentWrapper.Weight();
        w.units = 'LB';
        w.value = weight;
        RequestShipmentWrapper.RequestedPackageLineItems rpl= new RequestShipmentWrapper.RequestedPackageLineItems();
        rpl.Weight = w;
        
        requestBody.requestedShipment.requestedPackageLineItems = new list<RequestShipmentWrapper.RequestedPackageLineItems>{rpl};
        req.setBody(JSON.serialize(requestBody));
        System.debug('@@@@@ 1'+JSON.serialize(requestBody));
        Http http = new Http();
        HTTPResponse res = http.send(req);
        ResponseShipmentWrapper response = new ResponseShipmentWrapper();
        if (res.getStatusCode() == 200) {
            // Process the response data as needed
            system.debug('@@@@@ 3 '+res.getBody());
           // Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
             //system.debug('@@@@@ 3 '+(String)responseMap.get('output'));
             response = (ResponseShipmentWrapper)JSON.deserialize(res.getBody(),  ResponseShipmentWrapper.class);
            system.debug('@@@@@ 4 '+response);
        return response;
        }
        else if(res.getStatusCode() == 400){
            //Error Handling
            response.error = 'Error  Bad Request';
            return response;
        }else if(res.getStatusCode() == 401){
            //Error Handling
            response.error = 'Error  unauthorized';
            return response;
        }
        else if(res.getStatusCode() == 500){
            //Error Handling
            response.error = 'Error  failure';
            return response;
        }
        else if(res.getStatusCode() == 503){
            //Error Handling
            response.error = 'Error  service unavailable';
            return response;
        }
        return response;
    }
    
    
    public class ShippingRate {
        @AuraEnabled public String service { get; set; }
        @AuraEnabled public Decimal rate { get; set; }
        @AuraEnabled public string error { get; set; }
        
        public ShippingRate(String service, Decimal rate, string error) {
            this.service = service;
            this.rate = rate;
            this.error = error;
        }
    }
}