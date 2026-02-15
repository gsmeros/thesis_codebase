//
//  LoginViewController.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 10/01/2021.
//

import UIKit

class LoginViewController: UIViewController {

    private enum Segue: String {
        case goToRegister = "go to register"
        case goToMain = "go to main"
    }
    
    private func perform(_ segue: Segue) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: segue.rawValue, sender: self)
        }
    }
    
    @IBOutlet weak var formContainerView: UIView!
    
    let controller = StoryboardIdentifier<FormBaseViewController>(UIStoryboard(name: "Main", bundle: nil), "FormBaseViewController").instantiate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller.formType = .login
        add(asChildViewController: controller)
    }
    
    func presentAlertController(_ alert: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            self.present(alert, animated: animated, completion: nil)
        }
    }
    
    @IBAction func continuePressed(_ sender: Any) {
        let validation = self.controller.form.isValid()
        self.controller.tableView.reloadData()
        if !validation.0 {
            let responseAlert = UIAlertController.init(title: "Form Error", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
                
            }
            responseAlert.setValue(validation.1, forKey: "attributedMessage")
            responseAlert.addAction(okAction)
            self.presentAlertController(responseAlert)
        } else {
            let results = self.controller.form.dictResults
            guard let username = results["username"] as? String, let password = results["password"] as? String else {
                DispatchQueue.main.async {
                    let responseAlert = UIAlertController.init(title: "Error", message: "Something went wrong", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
                    }
                    responseAlert.addAction(okAction)
                    DispatchQueue.main.async {
                        self.presentAlertController(responseAlert)
                    }
                }
                return
            }
            UserHandler.shared.logIn(username: username, password: password) { (success, errorMessage) in
                if success {
                    self.perform(.goToMain)
                } else {
                    let responseAlert = UIAlertController.init(title: "Form Error", message: errorMessage ?? "Could not login with these details. Try again", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "Ok", style: .default) { (action) in
                    }
                    responseAlert.addAction(okAction)
                    DispatchQueue.main.async {
                        self.presentAlertController(responseAlert)
                    }
                }
            }
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        formContainerView.addSubview(viewController.view)
        NSLayoutConstraint.activate([
            viewController.view.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 0),
            viewController.view.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: 0),
            viewController.view.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 0),
            viewController.view.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 0)
        ])
        viewController.didMove(toParent: self)
    }
}
