//
//  CalendarView.swift
//
//  Created by ahmed hussien on 22/01/2024.
//

import SwiftUI

// MARK: - Top Calendar View
struct CalendarView: View {
    @EnvironmentObject var viewModel: ViewModel
    var body: some View {
        VStack{
            HStack(spacing: 70) {
                Button(action: {
                        self.viewModel.calendarModel.crntPage = Calendar.current.date(byAdding: .month, value: -1, to: self.viewModel.calendarModel.crntPage)!

                }) { Image("arrowLeft") }
                    .frame(width: 35, height: 35, alignment: .leading)
                
                Text(viewModel.calendarModel.titleOfMonth.toStringWithoutFormat(withFormat: "MMMM yyyy"))
                    .appFont(.headline)
                    .foregroundColor(.theme.primary)
                
                Button(action: {
                        self.viewModel.calendarModel.crntPage = Calendar.current.date(byAdding: .month, value: 1, to: self.viewModel.calendarModel.crntPage)!
                }) { Image("arrowRight") }
                    .frame(width: 35, height: 35, alignment: .trailing)
            }
            .padding()
            CustomCalendar(calendarModel:$viewModel.calendarModel)
                    .padding()
                    .frame(height: UIScreen.main.bounds.height*0.4)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

#Preview {
    CalendarView().environmentObject(ViewModel())
}
