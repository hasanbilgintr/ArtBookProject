//
//  ViewController.swift
//  230924_ArtBookProject
//
//  Created by hasan bilgin on 24.09.2023.
//

/*
 Core Data kullanımı
 -Proje Açarken User Core Data alanını aktif ettim
 
 -proje açılınca dosyaların nen altında projename.xcdatamodel oluştu ve AppDelegate.swift CoreData kütüphanesi ve 2 metodu eklenmiştir
 
 -entity(sınıf/model) oluşturmak için Add Entity tıkladık-> oluşturulan Entity çift tıklarsak adını değiştirebiliriz. Attribute nin altında + ya tıklayarak attribute verebiliriz (property-değişken tipi  düşünebiliriz)
 
 -storyboardda mesela otomatik Constraints verdik sonradan manuel itemi değiştirdik ama bozuldu düzelmek için itemi seçip Update Constraint Constants seçilmelidir düzeltir
 
 -Not storyboarrda viewController de buton mesela ok ile çektiğpimizde olan storyboardda üstteki viewcontroller butonuna tıklayıp sağ üstte show the connection inspector a gelip sarı ücgen işaret çıkıyo yani hata benzeri yada direk swiftte ? varsa bi sıkıntı vardır diyebiliriz. Çözümü ise sarı işaretli olanları hepsini x ile silelim ve ok ile koda getirilenleride silelim. olan storyboarda sağ tıklayıp Open As ile Soruce Code tıklarız. orda koda dökülmiş hali vardır yani xmldir ve ordan viewContoller (ilk ekranda)
 bunlar vardır  <viewController id="BYZ-38-t0r" customClass="ViewController" customModule="_30924_ArtBookProject" customModuleProvider="target" sceneMemberID="viewController">
 açışmış olan Swiftte eksikse onları düzeltiriz. Ardından En üst çubuktan Product->Clean Build Folder. Ardından ve buildleyelim (Command+B) düzelmesi bekleriz
 
 */


import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedName = ""
    var selectedid : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //nagitaion bar üst buton oluşturma...
        //navigationController direk ulaşabiliyoruz
        //UIBarButtonItem.SystemItem hazır butonları eklediğimiz functiondur
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:  #selector(addButtonClicked))
        tableView.delegate=self
        tableView.dataSource=self
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //diğer ekrandan gelirken karşılamak
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "newData"), object: nil)
    }
    
   @objc func getData(){
       
       //tümünü silicektir
       nameArray.removeAll()//keepingCapacity : false eklenebilir
       idArray.removeAll()//keepingCapacity : false eklenebilir
       
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchReguest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        //işlemimi hızlandıran bir koddur
        fetchReguest.returnsObjectsAsFaults = false
        
        do{
            let results=try context.fetch(fetchReguest)
            
            if results.count > 0 {
                
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        self.nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        self.idArray.append(id)
                    }
                    
                    //veri eklendiğinde listeyi yenilemesi
                    self.tableView.reloadData()
                }
            }
        }catch{
            print("error")
        }
        
    }
    
    @objc func addButtonClicked(){
        
        selectedName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=UITableViewCell()
        cell.textLabel?.text=nameArray[indexPath.row]
        return cell
    }
    
    //ekran geçişi hazırlama
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.chosenName = selectedName
            destinationVC.chosenId = selectedid
        }
    }
    
    //tableview satıra tıklandığında
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedid = idArray[indexPath.row]
    
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    
        //tableview Delete işlemi yapıldığında çalışçak olan fucntion
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            //Stringe çevrildi
            let idString = idArray[indexPath.row].uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            fetchRequest.returnsObjectsAsFaults = false
            
            //ilk önce veriyi bulup sonra silicez ondan 2li do tryli
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{
                                //CoreDatadan silme işlemi yapıcaktır
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                //tabi diğer tableview silme işlemide yapılabilirdi
                                self.tableView.reloadData()
                                do{
                                    //silme işleminden sonra yapılması gerekiyormuş
                                    try context.save()
                                }catch{
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }catch{
                print("error")
            }
            
            
            
            
        }
        
    }
}

