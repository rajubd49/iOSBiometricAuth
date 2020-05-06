//
//  ViewController.swift
//  iOSBiometricAuth
//
//  Created by Raju on 3/5/20.
//  Copyright © 2020 Raju. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    var context = LAContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //To test this app usingg simulator, goto Simulator->Features->FaceID/TouchID-> Enrolled then try Matcing/Non matcing options
        prepareLAContext()
        evaluatePolicy()
    }
    
    private func prepareLAContext() {
        context.localizedReason = "App needs your authentication"
        context.localizedFallbackTitle = "Fallback"
        context.localizedCancelTitle = "Cancel"
        context.touchIDAuthenticationAllowableReuseDuration = LATouchIDAuthenticationMaximumAllowableReuseDuration //Or duration in seconds like 60
    }
    
    private func evaluatePolicy() {
        var evaluationError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &evaluationError) {
            
            switch context.biometryType {
            case .faceID:
                print("Face ID")
            case .touchID:
                print("Touch ID")
            case .none:
                print("Biometry Type None")
            @unknown default:
                print("Unknown Biometry Type")
            }
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Fallback title - override reason") { (success, error) in
                if let error = error {
                    let laError = LAError(_nsError: error as NSError)
                    switch laError.code {
                    case LAError.Code.userCancel:
                        print("User cancelled")
                    case LAError.Code.appCancel:
                        print("App Cancelled")
                    case LAError.Code.userFallback:
                        // We can add fallback logic here like using passcode or password authentication.
                        self.promptForCode()//This will never call unless we set context.localizedFallbackTitle
                        print("Fallback error")
                    case LAError.Code.authenticationFailed:
                        print("Authentication failed")
                    default:
                        print("Evaluation failed with unknown error")
                    }
                } else {
                    print("Successful")
                }
            }
            //We can cancel user authentication using code below for a delay of defined seconds
            //Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { (timer) in
            //    self.context.invalidate()
            //}
            
        } else {
            print(evaluationError?.localizedDescription ?? "Evaluation Error")
            if let error = evaluationError {
                let laError = LAError(_nsError: error as NSError)
                switch laError.code {
                case LAError.Code.biometryNotEnrolled:
                    print("Biometry Not Enrolled")
                    self.promptForBiometricEnrollment()
                default:
                    print("Evaluation failed with unknown error")
                }
            }
        }
        
    }
    
    private func promptForBiometricEnrollment() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Biometric Enrollment", message: "Would you like to enroll now?", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }))
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func promptForCode() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Biometric Enrollment", message: "Would you like to enroll now?", preferredStyle: .alert)
            alertController.addTextField { (textField) in
                textField.placeholder = "Enter your code"
                textField.isSecureTextEntry = true
            }
            alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertAction) in
                if let text = alertController.textFields?.first?.text {
                    print(text)
                    //Add your logic here to unlock app feature
                }
            }))
            self.present(alertController, animated: true, completion: nil)
        }
    }

}

