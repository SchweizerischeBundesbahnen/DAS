## Deep Link DAS Client

### Purpose

The purpose of this page is to define the interface for deep links parsed by the DAS mobile client in order for other
applications to deep link to the client.

### Technological Background

The DAS mobile client is implemented using the Cross Platform Framework Flutter. Deep linking when targeting Android and
iOS platforms can be done in multiple ways, e.g.:

1. using [app links](https://developer.android.com/training/app-links)
   and [universal links](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content)
   respectively. Both of them follow the http / https schema and require a web domain to verify ownership. For specific
   setup of the verification process, check out the links provided before or the Flutter setup links for Android and
   iOS.
2. using [web links](https://developer.android.com/training/app-links#web-links)
   and [URL scheme](https://developer.apple.com/documentation/xcode/defining-a-custom-url-scheme-for-your-app)
   respectively. They do not need to be verified.

### DeepLink Schema Specificatio

##### Versioning

The versioning follows a semantic versioning scheme with v1 / v2 etc. prepended of the path.

##### Authority

We use one authority for all flavors, as they can be distinguished in the path. The authority is
driveradvisorysystem.sbb.ch.
The distinguished flavors (variants) are: dev, inte, prod.

#### Final Scheme

The (http) schemes that resolve from the above points are:

| Flavor (Variant) | Version | Authority                   | Scheme                                                 |
|------------------|---------|-----------------------------|--------------------------------------------------------|
| DEV              | v1      | driveradvisorysystem.sbb.ch | https://driveradvisorysystem.sbb.ch/dev/v1/PATH+QUERY  |
| INTE             | v1      | driveradvisorysystem.sbb.ch | https://driveradvisorysystem.sbb.ch/inte/v1/PATH+QUERY |
| PROD             | v1      | driveradvisorysystem.sbb.ch | https://driveradvisorysystem.sbb.ch/prod/v1/PATH+QUERY |

#### Path And Query Parameters

Opening up https://driveradvisorysystem.sbb.ch/dev/v1/ on a device with DAS installed will simply open up the (DEV) app
on the home screen (currently the train selection screen). To make use of deep linking and open up direct train journeys
on the device, one needs to add at least the following path and query parameters.

| Route (Page)            | MUST Params                                                                                                                     | RECOMMENDED Params                                                                                                                                                                                                                                                                                                                      |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Train Journey           | /trainJourney?trainNumber=123456789,<br>(might not be able to find an exact train journey and display error / selection screen) | /trainJourney?trainNumber=123456789&companyCode=1285&journeyDate=1970-01-31                                                                                                                                                                                                                                                             |
| Multiple Train Journeys | /trainJourneys?data={[{"trainNumber":"123456789"}]} (or as above)                                                               | /trainJourneys?data={[<br>{"trainNumber":"123456789", "companyCode"="1285", "journeyDate":"1970-01-31", "startServicePoint":"IDENTIFIERA", "endServicePoint":"IDENTIFIERB"},<br>{"trainNumber":"987654321", "companyCode"="2185", "journeyDate":"1970-01-31", "startServicePoint":"IDENTIFIERC", "endServicePoint":"IDENTIFIERD"}<br>]} |

### Testing during development

Testing the deeplinks can be done via the [DeepLink Validator](https://docs.flutter.dev/tools/devtools/deep-links)
shipped with Flutter Dev Tools.