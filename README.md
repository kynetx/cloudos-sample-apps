cloudos-sample-apps
===================

Sample CloudOS Applications

appTemplate.krl - Application Template (Redux)
----------------------------------

New and Improved myCloud application template. The original appTemplate required that a main page first be rendered before alternate pages within the application could be displayed. In this revision any page within the application can be rendered without the requirement to visit the main page.

appTemplateDeprecated.krl - Application Template (deprecated)
-------------------------------

myCloud application template provides example of adding menu to an application and web form submission.

helloWorld.krl - Hello World Application
----------------------------------

Here is the classic Hello, World application to get you started building myCloud dashboard applications

helloGuest.krl - Hello Guest Application
----------------------------------

While the classic Hello World application should be run by an authenticated user, this version of Hello, World is intended to be run by an unauthenticated user. The main difference is that the initial event raised to the application is web:cloudAppSelectedAnonymous, instead of web:cloudAppSelected.

appMenu.krl - Application Menu
---------------------------

You can add items to the application menu. This sample adds two new items. The menu items labels and associated actions are specified in the appMenu hash and passed as attributes to cloudos:appReadyToLoad. To respond to the events when they are raised add rules for web:cloudAppAction.

subscriptionExample.krl - subscribe example
----------------------------

To exercise this subscribe (and unsubscribe) example you will need to install this ruleset in two separate Personal Clouds. Note: To simplify this example the doorbell ECI will need to be hardcode in the appSubscribe_cloudAppCommand_subscribe rule.

SquareTagJournal - Journal App in SquareTag
----------------------------

This app demonstrates storing and displaying data from entity variables as well as how to program to the SquareTag API.
