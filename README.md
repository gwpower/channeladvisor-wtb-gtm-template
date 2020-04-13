This tag will enable sales tracking through the Where To Buy network. When users click a retailer store on a Where To Buy widget, they will be redirected to the website. This tag will capture the click reference ID. When a user makes a sale, this data will be sent back to ChannelAdvisor and linked with the initial click. 

This tag does not capture any personally identifiable information from the end user. The sales checkout will capture information about the products purchased, including the order number. It does not capture delivery addresses or any information relating to the person making the purchase.

## Setting Up Data Layer

In order to capture shopping cart information, information needs to be added to the data layer on the checkout complete page of any website using this tag. The data layer variables need to be formatted as follows. 

**Please provide one or more product identifier. This includes EAN, GTIN, MPN or UPC. If you have more than one of these available, please provide them.**

```javascript
dataLayer.push({
	"products": [
		{
			"price":<unitPrice>,
			"quantity":<quantity>,
			"brandname":<brandname>,
			"ean":<productEan>, 
			"mpn":<productMpn>,
			"gtin":<productGtin>,
			"upc":<productUpc>,
			"sku":<productSku>
		}
	],
	"orderid": <orderiId>,
	"tags": [<]tag1>...<tagn>]
});
```

1. products is a list in itself, meanung that every single product (line item) purchased in a sale will be sent through as an item in the list of products with their corresponding fields.
2. one of these identifiers is mandatory: EAN, GTIN, MPN or UPC (1 of these identifiers must be provided. More than one is also ok if possible).
3. price is a mandatory field. It corresponds to the unit price of the product (the line item).
4. quantity is a mandatory field. The amount of products purchased (for the line item).
5. brandName is a mandatory field. As its own name indicates, the product brand name as such.
6. orderId is a mandatory field. It corresponds to the transaction/sale ID at the retailer side (The order id as such at the retailer side).
7. tags is an optional field. It corresponds to any tags that the retailer might send with the products (so called retailer tags).