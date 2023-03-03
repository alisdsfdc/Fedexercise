public class RequestShipmentWrapper {
    public AccountNumber accountNumber{ get; set; }
    public RequestedShipment requestedShipment{ get; set; }
    
    public class Address {
        public Integer postalCode{ get; set; }
        public String countryCode{ get; set; }
    }
    
    public class Shipper {
        public Address address{ get; set; }
    }
    
    public class RequestedPackageLineItems {
        public Weight weight{ get; set; }
    }
    
    public class RequestedShipment {
        public Shipper shipper{ get; set; }
        public Shipper recipient{ get; set; }
        public String pickupType{ get; set; }
        public List<String> rateRequestType{ get; set; }
        public List<RequestedPackageLineItems> requestedPackageLineItems{ get; set; }
    }
    
    public class Weight {
        public String units{ get; set; }
        public Integer value{ get; set; }
    }
    
    public class AccountNumber {
        public String value{ get; set; }
    }
}