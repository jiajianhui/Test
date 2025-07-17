//
//  FetchData.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/17.
//

import SwiftUI

// 两个结构的目的是让 JSON 数据能自动转成 Swift 的对象数组，便于在 UI 中展示，而不用手动解析 JSON 字符串。
// Response —— 整体响应结构，包含 results 数组
// Result —— 单个歌曲项的结构；变量名与 JSON 字段名一致

// Codable 让结构体支持 JSON 的自动编解码
struct Response: Codable {
    var results: [Result]
}

struct Result: Codable {
    var trackId: Int
    var trackName: String
    var collectionName: String
}

struct FetchData: View {
    
    @State private var results = [Result]()
    
    var body: some View {
        List(results, id: \.trackId) { result in
            VStack(alignment: .leading) {
                Text(result.trackName)
                    .font(.title2)
                    .fontWeight(.bold)
                Text(result.collectionName)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.plain)
        .task {
            await loadData()
        }
    }
    
    // 网络请求
    func loadData() async {
        
        // 构造URL；将字符串转换成 URL
        guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
            print("invalid url")
            return
        }
        
        do {
            // 发送请求
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // 用 JSONDecoder 将 JSON 数据解码为 Response 类型
            if let decodeResponse = try? JSONDecoder().decode(Response.self, from: data) {
                results = decodeResponse.results
            }
        } catch {
            print("invalid data")
        }
        
    }
}

#Preview {
    FetchData()
}
