//
//  MKMapView+.swift
//  BeGo Everyday
//
//  Created by yoonbumtae on 2023/02/11.
//


import MapKit

extension MKMapView {

    /**
     ``delta`` is the zoom factor
     - 2 will zoom out x2
     - .5 will zoom in by x2
     */
    func setZoomByDelta(delta: Double, animated: Bool) {
        var _region = region;
        var _span = region.span;
        _span.latitudeDelta *= delta;
        _span.longitudeDelta *= delta;
        _region.span = _span;

        setRegion(_region, animated: animated)
    }
}
