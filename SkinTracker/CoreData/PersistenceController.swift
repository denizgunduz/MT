//
//  PersistenceController.swift
//  SkinTracker
//
//  Created by Deniz Gunduz on 26.11.2021.
//

import CoreData
import UIKit

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentCloudKitContainer = {
        let container = NSPersistentCloudKitContainer(name: "AppModel")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                Typical reasons for an error here include:
                * The parent directory does not exist, cannot be created, or disallows writing.
                * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                * The device is out of space.
                * The store could not be migrated to the current model version.
                Check the error message to determine what the actual problem was.
                */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })

        return container
    }()
    
    func saveUser(_ userName: String, _ isSubUser: Bool = false) -> User {
        let user = User(context: self.container.viewContext)
        user.id = UUID.init()
        user.name = userName
        user.isSubUser = isSubUser
        self.save()
        return user
    }
    
    func fetchSettings() -> Settings? {
        let context = self.container.viewContext
        let request: NSFetchRequest<Settings> = Settings.fetchRequest()
        
        do {
            let settingsCoreData = try context.fetch(request)
            if let s = settingsCoreData.first {
                return s
            }
        } catch {
            print("Fetch failed: Error \(error.localizedDescription)")
        }

        return nil
    }
    
    func saveSettings(_ notificationPreiod: Int) -> Settings {
        var settings = fetchSettings()
        if settings != nil {
            settings?.notificationPeriod = Int16(notificationPreiod)
        }
        else {
            settings = Settings(context: self.container.viewContext)
            settings?.notificationPeriod = Int16(notificationPreiod)
        }
        
        self.save()
        
        return settings!
    }
    
    func fetchUsers() -> [User] {
        let context = self.container.viewContext
        let request: NSFetchRequest<User> = User.fetchRequest()
        var users: [User] = []
        do {
            let usersCoreData = try context.fetch(request)
            users = usersCoreData.map { $0 }
        } catch {
            print("Fetch failed: Error \(error.localizedDescription)")
            users = []
        }

        return users
    }
    
    func deleteUser(_ user: User) {
        let context = self.container.viewContext
        context.delete(user)
        self.save()
    }
    
    func updateUserLastSelection(_ user: User) {
        let context = self.container.viewContext
        
        let request: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let usersCoreData = try context.fetch(request)
            let users = usersCoreData.map { $0 }
            users.forEach { item in
                item.lastSelection = false
            }
            user.lastSelection = true
        } catch {
            print("Fetch failed: Error \(error.localizedDescription)")
        }
        
        self.save()
    }
    
    func fetchBodyPoints() -> [BodyPoint] {
        let context = self.container.viewContext
        let request: NSFetchRequest<BodyPoint> = BodyPoint.fetchRequest()
        var points: [BodyPoint] = []
        do {
            let pointsCoreData = try context.fetch(request)
            points = pointsCoreData.map { $0 }
        } catch {
            print("Fetch failed: Error \(error.localizedDescription)")
            points = []
        }

        return points
    }
    
    func saveBodyPoint(_ point: CGPoint, _ sideType: Int, _ previewImage: UIImage?) -> BodyPoint {
        let bPoint = BodyPoint.init(context: self.container.viewContext)
        bPoint.y = point.y
        bPoint.x = point.x
        bPoint.addDate = Date()
        bPoint.sideType = Int16(sideType)
        bPoint.preview = previewImage?.pngData()
        bPoint.user = SkinTrackerAppManager.shared.selectedUser
        bPoint.lastPhotoDate = Date()
        self.save()
        return bPoint
    }
    
    func saveBodyPhoto(_ bodyPoint: BodyPoint, _ image: UIImage?) -> BodyPhoto {
        let photo = BodyPhoto(context: self.container.viewContext)
        photo.id = UUID()
        photo.addDate = Date()
        photo.data = image?.pngData()
        photo.bodyPoint = bodyPoint
        self.save()
        return photo
    }
    
    func deleteBodyPoint(_ point: BodyPoint) {
        let context = self.container.viewContext
        context.delete(point)
        self.save()
    }
    
    func save() {
        let context = container.viewContext

        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Show some error here
                print(error)
            }
        }
    }
}
