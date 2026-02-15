//
//  RegisterViewController.swift
//  Movie Recommender
//
//  Created by Georgios Smeros on 10/01/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var formContainerView: UIView!
    
    let controller = StoryboardIdentifier<FormBaseViewController>(UIStoryboard(name: "Main", bundle: nil), "FormBaseViewController").instantiate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let form: Form = Form.accountCreationForm
        controller.formType = .create
        add(asChildViewController: controller)
    }
    
    func presentAlertController(_ alert: UIViewController, animated: Bool = true) {
        DispatchQueue.main.async {
            self.present(alert, animated: animated, completion: nil)
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
            UserHandler.shared.createAccount(username: username, password: password) { (success, errorMessage) in
                if success {
                    let responseAlert = UIAlertController.init(title: "Success", message: "Account Created. You can now login.", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
                        DispatchQueue.main.async {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    responseAlert.addAction(okAction)
                    DispatchQueue.main.async {
                        self.presentAlertController(responseAlert)
                    }
                } else {
                    let responseAlert = UIAlertController.init(title: "Error", message: errorMessage ?? "Could not create account with these details. Try again", preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: "OK", style: .default) { (action) in
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

struct StoryboardIdentifier<T: UIViewController> {
    let storyboard: UIStoryboard
    let identifier: String?
    
    init(_ storyboard: UIStoryboard, _ identifier: String? = nil) {
        self.storyboard = storyboard
        self.identifier = identifier
    }
    
    /// Instantiates the view controller.
    /// If the expected controller is not present, this method will crash.
    ///
    /// - Returns: A newly instantiated view controller of the expected class.
    /// - Precondition: There must be a view controller of the expected class in the storyboard under that identifier.
    ///
    func instantiate() -> T {
        guard let identifier = self.identifier else {return storyboard.instantiateInitialViewController() as! T}
        
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    /// Gets an identifier that could return any UIViewController, where you don't care about the particular type.
    /// Swift can't (yet) refer to a subclass via its superclass, so you need a separate type of identifier.
    /// This lets you avoid generic constraints if you want to treat all identifiers the same way.
    ///
    var common: StoryboardIdentifier<UIViewController> {
        return StoryboardIdentifier<UIViewController>(storyboard, identifier)
    }
}

