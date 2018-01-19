//
//  ViewController.swift
//  Directions
//
//  Created by Jorge MR on 08/11/17.
//  Copyright © 2017 jorge Mtz R. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapKitView: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapKitView.delegate = self
        mapKitView.showsScale = true // left corner scale 0___50___100___150m
        mapKitView.userTrackingMode = .followWithHeading // light on user location o<
        mapKitView.showsUserLocation = true
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            makeZoom()
        }
        
        //Reconocer gesto
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longpress))
        uilpgr.minimumPressDuration = 2 //tiempo para que se reconozca el gesto
        mapKitView.addGestureRecognizer(uilpgr) //agrega el gesto al mapa
    }
    
    func makeZoom(){
        let userCoordinates = locationManager.location?.coordinate
        let latDelta : CLLocationDegrees = 0.025
        let longDelta : CLLocationDegrees = 0.025
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)//nivel de Zoom en Ancho y alto de la region
        let region = MKCoordinateRegion(center: userCoordinates!, span: span)
        mapKitView.setRegion(region, animated: true)
    }
    
    @objc func longpress(gestureRecognizer: UIGestureRecognizer){
        let touchPoint = gestureRecognizer.location(in: self.mapKitView)//guarda las coordenadas de donde se hizo el gesto
        let coordenadas = mapKitView.convert(touchPoint, toCoordinateFrom: self.mapKitView) //convierte coordenadas de la pantalla a coordenadas del mapa
        
        let anotacion = MKPointAnnotation()
        anotacion.title = "Nuevo punto"
        anotacion.subtitle = "subtitulo"
        anotacion.coordinate = coordenadas
        mapKitView.addAnnotation(anotacion)
        
        let userCoordinates = locationManager.location?.coordinate
        let destinationCoordinates = coordenadas
        
        let sourcePlaceMark = MKPlacemark(coordinate: userCoordinates!)
        let destinarionPlaceMark = MKPlacemark(coordinate: destinationCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinarionPlaceMark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destinationItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let response = response else {
                print("Ocurrio un error")
                return }
            let route = response.routes[0]
            //linea de con poligonos, y sobre los caminos
            self.mapKitView.add(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect //Rectangulo minimo que cubre del usuario al punto
            self.mapKitView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true) //Zoom al rectangulo
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        renderer.lineWidth = 5.0
        return renderer
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

