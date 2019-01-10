//
//  AgregarViewController.swift
//  coreDataFinal
//
//  Created by Tecnova on 1/10/19.
//  Copyright © 2019 Gabriel Soto Valenzuela. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AgregarViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var nombre: UITextField!
    @IBOutlet weak var descripcion: UITextField!
    @IBOutlet weak var verCoordenadas: UIButton!
    
    var manager = CLLocationManager()
    var latitud : CLLocationDegrees!
    var longitud : CLLocationDegrees!
    
    override func viewDidLoad()
    {
       super.viewDidLoad()
       manager.delegate = self
       manager.requestWhenInUseAuthorization()
       manager.desiredAccuracy = kCLLocationAccuracyBest
       manager.startUpdatingLocation()
       
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        if let location = locations.first
        {
            self.latitud = location.coordinate.latitude
            self.longitud = location.coordinate.longitude
        }
    }
    
    @IBAction func obtenerCoordenadas(_ sender: UIButton)
    {
        verCoordenadas.setTitle("Lat: \(latitud!) - Long: \(longitud!)", for: .normal)
    }
    
    @IBAction func guardar(_ sender: UIButton)
    {
        let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entityLugares = NSEntityDescription.insertNewObject(forEntityName: "Lugares", into: contexto) as! Lugares
        
        entityLugares.nombre = nombre.text
        entityLugares.descripcion = descripcion.text
        entityLugares.latitud = latitud
        entityLugares.longitud = longitud
        //id autoincrementable
        // select * from Lugares order by id desc LIMIT 1
        let fetchResult : NSFetchRequest<Lugares> = Lugares.fetchRequest()
        let orderById = NSSortDescriptor(key: "id", ascending: false) //true ascendente, false descendenteº
        fetchResult.sortDescriptors = [orderById]
        fetchResult.fetchLimit = 1
        
        do {
            let idResult = try contexto.fetch(fetchResult)
            let id = idResult[0].id + 1
            entityLugares.id = id
            
        } catch let error as NSError {
            print("hubo un error \(error)")
        }
        
        do {
            try contexto.save()
            print("guardado")
            nombre.text = ""
            descripcion.text = ""
        } catch let error as NSError  {
             print(" no guardo \(error)")
        }
    }
}
