//
//  PlaceHolderView.swift
//  Test
//
//  Created by 贾建辉 on 2024/7/19.
//

import SwiftUI

struct PlaceHolderView: View {
    var body: some View {
        
        VStack {
            Image("color")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 20, content: {
                Text("hello")
                    .font(.title)
                    .foregroundStyle(.blue)
                    .fontWeight(.bold)
                Text("Nature, with its vast array of wonders, captivates our senses and inspires our hearts. From the majestic mountains that touch the sky to the serene lakes that mirror the heavens, every element of nature tells a unique story. The rustling leaves in a dense forest, the blooming flowers in spring, and the vibrant hues of a sunset are all reminders of the beauty that surrounds us. This natural beauty is not just a visual delight but also a source of peace and tranquility. It is in the presence of nature that we often find solace and a deeper connection to the world around us.")
                  
                Button(action: {}, label: {
                    Text("返回")
                })
                .buttonStyle(.borderedProminent)
            })
            
        }
        .padding()
        
        .redacted(reason: .placeholder)
    }
}

#Preview {
    PlaceHolderView()
}
