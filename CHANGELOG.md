# Changelog

## v1.0.1 (2014-02-09)

### Bug fixes

* Account for SOAP header when parsing messages

## v1.0.0 (2014-10-27)

### Features

* Update WSDLs and behavior to ws-ISBM 1.0 specification including support for UsernameTokens, XPath filter expressions, RemovePublication and ExpireRequest operations and expiry parameter for PostRequest
* Allow for single topic string to be passed in addition to a topic array

### Bug fixes

* When parsing responses, don't replace default namespace if it already exists
* Ensure a topic string is present when a topic array is passed

### Misc

* Explicitly add Akami as a dependent gem

## v1.0.rc8.7 (2014-04-14)

* Fix error with default options not being set
* Replace "nil/empty" with "blank" for better readability
* Message content is now a Nokogiri document rather than element to allow schema validation

## v1.0.rc8.6 (2013-09-09)

### Features

* Add support for provider and consumer request services

### Misc

* Added test coverage and gem dependency badges
* Target MRI and multiple JDKs on Travis
* Update development dependencies
* Add additional YARD and README documentation

## v1.0.rc8.5 (2013-07-31)

* Initial public release
