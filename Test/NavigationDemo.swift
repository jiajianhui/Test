//
//  NavigationDemo.swift
//  Test
//
//  Created by 贾建辉 on 2024/4/5.
//

import SwiftUI

struct NavigationDemo: View {
    
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            SheetView()
                .tabItem {
                    Image(systemName: "doc.text.image")
                    Text("Today")
                   
                }
            
            Text("2")
                .tabItem {
                    Image(systemName: "doc.text.image")
                    Text("Today")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    NavigationDemo()
}


struct SheetView: View {
    @State var showSheet: Bool = false
    
    var body: some View {
        NavigationView {
            Text("!")
            
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {showSheet = true}, label: {
                        Image(systemName: "plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22)
                            .cornerRadius(16)
                    })
                    
                    
                    
                }
            })
        }
        .sheet(isPresented: $showSheet, content: {
            Text("1")
        })
    }
}
