import { LightningElement, track } from 'lwc';
import getShippingRates from '@salesforce/apex/ShippingRateController.getShippingRates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ShippingRateCalculator extends LightningElement {
    @track originZipCode = '';
    @track destinationZipCode = '';
    @track weightOfPacket = '';

    @track rates;

    handleOriginAddressZipChange(event) {
        this.originZipCode = event.target.value;
    }

    handleDestinationAddressZipChange(event) {
        this.destinationZipCode = event.target.value;
    }

    handleWeightChange(event) {
        this.weightOfPacket = event.target.value;
    }

    getShippingRates() {
        if(this.originZipCode == '' || this.destinationZipCode ==''){
                const event = new ShowToastEvent({
                    title: 'Error !!!',
                    message: 'Please Enter origin/Destination Zip code',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            
        }
        else{
        getShippingRates({ originZipCode: this.originZipCode, destinationZipCode: this.destinationZipCode, weight: this.weightOfPacket })
            .then(result => {
               console.log('@@@@@ '+result);

                if(result.length >0 &&result.length ==1 &&result[0].error != ''){
                    const event = new ShowToastEvent({
                        title: 'Error !!!',
                        message: error,
                        variant: 'error',
                        mode: 'sticky'
                    });
                }
                else{
                    const event = new ShowToastEvent({
                        title: 'Success !!!',
                        message: 'Call out was success',
                        variant: 'Success',
                        mode: 'sticky'
                    });
                 this.rates = result;
                }
            })
            .catch(error => {
                console.log('@@@@@ '+error);
                console.error(error);
                const event = new ShowToastEvent({
                    title: 'Error !!!',
                    message: 'An Error occured',
                    variant: 'error',
                    mode: 'sticky'
                });
                this.dispatchEvent(event);
            });
        }
    }
}