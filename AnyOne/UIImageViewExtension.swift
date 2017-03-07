//
//  UIImageExtension.swift
//  AnyOne
//
//  Created by Samarth Paboowal on 11/12/16.
//  Copyright © 2016 Junkie Labs. All rights reserved.
//

import UIKit

let imageCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    func downloadImageAndCache(imageURL: NSString) {
        
        self.image = nil
        
        if let cachedImage = imageCache.object(forKey: imageURL) as? UIImage {
            
            self.image = cachedImage
            return
        }
        
        let urlString = URL(string: imageURL as String)
        let request = URLRequest(url: urlString!)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            
            if let downloadError = error as? NSError {
                print(downloadError.localizedDescription)
            }
            
            DispatchQueue.main.async {
                if let downloadedImage = UIImage(data: data!) {
                    
                    imageCache.setObject(downloadedImage, forKey: imageURL)
                    self.image = downloadedImage
                }
            }
            
        }).resume()
    }
}
