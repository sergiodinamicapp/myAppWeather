//
//  ViewController.swift
//  PruebaTalentoMobile
//
//  Created by Sergio on 27/3/17.
//  Copyright © 2017 Sergio. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate {
    
    //MARK: - VARIABLES
    
    var ciudad : [Ciudad] = []
    var filtered : [Ciudad] = []
    var searchBarActivate : Bool = false
    var tiempo : [Tiempo] = []
    var search1 : String = "Madrid"
    var search2 : String = "City Center"
    var temperaturaString : String = ""
    var temperaturaInt : Float = 0.0
    
    //MARK: - IBOUTLET
    
    @IBOutlet weak var ciudadLB: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableViewDetail: UITableView!
    @IBOutlet weak var imageAnimation: UIImageView!
    @IBOutlet weak var tempLB: UILabel!
    @IBOutlet weak var mapViewDetail: MKMapView!
    @IBOutlet weak var humLB: UILabel!
    @IBOutlet weak var cloudsLB: UILabel!
    @IBOutlet weak var windLB: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    //MARK: - IBACTION
    
    @IBAction func action1(_ sender: UIButton) {
        
    }
    
    @IBAction func action2(_ sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Simular historial de búsqueda
        
        button1.setTitle(search1, for: .normal)
        button2.setTitle(search2, for: .normal)
        
        //Inicializar funciones
        
       fetchJson()
       fetchWeather()
        
        //Inicializar animación
        
        let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
        let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
        self.imageAnimation.transform = scale.concatenating(translation)
    }
    
    //Método llamadas JSON
    
    func fetchWeather(){
        
        let url = URL(string: "http://api.geonames.org/weatherJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&username=ilgeonamessample")
        print(url!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error")
            }
            else {
                self.tiempo = [Tiempo]()
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as AnyObject
                        if let weatherObservations = myJson["weatherObservations"] as? NSArray{
                            for datosTiempo in (weatherObservations as? [[String: Any]])! {
                                let meteorologia = Tiempo()
                                if let temp = datosTiempo["temperature"] as? String {
                                    meteorologia.temperature = temp
                                }
                                if let hum = datosTiempo["humidity"] as? Int {
                                    meteorologia.humidity = hum
                                    print(hum)
                                }
                                if let cloud = datosTiempo["clouds"] as? String {
                                    meteorologia.clouds = cloud
                                    print(cloud)
                                }
                                if let wind = datosTiempo["windSpeed"] as? String {
                                    meteorologia.windSpeed = wind
                                    print(wind)
                                }
                                if let latitud = datosTiempo["lat"] as? Int {
                                    meteorologia.lat = latitud
                                    print(latitud)
                                }
                                if let longitud = datosTiempo["lng"] as? Int {
                                    meteorologia.lng = longitud
                                    print(longitud)
                                }
                                    self.tiempo.append(meteorologia)
                            }
                        }
                    }
                    catch{
                    }
                }
            }
        }
        task.resume()
    }

    func fetchJson(){
        
        let url = URL(string: "http://api.geonames.org/searchJSON?q=Madrid&maxRows=10&startRow=0&lang=en&isNameRequired=true&style=FULL&username=ilgeonamessample")
        print(url!)
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print("Error")
            }
            else {
                self.ciudad = [Ciudad]()
                if let content = data {
                    do {
                        let myJson = try JSONSerialization.jsonObject(with: content, options: .allowFragments) as AnyObject
                        if let geonames = myJson["geonames"] as? NSArray{
                            //print(geonames)
                            for datosCiudad in (geonames as? [[String: Any]])! {
                                let ciudades = Ciudad()
                            if let nombreCiudad = datosCiudad["asciiName"] as? String {
                                ciudades.asciiName = nombreCiudad
                                print(nombreCiudad)
                                }
                                self.ciudad.append(ciudades)
                            }
                        }
                        DispatchQueue.main.async {
                            self.tableViewDetail.reloadData()
                        }
                    }
                    catch{
                    }
                }
            }
        }
        task.resume()
    }
    
    //SearchBar
    
    private func searchBarShouldBeginEditing(_ searchBar: UISearchBar) {
        searchBarActivate = true
    }
    
    private func searchBarShouldEndEditing(_ searchBar: UISearchBar) {
        searchBarActivate = false
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filtered = ciudad.filter({ (text) -> Bool in
            let temp : NSString = text.asciiName as NSString
            let range = temp.range(of: searchText, options: NSString.CompareOptions.caseInsensitive)
            return range.location != NSNotFound
        })
        if (filtered.count == 0){
            searchBarActivate = false
        }else{
            searchBarActivate = true
        }
        self.tableViewDetail.reloadData()
    }
    
    //Animación
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.imageAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//Configuración celdas

extension ViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBarActivate {
            return filtered.count
        }else{
            return self.ciudad.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetalleCell", for: indexPath) as! ViewCell
        if searchBarActivate{
            cell.nombreCiudad.text = String(describing: filtered[indexPath.item].asciiName)
        }else{
            cell.nombreCiudad.text = String(describing: ciudad[indexPath.item].asciiName)
        }
        return cell
    }
}

extension ViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Pintar datos
        
        ciudadLB.text = String(describing: ciudad[indexPath.item].asciiName)
        humLB.text = String(describing: tiempo[indexPath.item].humidity)
        cloudsLB.text = String(describing: tiempo[indexPath.item].clouds)
        windLB.text = String(describing: tiempo[indexPath.item].windSpeed)+"Km/h"
        tempLB.text = String(describing: tiempo[indexPath.item].temperature)

        
        //Animación
       
        temperaturaString = tempLB.text!
            
        temperaturaInt = Float(temperaturaString)!
            
        if (temperaturaInt < 0){
            imageAnimation.image = #imageLiteral(resourceName: "snow-37012_1280")
            
            let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
            let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
            self.imageAnimation.transform = scale.concatenating(translation)
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.imageAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
        } else if (temperaturaInt >= 0 && temperaturaInt < 10){
            imageAnimation.image = #imageLiteral(resourceName: "rain-1265201_1280")
            
            let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
            let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
            self.imageAnimation.transform = scale.concatenating(translation)
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.imageAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
            
        } else if (temperaturaInt >= 10 && temperaturaInt < 20){
            imageAnimation.image = #imageLiteral(resourceName: "cloudy-98504_1280")

            let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
            let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
            self.imageAnimation.transform = scale.concatenating(translation)
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.imageAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)

        } else if (temperaturaInt >= 20){
            imageAnimation.image = #imageLiteral(resourceName: "sun-159392_1280")
            
            let scale = CGAffineTransform(scaleX: 0.0, y: 0.0)
            let translation = CGAffineTransform(translationX: 0.0, y: 500.0)
            self.imageAnimation.transform = scale.concatenating(translation)
            UIView.animate(withDuration: 1.5, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.imageAnimation.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
            }, completion: nil)
        }

        //Últimas búsquedas
        
        search2 = search1
        search1 = String(describing: ciudad[indexPath.item].asciiName)
        
        button1.setTitle(search1, for: .normal)
        button2.setTitle(search2, for: .normal)
        
        //Maps
        
        let lati = Int(tiempo[indexPath.item].lat)
        let longi = Int(tiempo[indexPath.item].lng)
        let location = CLLocationCoordinate2DMake(CLLocationDegrees(lati), CLLocationDegrees(longi))
        print(location)
        
                    let annotation = MKPointAnnotation()
                    annotation.title = self.ciudadLB.text
                    annotation.coordinate = location
                    self.mapViewDetail.showAnnotations([annotation], animated: true)
                    self.mapViewDetail.selectAnnotation(annotation, animated: true)
    }
}
