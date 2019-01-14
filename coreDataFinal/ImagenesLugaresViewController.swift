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
    var refrescar : UIRefreshControl!
    
    
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
        
        //Se diseña para que el collection view se vea de a 3 en la vista
        let itemSize = UIScreen.main.bounds.width/3 - 3
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 3
        collection.collectionViewLayout = layout
        
        llamarImagen()
        
        // pull to refresh
        refrescar = UIRefreshControl()
        collection.alwaysBounceVertical = true
        refrescar.tintColor = UIColor.green
        refrescar.addTarget(self, action: #selector(recargarDatos), for: .valueChanged)
        collection.addSubview(refrescar)
        
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
    
    func entrarGaleria()
    {
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
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imagenes.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collection.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImagenCollectionViewCell
        
        let imagen = imagenes[indexPath.row]
        
        if let imagen = imagen.imagenes{
            cell.imagen.image = UIImage(data: imagen as Data)
            
        }
        return cell
    }
    func llamarImagen()
    {
        let contexto = conexion()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        let idLugar = String(id)
        fetchRequest.predicate = NSPredicate(format: "id_lugares == %@", idLugar)
        do {
            imagenes = try contexto.fetch(fetchRequest)
        } catch let error as NSError  {
            print("no funciona", error)
        }
    }
    
    @objc func recargarDatos()
    {
        llamarImagen()
        collection.reloadData()
        stop()
    }
    
    func stop()
    {
        refrescar.endRefreshing()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        performSegue(withIdentifier: "imagen", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imagen"{
            let id = sender as! NSIndexPath
            let fila = imagenes[id.row]
            let destino = segue.destination as! ImagenVistaViewController
            destino.imagenLugar = fila
        }
    }
}
