import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import FILTER_CHANNEL from '@salesforce/messageChannel/PropertyFiltersChannel__c';

export default class PropertyFilters extends LightningElement {
    searchKey = '';
    maxPrice = 2000000;
    bedrooms = '0';
    bathrooms = '0';

    @wire(MessageContext)
    messageContext;

    get roomOptions() {
        return [
            { label: 'Cualquiera', value: '0' },
            { label: '1+', value: '1' },
            { label: '2+', value: '2' },
            { label: '3+', value: '3' },
            { label: '4+', value: '4' }
        ];
    }

    handleSearchKeyChange(event) {
        this.searchKey = event.target.value;
        this.publishFilterChange();
    }

    handlePriceChange(event) {
        this.maxPrice = event.target.value;
        this.publishFilterChange();
    }

    handleBedroomsChange(event) {
        this.bedrooms = event.target.value;
        this.publishFilterChange();
    }

    handleBathroomsChange(event) {
        this.bathrooms = event.target.value;
        this.publishFilterChange();
    }

    publishFilterChange() {
        const payload = {
            searchKey: this.searchKey,
            maxPrice: Number(this.maxPrice),
            bedrooms: Number(this.bedrooms),
            bathrooms: Number(this.bathrooms)
        };
        // Post the message in the channel
        publish(this.messageContext, FILTER_CHANNEL, payload);
    }
}