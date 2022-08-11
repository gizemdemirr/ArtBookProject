//
//  DetailsVC.swift
//  ArtBookProject
//
//  Created by Gizem on 27.07.2022.
//

import UIKit

import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    
    
    @IBOutlet weak var artistText: UITextField!
    
    @IBOutlet weak var yearText: UITextField!
    
    
    @IBOutlet weak var saveButtonOutlet: UIButton!
    
    
    
    var chosenPainting = ""
    var chosenPaintingId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        boş değil ise data çekicem, boş ise ne gösteriyosam onu gösstermeye devam ediceem
        if chosenPainting != "" {
            saveButtonOutlet.isHidden = true
//            CORE DATA
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
    
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
//            idsi argümana eşit olan idyi bana bul
            let idString = chosenPaintingId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name")  as? String {
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "artist") as? String {
                            artistText.text = artist
                        }
                        if let year = result.value(forKey: "year")  as? Int {
                            yearText.text = String(year)
                        }
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            }catch {
                print("error")
            }
           
        }else {
//            görünür olması için
            saveButtonOutlet.isHidden = false
//            tıklanamaz olması için
            saveButtonOutlet.isEnabled = false
        }
        
        
        
        
        
//     RECOGNIZERS
//        klavyeyi kapatmak
    let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
//      gestureRecognizer ı  viewin kendisine vermeliyiz
        view.addGestureRecognizer(gestureRecognizer)
//        tıklama işlemlerinde gestureRecognizer kullanılır
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)
    
    }
    @objc func selectImage() {
//      Kullanıcıyı galeriye götürmek UIImagePickerController
        let picker = UIImagePickerController()
//        pickerın fonkdiyonlarını çağırabilmek için
        picker.delegate = self
//        kullanıcı kamera mı açsın galeriden mi kullansın o seçilir
        picker.sourceType = .photoLibrary
//        kullanıcı fotoğrafı editleyebilsin diye
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
    }
    //        kullanıcı resmi seçtikten sonra ne yapacak işlemi burada yapılır
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        any i imageviewe çevirme
        imageView.image = info[.originalImage] as? UIImage
        saveButtonOutlet.isEnabled = true
//        açtığım pickerı kapatmak için
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    

    @IBAction func saveButton(_ sender: Any) {
//        KAYDETME İŞLEMİ
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
//        ATTRIBUTES
        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(artistText.text!, forKey: "artist")
//        yearı int e çevirmek
        if let year = Int(yearText.text!){
        newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
//        görseli dataya çevirmek
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
       
        do {
            try context.save()
            print("success")
        }catch {
            print("error")
        }
//        önceki vc a giderken tableviewi yenile verileri getir
//        burdan mesaj gönderdiğimde orada ne yapacağımı yazıyorum bunu sağlayan NotificationCenter
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
//        bir önceki viewControllera gitmek
        self.navigationController?.popViewController(animated: true)
      
    }
    
    

}
