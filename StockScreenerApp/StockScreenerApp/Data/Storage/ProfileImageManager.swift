//
//  ProfileImageManager.swift
//  StockScreenerApp
//
//  Created on 2/11/26.
//

import UIKit

class ProfileImageManager {
    static let shared = ProfileImageManager()
    
    private let fileManager = FileManager.default
    private let imageName = "profile_image.jpg"
    
    private var imageURL: URL {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent(imageName)
    }
    
    private init() {}
    
    // MARK: - Save Image
    
    func saveProfileImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return nil
        }
        
        do {
            try data.write(to: imageURL, options: [.atomic])
            return imageName
        } catch {
            return nil
        }
    }
    
    // MARK: - Load Image
    
    func loadProfileImage() -> UIImage? {
        guard fileManager.fileExists(atPath: imageURL.path) else {
            return nil
        }
        
        return UIImage(contentsOfFile: imageURL.path)
    }
    
    // MARK: - Delete Image
    
    func deleteProfileImage() {
        try? fileManager.removeItem(at: imageURL)
    }
    
    // MARK: - Check if Image Exists
    
    func hasProfileImage() -> Bool {
        return fileManager.fileExists(atPath: imageURL.path)
    }
}
