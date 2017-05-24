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
SwiftBus.shared.routes(forAgencyTag: "sf-muni") { routes in
    for route in agencyRoutes.values {
        print("Route title: " + route.routeTitle)
    }
}
```

Or if you wanted to get a list of vehicle locations for a certain route:
```
SwiftBus.shared.vehicleLocations(forRouteTag: "N", forAgency: "sf-muni") { route in
    if let transitRoute = route as? TransitRoute {
        print("\(transitRoute.vehiclesOnRoute.count) vehicles on route N Judah\n")
    }
}
```

SwiftBus's usefulness shows itself here. If you tried to get the vehicle locations for a route on an agency that hasn't been loaded yet, SwiftBus will download all that information for you, so you can access it later without making any API calls. Using the example above, the route information for the N Judah is now downloaded, even though you didn't explicitly make that call.

Here's a list of all the calls you can make through the SwiftBus singleton:
```
open func transitAgencies(_ completion: ((_ agencies: [String: TransitAgency]) -> Void)?)

open func configuration(forAgency agency: TransitAgency?, completion: ((_ agency: TransitAgency?) -> Void)?)

open func configuration(forAgencyTag agencyTag: String?, completion: ((_ agency: TransitAgency?) -> Void)?)

open func routes(forAgency agency: TransitAgency?, completion: ((_ routes: [String: TransitRoute]) -> Void)?)

open func routes(forAgencyTag agencyTag: String?, completion: ((_ routes: [String: TransitRoute]) -> Void)?)

open func configuration(forRoute route: TransitRoute?, completion: ((_ route: TransitRoute?) -> Void)?)

open func configuration(forRouteTag routeTag: String?, withAgencyTag agencyTag: String?, completion: ((_ route: TransitRoute?) -> Void)?)

open func configurations(forMultipleRoutes routes: [TransitRoute?], completion: ((_ routes: [String: TransitRoute]) -> Void)?)

open func configurations(forMultipleRouteTags routeTags: [String], withAgencyTag agencyTag: String, completion: ((_ routes: [String: TransitRoute]) -> Void)?)

open func configurations(forMultipleRouteTags routeTags: [String], withAgencies agencies: [String], completion: ((_ routes: [String: TransitRoute]) -> Void)?)

open func vehicleLocations(forRoute route: TransitRoute?, completion: ((_ route: TransitRoute?) -> Void)?)

open func vehicleLocations(forRouteTag routeTag: String?, forAgency agencyTag: String?, completion: ((_ route: TransitRoute?) -> Void)?)

open func stationPredictions(forStop stop: TransitStop?, forRoutes routes: [TransitRoute?], completion: ((_ station: TransitStation?) -> Void)?)

open func stationPredictions(forStopTag stopTag: String, forRoutes routeTags: [String], withAgencyTag agencyTag: String, completion: ((_ station: TransitStation?) -> Void)?)

open func stopPredictions(forStop stop: TransitStop?, completion: ((_ stop: TransitStop?) -> Void)?)

open func stopPredictions(forStopTag stopTag: String?, onRouteTag routeTag: String?, withAgencyTag agencyTag: String?, completion: ((_ stop: TransitStop?) -> Void)?)
```

You don't have to deal with the SwiftBus singleton, though, if you don't want to. You can make these calls through the various Transit* objects included in SwiftBus. For example, you could get stop predictions by calling the singleton like this:
```

SwiftBus.shared.stopPredictions(forStopTag: "3909", onRouteTag: "N", withAgencyTag: "sf-muni") { route in
    ...
}
```

Or like this:
```
var route = TransitRoute(routeTag: "N", agencyTag: "sf-muni")
route.stopPredictions(forStopTag: "3909") { predictions in
    ...
}
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

1.2: New object: `TransitStation`. A station is just like a `TransitStop` except for that there are multiple lines that stop there. Getting the predictions for a certain station gets the predictions for all lines that stop at that stop. `TransitStation`s are created manually, so you don't have to show all lines that stop there.

1.3: Swift 3.0 suport, renaming func and variable names to fit new Swift 3.0 guidelines.

1.4: New Object: `TransitMessage`. Getting messages will now return an array of `TransitMessage` instead of an array of `String`. You now have the ability to see the priority given to a particular message.

## License

SwiftBus is available under the MIT license. See the LICENSE file for more info.
