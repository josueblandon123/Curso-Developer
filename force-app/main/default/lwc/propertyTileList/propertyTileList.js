import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, MessageContext } from 'lightning/messageService';
import FILTER_CHANNEL from '@salesforce/messageChannel/PropertyFiltersChannel__c';
import getFilteredProperties from '@salesforce/apex/PropertyController.getFilteredProperties';

export default class PropertyTileList extends LightningElement {
    searchKey = '';
    maxPrice = 0;
    bedrooms = 0;
    bathrooms = 0;
    pageSize = 6;
    pageNumber = 1;

    subscription = null;

    @wire(MessageContext)
    messageContext;

    @wire(getFilteredProperties, {
        searchKey: '$searchKey',
        maxPrice: '$maxPrice',
        bedrooms: '$bedrooms',
        bathrooms: '$bathrooms',
        pageSize: '$pageSize',
        pageNumber: '$pageNumber'
    })
    pagedProperties;

    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                FILTER_CHANNEL,
                (message) => this.handleFilterChange(message)
            );
        }
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleFilterChange(message) {
        this.searchKey = message.searchKey;
        this.maxPrice = message.maxPrice;
        this.bedrooms = message.bedrooms;
        this.bathrooms = message.bathrooms;
        this.pageNumber = 1; // Reset to the first page with each new filter
    }

    // Reactive Getters
    get properties() {
        return this.pagedProperties.data?.records || [];
    }

    get totalItemCount() {
        return this.pagedProperties.data?.totalItemCount || 0;
    }

    get totalPages() {
        return this.pagedProperties.data?.totalPages || 1;
    }

    get hasProperties() {
        return this.properties.length > 0;
    }

    get isListEmpty() {
        return !this.isLoading && this.properties.length === 0;
    }

    get isLoading() {
        return !this.pagedProperties.data && !this.pagedProperties.error;
    }

    get isFirstPage() {
        return this.pageNumber <= 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    handlePrevious() {
        if (this.pageNumber > 1) {
            this.pageNumber -= 1;
        }
    }

    handleNext() {
        if (this.pageNumber < this.totalPages) {
            this.pageNumber += 1;
        }
    }

    handlePropertySelect(event) {
        const propertyId = event.detail;
        console.log('Propiedad seleccionada ID:', propertyId);
    }
}