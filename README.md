cloudos-sample-apps
===================

Sample CloudOS Applications

a169x674 - Application Template
-------------------------------

myCloud application template provides example of adding menu to an application and web form submission.

a169x687 - Hello World Application
----------------------------------

Here is the classic Hello, World application to get you started building myCloud dashboard applications

a169x688 - Hello Guest Application
----------------------------------

While the classic Hello World application should be run by an authenticated user, this version of Hello, World is intended to be run by an unauthenticated user. The main difference is that the initial event raised to the application is web:cloudAppSelectedAnonymous, instead of web:cloudAppSelected.

a169x689 - Application Menu
---------------------------

You can add items to the application menu. This sample adds two new items. The menu items labels and associated actions are specified in the appMenu hash and passed as attributes to cloudos:appReadyToLoad. To respond to the events when they are raised add rules for web:cloudAppAction.

a169x690 - subscribe example
----------------------------

To exercise this subscribe (and unsubscribe) example you will need to install this ruleset in two separate Personal Clouds. Note: To simplify this example the doorbell ECI will need to be hardcode in the appSubscribe_cloudAppCommand_subscribe rule.
