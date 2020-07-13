___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.


___INFO___

{
  "type": "TAG",
  "id": "cvt_temp_public_id",
  "version": 1,
  "securityGroups": [],
  "displayName": "ChannelAdvisor Sales Tracking",
  "brand": {
    "id": "brand_dummy",
    "displayName": "Custom Template"
  },
  "description": "Tracks a click from a WTB widget and captures the sale",
  "containerContexts": [
    "WEB"
  ]
}


___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "AccessToken",
    "displayName": "Access Token",
    "simpleValueType": true,
    "alwaysInSummary": true,
    "help": "Enter the ChannelAdvisor access token"
  },
  {
    "type": "SELECT",
    "name": "EventAction",
    "displayName": "Event Action",
    "macrosInSelect": false,
    "selectItems": [
      {
        "value": "pageclick",
        "displayValue": "Page Click"
      },
      {
        "value": "salecapture",
        "displayValue": "Sale Capture"
      }
    ],
    "simpleValueType": true
  }
]


___SANDBOXED_JS_FOR_WEB_TEMPLATE___

const log = require ("logToConsole");

log('data =', data);

switch(data.EventAction)
{
    /*=============================================
    ============== PAGE CLICK EVENT =============
    =============================================*/
  	case "pageclick":
      const getQueryParameters = require("getQueryParameters");
      const setCookie = require('setCookie');
      var wtbClick = getQueryParameters("_refv", false);

      if(wtbClick != null)
      {
        log("Setting cookie called 'wtbclickref' with value '"+wtbClick+"'");
        const options = {
          'max-age': 2592000 * 1000,
        };
        setCookie("wtbclickref", wtbClick, options);
      }
      else
        log("URL did not contain a click ref");
    
    
    break;
    /*=============================================
    =========== CHECKOUT SALE CAPTURE ===========
    =============================================*/
  	case "salecapture":
    	var accessToken = data.AccessToken;
    	var validationErrors = "";
    	const getCookieValues = require("getCookieValues");
      	var clickref = getCookieValues("wtbclickref");
    	if(clickref != "") 
        {
          log("Clickref found: " + clickref);
        }
    	else{
          validationErrors += "2,";
          log("Unable to find 'wtbclickref' cookie.");
        }
    
        const copyDL = require('copyFromDataLayer');
        const orderid = copyDL("orderid");
        
    	
    	var requestInformation = "?s.cr=" + clickref+ "&s.oi=" + orderid;
    
    	//--- Set Tags Start ---
        const tags = copyDL("tags");
    	if(tags != null && tags.length != 0)
        {
           for(var i = 0; i < tags.length; i++)
           {
             requestInformation += "&s.tags["+i+"]=" + tags[i];
           }
        }
   	 	//--- Set Tags End ---
    	
        //--- Set Products Start ---
        const productdata = copyDL("products");
        log('Products =', productdata);
    	if(productdata != null && productdata.length != 0)
        {        
            for(var i = 0; i < productdata.length; i++)
            {
              requestInformation +=  "&s.p["+ i +"].s=" + productdata[i].sku;
              requestInformation +=  "&s.p["+ i +"].up=" + productdata[i].price;
              requestInformation +=  "&s.p["+ i +"].q=" + productdata[i].quantity;
              requestInformation +=  "&s.p["+ i +"].BName=" + productdata[i].brandname;
              //requestInformation +=  "&s.p["+ i +"].PName=" + productdata[i].name;
              if(productdata[i].ean != null && productdata[i].ean.length != 0)
                requestInformation +=  "&s.p["+ i +"].e=" + productdata[i].ean;
              if(productdata[i].upc != null && productdata[i].upc.length != 0)
                requestInformation +=  "&s.p["+ i +"].u=" + productdata[i].upc;
              if(productdata[i].gtin != null && productdata[i].gtin.length != 0)
                requestInformation +=  "&s.p["+ i +"].g=" + productdata[i].gtin;
              if(productdata[i].mpn != null && productdata[i].mpn.length != 0)
                requestInformation +=  "&s.p["+ i +"].m=" + productdata[i].mpn;
            }
          }
          else{
            validationErrors += "1,";
            log("Product data could not be found in the data layer. Unable to send request to strack."); 
          }
       	  //--- Set Products End ---
          
          const sendPixel = require('sendPixel'); //sends a get request
          const encodeUriComponent = require('encodeUriComponent');
         
          var url = 'https://strack.where-to-buy.co/api/v1/gtm/recordSale/' + encodeUriComponent(requestInformation + "&s.at="+accessToken);
          log("Sending GET request to - " + url); 
          sendPixel(url);
    
    break;
}

data.gtmOnSuccess();


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "set_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedCookies",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 3,
                "mapKey": [
                  {
                    "type": 1,
                    "string": "name"
                  },
                  {
                    "type": 1,
                    "string": "domain"
                  },
                  {
                    "type": 1,
                    "string": "path"
                  },
                  {
                    "type": 1,
                    "string": "secure"
                  },
                  {
                    "type": 1,
                    "string": "session"
                  }
                ],
                "mapValue": [
                  {
                    "type": 1,
                    "string": "wtbclickref"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "*"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  },
                  {
                    "type": 1,
                    "string": "any"
                  }
                ]
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "queryKeys",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "_refv"
              }
            ]
          }
        },
        {
          "key": "query",
          "value": {
            "type": 8,
            "boolean": true
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "wtbclickref"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "send_pixel",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://strack.where-to-buy.co/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "products"
              },
              {
                "type": 1,
                "string": "orderid"
              },
              {
                "type": 1,
                "string": "tags"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  }
]


___TESTS___

scenarios:
- name: Capture Cookie - Cookie is set from URL click
  code: "const logToConsole = require (\"logToConsole\");\n\nmock('getQueryParameters',\
    \ (key, multi) => {\n  if(key == \"_refv\")\n    return \"12345\";  \n});\n\n\
    mock('setCookie', (name, value, options) => {\n  if (value !== '12345') {\n  \
    \  fail('setCookie not called with the correct URL argyment \"'+value+'\"');\n\
    \  }\n  else{\n  \tlogToConsole(\"Created cookie called '\"+name+\"' with value\
    \ '\" + value + \"'\");\n  }\n});\n\nconst mockData = {\n  EventAction: \"pageclick\"\
    ,\n  AccessToken:\"token123\"\n};\n\nrunCode(mockData);\n\nassertApi('setCookie').wasCalled();\n\
    \n// Verify that the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: Missing Clickref - Cookies is not set becasue no url clickref exists
  code: |-
    const mockData = {
      EventAction: "pageclick",
      AccessToken:"1nIObu+inT1c5isuTjlfZDX+XUG3y+7vxM/SKgP9HLejq9JMGyGisj2ys54q2SzhK1/SfoQLGrskB5F86cGF8g+G7J+hAFDOonlkBkoV+q8="
    };

    runCode(mockData);
    assertApi('setCookie').wasNotCalled();
    assertApi('gtmOnSuccess').wasCalled();
- name: Basic Checkout - Checkout Products are sent to API
  code: "const log = require (\"logToConsole\");\n\nconst mockData = {\n  EventAction:\
    \ \"salecapture\",\n  AccessToken:\"1nIObu+inT1c5isuTjlfZDX+XUG3y+7vxM/SKgP9HLejq9JMGyGisj2ys54q2SzhK1/SfoQLGrskB5F86cGF8g+G7J+hAFDOonlkBkoV+q8=\"\
    \n};\n\nmock('getCookieValues', (key) => {\n  if(key == \"wtbclickref\")\n   \
    \ return \"gtm-test-12345\";  \n});\n\nmock('copyFromDataLayer', (key) => {\n\
    \  if(key == \"products\")\n    return [\n    \t{productId: 1, price: 5.33, quantity:\
    \ 5, brandname: \"brand 1\", name: \"product 1\", ean: \"123\", upc: \"123\",\
    \ sku: \"123\"},\n    \t{productId: 2, price: 3.55, quantity: 3, brandname: \"\
    brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n  \t\
    ];\n  if(key == \"orderid\")\n    return \"12345\";\n});\n\n// Call runCode to\
    \ run the template's code.\nrunCode(mockData);\nassertApi('sendPixel').wasCalled();\n\
    // Verify that the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: Missing Products - Should trigger API validation error in WTB logs
  code: "const mockData = {\n  EventAction: \"salecapture\",\n  AccessToken:\"token123\"\
    \n};\n\nmock('getCookieValues', (key) => {\n  if(key == \"wtbclickref\")\n   \
    \ return \"12345\";  \n});\n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    assertApi('sendPixel').wasCalled();\n// Verify that the tag finished successfully.\n\
    assertApi('gtmOnSuccess').wasCalled();"
- name: Large Cart - Shopping Cart With 50 Items
  code: "const log = require (\"logToConsole\");\n\nconst mockData = {\n  EventAction:\
    \ \"salecapture\",\n  AccessToken:\"1nIObu+inT1c5isuTjlfZDX+XUG3y+7vxM/SKgP9HLejq9JMGyGisj2ys54q2SzhK1/SfoQLGrskB5F86cGF8g+G7J+hAFDOonlkBkoV+q8=\"\
    \n};\n\nmock('getCookieValues', (key) => {\n  if(key == \"wtbclickref\")\n   \
    \ return \"gtm-test-50-items\";  \n});\n\nmock('copyFromDataLayer', (key) => {\n\
    \  if(key == \"products\")\n    return [\n\t{productId: 1, price: 5.33, quantity:\
    \ 5, brandname: \"brand 1\", name: \"product 1 extra long description for testing\"\
    , ean: \"123\", upc: \"123\", sku: \"123\"},\n\t{productId: 2, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 3, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 4, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra\
    \ long description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t\
    {productId: 5, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 6, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 7, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 8, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 9, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long description\
    \ for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 10,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean:\
    \ \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 11, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 12, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 13, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra\
    \ long description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t\
    {productId: 14, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 15, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 16, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 17, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 18, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long description\
    \ for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 19,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean:\
    \ \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 20, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 21, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 22, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean:\
    \ \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 23, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 24, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 25, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean:\
    \ \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 26, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 27, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 extra long description for testing\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 28, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 29, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 30, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 31, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 32, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 33, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long description\
    \ for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 342,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long\
    \ description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 352, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\",\
    \ ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 362, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 372, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 extra long description for testing\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 382, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 392, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"\
    product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 402, price:\
    \ 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\"\
    , upc: \"321\", sku:\"321\"},\n\t{productId: 412, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 422, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"\
    product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 432, price:\
    \ 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long description\
    \ for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 442,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean:\
    \ \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 452, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 462, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 472, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra\
    \ long description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t\
    {productId: 482, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 492, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long description\
    \ for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 50,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long\
    \ description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"}\n];\n  if(key\
    \ == \"orderid\")\n    return \"12345\";\n});\n\n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\nassertApi('sendPixel').wasCalled();\n// Verify that\
    \ the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: Bloated Products - Extra Long Request URL
  code: "const log = require (\"logToConsole\");\n\nconst mockData = {\n  EventAction:\
    \ \"salecapture\",\n  AccessToken:\"1nIObu+inT1c5isuTjlfZDX+XUG3y+7vxM/SKgP9HLejq9JMGyGisj2ys54q2SzhK1/SfoQLGrskB5F86cGF8g+G7J+hAFDOonlkBkoV+q8=\"\
    \n};\n\nmock('getCookieValues', (key) => {\n  if(key == \"wtbclickref\")\n   \
    \ return \"gtm-test-50-items\";  \n});\n\nmock('copyFromDataLayer', (key) => {\n\
    \  if(key == \"products\")\n    return [\n\t{productId: 1, price: 5.33, quantity:\
    \ 5, brandname: \"brand 1\", name: \"product 1 extra long description for testing.product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"123\", upc: \"123\", sku: \"123\"},\n\t{productId: 2, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated. product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.\", ean: \"321\", upc: \"321\"\
    , sku:\"321\"},\n\t{productId: 3, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 4,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra long\
    \ description for testing. product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 5,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 6, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.\", ean: \"321\", upc: \"321\"\
    , sku:\"321\"},\n\t{productId: 7, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 8,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 9, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 extra long description for testing.\
    \ product description that is very long which could potentially cause issues with\
    \ the length of the url when the request with all of the products is generated.product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 10, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.\", ean: \"321\", upc: \"321\"\
    , sku:\"321\"},\n\t{productId: 11, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated. product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 12,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated. product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 13, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 extra long description for testing.\
    \ product description that is very long which could potentially cause issues with\
    \ the length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 14, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated. product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.\", ean: \"321\", upc: \"321\"\
    , sku:\"321\"},\n\t{productId: 15, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated. product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 16,\
    \ price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated. product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.product\
    \ description that is very long which could potentially cause issues with the\
    \ length of the url when the request with all of the products is generated.\"\
    , ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 17, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2 product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated. product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.product description that is very\
    \ long which could potentially cause issues with the length of the url when the\
    \ request with all of the products is generated.\", ean: \"321\", upc: \"321\"\
    , sku:\"321\"},\n\t{productId: 18, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2 product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated. product description that is very long which could potentially\
    \ cause issues with the length of the url when the request with all of the products\
    \ is generated.product description that is very long which could potentially cause\
    \ issues with the length of the url when the request with all of the products\
    \ is generated.\", ean: \"321\", upc: \"321\", sku:\"321\"}\n      ];\n  if(key\
    \ == \"orderid\")\n    return \"12345\";\n});\n\n// Call runCode to run the template's\
    \ code.\nrunCode(mockData);\nassertApi('sendPixel').wasCalled();\n// Verify that\
    \ the tag finished successfully.\nassertApi('gtmOnSuccess').wasCalled();"
- name: Medium Cart - 25 Items
  code: "const log = require (\"logToConsole\");\n\nconst mockData = {\n  EventAction:\
    \ \"salecapture\",\n  AccessToken:\"1nIObu+inT1c5isuTjlfZDX+XUG3y+7vxM/SKgP9HLejq9JMGyGisj2ys54q2SzhK1/SfoQLGrskB5F86cGF8g+G7J+hAFDOonlkBkoV+q8=\"\
    \n};\n\nmock('getCookieValues', (key) => {\n  if(key == \"wtbclickref\")\n   \
    \ return \"gtm-test-50-items\";  \n});\n\nmock('copyFromDataLayer', (key) => {\n\
    \  if(key == \"products\")\n    return [\n\t{productId: 1, price: 5.33, quantity:\
    \ 5, brandname: \"brand 1\", name: \"product 1 extra long description for testing\"\
    , ean: \"123\", upc: \"123\", sku: \"123\"},\n\t{productId: 2, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 3, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 4, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra\
    \ long description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t\
    {productId: 5, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 6, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 7, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 8, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},{productId: 1, price: 5.33, quantity:\
    \ 5, brandname: \"brand 1\", name: \"product 1 extra long description for testing\"\
    , ean: \"123\", upc: \"123\", sku: \"123\"},\n\t{productId: 2, price: 3.55, quantity:\
    \ 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\",\
    \ sku:\"321\"},\n\t{productId: 3, price: 3.55, quantity: 3, brandname: \"brand\
    \ 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId:\
    \ 4, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2 extra\
    \ long description for testing\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t\
    {productId: 5, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 6, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 7, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 8, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n    {productId: 5, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n\t{productId: 6, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 7, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 8, price: 3.55,\
    \ quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\", upc:\
    \ \"321\", sku:\"321\"},\n     {productId: 8, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \    {productId: 5, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"\
    product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\t{productId: 6, price:\
    \ 3.55, quantity: 3, brandname: \"brand 1\", name: \"product 2\", ean: \"321\"\
    , upc: \"321\", sku:\"321\"},\n\t{productId: 7, price: 3.55, quantity: 3, brandname:\
    \ \"brand 1\", name: \"product 2\", ean: \"321\", upc: \"321\", sku:\"321\"},\n\
    \t{productId: 8, price: 3.55, quantity: 3, brandname: \"brand 1\", name: \"product\
    \ 2\", ean: \"321\", upc: \"321\", sku:\"321\"}\n];\n  if(key == \"orderid\")\n\
    \    return \"12345\";\n});\n\n// Call runCode to run the template's code.\nrunCode(mockData);\n\
    assertApi('sendPixel').wasCalled();\n// Verify that the tag finished successfully.\n\
    assertApi('gtmOnSuccess').wasCalled();"


___NOTES___

Created on 3/27/2020, 10:30:13 AM


