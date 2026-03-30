//
//  NavigationTransition.swift
//  Test
//
//  Created by 贾建辉 on 2026/3/30.
//

import SwiftUI

struct NavigationTransition: View {
    @Namespace private var namespace

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(sampleArticles) { article in
                        NavigationLink(value: article) {
                            CardView(article: article)
                        }
                        .buttonStyle(.plain)
                        // ✅ iOS 18: 标记为 zoom 动画的来源卡片
                        .matchedTransitionSource(id: article.id, in: namespace)
                    }
                }
                .padding(20)
            }
            
            .navigationTitle("学习笔记")
            .navigationDestination(for: Article.self) { article in
                DetailView(article: article, namespace: namespace)
            }
        }
    }
}


// MARK: - Model

struct Article: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: String
    let color: Color
    let emoji: String
}

let sampleArticles: [Article] = [
    Article(title: "SwiftUI 动画原理", subtitle: "理解 withAnimation 与隐式动画的区别，掌握弹性曲线调参技巧", category: "动画", color: Color(red: 0.36, green: 0.25, blue: 0.82), emoji: "✦"),
    Article(title: "Combine 数据流", subtitle: "用 Publisher、Subscriber 构建响应式架构，告别回调地狱", category: "架构", color: Color(red: 0.08, green: 0.56, blue: 0.44), emoji: "◈"),
    Article(title: "Swift Concurrency", subtitle: "async/await、Actor、TaskGroup 完整指南", category: "并发", color: Color(red: 0.82, green: 0.35, blue: 0.18), emoji: "⟁"),
    Article(title: "NavigationStack 路由", subtitle: "深度解析 NavigationPath 与类型安全路由", category: "导航", color: Color(red: 0.15, green: 0.42, blue: 0.78), emoji: "⬡"),
    Article(title: "Core Data + SwiftUI", subtitle: "@FetchRequest 与 SwiftUI 视图绑定最佳实践", category: "数据", color: Color(red: 0.68, green: 0.18, blue: 0.48), emoji: "◎"),
]


// MARK: - Card

struct CardView: View {
    let article: Article

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(article.color.opacity(0.12))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        // 内部描边
                        .strokeBorder(article.color.opacity(0.25), lineWidth: 1)
                )

            Text(article.emoji)
                .font(.system(size: 80))
                .opacity(0.08)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(16)

            VStack(alignment: .leading, spacing: 8) {
                Text(article.category)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(article.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(article.color.opacity(0.12), in: Capsule())

                Text(article.title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Text(article.subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(20)
        }
        .frame(height: 180)
    }
}

// MARK: - Detail

struct DetailView: View {
    let article: Article
    var namespace: Namespace.ID

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                // Hero 头部
                ZStack(alignment: .bottomLeading) {
                    Rectangle()
                        .fill(article.color.opacity(0.15))
                        .frame(height: 340)

                    Text(article.emoji)
                        .font(.system(size: 150))
                        .opacity(0.1)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(article.category)
                            .font(.system(size: 11, weight: .semibold))
                            .tracking(1.2)
                            .foregroundStyle(article.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(article.color.opacity(0.15), in: Capsule())

                        Text(article.title)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(article.subtitle)
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .padding(24)
                }

                // 正文
                VStack(alignment: .leading, spacing: 20) {
                    Divider().padding(.vertical, 8)

                    ForEach(0..<5) { i in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("章节 \(i + 1)")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                            Text("这里是《\(article.title)》的详细内容。实际项目中替换为真实数据。这段文字模拟正文段落的排版，展示详情页的完整布局效果。")
                                .font(.system(size: 15))
                                .foregroundStyle(.secondary)
                                .lineSpacing(6)
                        }
                        .padding(16)
                        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(24)
            }
        }
        .ignoresSafeArea(edges: .top)
        // ✅ iOS 18: 详情页使用 zoom 转场，sourceID 对应列表里的卡片
        .navigationTransition(.zoom(sourceID: article.id, in: namespace))
    }
}



#Preview {
    NavigationTransition()
}
