//
//  DictionaryKey.swift
//  Pods
//
//  Created by Adam Boyd on 2017/6/23.
//
//

import Foundation

public typealias AgencyTag = String
public typealias RouteTag = String
public typealias StopTag = String
public typealias DirectionName = String
public typealias PredictionGroup = [RouteTag: [StopTag: [TransitPrediction]]]

public typealias StopRoutePair = (stopTag: StopTag, routeTag: RouteTag)
