//
//  LocalNotificationManager.swift
//  Todolist
//
//  Created by 이정환 on 2020/12/26.
//


import Foundation
import UserNotifications

struct JHNotification {
    var id: String
    var title: String
}

class LocalNotificationManager {
    var notifications = [JHNotification]()
    
    func requestPermission() -> Void {
        UNUserNotificationCenter
            .current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                granted, error in
                if granted == true && error == nil {
                    // We have permission!
                }
        }
    }
    
    func addNotification(title: String) -> Void {
        notifications.append(JHNotification(id: UUID().uuidString, title: title))
    }
    
    func deleteNotifications(){
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()    // to remove all delivered notifications
        center.removeAllPendingNotificationRequests()   // to remove all pending notifications
       // UIApplication.shared.applicationIconBadgeNumber = 0 // to clear the icon notification badge
    }
    
    func schedule() -> Void {
              UNUserNotificationCenter.current().getNotificationSettings { settings in
                  switch settings.authorizationStatus {
                  case .notDetermined:
                      self.requestPermission()
                  case .authorized, .provisional:
                      self.scheduleNotifications()
                  default:
                      break
                    
                }
            }
            
        }
        
        func scheduleNotifications() -> Void {
            for notification in notifications {
                let content = UNMutableNotificationContent()
                
                let todoListViewModel = TodoViewModel()
                let todayCount = todoListViewModel.todayTodos.count
                let todayTodosNotDone = todoListViewModel.todayTodosNotDone.count
                
                content.title = notification.title
                
                
                
                if todayCount == 0 {
                } else {
                    if todayTodosNotDone == 0 {
                       content.body = "오늘의 할일을 모두 완수하였습니다.\n" + "내일도 오늘처럼 모두 완수해주세요.🤗"
                    } else {
                       content.body = "오늘의 할일이 \(todayTodosNotDone)/\(todayCount)만큼 진행되었습니다.\n" + "나머지 오늘의 할일 \(todayTodosNotDone)개를 완수해주세요😅."
                    }
                }
              
                 content.sound = .default
                 content.badge = 0
                
                var dateComponents = DateComponents()
                
                dateComponents.calendar = Calendar.current
                
                let plist = UserDefaults.standard
                
                
                dateComponents.hour = plist.integer(forKey: "hourAlert")
                dateComponents.minute = plist.integer(forKey: "minuteAlert")
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request) { error in
                    guard error == nil else { return }
                    print("Scheduling notification with id: \(notification.id)")
                }
            }
        }
}
