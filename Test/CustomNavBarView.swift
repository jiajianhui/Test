//
//  CustomNavBarView.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/7.
//

import SwiftUI

struct CustomNavBarView: View {
    
    @State var showNavBar: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                getScrollReader()
                ForEach(0..<5) { _ in
                    card
                }
            }
        }
        .coordinateSpace(.named("scroll"))
        
        .safeAreaPadding(.top, 20)  //将滚动视图向下挤30像素
        .background(Color.green)
        
        .overlay(alignment: .top) {
            header
        }
    }
}

#Preview {
    CustomNavBarView()
}


extension CustomNavBarView {
    var card: some View {
        RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(.ultraThickMaterial)
            .frame(height: 240)
            .frame(maxWidth: .infinity)
            .overlay {
                VStack(alignment: .leading) {
                    Circle()
                        .frame(width: 60)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(width: 100, height: 30)
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .frame(height: 30)
                        .frame(maxWidth: .infinity)
                }
                .opacity(0.2)
                .padding(30)
            }
            .padding(.horizontal)
    }
    
    var header: some View {
        ZStack {
            Color.black.opacity(0.0)
                .frame(height: getBarHeight())
                .background(.ultraThinMaterial)
                .opacity(showNavBar ? 1 : 0)
                .edgesIgnoringSafeArea(.top)
            
            HStack {
                Text("HomeView")
                    
                Spacer()
                Image(systemName: "person.circle")
            }
            .font(.system(size: showNavBar ? 24 : 30, weight: .bold))
            .padding(.horizontal)
            .offset(y: showNavBar ? getOffsetValue1() : getOffsetValue2())
        }
    }
    
    func getScrollReader() -> some View {
        GeometryReader(content: { geometry in
            Color.clear
                .frame(height: 100)
                .onChange(of: geometry.frame(in: .named("scroll")).minY) { _, newValue in
                    withAnimation(.default) {
                        if newValue < -12 {
                            showNavBar = true
                        } else {
                            showNavBar = false
                        }
                }
            }
        })
    }
    
    //根据不同的机型高度，调节相应组件的尺寸
    func getOffsetValue1() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
            case 844:
                return -30
            case 852:
                return -38
            default:
                return 0
        }
    }
    
    func getOffsetValue2() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
            case 844:
                return -24
            case 852:
                return -30
            default:
                return 0
        }
    }
    
    // 根据不同的机型（刘海屏、灵动岛）来设定不同的高度
    func getBarHeight() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        
        switch screenHeight {
            case 844:
                return 74
            case 852:
                return 86
            default:
                return 0
        }
    }
    
}
