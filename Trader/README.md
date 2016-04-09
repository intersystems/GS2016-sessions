# trader
Example on how to add unstructured data into an existing application, by using iKnow Rule Builder results

- load https://github.com/bdeboe/isc-iknow-rulesbuilder
- import trader_app.xml in Caché namespace
- configure RestHandler for this namespace (name : /csp/<yournamespace>rest; Dispatch class : App.RestHandler)
- http://localhost:ip-port/csp/trader/RulesBuilderDemo.csp?<domain> for RulesBuilder (see doc)
- http://localhost:ip-port/csp/trader/TraderApp.csp for Trader Demo
