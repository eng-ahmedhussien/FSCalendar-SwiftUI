//
//  CustomCalendar.swift
//
//  Created by ahmed hussien on 23/01/2024.
//

import SwiftUI
import FSCalendar

struct CustomCalendar: UIViewRepresentable {
    
    typealias UIViewType = FSCalendar
    @Binding var calendarModel : CalendarModel
    var calendar = FSCalendar()
    
    func makeUIView(context: Context) -> FSCalendar {
        configureCalendar(context:context)
        context.coordinator.setDateToCalender(from: calendarModel.startDay, to: calendarModel.endDay) ///set
        context.coordinator.setRangesToCalender()///set rangs to calendar
      
        NotificationCenter.default.addObserver(
            forName: Notification.Name(rawValue:"updateCalendar"),
            object: nil,
            queue: .main) { _ in
                context.coordinator.deselectDates(calendar: calendar)
                context.coordinator.setRangesToCalender()
            }
        return calendar
    }
    
    private  func configureCalendar(context: Context) {
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.allowsMultipleSelection = true;
        calendar.placeholderType = calendarModel.isEnableEditing ? .none :  .fillHeadTail
        calendar.scope = .month
        calendar.firstWeekday = 1
        calendar.appearance.borderRadius = 20
        calendar.today = nil
        calendar.appearance.weekdayTextColor = .black
        calendar.clipsToBounds = true
        calendar.appearance.weekdayTextColor = .gray
        calendar.locale =    Locale(identifier: "en_US")
        calendar.calendarHeaderView.isHidden = true
        calendar.headerHeight = 0.0
    }
    
    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.setCurrentPage(calendarModel.crntPage, animated: true) /// --->> update calendar view when click on left or right button
    }
    
    func makeCoordinator() -> CustomCalendar.Coordinator {
        Coordinator(self)
    }
    
    private func showAppMessageError(){
        showAppMessage("start date and end date must not be more than 7 day".localized(), appearance: .toast(.error))
    }
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        
        var parent: CustomCalendar
        init(_ parent: CustomCalendar) {
            self.parent = parent
        }
        //MARK: - other
        private func handleDateSelection(calendar:FSCalendar, date: Date){
            ///nothing selected:
            guard let startDate = parent.calendarModel.startDay else {
                ///first selected:
                parent.calendarModel.startDay = date
                return
            }
            ///only first date is selected:
            guard let _ = parent.calendarModel.endDay else {
                ///handle the case of if the last date is less than the first date:
                if date.isLessThanOrEqualTo(startDate) {
                    calendar.deselect(startDate)
                    parent.calendarModel.startDay = date
                    return
                }
                
                let maximumAllowedRange: TimeInterval = 6 * 24 * 60 * 60  // 7 days in seconds
                if date.timeIntervalSince(startDate.toLocalTime()) <= maximumAllowedRange {
                    let range = retrunRangeFromStartEndDays(from: startDate, to: date)
                    parent.calendarModel.endDay = range.last
                    
                    for d in range {
                        calendar.select(d)
                    }
                    return
                } else {
                    print("error")
                    return
                }
            }
            ///diselect dates
            deselectDates(calendar: calendar)
        }
        
        func deselectDates(calendar:FSCalendar){
        ///both are selected:
        for d in calendar.selectedDates {
            calendar.deselect(d.toLocalTime())
        }
        
        parent.calendarModel.endDay = nil
        parent.calendarModel.startDay = nil
    }
        
        private func retrunRangeFromStartEndDays(from: Date, to: Date) -> [Date] {
            if from > to { return [] }
            
            var tempDate = from
            var array = [tempDate]
            
            while tempDate < to {
                tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate)!
                array.append(tempDate)
            }
            
            return array
        }
        ///set ranges
        func setRangesToCalender() {
            
            DispatchQueue.main.async { [self] in
               // parent.calendarModel.dateRanges = ranges
                parent.calendar.reloadData()
            }
            for range in parent.calendarModel.dateRanges {
                setDateToCalender(from: range.startDate?.toDateWithoutFormat(), to: range.endDate?.toDateWithoutFormat())
            }
            
        }
        ///select days range
        func setDateToCalender(from: Date? = nil, to: Date? = nil) {
            if let start = from, let end = to {
                let range = retrunRangeFromStartEndDays(from: start, to: end)
                for d in range {
                    parent.calendar.select(d)
                }
            }
        }
        
        //MARK: - FSCalendarDelegate
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            handleDateSelection(calendar:calendar, date: date.toLocalTime())
        }
        
        func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
            ///both are selected:
            if parent.calendarModel.startDay != nil || parent.calendarModel.endDay != nil {
                for d in calendar.selectedDates {
                    calendar.deselect(d)
                }
    
                parent.calendarModel.endDay = nil
                parent.calendarModel.startDay = nil
            }
        }
        
        func calendar(_ calendar: FSCalendar, shouldDeselect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            if parent.calendarModel.isEnableEditing{
                return true
            }else{
                return false
            }
        }
        
        func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
            guard let startDay = parent.calendarModel.startDay else {
                return parent.calendarModel.isEnableEditing
            }

            let maximumAllowedRange: TimeInterval = 6 * 24 * 60 * 60
            if date - startDay <= maximumAllowedRange {
                return true
            } else {
                parent.showAppMessageError()
                deselectDates(calendar: calendar)
                return false
            }
            
        }
        
        //MARK: - FSCalendarDataSource
        func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
            DispatchQueue.main.async { [self] in
                parent.calendarModel.crntPage = calendar.currentPage
                parent.calendarModel.titleOfMonth = calendar.currentPage
            }
        }
        
        //MARK: - FSCalendarAppearance
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
            parent.calendarModel.getColorFor(date: date)
        }
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
    
    func isLessThanOrEqualTo(_ date: Date) -> Bool {
        return self.compare(date) != .orderedDescending
    }
}
