# SwiftBus
Interface for NextBus API written in Swift. Inspired by another side project of mine, [Muni Menu Bar](https://github.com/MrAdamBoyd/MuniMenuBar).

[![CI Status](http://img.shields.io/travis/Adam Boyd/SwiftBus.svg?style=flat)](https://travis-ci.org/Adam Boyd/SwiftBus)
[![Version](https://img.shields.io/cocoapods/v/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![License](https://img.shields.io/cocoapods/l/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)
[![Platform](https://img.shields.io/cocoapods/p/SwiftBus.svg?style=flat)](http://cocoapods.org/pods/SwiftBus)

## Contents
* [Installation](#installation)
* [Usage](#usage)
* [Requirements](#requirements)
* [NSAppTransportSecurity](#nsapptransportsecurity)
* [Author](#author)
* [Changelog](#changelog)
* [License](#license)

## Installation

SwiftBus is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "SwiftBus"
```

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

SwiftBus manages everything for you, so you can focus on making your app great. The primary way to interact with SwiftBus is through its singleton.

For example, if you wanted to get a list of routes for a certain agency, you'd do this:
```
SwiftBus.sharedController.routesForAgency("sf-muni", completion: {(agencyRoutes:[String : TransitRoute]) -> Void in
    for route in agencyRoutes.values {
        print("Route title: " + route.routeTitle)
    }
})
```

Or if you wanted to get a list of vehicle locations for a certain route:
```
SwiftBus.sharedController.vehicleLocationsForRoute("N", forAgency: "sf-muni", completion:{(route:TransitRoute?) -> Void in
    if let transitRoute = route as TransitRoute! {
        print("\(transitRoute.vehiclesOnRoute.count) vehicles on route N Judah\n")
    }
})
```

SwiftBus's usefulness shows itself here. If you tried to get the vehicle locations for a route on an agency that hasn't been loaded yet, SwiftBus will download all that information for you, so you can access it later without making any API calls. Using the example above, the route information for the N Judah is now downloaded, even though you didn't explicitly make that call.

Here's a list of all the calls you can make through the SwiftBus singleton:
```
public func transitAgencies(completion: (agencies:[String : TransitAgency]) -> Void)

public func routesForAgency(agencyTag: String, completion: (agency:TransitAgency?) -> Void)

public func configurationForMultipleRoutes(routeTags: [String], forAgency agencyTag:String, completion:(routes:[String : TransitRoute]) -> Void)

public func routesForAgency(agencyTag: String, completion: (routes:[String : TransitRoute] -> Void)

public func routeConfiguration(routeTag: String, forAgency agencyTag: String, completion:(route: TransitRoute?) -> Void)

public func vehicleLocationsForRoute(routeTag: String, forAgency agencyTag: String, completion:(route: TransitRoute?) -> Void)

public func stationPredictions(stopTag: String, forRoutes routeTags: [String], withAgency agencyTag: String, completion: (station: TransitStation?) -> Void)

public func stopPredictions(stopTag: String, onRoute routeTag: String, withAgency agencyTag: String, completion: (stop: TransitStop?) -> Void)
```

You don't have to deal with the SwiftBus singleton, though, if you don't want to. You can make these calls through the various Transit* objects included in SwiftBus. For example, you could get stop predictions by calling the singleton like this:
```
SwiftBus.sharedController.stopPredictions("3909", onRoute: "N", withAgency: "sf-muni", completion: {(route:TransitStop?) -> Void in
    ...
})
```

Or like this:
```
var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
route.getStopPredictionsForStop("3909", completion: {(success:Bool, predictions:[String : [TransitPrediction]]) -> Void in
    ...
})
```

## Requirements
SwiftBus will run on iOS 8 and above, and Mac OS X 10.9 Mavericks and above. If you are using or targeting iOS 9 and OS X 10.11 and above, you also need to have NSAppTransportSecurity working with `nextbus.com`.

## NSAppTransportSecurity
Starting in iOS 9 and OS X 10.11, Apple is restricting the use of `http` addresses unless otherwise specified. Because NextBus's website is currently http-only, NSAppTransportSecurity needs to be enabled for `nextbus.com`. Add this to your `Info.plist`:

```
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>nextbus.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSTemporaryExceptionMinimumTLSVersion</key>
            <string>TLSv1.1</string>
        </dict>
    </dict>
</dict>
```

## Author
My name is Adam Boyd.

Your best bet to contact me is on Twitter. [@MrAdamBoyd](https://twitter.com/MrAdamBoyd)

My website is [adamjboyd.com](http://www.adamjboyd.com).

## Changelog
1.0: Initial Release

1.1: Bug fixes

1.2: New object: TransitStation. A station is just like a TransitStop except for that there are multiple lines that stop there. Getting the predictions for a certain station gets the predictions for all lines that stop at that stop. TransitStations are created manually, so you don't have to show all lines that stop there.

## License

SwiftBus is available under the MIT license. See the LICENSE file for more info.
