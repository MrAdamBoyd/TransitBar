//
//  TransitAgency.swift
//  SwiftBus
//
//  Created by Adam on 2015-08-29.
//  Copyright (c) 2017 Adam Boyd. All rights reserved.
//

import Foundation

private let agencyTagEncoderString = "kAgencyTagEncoder"
private let agencyTitleEncoderString = "kAgencyTitleEncoder"
private let agencyShortTitleEncoderString = "kAgencyShortTitleEncoder"
private let agencyRegionEncoderString = "kAgencyRegionEncoder"
private let agencyRoutesEncoderString = "kAgencyRoutesEncoder"

open class TransitAgency: NSObject, NSCoding {
    
    open var agencyTag: String = ""
    open var agencyTitle: String = ""
    open var agencyShortTitle: String = ""
    open var agencyRegion: String = ""
    open var agencyRoutes: [String : TransitRoute] = [:] //[routeTag: Route]
    
    //Convenvience
    public override init() { }
    
    //User initialization, only need the agencyTag, everything else can be downloaded
    public init(agencyTag:String) {
        self.agencyTag = agencyTag
    }
    
    public init(agencyTag:String, agencyTitle:String, agencyRegion:String) {
        self.agencyTag = agencyTag
        self.agencyTitle = agencyTitle
        self.agencyRegion = agencyRegion
    }
    
    /**
    Downloads all agency data from provided agencytag
    
    - parameter completion:    Code that is called when the data is finished loading
        - parameter result:    Result of the API call
    */
    open func download(_ completion: ((_ result: SwiftBusResult<TransitAgency>) -> Void)?) {
        //We need to load the transit agency data
        let connectionHandler = SwiftBusConnectionHandler()
        
        //Need to request agency data first because only this call has the region and full name
        connectionHandler.requestAllAgencies() { result in
            
            switch result {
            case let .success(agencies):
                //Getting the current agency
                guard let thisAgency = agencies[self.agencyTag] else {
                    //This agency doesn't exist
                    completion?(.error(SwiftBusError.error(with: .unknownAgency)))
                    return
                }
                
                self.agencyTitle = thisAgency.agencyTitle
                self.agencyShortTitle = thisAgency.agencyShortTitle
                self.agencyRegion = thisAgency.agencyRegion
                
                connectionHandler.requestAllRouteData(self.agencyTag) { result in
                    switch result {
                    case let .success(agencyRoutes):
                        self.agencyRoutes = agencyRoutes
                        completion?(.success(self))
                    case let .error(error):
                        completion?(.error(error))
                    }
                }
                
            case let .error(error):
                completion?(.error(error))
            }
        }
    }

    //MARK : NSCoding
    
    required public init(coder aDecoder: NSCoder) {
        guard let tag = aDecoder.decodeObject(forKey: agencyTagEncoderString) as? String,
            let title = aDecoder.decodeObject(forKey: agencyTitleEncoderString) as? String else {
            //Make sure at least the tag and title exist
            return
        }
        self.agencyTag = tag
        self.agencyTitle = title
        self.agencyShortTitle = aDecoder.decodeObject(forKey: agencyShortTitleEncoderString) as? String ?? ""
        self.agencyRegion = aDecoder.decodeObject(forKey: agencyRegionEncoderString) as? String ?? ""
        self.agencyRoutes = aDecoder.decodeObject(forKey: agencyRoutesEncoderString) as? [String : TransitRoute] ?? [:]
    }
    
    open func encode(with aCoder: NSCoder) {
        aCoder.encode(self.agencyTag, forKey: agencyTagEncoderString)
        aCoder.encode(self.agencyTitle, forKey: agencyTitleEncoderString)
        aCoder.encode(self.agencyShortTitle, forKey: agencyShortTitleEncoderString)
        aCoder.encode(self.agencyRegion, forKey: agencyRegionEncoderString)
        aCoder.encode(self.agencyRoutes, forKey: agencyRoutesEncoderString)
    }
}
