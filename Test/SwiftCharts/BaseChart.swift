//
//  BaseChart.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/22.
//

import SwiftUI
import Charts

struct Pancakes: Identifiable {
    var id = UUID()
    var name: String
    var sales: Int
    
}

private let sales: [Pancakes] = [
    .init(name: "Cachapa", sales: 98),
    .init(name: "American", sales: 38),
    .init(name: "Injera", sales: 230),
    .init(name: "Dosa", sales: 174),
    .init(name: "Jian Bing", sales: 367)
]

struct BaseChart: View {
    var body: some View {
        VStack(alignment: .leading) {
            ChartTitle(title: "BaseChart")
            Chart(sales) { element in
                BarMark(
                    x: .value("Name", element.name),
                    y: .value("Sales", element.sales)
                )
            }
            Divider()
                .padding(.vertical, 30)
            ChartTitle(title: "BaseChart_X")
            Chart(sales) { element in
                BarMark(
                    x: .value("Sales", element.sales),
                    y: .value("Name", element.name)
                )
            }
            
        }
        .padding()
    }
}

struct ChartTitle: View {
    
    let title: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("hello")
                .font(.callout)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    BaseChart()
}
