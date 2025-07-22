//
//  BaseChart.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/22.
//

import SwiftUI
import Charts


private let curpertinoData: [SalesSummary] = [
    .init(weekday: "Mon", sales: 123),
    .init(weekday: "Tue", sales: 241),
    .init(weekday: "Wed", sales: 232),
    .init(weekday: "Thu", sales: 124),
    .init(weekday: "Fri", sales: 232),
    .init(weekday: "Sat", sales: 189),
    .init(weekday: "Sun", sales: 436),
]
private let SFData: [SalesSummary] = [
    .init(weekday: "Mon", sales: 453),
    .init(weekday: "Tue", sales: 151),
    .init(weekday: "Wed", sales: 143),
    .init(weekday: "Thu", sales: 232),
    .init(weekday: "Fri", sales: 232),
    .init(weekday: "Sat", sales: 401),
    .init(weekday: "Sun", sales: 236),
]

// 高级枚举
enum City1: String, CaseIterable, Identifiable {
    case CP
    case SF

    var id: String { rawValue }  //符合Identifiable，方便遍历

    var displayName: String {
        switch self {
        case .CP: return "Cupertino"
        case .SF: return "San Francisco"
        }
    }

    var salesData: [SalesSummary] {
        switch self {
        case .CP: return curpertinoData
        case .SF: return SFData
        }
    }
}

enum City {
    case CP
    case SF
}

struct LocationsToggle: View {
    
    @State var city: City = .CP
    
    // ！！！ 切换Picker时，如果让图表切换有动画，必须让 SalesSummary 结构的id
    var data: [SalesSummary] {
        switch city {
        case .CP:
            return curpertinoData
        case .SF:
            return SFData
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            
            ChartTitle(title: "Location Sales")
            
            Picker("1", selection: $city.animation(.easeInOut)) {
                Text("Curpertino").tag(City.CP)
                Text("San Francisco").tag(City.SF)
            }
            .pickerStyle(.segmented)
            
            
            Chart(data) { element in
                BarMark(
                    x: .value("week", element.weekday),
                    y: .value("sales", element.sales)
                )
            }
            
        }
        .padding()
    }
}



#Preview {
    LocationsToggle()
}
