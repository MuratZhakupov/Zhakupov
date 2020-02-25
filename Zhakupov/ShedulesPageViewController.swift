//
//  ShedulesPageViewController.swift
//  Zhakupov
//
//  Created by Murat Zhakupov on 2/25/20.
//  Copyright © 2020 Murat Zhakupov. All rights reserved.
//

import UIKit
import Alamofire

class ShedulesPageViewController: UIPageViewController, UIPageViewControllerDelegate {
    
    fileprivate var items: [UIViewController] = []
    var weekDays = [Int: String]()
    
    var shedulesList = [Shedule]() {
        didSet {
            if shedulesList.count > 0 {
                saveShedulesToDisk()
                self.prepareItems()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Start App")
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = UIColor.red
        appearance.currentPageIndicatorTintColor = UIColor.white
        appearance.backgroundColor = UIColor.darkGray
        dataSource = nil
        delegate = self
        if !Connectivity.isConnectedToInternet {
            print("Отсутствует подключение к Интернету!")
            loadShedulesFromDisk()
            //showAlert(message: "Отсутствует подключение к Интернету!")
            //SVProgressHUD.dismiss()
            //SVProgressHUD.showError(withStatus: "Отсутствует подключение к Интернету!")
        } else {
            loadShedule()
        }
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        // Do any additional setup after loading the view.
    }
    
    fileprivate func prepareItems() {
        dataSource = self
        items.removeAll()
        for i in 1...7 {
            let shedulesForWeekDay = shedulesList.filter({ $0.weekDay == i })
            print("\(shedulesForWeekDay[0].weekDay)")
            setWeekDayTitle(ind: shedulesForWeekDay[0].weekDay)
            let c = createPageItemControler(with: shedulesForWeekDay)
            items.append(c)
        }
        //SVProgressHUD.dismiss()
        print("Items list OK. items count = \(items.count)")
        if let firstViewController = items.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
            self.title = weekDays[1]
        }
    }
    
    fileprivate func createPageItemControler(with shedules: [Shedule]) -> UIViewController {
    
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SheduleTableViewController") as! SheduleTableViewController
        vc.shedules = shedules
        return vc
    }
    
    func setWeekDayTitle(ind: Int) {
        switch ind {
        case 1:
            weekDays[ind]  = "Понедельник"
        case 2:
            weekDays[ind] = "Вторник"
        case 3:
            weekDays[ind] = "Среда"
        case 4:
            weekDays[ind] = "Четверг"
        case 5:
            weekDays[ind] = "Пятница"
        case 6:
            weekDays[ind] = "Суббота"
        case 7:
            weekDays[ind] = "Воскресенье"
        default: break
        }
    }

    func loadShedule() {
        print("Начинаем загрузку расписания")
        let string = "https://sample.fitnesskit-admin.ru/schedule/get_group_lessons_v2/1/"
        
        guard let encoded = string.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed), let url = URL(string: encoded) else {
            print("URL Error.")
            return
        }
        Alamofire.request(url,
                          method: .get,
                          parameters: [:])
            .validate()
            .responseJSON { response in
                guard response.result.isSuccess else {
                    print("Error while load shedule: \(String(describing: response.result.error))")
                    return
                }
                
                guard let data = response.result.value as? [[String : Any]] else {
                    print("Error get data from response")
                    print(response.result.value)
                    return
                }
                print("Data OK. \(data)")
                var shedules = [Shedule]()
                for dict in data {
                    do {
                        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
                        let shedule: Shedule = try! JSONDecoder().decode(Shedule.self, from: jsonData)
                        shedules.append(shedule)
                    } catch {
                        print(error)
                    }
                }
                DispatchQueue.main.async {
                    print("Массив с  расписанием заполнен")
                    print("\(shedules[0])")
                    self.shedulesList = shedules
                }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        print("pageViewController didFinishAnimating")
        if let firstVC = viewControllers?.first as? SheduleTableViewController {
            let dayIndex = firstVC.shedules[0].weekDay
            self.title = weekDays[dayIndex]
            print("dayIndex = \(dayIndex)")
            print("\(weekDays[dayIndex])")
        }
    }
    
    func saveShedulesToDisk() {
        if !shedulesList.isEmpty {
            do {
                let savedShedules = ShedulesListForSave()
                savedShedules.list = shedulesList
                try? UserDefaults.standard.set(PropertyListEncoder().encode(savedShedules), forKey: "com.saved_shedules.usersession")
                UserDefaults.standard.synchronize()
                print("Data saved")
            } catch {
                print(error)
            }
        }
    }
    
    func loadShedulesFromDisk() {
            do {
                //let shedules = NSKeyedUnarchiver.unarchiveObject(with: savedData) as! [Shedule]
                let encoded = UserDefaults.standard.object(forKey: "com.saved_shedules.usersession") as! Data
                let shedules = try! PropertyListDecoder().decode(ShedulesListForSave.self, from: encoded)
                self.shedulesList = shedules.list
                 print("Shedules loaded from disk")
            } catch {
                print(error)
            }
    
    }
    
}

extension ShedulesPageViewController: UIPageViewControllerDataSource {
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return items.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
            //return items.last
        }
        
        guard items.count > previousIndex else {
            return nil
        }
        
        return items[previousIndex]
    }
    
    func pageViewController(_: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = items.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        guard items.count != nextIndex else {
            return nil
            //return items.first
        }
        
        guard items.count > nextIndex else {
            return nil
        }
        
        return items[nextIndex]
}
}
