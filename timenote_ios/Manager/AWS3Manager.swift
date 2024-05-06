//
//  AWS3Manager.swift
//  Timenote
//
//  Created by Aziz Essid on 09/11/2020.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import AWSS3
import UIKit
import Combine

struct TimenoteURL {
    let url     : URL?
    let index   : Int?
}

class AWS3Manager {
    
    static public   let shared          : AWS3Manager   = AWS3Manager()
    static private  let bucketName      : String        = "timenote-dev-images"
    public var completionHandler        : AWSS3TransferUtilityUploadCompletionHandlerBlock?
    private(set) var imageUploadPublisher               = CurrentValueSubject<URL?, Never>(nil)
    private(set) var imageTimenoteUploadPublisher       = CurrentValueSubject<TimenoteURL?, Never>(nil)
    public var isUploadingProfil        : Bool          = false

    public func uploadVideo(with image: UIImage, isProfil: Bool = false, index: Int? = nil, completion: ((String) -> Void)? = nil) {   //1
        let name = NSUUID().uuidString
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        let data = image.jpegData(compressionQuality: 0.75)
                do {
                    try data?.write(to: fileURL)
                }
                catch {
                    print(error)
                }
        let type = "image/png"
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask,progress: Progress) -> Void in
            print(progress.fractionCompleted)   //2
            if progress.isFinished {           //3
//                print("Upload Finished...")
                //do any task here.
                
            }
        }
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")   //4
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        self.completionHandler = { (task:AWSS3TransferUtilityUploadTask, error:Error?) -> Void in
            if error != nil {
                print("Failure uploading file to \(AWSS3.default().configuration.endpoint.url.appendingPathComponent(task.bucket).appendingPathComponent(task.key)) : \(error.debugDescription)")
            } else {
                let url = AWSS3.default().configuration.endpoint.url.appendingPathComponent(task.bucket).appendingPathComponent(task.key)
                print("Success uploading file to \(url)")
                if let _ = completion {
                    completion!(url.absoluteString)
                }
                DispatchQueue.main.async {
                    if isProfil {
                        self.isUploadingProfil = false
                        self.imageUploadPublisher.send(url.absoluteURL)
                    } else {
                        self.imageTimenoteUploadPublisher.send(TimenoteURL(url: url.absoluteURL, index: index))
                    }
                }
            }
        }
        let prefix = isProfil ? "profil" : "timenote"
        DispatchQueue.global().async {
            self.isUploadingProfil = isProfil
            AWSS3TransferUtility.default().uploadFile(fileURL, bucket: AWS3Manager.bucketName, key: "\(prefix)/\(UserManager.shared.userInformation?.id ?? "NoId")/\(name)", contentType: type, expression: expression, completionHandler: self.completionHandler).continueWith(block: { (task:AWSTask) -> AnyObject? in
                if(task.error != nil){
                    print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
                }
                if(task.result != nil){
                    print("Starting upload...")
                }
                return nil
            })
        }
    }
}
