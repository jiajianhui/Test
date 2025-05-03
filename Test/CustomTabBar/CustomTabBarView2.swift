//
//  CustomTabBarView2.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/8.
//

import SwiftUI

struct CustomTabBarView2: View {
    
    @State var selectedID = 1
    
    var body: some View {
        TabView(selection: $selectedID) {
            Text("1")
                .tag(1)
            Text("2")
                .tag(2)
            Text("3")
                .tag(3)
            Text("4")
                .tag(4)
        }
        .overlay(alignment: .bottom) {
            CustomTabView(selectedID: $selectedID)
        }
        
        .ignoresSafeArea()
    }
}

#Preview {
    CustomTabBarView2()
}




//MARK: - 自定义TabBar
struct Icon: Identifiable {
    let id = UUID()
    let symbol: String
    let title: String
    let selectedID: SelectedID
    
}

enum SelectedID: Int {
    case one = 1, two = 2, three = 3, four = 4
}

let tabBarItems: [Icon] = [
    Icon(symbol: "house", title: "主页", selectedID: .one),
    Icon(symbol: "magnifyingglass", title: "搜索", selectedID: .two),
    Icon(symbol: "bell", title: "消息", selectedID: .three),
    Icon(symbol: "gear", title: "设置", selectedID: .four)
]


//自定义TabBar
struct CustomTabView: View {
    
    @Binding var selectedID: Int
    @Namespace private var animationNamespace
    
    private let mainColor: Color = .orange
    private let barHeight: CGFloat = 90
    
    
    var body: some View {
        ZStack {
            blurBG
            icons
        }
        .padding()
        
        
    }
}

//MARK: - 组件
extension CustomTabView {
    
    private var icons: some View {
        HStack(spacing: 0) {
            ForEach(tabBarItems) { item in
                VStack(spacing: 4) {
                    Image(systemName: item.symbol)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
//                        .symbolVariant(.fill)
//                        .imageScale(.large)
                        
                    
                    Text(item.title)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundStyle(selectedID == item.selectedID.rawValue ?  mainColor : .gray)
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .background {
                    Color.white.opacity(0.00001)  //增大触控区域
                }
                
                .overlay(alignment: .top) {
                    if selectedID == item.selectedID.rawValue {
                        Capsule()
                            .matchedGeometryEffect(id: "", in: animationNamespace)
                            .frame(width: 26, height: 3)
                            .foregroundStyle(mainColor)
                            .opacity(selectedID == item.selectedID.rawValue ? 1 : 0)
                    } else {
                        Capsule()
                            .frame(width: 26, height: 3)
                            .foregroundStyle(.clear)
                    }
                    
                }
                
                .onTapGesture {
                    withAnimation(.easeOut) {
                        UIImpactFeedbackGenerator(style: UIImpactFeedbackGenerator.FeedbackStyle.light).impactOccurred()
                        selectedID = item.selectedID.rawValue
                    }
                }
                
            }
        }
        .padding(.horizontal)
    }
    
    private var blurBG: some View {
        ZStack {
            HStack {
                ForEach(tabBarItems) { item in
                    VStack(spacing: 2) {
                    }
                    .opacity(0)
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeight)
                    .overlay(alignment: .top) {
                        Capsule()
                            .fill(mainColor.opacity(selectedID == item.selectedID.rawValue ? 0.6 : 0))
                            .frame(width: 26, height: 50)
                            
                    }
                }
            }
            .padding(.horizontal)
            
            //毛玻璃
            Capsule()
                .fill(.ultraThinMaterial)
                .frame(height: barHeight)
        }
    }
    
}
