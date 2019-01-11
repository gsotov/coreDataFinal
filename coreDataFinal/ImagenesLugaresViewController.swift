//
//  ImagenesLugaresViewController.swift
//  coreDataFinal
//
//  Created by Tecnova on 1/11/19.
//  Copyright © 2019 Gabriel Soto Valenzuela. All rights reserved.
//

import UIKit
import CoreData

class ImagenesLugaresViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    var imagenLugar : Lugares!
    var imagenes : [Imagenes] = []
    var id : Int16!
    var imagen : UIImage!
    
    
    @IBOutlet weak var collection: UICollectionView!
    func conexion () -> NSManagedObjectContext{
        let delegate = UIApplication.shared.delegate as! AppDelegate
        return delegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.delegate = self
        collection.dataSource = self
        
        self.title = imagenLugar.nombre
        id = imagenLugar.id
        let rightButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(acccionCamarar))
        self.navigationItem.rightBarButtonItem = rightButton
        // Do any additional setup after loading the view.
        
        llamarImagen()
    }
    @objc func acccionCamarar(){
        print("abrir camara")
        
        let alerta = UIAlertController(title: "Tomar Foto", message: "camara/galeria", preferredStyle: .actionSheet)
        
        let accionCamara = UIAlertAction(title: "Tomar Fotografia", style: .default) { (action) in
            self.tomarFotografia()
        }
        
        let accionGaleria = UIAlertAction(title: "Entregar Galeria", style: .default) { (action) in
            self.entrarGaleria()
        }
        
        let accionCancelar = UIAlertAction(title: "Canelar", style: .destructive, handler: nil)
        
        alerta.addAction(accionCamara)
        alerta.addAction(accionGaleria)
        alerta.addAction(accionCancelar)
        
        present(alerta, animated: true, completion: nil)
    }
    
    func tomarFotografia(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func entrarGaleria(){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let imagenTomada = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        imagen = imagenTomada
        
        let contexto = conexion()
        let entityImagenes = NSEntityDescription.insertNewObject(forEntityName: "Imagenes", into: contexto) as! Imagenes
        
        let uuid = UUID()
        entityImagenes.id = uuid
        entityImagenes.id_lugares = id
        let imagenFinal = imagen.pngData() as Data?
        entityImagenes.imagenes = imagenFinal
        
        imagenLugar.mutableSetValue(forKey: "imagenes").add((entityImagenes))
        
        do {
            try contexto.save()
            self.llamarImagen()
            self.collection.reloadData()
            dismiss(animated: true, completion: nil)
            print("guardado entityImagenes")
        } catch let error as NSError {
            print("error", error)
        }
        
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagenes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagenCollectionViewCell
        
        let imagen = imagenes[indexPath.row]
        
        if let imagen = imagen.imagenes{
            cell.imagen.image = UIImage(data: imagen as Data)
            
        }
        return cell
    }
    func llamarImagen(){
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        
        do {
            imagenes = try contexto.fetch(fetchRequest)
        } catch let error as NSError  {
            print("no funciona", error)
        }
    }
}
