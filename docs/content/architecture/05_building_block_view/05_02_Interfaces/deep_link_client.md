## Deep Link DAS-Client

### Purpose

The purpose of this page is to define the interface for deep links parsed by the **DAS-Client (mobile App)** in order **for other
applications to deep link to the client**.

### Technological Background

The DAS-Client is implemented using the Cross Platform Framework Flutter. Deep linking when targeting Android and
iOS are implemented using [app links] and [universal links] respectively. Both of them follow the http / https schema
and require a web domain to verify ownership. For specific setup of the verification process, check out the links
provided before or the [Flutter setup links] for Android and iOS.

### Deep Link Schema Specification

#### Versioning

The versioning follows a semantic versioning scheme with v1 / v2 etc. prepended of the path.

#### Authority

We use one authority for all flavors, as they can be distinguished in the path. The authority is
driveradvisorysystem.sbb.ch. This name may still change due to a project renaming in the near future, please make sure
to use the latest one when implementing deep linking to DAS.

#### Flavors

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
on the device, one needs to add at least the following path and query parameters. These are derived from specification [SFERA UIC IRS 90940 Ed.2](https://uic.org/events/uic-irs-90940-edition-2-sfera-protocol).

| Route (Page)  | MUST Params                                                                  | RECOMMENDED Params                                                                                                                                                                                                                                                                                                                                                            |
|---------------|------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Train Journey | /train-journey?data={[{"operationalTrainNumber":"123456789"}]} (or as above) | /train-journey?data={[<br>{"operationalTrainNumber":"123456789", "company"="1285", "startDate":"1970-01-31", "tafTapLocationReferenceStart":"CH04128", "tafTapLocationReferenceEnd":"CH07000"},<br>{"operationalTrainNumber":"987654321", "company"="2185", "startDate":"1970-01-31", "tafTapLocationReferenceStart":"CH00218", "tafTapLocationReferenceEnd":"CH03000"}<br>]} |

Remarks about parameter-values (derived from [SFERA xsd](../../../../../sfera_mock/src/main/resources/SFERA_v3.00.xsd) copy):
* `[]`: The list allows passing a whole tour [1..*] of the very same train driver.
* `operationalTrainNumber`: Source NeTS-FPS, which represents an operational train-number (for e.g. as in "IC 1 **625**"). In the near future 2031 this may change with TMS::CM1. 
* `tafTapLocationReferenceStart/End`: Represents operational stop-points (de:Betriebspunkte), considered by a Digital-driving-order (de:Fahrordnung) and consists of an ISO Country Code (ISO 3166-1) and the primary location code (the format within this specification is proprietary and derived from the underlying SFERA service-contract, for e.g. Bern "CH07000").
* `company`: As defined by [RICS company code](https://uic.org/support-activities/it/rics), for e.g. BLS P "1163", BLS C "3356".
* `startDate`: SFERA focuses on the day when the Digital-driving-order begins (must not be misunderstood as operationDay of the vehicle-journey).

### Testing during development

Testing the Deep Links can be done via the [Deep Link Validator](https://docs.flutter.dev/tools/devtools/deep-links)
shipped with Flutter Dev Tools.


[app links]: https://developer.android.com/training/app-links

[universal links]: https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content

[Flutter setup links]: https://docs.flutter.dev/ui/navigation/deep-linking
