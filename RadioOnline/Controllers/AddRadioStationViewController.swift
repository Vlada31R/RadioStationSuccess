//
//  AddRadioStationViewController.swift
//  RadioOnline
//
//  Created by student on 8/20/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import ChameleonFramework
import ProgressHUD

class AddRadioStationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var URLStreamTextField: UITextField!
    @IBOutlet weak var URLImageTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var urlStreamLabel: UILabel!
    @IBOutlet weak var urlImgLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var orLabel: UILabel!

    //get image from gallery
    var libraryURL = ""
    @IBOutlet weak var myImageView: UIImageView!
    @IBAction func chooseImageButton(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        self .present(imagePicker, animated: true, completion: nil)
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {

            let fileManager = FileManager.default
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("pict.jpg")
            let image = pickedImage
            print(paths)
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            fileManager.createFile(atPath: paths as String, contents: imageData, attributes: nil)
            libraryURL = paths

            myImageView.contentMode = .scaleAspectFit
            myImageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        DataManager.changeColor(view: self.view)
        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: .reload, object: nil)
        recolourAllElements()
    }

    //*******************************************************************************************************************************************
    // MARK: Recolour all elements (Chameleon framework)
    //*******************************************************************************************************************************************

    @objc func reload(notification: NSNotification) {
        DataManager.changeColor(view: self.view)
        recolourAllElements()
    }

    func recolourAllElements() {
        nameLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        descLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        urlStreamLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)
        urlImgLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)

        nameTextField.layer.borderWidth = 2
        nameTextField.layer.cornerRadius = 6
        nameTextField.attributedPlaceholder = NSAttributedString(string: nameTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: ContrastColorOf(nameTextField.backgroundColor!, returnFlat: true)])
        nameTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor

        descriptionTextField.layer.borderWidth = 2
        descriptionTextField.layer.cornerRadius = 6
        descriptionTextField.attributedPlaceholder = NSAttributedString(string: descriptionTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: ContrastColorOf(descriptionTextField.backgroundColor!, returnFlat: true)])
        descriptionTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor

        URLStreamTextField.layer.borderWidth = 2
        URLStreamTextField.layer.cornerRadius = 6
        URLStreamTextField.attributedPlaceholder = NSAttributedString(string: URLStreamTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: ContrastColorOf(URLStreamTextField.backgroundColor!, returnFlat: true)])
        URLStreamTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor

        URLImageTextField.layer.borderWidth = 2
        URLImageTextField.layer.cornerRadius = 6
        URLImageTextField.attributedPlaceholder = NSAttributedString(string: URLImageTextField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor: ContrastColorOf(URLImageTextField.backgroundColor!, returnFlat: true)])
        URLImageTextField.layer.borderColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true).cgColor

        nameTextField.textColor = ContrastColorOf(nameTextField.backgroundColor!, returnFlat: true)
        descriptionTextField.textColor = ContrastColorOf(descriptionTextField.backgroundColor!, returnFlat: true)
        URLStreamTextField.textColor = ContrastColorOf(URLStreamTextField.backgroundColor!, returnFlat: true)
        URLImageTextField.textColor = ContrastColorOf(URLImageTextField.backgroundColor!, returnFlat: true)

        button.tintColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)

        orLabel.textColor = ContrastColorOf(self.view.backgroundColor!, returnFlat: true)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    //*******************************************************************************************************************************************
    // MARK: buttton function
    //*******************************************************************************************************************************************

    @IBAction func addNewRadioStation(_ sender: Any) {
        endEditing()
        let name = nameTextField.text!
        let desc = descriptionTextField.text!
        let urlStream = URLStreamTextField.text!
        var urlImage = URLImageTextField.text!
        if name.count > 0 && urlStream.count > 0 {
            for station in DataManager.stations {
                if station.name == name {
                    ProgressHUD.show()
                    ProgressHUD.showError("Sorry... station with this name already exists")
                    return
                }
            }
            if libraryURL.count>0 {
                do {
                    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let documentDirectory = URL(fileURLWithPath: path)
                    let originPath = documentDirectory.appendingPathComponent("pict.jpg")
                    let destinationPath = documentDirectory.appendingPathComponent("\(name).jpg")
                    libraryURL = destinationPath.path
                    try FileManager.default.moveItem(at: originPath, to: destinationPath)
                } catch {
                    print(error)
                }
                urlImage = "user"
            }
            DataManager.addNewRadioStation(name: name, desc: desc, urlStream: urlStream, urlImage: urlImage)
            NotificationCenter.default.post(name: .reload, object: nil)
            ProgressHUD.show()
            ProgressHUD.showSuccess("Radiostation add all station!")
            self.navigationController?.popViewController(animated: true)
        } else {
            ProgressHUD.show()
            ProgressHUD.showError("Sorry... some error, please retry! (Name or stream url is empty)")
        }

    }

    //*******************************************************************************************************************************************
    // MARK: touches method
    //*******************************************************************************************************************************************

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        endEditing()
    }

    func endEditing() {
        nameTextField.endEditing(true)
        descriptionTextField.endEditing(true)
        URLStreamTextField.endEditing(true)
        URLImageTextField.endEditing(true)
    }

}
