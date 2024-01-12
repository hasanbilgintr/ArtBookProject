//
//  DetailsVC.swift
//  230924_ArtBookProject
//
//  Created by hasan bilgin on 24.09.2023.
//

import UIKit
//eklendi
import CoreData

class DetailsVC: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    //,UIImagePickerControllerDelegate,UINavigationControllerDelegate resim seçmek için yazdık
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var artistText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenName = ""
    var chosenId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenName != ""{
            //button aktifmi
            //saveButton.isEnabled = false
            //button gizlensinmi
            saveButton.isHidden = true
            
            //CoreData
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult> (entityName: "Paintings")
            //chosenId strigne çevirdik
            let idString = chosenId?.uuidString
            //id ye idString atadık yazılımı böle
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        
                        if let artist = result.value(forKey: "artist") as? String{
                            artistText.text = artist
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data{
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch{
                print("error")
            }
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
        }
        
        
        //telefonda textfield tıkladığında klavye açılıyor yalnız başka bi yere tıkladığımızda bu klavye kapanması lazım ondan dolayı
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        //
        
        //image view tıklanabilir yapma ve tıklandıldığında ne yapılcak
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        //benzer bir işlem vardı not alabilirsin aklıma gelmedi
        picker.delegate = self
        //direk nerden açılcağını söledik camera, bu ve albüm seçneekleri mevcut
        picker.sourceType = .photoLibrary
        //kullanıcı seçtiği göreli editleyebilecek  tabi ona göre alltkiden o seçilmesi lazım ondna true dedik zorunlu değil
        picker.allowsEditing = true
        present(picker, animated: true)//completion nil yazıdık girilmeyebilir
        //kütüphane giderek resmi seçti kadar işlemleri yaptık sonrası içinde var devamı
    }
    
    //seçildiğkten sonra foto döndürücek
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //.editedImage editlenmiş fotoyu alır
        //originalImage görselin orjinal halidir //genelde ikisi kullanılır
        //? orda resim seçmeyebilir yada resime dönüştüremeyebilir ondna doalyısıyla
        imageView.image = info[.originalImage] as? UIImage
        //resim seçildikten sonra save butonu aktif ediyoruz
        saveButton.isEnabled = true
        //açılan foto menüsünü kapamak için
        self.dismiss(animated: true)// completion nil eklenebilir gerek yok
        
    }
    
    @objc func hideKeyboard(){
        //view de UIview in kendisi
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //UIApplication application kendisidir
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //NSEntityDescription yukarda entity ekledik yoksa gelmez
        //Paintings add entity eklerken o olucak
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
        //Attributes
        //attributes ne ise aynı olucak
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
        
        //eğerki sayıdan farklı bişey yazılırsa diye kontrol kondu
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        
        newPainting.setValue(UUID(), forKey: "id")
        
        //compressionQuality sıkıştırma demek yani 0.5=%50 dıkıştırma yapılmıştır
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do{
            try context.save()
            print("success")
        }catch{
            print("error")
        }
        
        //bir öncekiş ekrana geri dönerken bilgi aktarmak(göndermek)
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        //Bir önceki viewController geri gider demek
        self.navigationController?.popViewController(animated: true)
    }
    
    //info.plist alanında kullanılan albümü açmak için eklenip kullanıcıya bilgi verilebilir zorunlu değilmiş
    //herhangibir + ile privacy - Photo Library Usage Description seçtik ve Value (mesaj gösterilcek yere) To access photos yazdık
    
    
}
