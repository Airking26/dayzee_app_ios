//
//  CalendarViewController.swift
//  Timenote
//
//  Created by Aziz Essid on 7/7/20.
//  Copyright © 2020 timenote. All rights reserved.
//

import Foundation
import UIKit
import Combine
import JTAppleCalendar

struct SelectedCalendarCell {
    let indexPath   : IndexPath
    let date        : Date
    var cell        : DateCollectionViewCell?
}

class CalendarViewController : UIViewController {

    /* IBOUTLET */

    @IBOutlet weak var calendarCollectionView: JTACMonthView! { didSet {
        self.calendarCollectionView.calendarDelegate = self
        self.calendarCollectionView.calendarDataSource = self
        self.calendarCollectionView.scrollingMode = .stopAtEachCalendarFrame
        self.calendarCollectionView.scrollDirection = .horizontal
        self.calendarCollectionView.showsHorizontalScrollIndicator = false
    }}
    @IBOutlet weak var timenoteTableView: UITableView! { didSet {
        self.timenoteTableView.delegate = self
    }}
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var datePicker: DatePickerTextField! { didSet {
        self.datePicker.isMonthYear = true
        self.datePicker.isTimeActivated = false
        self.datePicker.datePickerView.maximumDate = nil
        self.datePicker.datePickerDelegate = self
        self.datePicker.text = Date().toMonthYearString()
    }}
    @IBOutlet weak var calendaCollectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var monthLabels: [UILabel]!
    private var timenotes       : [TimenoteDataDto] = [] { didSet {
        self.calendarCollectionView.reloadDates(self.timenotes.map({$0.startingDate}).compactMap({$0}))
        if let date = self.calendarCollectionView.selectedDates.first {
            self.dayTimenotes = self.timenotes.filter({$0.startingDate?.getString(withFormat: "yyyy-MM-dd") == date.getString(withFormat: "yyyy-MM-dd")})
        }
    }}
    private var dayTimenotes    : [TimenoteDataDto] = [] { didSet {
        self.updateUI()
    }}
    private var dataSource      : ProfilDataSource!
    private var snapShot        : ProfilSnapShot!
    private var cancellableBag  = Set<AnyCancellable>()

    private var selectedTimenote    : TimenoteDataDto?  = nil

    /* VARIABLES */

    static let ListCellName             : String                = "TimenoteCalendarXibView"

    private var dateNow                 : Date                  = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())! { didSet {
        self.calendarCollectionView.reloadData()
        self.calendarCollectionView.deselectAllDates()
        self.calendarCollectionView.selectDates([self.dateNow])
        self.calendarCollectionView.scrollToDate(self.calendarCollectionView.selectedDates.first ?? self.dateNow)
    }}
    private var selectedCalendarCell    : SelectedCalendarCell? = nil

    private let minimumCalendarHeight   : CGFloat               = 40.0
    private let maximumCalendarHeight   : CGFloat               = 230.0
    private var isCollapsed : Bool  = false { didSet {
        guard self.isViewLoaded else { return }
        self.calendaCollectionViewHeightConstraint.constant = self.isCollapsed ? self.maximumCalendarHeight : self.minimumCalendarHeight
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
        let selectedDate = self.calendarCollectionView.selectedDates.first
        self.calendarCollectionView.reloadData()
        self.calendarCollectionView.scrollToDate(selectedDate ?? self.dateNow)
    }}

    public var userId   : String    = UserManager.shared.userInformation?.id ?? ""

    /* OVERRIDE */

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureDataSource()
        self.configureDate()
        self.datePicker.datePickerView.minimumDate = nil
        TimenoteManager.shared.timenotesCalendarPublisher.assign(to: \.self.timenotes, on: self).store(in: &self.cancellableBag)
        self.timenoteTableView.register(UINib(nibName: CalendarViewController.ListCellName, bundle: nil), forCellReuseIdentifier: CalendarViewController.ListCellName)

        commonInit()
        setLocalize()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let naviguationController = segue.destination as? UINavigationController, let timenoteDetailViewController = naviguationController.viewControllers.first as? TimenoteDetailViewController {
            timenoteDetailViewController.timenote = self.selectedTimenote
            self.selectedTimenote = nil
        }
    }

    private func configureDataSource() {
        self.dataSource = ProfilDataSource(tableView: self.timenoteTableView, cellProvider: { (tableView, indexPath, timenote) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: CalendarViewController.ListCellName) as? TimenoteCalendarXibView
            cell?.configure(timenote: timenote)
            return cell
        })
        self.dataSource.defaultRowAnimation = .fade
    }

    private func commonInit() {
        let letftswipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(previousIsTapped(_:)))
        letftswipe.direction = .right
        let righttswipe = UISwipeGestureRecognizer(target: self,
                                                   action: #selector(nextIsTapped(_:)))
        righttswipe.direction = .left

        calendarCollectionView.addGestureRecognizer(letftswipe)
        calendarCollectionView.addGestureRecognizer(righttswipe)
    }
    
    private func setLocalize() {
        monthLabels.forEach {
            $0.text = $0.text?.localized
        }
    }

    private func updateUI() {
        self.snapShot = ProfilSnapShot()
        self.snapShot.appendSections([.main])
        self.snapShot.appendItems(self.dayTimenotes)
        self.dataSource.apply(self.snapShot, animatingDifferences: true)
    }


    deinit {
        self.cancellableBag.forEach({$0.cancel()})
    }

    private func configureDate() {
        DispatchQueue.main.async {
            self.monthLabel.text = self.dateNow.getMonthNameString()
            self.datePicker.text = self.dateNow.toMonthYearString()
            TimenoteManager.shared.getDateTimenotes(userId: self.userId, date: self.dateNow)
            self.view.layoutIfNeeded()
        }
    }

    /* IBACTION */

    @objc func previousIsTapped(_ sender: UIGestureRecognizer) {
        self.selectedCalendarCell?.cell?.unselect()
        self.dateNow = self.dateNow.byAddingMonths(months: -1)
        self.configureDate()
    }

    @objc func nextIsTapped(_ sender: UIGestureRecognizer) {
        self.selectedCalendarCell?.cell?.unselect()
        self.dateNow = self.dateNow.byAddingMonths(months: 1)
        self.configureDate()
    }

    @IBAction func toggleCalendarView(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.isCollapsed = sender.isSelected
    }
}

extension CalendarViewController : DatePickerTextFieldDelegate {
    func didUpdateSelectedDate(_ date: Date, _ dateToString: String, textField: UITextField?) {
        self.calendarCollectionView.deselectAllDates()
        self.dateNow = date
        self.configureDate()
    }

}

extension CalendarViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedTimenote = self.dayTimenotes[indexPath.row]
        self.performSegue(withIdentifier: "goToTimenoteDetail", sender: self)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let timenote = self.dayTimenotes[indexPath.row]
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action, view, completion) in
            TimenoteManager.shared.deleteTimenote(timenoteId: timenote.id, completion: { success in })
            completion(true)
        })
        deleteAction.backgroundColor = .systemBackground
        deleteAction.image = UIImage(systemName: "trash")?.withTintColor(.red, renderingMode: .alwaysOriginal)

        let editAction = UIContextualAction(style: .normal, title: "", handler: { (action

                                                                                   , view, completion) in

        })
        editAction.backgroundColor = .systemBackground
        editAction.image = UIImage(systemName: "pencil")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        return UISwipeActionsConfiguration(actions: timenote.createdBy.id == UserManager.shared.userInformation?.id ? [deleteAction, editAction] : [editAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let timenote = self.dayTimenotes[indexPath.row]
        let duplicateAction = UIContextualAction(style: .normal, title: "", handler: { (action, view, completion) in
            TimenoteManager.shared.timenoteLastDuplicate.send(timenote)
            self.dismiss(animated: true, completion: nil)
            completion(true)
        })
        duplicateAction.backgroundColor = .systemBackground
        duplicateAction.image = UIImage(systemName: "doc.on.doc")?.withTintColor(.label, renderingMode: .alwaysOriginal)

        let remindAction = UIContextualAction(style: .normal, title: "", handler: { (action, view, completion) in
            if TimenoteManager.shared.hasAlarm(timenoteId: timenote.id) {
                TimenoteManager.shared.deleteAlarm(timenoteId: timenote.id)
                DispatchQueue.main.async {
                    action.image = UIImage(systemName: "bell")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                    completion(true)
                }
            } else {
                TimenoteManager.shared.createAlarm(timenodId: timenote.id, userId: timenote.createdBy.id, date: timenote.startingDate) { (success) in
                    guard success else { return }
                    DispatchQueue.main.async {
                        action.image = UIImage(systemName:"bell.fill")?.withTintColor(.label, renderingMode: .alwaysOriginal)
                        completion(true)
                    }
                }
            }
        })
        remindAction.backgroundColor = .systemBackground
        remindAction.image = UIImage(systemName: TimenoteManager.shared.hasAlarm(timenoteId: timenote.id) ? "bell.fill" : "bell")?.withTintColor(.label, renderingMode: .alwaysOriginal)
        guard let date = timenote.startingDate else { return UISwipeActionsConfiguration(actions: [duplicateAction]) }
        guard date > Date() else { return UISwipeActionsConfiguration(actions: [duplicateAction]) }
        return  UISwipeActionsConfiguration(actions: [duplicateAction, remindAction])
    }
}

extension CalendarViewController : JTACMonthViewDelegate, JTACMonthViewDataSource, UICollectionViewDelegateFlowLayout {

    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as? DateCollectionViewCell
        cell?.configure(date: date, isSelected: cellState.isSelected, isToggled: self.isCollapsed, belongsTo: cellState.dateBelongsTo, hasData: (self.timenotes.first(where: {$0.startingDate?.getString(withFormat: "yyyy-MM-dd") == date.getString(withFormat: "yyyy-MM-dd")}) != nil))
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableCell(withReuseIdentifier: "DateCollectionViewCell", for: indexPath) as! DateCollectionViewCell
        cell.configure(date: date, isSelected: cellState.isSelected, isToggled:  self.isCollapsed, belongsTo: cellState.dateBelongsTo, hasData: (self.timenotes.first(where: {$0.startingDate?.getString(withFormat: "yyyy-MM-dd") == date.getString(withFormat: "yyyy-MM-dd")}) != nil))
        return cell
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as? DateCollectionViewCell
        self.dayTimenotes = self.timenotes.filter({$0.startingDate?.getString(withFormat: "yyyy-MM-dd") == date.getString(withFormat: "yyyy-MM-dd")})
        cell?.select(isSelected: cellState.isSelected)
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as? DateCollectionViewCell
        cell?.select(isSelected: cellState.isSelected)
    }

    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        return ConfigurationParameters(startDate: dateNow.startOfMonth,
                                       endDate: dateNow.endOfMonth,
                                       numberOfRows: self.isCollapsed ? 6 : 1,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid,
                                       hasStrictBoundaries: false)
    }
    
}
