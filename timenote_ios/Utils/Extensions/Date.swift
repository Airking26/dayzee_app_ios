//
//  Date.swift
//  helodoc
//
//  Created by Aziz Essid on 6/9/20.
//  Copyright © 2020 Aziz Essid. All rights reserved.
//

import Foundation

public let weekDayFr    = Locale.current.isFrench ? ["dim.", "lun.", "mar.", "mer.", "jeu.", "ven.", "sam."] : ["sun.", "mon.", "tue.", "wed.", "thu.", "fri.", "sat."]
public let monthFr      = Locale.current.isFrench ? ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet" , "Août", "Septembre", "Octobre", "Novembre", "Décembre"] : ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options, timeZone: TimeZone = TimeZone(secondsFromGMT: 0)!) {
        self.init()
        self.formatOptions = formatOptions
        self.timeZone = timeZone
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
}

extension String {
    var iso8601withFractionalSeconds: Date? { return Formatter.iso8601withFractionalSeconds.date(from: self) }
}

extension Date {

    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }

    func getYearInt() -> Int {
        return  Calendar.current.component(.year, from: self)
    }

    func getMonth() -> Int {
        return Calendar.current.component(.month, from: self)
    }

    func getDayInt() -> Int {
        return  Calendar.current.component(.day, from: self)
    }

    func isBetween(_ date1: Date, _ date2: Date) -> Bool {
        print(date1.compare(self).rawValue * self.compare(date2).rawValue)
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }

    private func formatDateElem(value : Int, string : String, isLast : Bool) -> String {
        guard value > 0 else { return "" }
        let lastString = string + (isLast ? " et " : "")
        return "\(value) \(lastString)"
    }

    func formattedDifference(_ date2 : Date) -> String {
        let dateFormatter: DateFormatter = DateFormatter()
        let difference = self.compare(date2).rawValue
        let dateDifference = Date(timeIntervalSinceReferenceDate: TimeInterval(difference))
        let year : Int = dateDifference.getYearInt()
        let yearString = self.formatDateElem(value: year, string: "ans", isLast: false);
        let month : Int = dateDifference.getMonth()
        let monthString = self.formatDateElem(value: month, string: "mois", isLast: false);
        dateFormatter.dateFormat = "dd"
        let day = Int(dateFormatter.string(from: dateDifference)) ?? 0
        let dayString = self.formatDateElem(value: day, string: "jours", isLast: false);
        dateFormatter.dateFormat = "HH"
        let hour = Int(dateFormatter.string(from: dateDifference)) ?? 0
        let hourString = self.formatDateElem(value: hour, string: "heures", isLast: false);
        dateFormatter.dateFormat = "mm"
        let minute = Int(dateFormatter.string(from: dateDifference)) ?? 0
        let minuteString = self.formatDateElem(value: minute, string: "minutes", isLast: false);
        dateFormatter.dateFormat = "ss"
        let seconde = Int(dateFormatter.string(from: dateDifference)) ?? 0
        let secondeString = self.formatDateElem(value: seconde, string: "seconde", isLast: true);
        return yearString + monthString + dayString + hourString + minuteString + secondeString;
    }

    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = ConfigUtil.dateFormat
        return formatter.string(from: self)
    }

    func toMonthYearString() -> String {
        let month = self.getMonthString()
        let year = self.getYear()
        return "\(month) \(year)"
    }

    func toDateDayString() -> String {
        let month = self.getMonthString()
        let year = self.getYear()
        let date = self.getDay()
        return "\(date) \(month) \(year)"
    }

    func toDateTimeString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = ConfigUtil.dateFormatTime
        return formatter.string(from: self)
    }

    func getString(withFormat format: String) -> String {

        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "fr-FR")

        return dateFormatter.string(from: self)

    }

    func getYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        return dateFormatter.string(from: self)
    }


    func getMonthString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let strMonth = dateFormatter.string(from: self).capitalizingFirstLetter()
        return strMonth
    }

    func getDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd"
        return dateFormatter.string(from: self)
    }

    func getHour() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }

    func getDetails() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy • HH:mm"
        let string = dateFormatter.string(from: self)
        return string
    }

    func getShortDare() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        let string = dateFormatter.string(from: self)
        return string
    }

    func toTimenoteString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = dateFormatter.string(from: self)
        return date
    }

    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }

    func getDayString() -> String {
        return weekDayFr[self.get(.weekday) - 1]
    }

    func getMonthNameString() -> String {
        return monthFr[self.get(.month) - 1]
    }

    func getDaysInMonth() -> Int {
        let dateComponents = DateComponents(year: self.getYearInt(), month: self.getMonth())
        let calendar = Calendar.current
        let date = calendar.date(from: dateComponents)!

        let range = calendar.range(of: .day, in: .month, for: date)!
        return range.count
    }

    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }

    var startOfYear: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: self)
        return  calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }

    func getCurrentLocalDate()-> Date {
        var now = self
        var nowComponents = DateComponents()
        let calendar = Calendar.current
        nowComponents.year = Calendar.current.component(.year, from: now)
        nowComponents.month = Calendar.current.component(.month, from: now)
        nowComponents.day = Calendar.current.component(.day, from: now)
        nowComponents.hour = Calendar.current.component(.hour, from: now)
        nowComponents.minute = Calendar.current.component(.minute, from: now)
        nowComponents.second = Calendar.current.component(.second, from: now)
        nowComponents.timeZone = TimeZone(abbreviation: "GMT")!
        now = calendar.date(from: nowComponents)!
        return now as Date
    }

    var less30minutes: Date {
        get {
            return Calendar.current.date(byAdding: .minute, value: -29, to: self)!
        }
    }

    func byAddingMinutes(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }

    func byLessMinutes(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: -minutes, to: self)!
    }

    func byAddingDays(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: self)!
    }

    func byAddingMonths(months: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: months, to: self)!
    }

    func byRemovingMonths(months: Int) -> Date {
        var month = self.get(.month) - months - 1
        if month < 0 {
            month += 12
        }
        return Calendar.current.date(byAdding: .month, value: month, to: self.startOfYear)!
    }

    func timeAgoDisplay() -> String {
        var preDateString = Locale.current.isFrench ? "Il y a " : ""
        var postDateString = Locale.current.isFrench ? "" : " ago"
        var secondsAgo = Int(Date().timeIntervalSince(self))
        if secondsAgo == 0 {
            return Locale.current.isFrench ? "Maintenant" : "Now"
        } else if secondsAgo < 0 {
            preDateString = Locale.current.isFrench ? "Dans " : "In "
            postDateString = ""
            secondsAgo = Int(self.timeIntervalSince(Date()))
        }
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let week = 7 * day
        let month = 4 * week
        let year = 12 * month
        var secondsString = Locale.current.isFrench ? "seconde" : "second"
        var minuteString = "minute"
        var hourString = Locale.current.isFrench ? "heure" : "hour"
        var dayString = Locale.current.isFrench ? "jour" : "day"
        var monthString = Locale.current.isFrench ? "mois" : "month"
        var yearStrinng = Locale.current.isFrench ? "ans" : "year"
        let andString = Locale.current.isFrench ? "et" : "and"
        if secondsAgo < minute {
            secondsString = secondsAgo > 1 ? "\(secondsString)s" : secondsString
            return "\(preDateString)\(secondsAgo) \(secondsString)"
        }
        else if secondsAgo < hour {
            secondsString = secondsAgo % minute > 1 ? "\(secondsString)s" : secondsString
            let seconde = secondsAgo % minute != 0 ? " \(andString) \(secondsAgo % minute) \(secondsString)" : ""
            minuteString = secondsAgo / minute > 1 ? "\(minuteString)s" : minuteString
            let minutes = secondsAgo / minute
            return "\(preDateString)\(minutes) \(minuteString)\(seconde)\(postDateString)"
        }
        else if secondsAgo < day {
            minuteString = ((secondsAgo % hour) / minute) > 1 ? "\(minuteString)s" : minuteString
            let minute = ((secondsAgo % hour) / minute) != 0 ? " \(andString) \((secondsAgo % hour) / minute) \(minuteString)" : ""
            hourString = (secondsAgo / hour) > 1 ? "\(hourString)s" : hourString
            return "\(preDateString)\(secondsAgo / hour) \(hourString)\(minute)\(postDateString)"
        }
        else if secondsAgo < month {
            hourString = ((secondsAgo % day) / hour) > 1 ? "\(hourString)s" : hourString
            let hour = ((secondsAgo % day) / hour) != 0 ? " \(andString) \((secondsAgo % day) / hour) \(hourString)" : ""
            dayString = (secondsAgo / day) > 1 ? "\(dayString)s" : dayString
            return "\(preDateString)\(secondsAgo / day) \(dayString)\(hour)\(postDateString)"
        }
        else if secondsAgo < year {
            dayString = ((secondsAgo % month) / day) > 1 ? "\(dayString)s" : dayString
            let day = ((secondsAgo % month) / day) != 0 ? " \(andString) \((secondsAgo % month) / day) \(dayString)" : ""
            monthString = Locale.current.isFrench == false ? (secondsAgo / month) > 1 ? "\(monthString)s" : monthString : monthString
            return "\(preDateString)\(secondsAgo / month) \(monthString)\(day)\(postDateString)"
        }
        monthString = Locale.current.isFrench == false ? ((secondsAgo % year) / month) > 1 ? "\(monthString)s" : monthString : monthString
        let monthFullString = ((secondsAgo % year) / month) != 0 ? " \(andString) \((secondsAgo % year) / month) \(monthString)" : ""
        yearStrinng = (secondsAgo / year) > 1 ? "\(yearStrinng)s" : yearStrinng
        return "\(preDateString)\(secondsAgo / year) \(yearStrinng)\(monthFullString)\(postDateString)"
    }
}
