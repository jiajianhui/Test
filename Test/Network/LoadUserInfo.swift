//
//  LoadUserInfo.swift
//  Test
//
//  Created by 贾建辉 on 2025/7/19.
//

import SwiftUI

struct LoadUserInfo: View {
    
    @State private var user: UserModel?
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: user?.avatar_url ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 200)
            
            Text(user?.login ?? "")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(user?.bio ?? "")
                .font(.title2)
                .foregroundStyle(Color.gray)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .task {
            // 不处理错误，try? —— 把错误“自动转换成 nil
            user = try? await getUser()
            
//            user = await getUser()
        }
    }
    
    
    // 获取数据函数（抛出错误）
    func getUser() async throws -> UserModel {
        let endPoint = "https://api.github.com/users/jiajianhui"
        
        guard let url = URL(string: endPoint) else { throw GHerror.invalidURL }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GHerror.invalidRES
        }
        
        do {
            return try JSONDecoder().decode(UserModel.self, from: data)
        } catch {
            throw GHerror.invalidDATA
        }
    }
    
    // 不处理错误
//    func getUser() async -> UserModel? {
//        
//        guard let url = URL(string: "https://api.github.com/users/jiajianhui") else {
//            return nil
//        }
//        
//        do {
//            let (data, _) = try await URLSession.shared.data(from: url)
//            
//            return try JSONDecoder().decode(UserModel.self, from: data)
//        } catch {
//            return nil
//        }
//    }
}

// user模型
struct UserModel: Codable {
    var login: String
    var avatar_url: String
    var bio: String
}

// 自定义错误
enum GHerror: Error {
    case invalidURL
    case invalidRES
    case invalidDATA
}
#Preview {
    LoadUserInfo()
}
