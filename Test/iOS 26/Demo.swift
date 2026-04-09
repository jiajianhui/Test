//
//  Demo.swift
//  Test
//
//  Created by 贾建辉 on 2026/4/9.
//

import SwiftUI


// MARK: -  数据结构
struct Book: Identifiable, Hashable {
    let id: UUID = UUID()
    let cover: String
    let name: String
    let author: String
    let summary: String
    let star: Int
    let content: String
    let categary: String
    let color: Color
}

// 假数据
let books: [Book] = [
    Book(
        cover: "book.closed",
        name: "时间的秩序",
        author: "卡洛·罗韦利",
        summary: "用诗意的方式讲述时间并非我们直觉中的线性存在。",
        star: 5,
        content: "时间并不是均匀流逝的背景，而是由事件关系编织而成的网络……",
        categary: "科学",
        color: .blue
    ),
    Book(
        cover: "books.vertical",
        name: "人类简史",
        author: "尤瓦尔·赫拉利",
        summary: "从认知革命到科技革命，重构人类发展的宏大叙事。",
        star: 4,
        content: "七万年前，智人还只是非洲大陆上不起眼的一支物种……",
        categary: "历史",
        color: .green
    ),
    Book(
        cover: "text.book.closed",
        name: "百年孤独",
        author: "加西亚·马尔克斯",
        summary: "魔幻现实主义代表作，讲述布恩迪亚家族的兴衰。",
        star: 5,
        content: "多年以后，面对行刑队，奥雷里亚诺上校将会想起父亲带他去见识冰块的那个遥远的下午……",
        categary: "小说",
        color: .orange
    ),
    Book(
        cover: "book.pages",
        name: "刻意练习",
        author: "安德斯·艾利克森",
        summary: "揭示天赋背后真正起作用的是训练方法。",
        star: 4,
        content: "刻意练习并不是简单重复，而是带有明确目标和反馈机制的训练……",
        categary: "成长",
        color: .purple
    ),
    Book(
        cover: "book",
        name: "设计心理学",
        author: "唐纳德·诺曼",
        summary: "从认知角度解释为什么好设计让人舒服。",
        star: 5,
        content: "设计的本质，是让人不需要思考就能正确使用……",
        categary: "设计",
        color: .pink
    ),
    Book(
        cover: "rectangle.stack",
        name: "原则",
        author: "瑞·达利欧",
        summary: "通过原则化思维，提升决策质量与人生效率。",
        star: 4,
        content: "生活和工作中的很多问题，都可以用系统化原则去解决……",
        categary: "商业",
        color: .teal
    )
]


// MARK: - 主 View
struct Demo: View {
    
    enum MyTab {
        case home, list, setting
    }
    
    @State private var currentTab: MyTab = .home
    
    @State private var showSheet: Bool = false
    
    // 动画相关
    @Namespace private var namespace
    
    var body: some View {
        TabView(selection: $currentTab) {
            Tab("home", systemImage: "house", value: .home) {
                home
            }

            Tab("list", systemImage: "fleuron", value: .list) {
                list
            }
            
            // 使用自定义 icon
            Tab(value: .setting) {
                Text("1")
            } label: {
                VStack {
                    Image(systemName: "heart")
                    Text("3")
                }
            }
            
        }
        
        // 类似Apple Music的效果
//        .tabBarMinimizeBehavior(.onScrollDown)
        
//        .tabViewBottomAccessory {
//            Button {
//                
//            } label: {
//                HStack {
//                    Image(systemName: "plus")
//                    Text(verbatim: "Add")
//                }
//            }
//            
//
//        }
        
    }
}

#Preview {
    Demo()
}


// MARK: - 组件
extension Demo {
    
    var home: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing:20) {
                    ForEach(books) { book in
                        
                        // value 驱动跳转
                        NavigationLink(value: book) {
                            BookCover(book: book)
                                // 动画源头
                                .matchedTransitionSource(id: book.id, in: namespace)
                        }
                        .buttonStyle(.plain)  // 让字体颜色保持设定的颜色，而非蓝色
                    }
                }
                .padding()
                .scrollTargetLayout()
            }
            .scrollIndicators(.hidden)
//            .scrollTargetBehavior(.viewAligned)  // 自动对齐附近元素、.paging——一页一页翻（像banner轮播）
            
            .navigationTitle("我的书架")
            
            // 写在 NavigationStack 里面
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Image("color")
                        .resizable()
                        .scaledToFit()
                        
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

            }
            
            // 详情页
            .navigationDestination(for: Book.self) { book in
                BookDetail(book: book, namespace: namespace)
            }
        }
        .sheet(isPresented: $showSheet) {
            Color.green
                .ignoresSafeArea()
                .presentationDragIndicator(.visible)
        }
        
        
    }
    
    var list: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing:20) {
                    ForEach(0..<10) { _ in
                        
                        NavigationLink {
                            Text("1")
                        } label: {
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .fill(.green.opacity(0.2))
                                .frame(height: 220)
                        }

                        
                    }
                }
                .padding()
            }
            .scrollIndicators(.hidden)
            
            .navigationTitle("List")
            
        }
    }
}


// 卡片
struct BookCover: View {
    
    let book: Book
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(book.color.opacity(0.07))
                .strokeBorder(book.color.opacity(0.2), lineWidth: 1)
                .frame(height: 160)
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text(book.categary)
                        .font(.caption)
                        .foregroundStyle(book.color)
                        .padding(4)
                        .padding(.horizontal, 6)
                        .background {
                            Capsule()
                                .fill(book.color.opacity(0.15))
                        }
                               
                    Text(book.name)
                        .font(.title)
                        .fontWeight(.medium)
                        
                    Text(book.author)
                        .opacity(0.5)
                    
                                                 
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(systemName: book.cover)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 70)
                    .foregroundStyle(book.color)
                    .opacity(0.5)
            }
            .padding(.horizontal, 30)
        }
    }
}

// 详情
struct BookDetail: View {
    
    let book: Book
    let namespace: Namespace.ID
    
    @State private var showSheet: Bool = false
    
    
    // 这是一个“自定义 sheet 高度策略，iOS 系统会根据这个策略去计算你的 sheet 最终高度
    struct SmallSheetDetent: CustomPresentationDetent {
        static func height(in context: Context) -> CGFloat? {
            context.maxDetentValue * 0.8
        }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                
                // hero
                ZStack {
                    Rectangle()
                        .fill(book.color.opacity(0.1))
                    Image(systemName: book.cover)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100)
                        .foregroundStyle(book.color.opacity(0.3))
                    
                    VStack(alignment: .leading) {
                        
                        Text(book.categary)
                            .font(.caption)
                            .foregroundStyle(book.color)
                            .padding(4)
                            .padding(.horizontal, 6)
                            .background {
                                Capsule()
                                    .fill(book.color.opacity(0.15))
                            }
                                   
                        Text(book.name)
                            .font(.title)
                            .fontWeight(.medium)
                            
                        Text(book.author)
                            .opacity(0.5)
                        
                                                     
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(30)
                }
                .frame(height: 300)
                
                // 正文
                Text(book.content)
                    .padding(20)
                
                VStack(spacing: 20) {
                    ForEach(0..<6) { _ in
                        RoundedRectangle(cornerRadius: 30, style: .continuous)
                            .fill(book.color.opacity(0.1))
                            .frame(height: 120)
                    }
                }
                .padding(.horizontal)
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea()
        
        // toolbar 不是全局的，每个页面都有自己的一套 toolbar 状态
        // SwiftUI 的 toolbar 是 跟着页面走的，不是跟着 NavigationStack 走的。
        // 在 BookDetail 的 body 结尾处修改
        .toolbar {
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            
            ToolbarSpacer(.flexible, placement: .topBarTrailing)
            
            ToolbarItem(placement: .topBarTrailing) {
                
                
                Menu {
                    Button("编辑", systemImage: "pencil.line") {
                        
                    }
                    
                    Button("详情", systemImage: "info.circle") {
                        showSheet = true
                    }
                    
                    Divider()
                    
                    Button("删除", systemImage: "trash", role: .destructive) {
                    }
                } label: {
                    Image(systemName: "ellipsis")
                }

            }
            
            
        }
        .sheet(isPresented: $showSheet, content: {
            Text("1")
                .presentationDetents([.medium, .custom(SmallSheetDetent.self)])
                .presentationDragIndicator(.visible)
            
        })
        
        
        // 从 matchedTransitionSource 卡片位置，直接放大过来
        .navigationTransition(.zoom(sourceID: book.id, in: namespace))
    }
}

#Preview("详情页") {
    
    @Previewable @Namespace var namespace
    
    BookDetail(
        book: .init(
            cover: "book.closed",
            name: "时间的秩序",
            author: "卡洛·罗韦利",
            summary: "用诗意的方式讲述时间并非我们直觉中的线性存在。",
            star: 5,
            content: "时间并不是均匀流逝的背景，而是由事件关系编织而成的网络……",
            categary: "科学",
            color: .blue
        ),
        namespace: namespace
    )
}
